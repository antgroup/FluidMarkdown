package io.noties.markwon.core.spans;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.os.Build;
import android.text.Layout;
import android.text.TextPaint;
import android.text.TextUtils;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;

import com.fluid.afm.span.BaseIconTextSpan;
import com.fluid.afm.styles.BulletStyle;
import com.fluid.afm.styles.Shape;
import com.fluid.afm.utils.Utils;

import io.noties.markwon.core.MarkwonTheme;
import io.noties.markwon.utils.LeadingMarginUtils;

/**
 * 无序列表项
 */
public class BulletListItemSpan extends BaseIconTextSpan {

    private static final boolean IS_NOUGAT;
    private static final int DEFAULT_STROKE_WIDTH = Utils.dpToPx(1);
    private static final int DEFAULT_LEADING_MARGIN = Utils.dpToPx(24);
    private Integer leadingMargin = null;

    static {
        final int sdk = Build.VERSION.SDK_INT;
        IS_NOUGAT = Build.VERSION_CODES.N == sdk || Build.VERSION_CODES.N_MR1 == sdk;
    }

    private final MarkwonTheme theme;

    private final Paint paint = ObjectsPool.paint();
    private final RectF circle = ObjectsPool.rectF();
    private final Rect rectangle = ObjectsPool.rect();

    private final int level;

    private BulletStyle style;

    public BulletListItemSpan(
            @NonNull MarkwonTheme theme,
            @IntRange(from = 0) int level) {
        super(theme.getTextView());
        this.theme = theme;
        this.level = level;
        style = theme.getBulletStyle(level);
    }

    @Override
    protected String getImageUrl() {
        if (style != null && style.shape() != null) {
            return style.shape().icon();
        }
        return "";
    }

    @Override
    protected void applyStyle(TextPaint paint) {
        applyStyleInner(paint);
    }

    private void applyStyleInner(Paint p) {
        style = theme.getBulletStyle(level);
        if (TextUtils.isEmpty(getImageUrl())) {
            paint.setStrokeWidth(DEFAULT_STROKE_WIDTH);
        }
        if (validShape() && style.shape().color() != 0) {
            paint.setColor(style.shape().color());
        } else {
            paint.setColor(p.getColor());
        }
    }

    public int getLeadingMarginIfUsed() {
        return leadingMargin == null ? 0 : leadingMargin;
    }

    @Override
    public int getLeadingMargin(boolean first) {
        if (style.leadingSpacing() >= 0) {
            leadingMargin = style.leadingSpacing();
        } else {
            leadingMargin = (int) (realTextSize + 0.5) / 2;
        }
        if (style.leading() > 0) {
            leadingMargin += style.leading();
        } else {
            leadingMargin += (int) (realTextSize + 0.5) / 2;
        }
        if (style.shape() != null && style.shape().size() > 0) {
            leadingMargin += style.shape().size();
        } else {
            final int textLineHeight = (int) (paint.descent() - paint.ascent() + .5F);

            final int side = getSpotSize(textLineHeight);
            leadingMargin += getSpotSize(side) + DEFAULT_LEADING_MARGIN;
        }
        return leadingMargin;
    }

    private boolean validShape() {
        if (style.shape() == null) {
            return false;
        }
        if (style.shape().type() == Shape.SHAPE_CIRCLE || style.shape().type() == Shape.SHAPE_RECT || style.shape().type() == Shape.SHAPE_RING || style.shape().type() == Shape.SHAPE_RECT_OUTLINE) {
            return style.shape().size() > 0;
        } else {
            return style.shape().type() == Shape.SHAPE_ICON;
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

        applyStyleInner(paint);
        boolean validShape = validShape();
        if (validShape && style.shape().type() == Shape.SHAPE_ICON) {
            if (mDrawableWrapper != null && mDrawableWrapper.getDrawable() != null) {
                c.save();
                c.translate(x, baseline - iconOffset);
                mDrawableWrapper.getDrawable().draw(c);
                c.restore();
            }
            return;
        }
        final int save = c.save();
        try {
            final int width = leadingMargin;

            // @since 1.0.6 we no longer rely on (bottom-top) calculation in order to detect line height
            // it lead to bad rendering as first & last lines received different results even
            // if text size is the same (first line received greater amount and bottom line -> less)
            final int textLineHeight = (int) (paint.descent() - paint.ascent() + .5F);

            final int side = getSpotSize(textLineHeight);

            final int marginLeft = validShape ? style.leading() : (width - side) / 2;

            // in order to support RTL
            final int l;
            final int r;
            {
                // @since 4.2.1 to correctly position bullet
                // when nested inside other LeadingMarginSpans (sorry, Nougat)
                if (IS_NOUGAT) {

                    // @since 2.0.2
                    // There is a bug in Android Nougat, when this span receives an `x` that
                    // doesn't correspond to what it should be (text is placed correctly though).
                    // Let's make this a general rule -> manually calculate difference between expected/actual
                    // and add this difference to resulting left/right values. If everything goes well
                    // we do not encounter a bug -> this `diff` value will be 0
                    final int diff;
                    if (dir < 0) {
                        // rtl
                        diff = x - (layout.getWidth() - (width * level));
                    } else {
                        diff = (width * level) - x;
                    }

                    final int left = x + (dir * marginLeft);
                    final int right = left + (dir * side);
                    l = Math.min(left, right) + (dir * diff);
                    r = Math.max(left, right) + (dir * diff);

                } else {
                    if (dir > 0) {
                        l = x + marginLeft;
                    } else {
                        l = x - width + marginLeft;
                    }
                    r = l + side;
                }
            }

            final int t = baseline + (int) (((paint.descent() + paint.ascent()) / 2.F + .5F) * (1 + Utils.FONT_SPACING_IN_LINE)) - (side / 2);
            final int b = t + side;
            boolean drawn = false;
            if (validShape) {
                if (style.shape().type() == Shape.SHAPE_CIRCLE || style.shape().type() == Shape.SHAPE_RING) {
                    circle.set(l, t, r, b);
                    Paint.Style paintStyle =  Paint.Style.FILL;
                    if (style.shape().type() == Shape.SHAPE_RING || (!validShape && level == 0)) {
                        paintStyle = Paint.Style.STROKE;
                    }
                    paint.setStyle(paintStyle);
                    c.drawOval(circle, paint);
                    drawn = true;
                } else if (style.shape().type() == Shape.SHAPE_RECT || style.shape().type() == Shape.SHAPE_RECT_OUTLINE) {
                    rectangle.set(l, t, r, b);
                    if (style.shape().type() == Shape.SHAPE_RECT) {
                        paint.setStyle(Paint.Style.FILL);
                    } else {
                        paint.setStyle(Paint.Style.STROKE);
                        paint.setStrokeWidth(style.shape().lineWidth());
                    }
                    c.drawRect(rectangle, paint);
                    drawn = true;
                }
            }
            if (!drawn) {
                if (level == 0 || level == 1) {
                    circle.set(l, t, r, b);

                    final Paint.Style style = level == 0
                            ? Paint.Style.FILL
                            : Paint.Style.STROKE;
                    paint.setStyle(style);

                    c.drawOval(circle, paint);
                } else {
                    rectangle.set(l, t, r, b);
                    paint.setStyle(Paint.Style.FILL);
                    c.drawRect(rectangle, paint);
                }
            }

        } finally {
            c.restoreToCount(save);
        }
    }

    private int getSpotSize(int textLineHeight) {
        if (validShape() && style.shape().size() > 0) {
            return style.shape().size();
        }
        return textLineHeight / 3;
    }
}
