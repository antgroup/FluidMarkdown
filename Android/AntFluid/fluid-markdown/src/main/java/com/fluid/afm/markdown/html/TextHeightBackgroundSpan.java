package com.fluid.afm.markdown.html;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.text.style.ReplacementSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class TextHeightBackgroundSpan extends ReplacementSpan {

    private final int backgroundColor;

    public TextHeightBackgroundSpan(int backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, @Nullable Paint.FontMetricsInt fm) {
        return (int) paint.measureText(text, start, end);
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        final int oldColor = paint.getColor();
        final Paint.Style oldStyle = paint.getStyle();

        Paint.FontMetrics fontMetrics = paint.getFontMetrics();

        float backgroundTop = y + fontMetrics.ascent;
        float backgroundBottom = y + fontMetrics.descent;

        paint.setColor(backgroundColor);
        paint.setStyle(Paint.Style.FILL);
        
        RectF rect = new RectF(
                x,
                backgroundTop,
                x + paint.measureText(text, start, end),
                backgroundBottom
        );
        canvas.drawRect(rect, paint);

        paint.setColor(oldColor);
        paint.setStyle(oldStyle);
        canvas.drawText(text, start, end, x, y, paint);
    }
} 