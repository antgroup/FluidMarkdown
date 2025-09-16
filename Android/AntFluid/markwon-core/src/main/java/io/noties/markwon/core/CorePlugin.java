package io.noties.markwon.core;

import android.content.Context;
import android.text.Spannable;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ForegroundColorSpan;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import com.fluid.afm.styles.TitleStyle;
import com.fluid.afm.utils.MDLogger;

import org.commonmark.node.Block;
import org.commonmark.node.BlockQuote;
import org.commonmark.node.BulletList;
import org.commonmark.node.Code;
import org.commonmark.node.Emphasis;
import org.commonmark.node.FencedCodeBlock;
import org.commonmark.node.HardLineBreak;
import org.commonmark.node.Heading;
import org.commonmark.node.HtmlBlock;
import org.commonmark.node.HtmlInline;
import org.commonmark.node.Image;
import org.commonmark.node.IndentedCodeBlock;
import org.commonmark.node.Link;
import org.commonmark.node.ListBlock;
import org.commonmark.node.ListItem;
import org.commonmark.node.Node;
import org.commonmark.node.OrderedList;
import org.commonmark.node.Paragraph;
import org.commonmark.node.SoftLineBreak;
import org.commonmark.node.StrongEmphasis;
import org.commonmark.node.Text;
import org.commonmark.node.ThematicBreak;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.noties.markwon.AbstractMarkwonPlugin;
import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.MarkwonSpansFactory;
import io.noties.markwon.MarkwonVisitor;
import io.noties.markwon.RenderProps;
import io.noties.markwon.SpanFactory;
import io.noties.markwon.SpannableBuilder;
import io.noties.markwon.core.factory.BlockQuoteSpanFactory;
import io.noties.markwon.core.factory.CodeBlockSpanFactory;
import io.noties.markwon.core.factory.CodeSpanFactory;
import io.noties.markwon.core.factory.EmphasisSpanFactory;
import io.noties.markwon.core.factory.HeadingSpanFactory;
import io.noties.markwon.core.factory.LinkSpanFactory;
import io.noties.markwon.core.factory.ListItemSpanFactory;
import io.noties.markwon.core.factory.StrongEmphasisSpanFactory;
import io.noties.markwon.core.factory.ThematicBreakSpanFactory;
import io.noties.markwon.core.spans.BulletListItemSpan;
import io.noties.markwon.core.spans.CodeBlockSpan;
import com.fluid.afm.span.CodeLanguageSpan;
import com.fluid.afm.span.HeadingTopOrBottomSpacingSpan;
import com.fluid.afm.span.LinkWithIconSpan;
import io.noties.markwon.core.spans.OrderedListItemSpan;
import com.fluid.afm.span.ParagraphSpacingSpan;
import io.noties.markwon.core.spans.TextViewSpan;
import io.noties.markwon.image.ImageProps;
import com.fluid.afm.utils.Utils;

/**
 * @see CoreProps
 * @since 3.0.0
 */
public class CorePlugin extends AbstractMarkwonPlugin {

    /**
     * @see #addOnTextAddedListener(OnTextAddedListener)
     * @since 4.0.0
     */
    public interface OnTextAddedListener {

        /**
         * Will be called when new text is added to resulting {@link SpannableBuilder}.
         * Please note that only text represented by {@link Text} node will trigger this callback
         * (text inside code and code-blocks won\'t trigger it).
         * <p>
         * Please note that if you wish to add spans you must use {@code start} parameter
         * in order to place spans correctly ({@code start} represents the index at which {@code text}
         * was added). So, to set a span for the whole length of the text added one should use:
         * <p>
         * {@code
         * visitor.builder().setSpan(new MySpan(), start, start + text.length(), 0);
         * }
         *
         * @param visitor {@link MarkwonVisitor}
         * @param text    literal that had been added
         * @param start   index in {@code visitor} as which text had been added
         * @see #addOnTextAddedListener(OnTextAddedListener)
         */
        void onTextAdded(@NonNull MarkwonVisitor visitor, @NonNull String text, int start);
    }

    @NonNull
    public static CorePlugin create(Context context) {
        return new CorePlugin(context);
    }

