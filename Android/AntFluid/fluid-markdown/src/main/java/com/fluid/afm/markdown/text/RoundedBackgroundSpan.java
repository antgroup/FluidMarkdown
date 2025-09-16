package com.fluid.afm.markdown.text;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.text.Spanned;
import android.text.style.ReplacementSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.noties.markwon.core.MarkwonTheme;
public class RoundedBackgroundSpan extends ReplacementSpan {

    private final MarkwonTheme theme;
    private float cornerRadius;
    private final int paddingV;
    private final int paddingH;
    private final Typeface typeface;

    public RoundedBackgroundSpan(MarkwonTheme theme, float cornerRadius) {
        this.theme = theme;
        this.cornerRadius = cornerRadius;
        this.cornerRadius = theme.codeStyle().inlineBackgroundRadius();
        this.paddingV = theme.codeStyle().inlinePaddingVertical();
        this.paddingH = theme.codeStyle().inlinePaddingHorizontal();
        typeface = theme.codeStyle().codeTypeface();
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, @Nullable Paint.FontMetricsInt fm) {
        return (int) (paint.measureText(text, start, end) + paddingH + paddingH);
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        if (!isSelf(start, end, text, this)) {
            return;
        }
        final int oldColor = paint.getColor();
        final float oldTextSize = paint.getTextSize();
        final Typeface oldTypeface = paint.getTypeface();

        theme.applyInlineCodeBackgroundColor(paint);
        paint.setAntiAlias(true);

        Paint.FontMetrics fm = paint.getFontMetrics();

        float backgroundTop = y + fm.ascent - paddingV;
        float backgroundBottom = y + fm.descent + paddingV;

        RectF rect = new RectF(
                x,
                backgroundTop,
                x + measureTextWidth(paint, text, start, end) + paddingH + paddingH,
                backgroundBottom
        );
        canvas.drawRoundRect(rect, cornerRadius, cornerRadius, paint);

        if (typeface != null) {
            paint.setTypeface(typeface);
        }
        paint.setColor(theme.getInlineCodeTextColor());
        canvas.drawText(text, start, end, x + paddingH, y, paint);

        paint.setColor(oldColor);
        paint.setTextSize(oldTextSize);
        paint.setTypeface(oldTypeface);
    }

    private static boolean isSelf(int start, int end, CharSequence text, Object span) {
        final int spanStart = ((Spanned) text).getSpanStart(span);
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanStart <= start && spanEnd >= end - 1;
    }

    private float measureTextWidth(Paint paint, CharSequence text, int start, int end) {
        return paint.measureText(text, start, end);
    }
}
