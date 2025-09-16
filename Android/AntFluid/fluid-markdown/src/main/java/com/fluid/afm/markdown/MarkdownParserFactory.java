package com.fluid.afm.markdown;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.content.res.AppCompatResources;

import com.fluid.afm.MarkdownAwareMovementMethod;
import com.fluid.afm.R;
import com.fluid.afm.func.IImageClickCallback;
import com.fluid.afm.markdown.code.CodeBlockPlugin;
import com.fluid.afm.markdown.html.CustomHtmlPlugin;
import com.fluid.afm.markdown.html.HtmlMarkTagHandler;
import com.fluid.afm.markdown.html.HtmlParaTagHandler;
import com.fluid.afm.markdown.html.HtmlSpanTagHandler;
import com.fluid.afm.markdown.icon.IconSpanHandler;
import com.fluid.afm.markdown.iconlink.IconLinkSpanHandler;
import com.fluid.afm.markdown.list.DefinitionListPlugin;
import com.fluid.afm.markdown.span.LinkClickSpan;
import com.fluid.afm.markdown.text.AfmTextPlugin;
import com.fluid.afm.markdown.widget.PrinterMarkDownTextView;
import com.fluid.afm.network.ImageLoaderSchemeHandler;
import com.fluid.afm.styles.MarkdownStyles;
import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.Utils;

import org.commonmark.node.Link;

import java.util.ArrayList;

import io.noties.markwon.AbstractMarkwonPlugin;
import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.MarkwonSpansFactory;
import io.noties.markwon.RenderProps;
import io.noties.markwon.SpanFactory;
import io.noties.markwon.core.CorePlugin;
import io.noties.markwon.core.CoreProps;
import io.noties.markwon.ext.latex.JLatexMathPlugin;
import io.noties.markwon.ext.strikethrough.StrikethroughPlugin;
import io.noties.markwon.ext.tables.TablePlugin;
import io.noties.markwon.ext.tasklist.TaskListPlugin;
import io.noties.markwon.image.AsyncDrawable;
import io.noties.markwon.image.DefaultDownScalingMediaDecoder;
import io.noties.markwon.image.ImagesPlugin;
import io.noties.markwon.inlineparser.MarkwonInlineParser;
import io.noties.markwon.inlineparser.MarkwonInlineParserPlugin;
import io.noties.markwon.movement.MovementMethodPlugin;
import io.noties.markwon.syntax.SyntaxHighlightPlugin;

public class MarkdownParserFactory {
    public static final String TAG = "MarkdownPluginsCreator";

    public static MarkdownParser create(Context context, PrinterMarkDownTextView textView) {
        return create(context, textView, MarkdownStyles.getDefaultStyles(), null);
    }

    public static void bindMarkdownParser(Context context, PrinterMarkDownTextView textView, MarkdownStyles styles, ElementClickEventCallback callback) {
        create(context, textView, styles, callback);
    }

    public static MarkdownParser create(Context context, PrinterMarkDownTextView textView, MarkdownStyles styles, ElementClickEventCallback callback) {
        ArrayList<AbstractMarkwonPlugin> finalPlugins = getDefaultPlugins(context, textView, callback);
        return new MarkdownParser(context, finalPlugins, textView, styles);
    }

    public static ArrayList<AbstractMarkwonPlugin> getPlugins(Context context, PrinterMarkDownTextView textView, TablePlugin tablePlugin) {
        ArrayList<AbstractMarkwonPlugin> plugins = getDefaultPlugins(context, textView, null);
        plugins.add(tablePlugin);
        plugins.add(CorePlugin.create(context));
        plugins.add(MarkwonInlineParserPlugin.create(MarkwonInlineParser.factoryBuilder()));
        plugins.add(CodeBlockPlugin.create(context, false));
        return plugins;
    }