    /**
     * @return a set with enabled by default block types
     * @since 4.4.0
     */
    @NonNull
    public static Set<Class<? extends Block>> enabledBlockTypes() {
        return new HashSet<>(Arrays.asList(
                BlockQuote.class,
                Heading.class,
                FencedCodeBlock.class,
                HtmlBlock.class,
                ThematicBreak.class,
                ListBlock.class,
                IndentedCodeBlock.class
        ));
    }

    // @since 4.0.0
    private final List<OnTextAddedListener> onTextAddedListeners = new ArrayList<>(0);

    // @since 4.5.0
    private boolean hasExplicitMovementMethod;
    private final Context context;

    protected CorePlugin(Context context) {
        this.context = context;
    }

    /**
     * @since 4.5.0
     */
    @SuppressWarnings("UnusedReturnValue")
    @NonNull
    public CorePlugin hasExplicitMovementMethod(boolean hasExplicitMovementMethod) {
        this.hasExplicitMovementMethod = hasExplicitMovementMethod;
        return this;
    }

    /**
     * Can be useful to post-process text added. For example for auto-linking capabilities.
     *
     * @see OnTextAddedListener
     * @since 4.0.0
     */
    @SuppressWarnings("UnusedReturnValue")
    @NonNull
    public CorePlugin addOnTextAddedListener(@NonNull OnTextAddedListener onTextAddedListener) {
        onTextAddedListeners.add(onTextAddedListener);
        return this;
    }

    @Override
    public void configureTheme(@NonNull MarkwonTheme.Builder builder) {

    }

    @Override
    public void configureVisitor(@NonNull MarkwonVisitor.Builder builder) {
        text(builder);
        strongEmphasis(builder);
        emphasis(builder);
        blockQuote(builder);
        code(builder);
        fencedCodeBlock(builder);
        indentedCodeBlock(builder);
        image(builder);
        bulletList(builder);
        orderedList(builder);
        listItem(builder);
        thematicBreak(builder);
        heading(builder);
        softLineBreak(builder);
        hardLineBreak(builder);
        paragraph(context, builder);
        link(builder);
    }

    @Override
    public void configureSpansFactory(@NonNull MarkwonSpansFactory.Builder builder) {

        // reuse this one for both code-blocks (indent & fenced)
        final CodeBlockSpanFactory codeBlockSpanFactory = new CodeBlockSpanFactory();

        builder
                .setFactory(StrongEmphasis.class, new StrongEmphasisSpanFactory())
                .setFactory(Emphasis.class, new EmphasisSpanFactory())
                .setFactory(BlockQuote.class, new BlockQuoteSpanFactory())
                .setFactory(Code.class, new CodeSpanFactory())
                .setFactory(FencedCodeBlock.class, codeBlockSpanFactory)
                .setFactory(IndentedCodeBlock.class, codeBlockSpanFactory)
                .setFactory(ListItem.class, new ListItemSpanFactory())
                .setFactory(Heading.class, new HeadingSpanFactory())
                .setFactory(Link.class, new LinkSpanFactory())
                .setFactory(ThematicBreak.class, new ThematicBreakSpanFactory());
    }

    @Override
    public void beforeSetText(@NonNull TextView textView, @NonNull Spanned markdown) {
        OrderedListItemSpan.measure(textView, markdown);

        // @since 4.4.0
        // we do not break API compatibility, instead we introduce the `instance of` check
        if (markdown instanceof Spannable) {
            final Spannable spannable = (Spannable) markdown;
            TextViewSpan.applyTo(spannable, textView);
        }
    }

    @Override
    public void afterSetText(@NonNull TextView textView) {
        // let's ensure that there is a movement method applied
        // we do it `afterSetText` so any user-defined movement method won't be
        // replaced (it should be done in `beforeSetText` or manually on a TextView)
        // @since 4.5.0 we additionally check if we should apply _implicit_ movement method
        if (!hasExplicitMovementMethod && textView.getMovementMethod() == null) {
            textView.setMovementMethod(LinkMovementMethod.getInstance());
        }
    }

