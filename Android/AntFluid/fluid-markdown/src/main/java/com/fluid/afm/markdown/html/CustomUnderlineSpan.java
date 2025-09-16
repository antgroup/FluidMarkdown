package com.fluid.afm.markdown.html;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.style.ReplacementSpan;

/**
 * 自定义下划线
 */
public class CustomUnderlineSpan extends ReplacementSpan {

    public static final String TAG = "CustomUnderlineSpan";
    private final int color;
    private final float thickness;

    public CustomUnderlineSpan(int color, float thickness) {
        this.color = color;
        this.thickness = thickness;
    }

    @Override
    public int getSize(Paint paint, CharSequence text, int start, int end, Paint.FontMetricsInt fm) {
        return (int) paint.measureText(text, start, end);
    }

    @Override
    public void draw(Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, Paint paint) {
        int oldColor = paint.getColor();
        paint.setColor(color);
        paint.setStrokeWidth(thickness);

        canvas.drawLine(x,
                y,
                x + paint.measureText(text, start, end),
                y,
                paint);
        paint.setColor(oldColor);
        canvas.drawText(text, start, end, x, y, paint);
    }
}