    public static ArrayList<AbstractMarkwonPlugin> getDefaultPlugins(Context context, PrinterMarkDownTextView textView, ElementClickEventCallback callback) {
        ArrayList<AbstractMarkwonPlugin> plugins = new ArrayList<>();
        plugins.add(linkPlugin(callback));
        plugins.add(imagePlugin(context, callback));
        if (textView != null) {
            plugins.add(htmlPlugin(context, textView, callback));
        }
        plugins.add(MovementMethodPlugin.create(MarkdownAwareMovementMethod.create()));
        plugins.add(createJLatexMathPlugin(context));
        plugins.add(createSyntaxHighlightPlugin());
        plugins.add(createStrikethroughPlugin());
        plugins.add(printStreamPlugin(context, callback));
        plugins.add(createTaskListPlugin(context));
        plugins.add(definitationPlugin());
        plugins.add(TablePlugin.create(context));
        return plugins;
    }

    public static AbstractMarkwonPlugin createJLatexMathPlugin(Context context) {
        JLatexMathPlugin.init(context);
        float size = Utils.dpToPx(context, 16f);
        JLatexMathPlugin.BuilderConfigure jBuilder = builder -> {
            builder.blocksEnabled(true);
            builder.inlinesEnabled(true);
            builder.blocksLegacy(true);
            builder.errorHandler(new JLatexMathPlugin.ErrorHandler() {
                @Nullable
                @Override
                public Drawable handleError(@NonNull String latex, @NonNull Throwable error) {
                    MDLogger.e(
                            TAG,
                            "latex error:" + latex, error
                    );
                    return null;
                }
            });
        };
        return JLatexMathPlugin.create(size, jBuilder);
    }

    public static AbstractMarkwonPlugin createTaskListPlugin(Context context) {
        return TaskListPlugin.create(context);
    }

    public static AbstractMarkwonPlugin createSyntaxHighlightPlugin() {
        return SyntaxHighlightPlugin.createDefault();
    }

    public static AbstractMarkwonPlugin createStrikethroughPlugin() {
        return StrikethroughPlugin.create();
    }

    public static AbstractMarkwonPlugin definitationPlugin() {
        return DefinitionListPlugin.create();
    }

    public static AbstractMarkwonPlugin linkPlugin(ElementClickEventCallback callback) {
        return new AbstractMarkwonPlugin() {
            @Override
            public void configureSpansFactory(@NonNull MarkwonSpansFactory.Builder builder) {
                builder.setFactory(Link.class, new SpanFactory() {
                    @Nullable
                    @Override
                    public Object getSpans(@NonNull MarkwonConfiguration configuration, @NonNull RenderProps props) {
                        return new LinkClickSpan(CoreProps.LINK_DESTINATION.require(props), props, configuration.theme(), callback);
                    }
                });
            }
        };
    }

    public static ImagesPlugin imagePlugin(Context context, ElementClickEventCallback callback) {
        IImageClickCallback imageClickCallback = (url, description) -> {
            if (callback != null) {
                callback.onImageClicked(url, description);
            }
        };
         return ImagesPlugin.create(imageClickCallback).addSchemeHandler(ImageLoaderSchemeHandler.create(context))
                .addMediaDecoder(DefaultDownScalingMediaDecoder.create(Utils.getScreenWidth(context) - 2 * Utils.dpToPx(context, 16f), 0))
                .placeholderProvider(new ImagesPlugin.PlaceholderProvider() {
                    @Nullable
                    @Override
                    public Drawable providePlaceholder(@NonNull AsyncDrawable drawable) {
                        return AppCompatResources.getDrawable(context, R.drawable.default_placeholderdefault);
                    }
                });

    }

    public static AbstractMarkwonPlugin htmlPlugin(Context context, TextView textView, ElementClickEventCallback onClickCallback) {
        return CustomHtmlPlugin.create()
                .addHandler(new HtmlSpanTagHandler(context, onClickCallback))
                .addHandler(new HtmlMarkTagHandler())
                .addHandler(new HtmlParaTagHandler(context))
                .addHandler(new IconLinkSpanHandler(textView, onClickCallback))
                .addHandler(new IconSpanHandler(textView));
    }

    public static AbstractMarkwonPlugin printStreamPlugin(Context context, ElementClickEventCallback linkClickedCallback) {
        return new AfmTextPlugin(context).setCustomClickListener(linkClickedCallback);
    }

}