    private void text(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(Text.class, new MarkwonVisitor.NodeVisitor<Text>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull Text text) {

                final String literal = text.getLiteral();

                visitor.builder().append(literal);

                // @since 4.0.0
                if (!onTextAddedListeners.isEmpty()) {
                    // calculate the start position
                    final int length = visitor.length() - literal.length();
                    for (OnTextAddedListener onTextAddedListener : onTextAddedListeners) {
                        onTextAddedListener.onTextAdded(visitor, literal, length);
                    }
                }
            }
        });
    }

    private static void strongEmphasis(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(StrongEmphasis.class, new MarkwonVisitor.NodeVisitor<StrongEmphasis>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull StrongEmphasis strongEmphasis) {
                final int length = visitor.length();
                visitor.visitChildren(strongEmphasis);
                visitor.setSpansForNodeOptional(strongEmphasis, length);
            }
        });
    }

    private static void emphasis(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(Emphasis.class, new MarkwonVisitor.NodeVisitor<Emphasis>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull Emphasis emphasis) {
                final int length = visitor.length();
                visitor.visitChildren(emphasis);
                visitor.setSpansForNodeOptional(emphasis, length);
            }
        });
    }

    private static void blockQuote(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(BlockQuote.class, new MarkwonVisitor.NodeVisitor<BlockQuote>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull BlockQuote blockQuote) {

                visitor.blockStart(blockQuote);

                final int length = visitor.length();

                visitor.visitChildren(blockQuote);
                visitor.setSpansForNodeOptional(blockQuote, length);

                visitor.blockEnd(blockQuote);
                int space = visitor.configuration().theme().blockQuoteStyle().paragraphSpacing() + visitor.configuration().theme().blockQuoteStyle().bottomMargin() - visitor.configuration().theme().getParagraphBreakHeight();
                int start = visitor.length();
                visitor.builder().append('\n').append('\u00a0');
                if (space > 0) {
                    visitor.setSpans(start, ParagraphSpacingSpan.create(space));
                } else {
                    visitor.setSpans(start, ParagraphSpacingSpan.create(Utils.dpToPx(8f)));
                }
            }
        });
    }

    private static void code(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(Code.class, new MarkwonVisitor.NodeVisitor<Code>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull Code code) {
                final int length = visitor.length();
                // NB, in order to provide a _padding_ feeling code is wrapped inside two unbreakable spaces
                // unfortunately we cannot use this for multiline code as we cannot control where a new line break will be inserted
                SpannableBuilder builder = visitor.builder();
                builder.append(code.getLiteral());
                visitor.setSpansForNodeOptional(code, length);
             }
        });
    }

    private static void fencedCodeBlock(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(FencedCodeBlock.class, new MarkwonVisitor.NodeVisitor<FencedCodeBlock>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull FencedCodeBlock fencedCodeBlock) {
                final int length = visitor.length();

                visitCodeBlock(visitor, fencedCodeBlock.getInfo(), fencedCodeBlock.getLiteral(), fencedCodeBlock);

                handleCodeBlockLeftMargin(length, visitor);
                int start = visitor.length();
                visitor.builder()
                        .append('\n')
                        .append('\u00a0');
                visitor.setSpans(start + 1, ParagraphSpacingSpan.create(visitor.configuration().theme().getParagraphBreakHeight()));
            }
        });
    }

    private static void handleCodeBlockLeftMargin(int length, MarkwonVisitor visitor) {
        if (bulletListItemSpan != null || orderedListItemSpan != null) {
            List<SpannableBuilder.Span> itemSpans = visitor.builder().getSpans(length + 1, length + 2);
            if (itemSpans == null) {
                return;
            }

            for (SpannableBuilder.Span itemSpan : itemSpans) {
                Object object = itemSpan.what;
                if (object instanceof CodeBlockSpan) {
                    MDLogger.d("MYA_CorePlugin", "handleCodeBlockLeftMargin bulletListItemSpan="
                            + bulletListItemSpan + ", orderedListItemSpan=" + orderedListItemSpan);
                    ((CodeBlockSpan) object).setListItemSpan(bulletListItemSpan, orderedListItemSpan);
                }
            }

            clear();
        } else {
            codeBlockStartIndex = length;
        }
    }

    private static void indentedCodeBlock(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(IndentedCodeBlock.class, new MarkwonVisitor.NodeVisitor<IndentedCodeBlock>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull IndentedCodeBlock indentedCodeBlock) {
                visitCodeBlock(visitor, null, indentedCodeBlock.getLiteral(), indentedCodeBlock);
            }
        });
    }

    // @since 4.0.0
    // his method is moved from ImagesPlugin. Alternative implementations must set SpanFactory
    // for Image node in order for this visitor to function
    private static void image(MarkwonVisitor.Builder builder) {
        builder.on(Image.class, new MarkwonVisitor.NodeVisitor<Image>() {
            @Override
            public void visit(@NonNull MarkwonVisitor visitor, @NonNull Image image) {

                // if there is no image spanFactory, ignore
                final SpanFactory spanFactory = visitor.configuration().spansFactory().get(Image.class);
                if (spanFactory == null) {
                    visitor.visitChildren(image);
                    return;
                }

                final int length = visitor.length();

                visitor.visitChildren(image);

                // we must check if anything _was_ added, as we need at least one char to render
                if (length == visitor.length()) {
                    visitor.builder().append('\uFFFC');
                }

                final MarkwonConfiguration configuration = visitor.configuration();

                final Node parent = image.getParent();
                final boolean link = parent instanceof Link;

                final String destination = configuration
                        .imageDestinationProcessor()
                        .process(image.getDestination());

                final RenderProps props = visitor.renderProps();

                // apply image properties
                // Please note that we explicitly set IMAGE_SIZE to null as we do not clear
                // properties after we applied span (we could though)
                ImageProps.DESTINATION.set(props, destination);
                ImageProps.REPLACEMENT_TEXT_IS_LINK.set(props, link);
                ImageProps.IMAGE_SIZE.set(props, null);

                visitor.setSpans(length, spanFactory.getSpans(configuration, props));
            }
        });
    }
    private static BulletListItemSpan bulletListItemSpan;
    private static OrderedListItemSpan orderedListItemSpan;
    private static Integer codeBlockStartIndex = null;

    private static void clear() {
        bulletListItemSpan = null;
        orderedListItemSpan = null;
    }

    @VisibleForTesting
    static void visitCodeBlock(
            @NonNull MarkwonVisitor visitor,
            @Nullable String info,
            @NonNull String code,
            @NonNull Node node) {

        visitor.blockStart(node);

        final int length = visitor.length();

        StringBuilder language = new StringBuilder();
        visitor.builder()
                .append('\u00a0').append('\n')
                .append(visitor.configuration().syntaxHighlight().highlight(info, code, language));

        visitor.ensureNewLine();

        visitor.builder().append('\u00a0');

        // @since 4.1.1
        CoreProps.CODE_BLOCK_INFO.set(visitor.renderProps(), info);

        visitor.setSpansForNodeOptional(node, length);

        // store language
        visitor.setSpans(length + 2, new CodeLanguageSpan(language.toString()));
        visitor.blockEnd(node);
    }

    private static void bulletList(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(BulletList.class, new SimpleBlockNodeVisitor());
    }

    private static void orderedList(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(OrderedList.class, new SimpleBlockNodeVisitor());
    }

    private static void listItem(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(ListItem.class, (visitor, listItem) -> {

            final int length = visitor.length();

            codeBlockStartIndex = null;
            // it's important to visit children before applying render props (
            // we can have nested children, who are list items also, thus they will
            // override out props (if we set them before visiting children)
            visitor.visitChildren(listItem);

            final Node parent = listItem.getParent();
            if (parent instanceof OrderedList) {
                final int start = ((OrderedList) parent).getStartNumber();

                CoreProps.LIST_ITEM_TYPE.set(visitor.renderProps(), CoreProps.ListItemType.ORDERED);
                CoreProps.ORDERED_LIST_ITEM_NUMBER.set(visitor.renderProps(), start);
                CoreProps.BULLET_LIST_ITEM_LEVEL.set(visitor.renderProps(), listLevel(listItem));

                // after we have visited the children increment start number
                final OrderedList orderedList = (OrderedList) parent;
                orderedList.setStartNumber(orderedList.getStartNumber() + 1);

            } else {
                CoreProps.LIST_ITEM_TYPE.set(visitor.renderProps(), CoreProps.ListItemType.BULLET);
                CoreProps.BULLET_LIST_ITEM_LEVEL.set(visitor.renderProps(), listLevel(listItem));
            }

            visitor.setSpansForNodeOptional(listItem, length);

            getListItemSpanAndResetCodeBlockLeftMargin(length, visitor);
            if (visitor.hasNext(listItem)) {
                visitor.ensureNewLine();
            }
        });
    }
    private static void getListItemSpanAndResetCodeBlockLeftMargin(int length, MarkwonVisitor visitor) {
        clear();

        List<SpannableBuilder.Span> itemSpans = visitor.builder().getSpans(length, length + 1);

        for (SpannableBuilder.Span itemSpan : itemSpans) {
            Object object = itemSpan.what;
            if (object instanceof BulletListItemSpan) {
                bulletListItemSpan = (BulletListItemSpan) object;
            } else if (object instanceof OrderedListItemSpan) {
                orderedListItemSpan = (OrderedListItemSpan) object;
            }
        }
        if (codeBlockStartIndex != null) {
            handleCodeBlockLeftMargin(codeBlockStartIndex, visitor);
            codeBlockStartIndex = null;
        }
        clear();
    }

    private static int listLevel(@NonNull Node node) {
        int level = 0;
        Node parent = node.getParent();
        while (parent != null) {
            if (parent instanceof ListItem) {
                level += 1;
            }
            parent = parent.getParent();
        }
        if (level < 0) {
            level = 0;
        }
        return level;
    }

    private static void thematicBreak(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(ThematicBreak.class, (visitor, thematicBreak) -> {
            visitor.blockStart(thematicBreak);

            final int length = visitor.length();

            // without space it won't render
            visitor.builder().append('\u00a0');

            visitor.setSpansForNodeOptional(thematicBreak, length);

            visitor.blockEnd(thematicBreak);
        });
    }

    private static void heading(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(Heading.class, (visitor, heading) -> {
            TitleStyle titleStyle = visitor.configuration().theme().getTitleStyle(heading.getLevel());
            if (heading.getPrevious() != null
                    && !(heading.getPrevious() instanceof Heading)
                    && !(heading.getPrevious() instanceof ThematicBreak)
                    && titleStyle != null && titleStyle.paragraphSpacingBefore() > 0) {
                int paragraphBreakHeight = titleStyle.paragraphSpacingBefore();
                final int start = visitor.length();
                visitor.builder().append("\n\u00a0");
                visitor.setSpans(start + 1, new HeadingTopOrBottomSpacingSpan(paragraphBreakHeight));
            }

            visitor.blockStart(heading);

            final int length = visitor.length();
            visitor.visitChildren(heading);

            CoreProps.HEADING_LEVEL.set(visitor.renderProps(), heading.getLevel());

            visitor.setSpansForNodeOptional(heading, length);
            if (titleStyle != null && titleStyle.paragraph().paragraphSpacing() > 0) {
                int paragraphBreakHeight = titleStyle.paragraph().paragraphSpacing();
                final int start = visitor.length();
                visitor.builder().append("\n\u00a0");
                visitor.setSpans(start + 1, new HeadingTopOrBottomSpacingSpan(paragraphBreakHeight));
            } else if (titleStyle == null) {
                final int start = visitor.length();
                visitor.builder().append("\n\u00a0");
                visitor.setSpans(start + 1, new HeadingTopOrBottomSpacingSpan(visitor.configuration().theme().getParagraphBreakHeight() + Utils.dpToPx(2)));
            }
            visitor.blockEnd(heading);
        });
    }

    private static void softLineBreak(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(SoftLineBreak.class, (visitor, softLineBreak) -> visitor.builder().append(' '));
    }

    private static void hardLineBreak(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(HardLineBreak.class, (visitor, hardLineBreak) -> visitor.ensureNewLine());
    }

    private static void paragraph(Context context, @NonNull MarkwonVisitor.Builder builder) {
        builder.on(Paragraph.class, (visitor, paragraph) -> {
            if (paragraph.getParent() instanceof BlockQuote) {
                visitor.ensureNewLine();
                final int start = visitor.length();
                visitor.builder().append('\u00a0').append('\n');
                visitor.setSpans(start, ParagraphSpacingSpan.create(Utils.dpToPx(3)));
            }
            int paragraphStart = visitor.length();
            final boolean inTightList = isInTightList(paragraph);

            if (!inTightList) {
                visitor.blockStart(paragraph);
            }

            final int length = visitor.length();
            visitor.visitChildren(paragraph);

            CoreProps.PARAGRAPH_IS_IN_TIGHT_LIST.set(visitor.renderProps(), inTightList);

            // @since 1.1.1 apply paragraph span
            visitor.setSpansForNodeOptional(paragraph, length);

            int paragraphBreakHeight = ensureParagraphBreakHeight(context, visitor, paragraph);
            boolean addParagraphBreak;
            if (paragraphBreakHeight <= 0 || paragraph.getParent() == null) {
                addParagraphBreak = false;
            } else {
                addParagraphBreak = paragraph.getParent().getParent() != null || paragraph.getParent().getLastChild() != paragraph;
            }

            if (addParagraphBreak) {
                visitor.ensureNewLine();
                final int start = visitor.length();
                visitor.builder().append('\u00a0');
                visitor.setSpans(start, ParagraphSpacingSpan.create(paragraphBreakHeight));
            }
            if (!inTightList) {
                visitor.blockEnd(paragraph);
            }
            if (paragraph.getParent() instanceof BlockQuote && visitor.configuration().theme().blockQuoteStyle().fontColor() != 0) {
                visitor.setSpans(paragraphStart, new ForegroundColorSpan(visitor.configuration().theme().blockQuoteStyle().fontColor()));
            }
        });
    }

    private static int ensureParagraphBreakHeight(Context context, @NonNull MarkwonVisitor visitor, @NonNull Paragraph paragraph) {
        int height = visitor.configuration().theme().getParagraphBreakHeight();
        try {
            Node next = paragraph.getNext();
            if (next != null && next.getFirstChild() instanceof HtmlInline) {
                HtmlInline htmlInline = (HtmlInline) next.getFirstChild();
                Pattern pattern = Pattern.compile("para-space-before\\s*:\\s*(\\d+)rpx");
                Matcher matcher = pattern.matcher(htmlInline.getLiteral());
                if (matcher.find()) {
                    String mg = matcher.group(1);
                    if (!TextUtils.isEmpty(mg) && TextUtils.isDigitsOnly(mg)) {
                        height = (int) Utils.rpxToPx(Float.parseFloat(mg), context);
                    }
                }
            }
        } catch (Exception e) {
            MDLogger.e("Paragraph", "Parse custom space error: " + e.getMessage());
        }
        return height;
    }

    private static boolean isInTightList(@NonNull Paragraph paragraph) {
        final Node parent = paragraph.getParent();
        if (parent != null) {
            final Node gramps = parent.getParent();
            if (gramps instanceof ListBlock) {
                ListBlock list = (ListBlock) gramps;
                return list.isTight();
            }
        }
        return false;
    }

    private static void link(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(Link.class, (visitor, link) -> {
            final int length = visitor.length();
            visitor.visitChildren(link);
            if (Utils.isInTableNode(link)) {
                return;
            }
            final String destination = link.getDestination();
            CoreProps.LINK_DESTINATION.set(visitor.renderProps(), destination);
            CoreProps.LINK_TEXT_DESCRIPTION.set(visitor.renderProps(), link.getTitle());
            visitor.setSpansForNodeOptional(link, length);
            int lengthAfter = visitor.length();
            if (length < lengthAfter && !TextUtils.isEmpty(visitor.configuration().theme().linkStyle().icon())) {
                SpannableBuilder.setSpans(visitor.builder(), new LinkWithIconSpan(visitor.configuration().theme()), lengthAfter - 1, lengthAfter);
            }
        });
    }
}
