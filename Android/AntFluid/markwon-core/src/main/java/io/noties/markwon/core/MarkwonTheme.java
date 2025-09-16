
package io.noties.markwon.core;

import android.content.Context;
import android.graphics.Paint;
import android.graphics.Typeface;
import android.text.TextPaint;
import android.text.TextUtils;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.styles.BlockQuoteStyle;
import com.fluid.afm.styles.BulletStyle;
import com.fluid.afm.styles.CodeStyle;
import com.fluid.afm.styles.FootnoteStyle;
import com.fluid.afm.styles.HorizonRuleStyle;
import com.fluid.afm.styles.LinkStyle;
import com.fluid.afm.styles.MarkdownStyles;
import com.fluid.afm.styles.OrderStyle;
import com.fluid.afm.styles.ParagraphStyle;
import com.fluid.afm.styles.TableStyle;
import com.fluid.afm.styles.TitleStyle;
import com.fluid.afm.styles.UnderlineStyle;
import com.fluid.afm.utils.Utils;

import java.util.List;
import java.util.Map;

import io.noties.markwon.MarkwonPlugin;
import io.noties.markwon.utils.ColorUtils;

/**
 * Class to hold <i>theming</i> information for rending of markdown.
 * <p>
 * Since version 3.0.0 this class should be considered as <em>CoreTheme</em> as its
 * information holds data for core features only. But based on this other components can still use it
 * to display markdown consistently.
 * <p>
 * Since version 3.0.0 this class should not be instantiated manually. Instead a {@link MarkwonPlugin}
 * should be used: {@link MarkwonPlugin#configureTheme(Builder)}
 * <p>
 * Since version 3.0.0 properties related to <em>strike-through</em>, <em>tables</em> and <em>HTML</em>
 * are moved to specific plugins in independent artifacts
 *
 * @see CorePlugin
 * @see MarkwonPlugin#configureTheme(Builder)
 */
@SuppressWarnings("WeakerAccess")
public class MarkwonTheme {

    private static final float THEMATIC_BREAK_DEF_WIDTH = 5f;
    protected static final int BLOCK_QUOTE_DEF_COLOR_ALPHA = 25;
    protected static final float CODE_DEF_TEXT_SIZE_RATIO = .87F;
    public static final int CODE_BLOCK_HEADER_HEIGHT =  Utils.dpToPx(40);


    public static final int THEMATIC_BREAK_DEF_ALPHA = 25;
    private ParagraphStyle paragraph;
    private HorizonRuleStyle horizonRule;
    private LinkStyle link;
    private TableStyle table;
    private TitleStyle[] titleStyles;
    private Map<Integer, OrderStyle> orderStyles;
    private OrderStyle baseOrder;
    private Map<Integer, BulletStyle> bulletStyles;
    private BulletStyle baseBullet;
    private FootnoteStyle footnote;
    private BlockQuoteStyle blockQuote;
    private CodeStyle code;
    private UnderlineStyle underline;
    private final TextView textView;

    /**
     * Create an <strong>empty</strong> instance of {@link Builder} with no default values applied
     * <p>
     * Since version 3.0.0 manual construction of {@link MarkwonTheme} is not required, instead a
     * {@link MarkwonPlugin#configureTheme(Builder)} should be used in order
     * to change certain theme properties
     *
     * @since 3.0.0
     */
    @SuppressWarnings("unused")
    @NonNull
    public static Builder emptyBuilder() {
        return new Builder();
    }

    /**
     * Factory method to create a {@link Builder} instance and initialize it with values
     * from supplied {@link MarkwonTheme}
     *
     * @param copyFrom {@link MarkwonTheme} to copy values from
     * @return {@link Builder} instance
     * @see #builderWithDefaults(Context)
     * @since 1.0.0
     */
    @NonNull
    public static Builder builder(@NonNull MarkwonTheme copyFrom) {
        return new Builder(copyFrom);
    }

    /**
     * Factory method to obtain a {@link Builder} instance initialized with default values taken
     * from current application theme.
     *
     * @param context Context to obtain default styling values (colors, etc)
     * @return {@link Builder} instance
     * @since 1.0.0
     */
    @NonNull
    public static Builder builderWithDefaults(@NonNull Context context) {
        return new Builder();
    }

