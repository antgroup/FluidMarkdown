package io.noties.markwon.core.spans;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.Layout;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.style.LeadingMarginSpan;
import android.widget.TextView;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;

import com.fluid.afm.span.BaseIconTextSpan;
import com.fluid.afm.styles.OrderStyle;
import com.fluid.afm.styles.Shape;

import io.noties.markwon.core.MarkwonTheme;
import io.noties.markwon.utils.LeadingMarginUtils;
import com.fluid.afm.utils.Utils;

public class OrderedListItemSpan extends BaseIconTextSpan implements LeadingMarginSpan {

    private static final int DEFAULT_STROKE_WIDTH = Utils.dpToPx(1);
    private static final int ICON_SPACING = Utils.dpToPx(5);
    private static final int DEFAULT_LEADING_MARGIN = Utils.dpToPx(24);


    /**
     * Process supplied `text` argument and supply TextView paint to all OrderedListItemSpans
     * in order for them to measure number.
     * <p>
     * NB, this method must be called <em>before</em> setting text to a TextView (`TextView#setText`
     * internally can trigger new Layout creation which will ask for leading margins right away)
     *
     * @param textView to which markdown will be applied
     * @param text     parsed markdown to process
     * @since 2.0.1
     */

    private static final int BASE_CHAR_WIDTH = Utils.dpToPx(9f);
    private static final int SPACE = Utils.dpToPx(5f);

    public static void measure(@NonNull TextView textView, @NonNull CharSequence text) {

        if (!(text instanceof Spanned)) {
            // nothing to do here
            return;
        }

        final OrderedListItemSpan[] spans = ((Spanned) text).getSpans(
                0,
                text.length(),
                OrderedListItemSpan.class);

        if (spans != null) {
            final TextPaint paint = textView.getPaint();
            for (OrderedListItemSpan span : spans) {
                span.margin = (int) (paint.measureText(span.number) + .5F);
            }
        }
    }

    private final MarkwonTheme theme;
    private final String number;
    private final Paint paint = ObjectsPool.paint();

    private Integer leadingMargin = null;

    // we will use this variable to check if our order number text exceeds block margin,
    // so we will use it instead of block margin
    // @since 1.0.3
    private float margin;
    private final int level;
    private int numberLength;
    private OrderStyle style;

    public OrderedListItemSpan(
            @NonNull MarkwonTheme theme,
            @IntRange(from = 0) int number,
            @IntRange(from = 0) int level
    ) {
        super(theme.getTextView());

        style = theme.orderBean(level);
        this.theme = theme;
        this.level = level;
        if (style != null && style.shape() != null) {
            this.number = String.valueOf(number);
        } else {
            this.number = number + "." + '\u00a0';
        }
        numberLength = String.valueOf(number).length();
    }

    public int getLeadingMarginIfUsed() {
        return getProductLeading();
    }

    public int getProductLeading() {
        if (style != null) {
            if (style.shape() != null) {
                if (style.shape().type() == Shape.SHAPE_ICON) {
                    return getIconSize() + style.leading() + style.leadingSpacing();
                } else if (style.shape().type() == Shape.SHAPE_RECT) {
                    return style.shape().size() + style.leading() + style.leadingSpacing();
                }
            } else {
                if (style.orderFontSize() > 0) {
                    paint.setTextSize(style.orderFontSize());
                }
                float baseW = paint.measureText("4"); // 4 is the widest number
                return (int) (style.leading() + numberLength * baseW + style.leadingSpacing());
            }
        }
        return (int) margin + DEFAULT_LEADING_MARGIN;
    }


    @Override
    public int getLeadingMargin(boolean first) {
        leadingMargin = getProductLeading();
        return leadingMargin;
    }

    private void applyListItemStyle(@NonNull Paint paint) {
        paint.setStrokeWidth(DEFAULT_STROKE_WIDTH);
        paint.setLetterSpacing(0);
        if (style.orderFontSize() > 0) {
            paint.setTextSize(style.orderFontSize());
        }
    }

