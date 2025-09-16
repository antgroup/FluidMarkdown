package com.fluid.afm.span;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.style.ReplacementSpan;

import com.fluid.afm.utils.Utils;

public class AntUnderlineSupportMulLinesSpan extends ReplacementSpan {
    private final int color;
    private final float thickness;

    public AntUnderlineSupportMulLinesSpan(int color, float thickness) {
        this.color = color;
        this.thickness = thickness;
    }

    public int getColor() {
        return color;
    }

    public float getThickness() {
        return thickness;
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
        float lineY = y + paint.getTextSize() * Utils.FONT_SPACING_IN_LINE;

        canvas.drawLine(x,
                lineY,
                x + paint.measureText(text, start, end),
                lineY,
                paint);
        paint.setColor(oldColor);
        canvas.drawText(text, start, end, x, y, paint);
    }

}