    protected MarkwonTheme(@NonNull Builder builder) {
        this.textView = builder.textView;
        updateStyles(builder.mProductStyles);
    }

    public void updateStyles(MarkdownStyles styles) {
        this.paragraph = styles.paragraphStyle();
        this.horizonRule = styles.horizonRuleStyle();
        this.link = styles.linkStyle();
        this.table = styles.tableStyle();
        this.titleStyles = styles.titleStyles();
        this.orderStyles = styles.getOrderStylesMap();
        this.baseOrder = styles.getBaseOrderStyle();
        this.bulletStyles = styles.getBulletStylesMap();
        this.baseBullet = styles.getBaseBulletStyle();
        this.footnote = styles.getFootnoteStyle();
        this.blockQuote = styles.blockQuoteStyle();
        this.code = styles.codeStyle();
        this.underline = styles.underlineStyle();
    }

    public UnderlineStyle underlineStyle() {
        return underline;
    }

    public BlockQuoteStyle blockQuoteStyle() {
        return blockQuote;
    }

    public LinkStyle linkStyle() {
        return link;
    }

    public FootnoteStyle footnoteStyle() {
        return footnote;
    }

    public CodeStyle codeStyle() {
        return code;
    }

    public TextView getTextView() {
        return textView;
    }

    public void applyLinkStyle(@NonNull TextPaint paint, int textColor, boolean isBold, String decoration) {
        paint.setUnderlineText(link.underline());
        if (textColor!= 0) {
            paint.setColor(textColor);
        } else if (link.fontColor() != 0) {
            paint.setColor(link.fontColor());
        } else {
            paint.setColor(paint.linkColor);
        }
        if (isBold || link.isBold()) {
            paint.setFakeBoldText(true);
        }
        if (TextUtils.equals("none", decoration)) {
            paint.setUnderlineText(false);
        } else if (TextUtils.equals("line-through", decoration)) {
            paint.setUnderlineText(false);
            paint.setStrikeThruText(true);
        } else if (TextUtils.equals("underline", decoration)) {
            paint.setUnderlineText(true);
        } else {
            paint.setUnderlineText(link.underline());
        }
    }
    /**
     * @since 1.0.5
     */
    public void applyLinkStyle(@NonNull TextPaint paint) {
        paint.setUnderlineText(link.underline());
        if (link.fontColor() != 0) {
            paint.setColor(link.fontColor());
        }
        if (link.isBold()) {
            paint.setFakeBoldText(true);
        }
    }

    public void applyLinkStyle(@NonNull Paint paint) {
        paint.setUnderlineText(link.underline());
        if (link.fontColor() != 0) {
            // by default we will be using text color
            paint.setColor(link.fontColor());
        } else {
            // @since 1.0.5, if link color is specified during configuration, _try_ to use the
            // default one (if provided paint is an instance of TextPaint)
            if (paint instanceof TextPaint) {
                paint.setColor(((TextPaint) paint).linkColor);
            }
        }
    }

    public void applyBlockQuoteStyle(@NonNull Paint paint) {
        int color = blockQuote.lineColor();
        if (color == 0) {
            color = ColorUtils.applyAlpha(paint.getColor(), BLOCK_QUOTE_DEF_COLOR_ALPHA);
        }
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(color);
    }

    public int getCodeBlockMargin() {
        return code.blockLeading();
    }

    public int getInlineCodeTextColor() {
        return code.inlineFontColor();
    }

    /**
     * @since 3.0.0
     */
    public void applyInlineCodeTextStyle(@NonNull Paint paint) {
        paint.setTextSize(code.inlineFontSize());
        paint.setColor(code.inlineFontColor());
        paint.setTypeface(code.codeTypeface());

    }