    @Override
    public void drawLeadingMargin(Canvas c, Paint p, int x, int dir, int top, int baseline, int bottom, CharSequence text, int start, int end, boolean first, Layout layout) {

        // if there was a line break, we don't need to draw anything
        if (!first
                || !LeadingMarginUtils.selfStart(start, text, this)) {
            return;
        }

        paint.set(p);
        boolean drawIcon = mDrawableWrapper != null && mDrawableWrapper.getDrawable() != null;
        float oldSize = paint.getTextSize();

        float baselineOffset = 0;
        boolean isBold = paint.isFakeBoldText();
        if (drawIcon || (style != null && style.shape() != null)) {
            float textsize;
            if (style != null && style.orderFontSize() > 0) {
                textsize = style.orderFontSize();
            } else {
                float numberRatio = 0.62f;
                textsize = oldSize * numberRatio;
            }
            paint.setTextSize(textsize);
            if (style != null && style.isBold()) {
                paint.setFakeBoldText(true);
            }
            baselineOffset = (oldSize - textsize) / 2f * Utils.FONT_HEIGHT_IN_LINE;
        }

        applyListItemStyle(paint);

        // if we could force usage of #measure method then we might want skip this measuring here
        // but this won't hold against new values that a TextView can receive (new text size for
        // example...)
        String drawText = number;
        float numberWidth = paint.measureText(number);

        // @since 1.0.3
        float width = leadingMargin == null ? 0 : leadingMargin;
        if (style != null && style.shape() != null) {
            width = style.shape().size();
        }
        boolean isNumber = true;
        if (numberWidth > width) {
            // let's keep this logic here in case a user decided not to call #measure and is fine
            // with current implementation
            if (style == null || style.shape() == null) {
                width = numberWidth;
                margin = numberWidth;
            } else {
                isNumber = false;
                drawText = "...";
                numberWidth = (int) (paint.measureText(drawText) + .5F);
            }
        } else {
            margin = 0;
        }

        float left;
        if (style != null) {
            left = x;
        } else if (dir > 0) {
            left = x + (width * dir);
        } else {
            left = x + (width * dir) + width;
        }
        if (drawIcon) {
            left -= getIconSize() + ICON_SPACING;
            c.save();
            c.translate(left, baseline - iconOffset);
            mDrawableWrapper.getDrawable().draw(c);
            c.restore();
            float numberOffset = (getIconSize() - numberWidth) / 2f;
            left += numberOffset;
        } else if (style != null && style.shape() != null && style.shape().type() == Shape.SHAPE_RECT) {
            float fontTop = baseline - iconOffset;
            float rectTop = fontTop + (getIconSize() - style.shape().size()) / 2f;
            int oldColor = paint.getColor();
            Paint.Style oldStyle = paint.getStyle();
            paint.setStyle(Paint.Style.FILL);
            paint.setColor(style.shape().color());
            left += style.leading();
            c.drawRoundRect(left, rectTop, left + style.shape().size(), rectTop + style.shape().size(), style.shape().radius(), style.shape().radius(), paint);
            paint.setStyle(oldStyle);
            paint.setColor(oldColor);
            float numberOffset = (style.shape().size() - numberWidth) / 2f;
            if (isNumber) {
                numberOffset -= 1;
            }
            left += numberOffset;
        } else if (style == null) {
            left -= numberWidth;
        } else if (style.isBold()) {
            left += style.leading();
            paint.setFakeBoldText(true);
        }

        int oldColor = paint.getColor();
        if (style != null && style.orderFontColor() != 0) {
            paint.setColor(style.orderFontColor());
        }
        // @since 1.1.1 we are using `baseline` argument to position text

        c.drawText(drawText, left, baseline - baselineOffset, paint);
        paint.setColor(oldColor);
        paint.setTextSize(oldSize);
        paint.setFakeBoldText(isBold);
    }

    @Override
    protected String getImageUrl() {
        if (style != null && style.shape() != null && style.shape().type() == Shape.SHAPE_ICON) {
            return style.shape().icon();
        }
        return "";
    }

    @Override
    protected void applyStyle(TextPaint paint) {
        if (style == null || style.orderFontSize() == 0) {
            this.paint.setTextSize(paint.getTextSize());
        } else {
            this.paint.setTextSize(style.orderFontSize());
        }
        if (style == null || style.orderFontColor() == 0) {
            this.paint.setColor(paint.getColor());
        } else {
            this.paint.setColor(style.orderFontColor());
        }
    }
}