    /**
     * @since 3.0.0
     */
    public void applyCodeBlockTextStyle(@NonNull Paint paint) {

        // apply text color, first check for block specific value,
        // then check for code (inline), else do nothing (keep original color of text)

        int textColor;

        Typeface typeface;
        int textSize;
        textColor = code.codeFontColor();
        typeface = code.codeTypeface();
        textSize = code.codeFontSize();
        if (textColor != 0) {
            paint.setColor(textColor);
        }
        if (typeface != null) {
            paint.setTypeface(typeface);

            // please note that we won't be calculating textSize
            // (like we do when no Typeface is provided), if it's some specific typeface
            // we would confuse users about textSize

            if (textSize > 0) {
                paint.setTextSize(textSize);
            }
        } else {

            // by default use monospace
            paint.setTypeface(Typeface.MONOSPACE);
            if (textSize > 0) {
                paint.setTextSize(textSize);
            } else {
                // calculate default value
                paint.setTextSize(paint.getTextSize() * CODE_DEF_TEXT_SIZE_RATIO);
            }
        }
    }

    /**
     * @since 3.0.0
     */
    public void applyCodeBackgroundColor(@NonNull Paint paint) {
        paint.setColor(code.codeBackgroundColor());
    }

    public void applyInlineCodeBackgroundColor(@NonNull Paint paint) {
        paint.setColor(code.inlineBackgroundColor());
    }

    public int getCodeBackgroundRadius() {
        return code.codeBackgroundRadius();
    }

    /**
     * @since 3.0.0
     */
    public int getCodeBlockBackgroundColor(@NonNull Paint paint) {
        return code.codeBackgroundColor();
    }

    public void applyThematicBreakStyle(@NonNull Paint paint) {
        final int color = horizonRule.getColor() == 0 ? ColorUtils.applyAlpha(paint.getColor(), THEMATIC_BREAK_DEF_ALPHA) : horizonRule.getColor();
        paint.setColor(color);
        paint.setStyle(Paint.Style.FILL);
        if (horizonRule.getHeight() >= 0) {
            paint.setStrokeWidth((float) horizonRule.getHeight());
        } else {
            paint.setStrokeWidth(THEMATIC_BREAK_DEF_WIDTH);
        }
    }

    public int getParagraphBreakHeight() {
        return paragraph.paragraphSpacing();
    }

    public TitleStyle getTitleStyle(int level) {
        return titleStyles[level - 1];
    }

    public TitleStyle getTitleStyles(int level) {
        return titleStyles[level];
    }

    public BulletStyle getBulletStyle(int level) {
        BulletStyle bulletStyle = bulletStyles.get(level);
        if (bulletStyle == null) {
            if (baseBullet == null) {
                baseBullet = BulletStyle.create();
            }
            bulletStyle = baseBullet;
        }
        return bulletStyle;
    }

    public TableStyle getTableStyle() {
        return table;
    }

    public OrderStyle orderBean(int level) {
        OrderStyle orderBean = orderStyles.get(level);
        if (orderBean == null) {
            if (baseOrder == null) {
                baseOrder = OrderStyle.create();
            }
            orderBean = baseOrder;
        }
        return orderBean;
    }

    public LinkStyle getLinkStyles() {
        return link;
    }

    public HorizonRuleStyle getHorizonRule() {
        return horizonRule;
    }

    @SuppressWarnings("unused")
    public static class Builder {

        private TextView textView;
        private MarkdownStyles mProductStyles;

        Builder() {
        }

        Builder(@NonNull MarkwonTheme theme) {
            this.textView = theme.getTextView();
            mProductStyles = new MarkdownStyles()
                    .paragraphStyle(theme.paragraph)
                    .codeStyle(theme.code)
                    .linkStyle(theme.link)
                    .blockQuoteStyle(theme.blockQuote)
                    .horizonRuleStyle(theme.horizonRule)
                    .tableStyle(theme.table)
                    .setTitleStyles(theme.titleStyles)
                    .setOrderStyles(theme.orderStyles)
                    .setBaseOrderStyle(theme.baseOrder)
                    .setBulletStyles(theme.bulletStyles)
                    .baseBulletStyle(theme.baseBullet)
                    .footnoteStyle(theme.footnote)
                    .underlineStyle(theme.underline);

        }

        public Builder setTextView(TextView textView) {
            this.textView = textView;
            return this;
        }

        public Builder setStyles(MarkdownStyles productStyles) {
            this.mProductStyles = productStyles;
            return this;
        }

        @NonNull
        public MarkwonTheme build(List<MarkwonPlugin> plugins) {
            if (plugins != null) {
                for (MarkwonPlugin plugin : plugins) {
                    plugin.configureTheme(this);
                }
            }
            return new MarkwonTheme(this);
        }
    }

}