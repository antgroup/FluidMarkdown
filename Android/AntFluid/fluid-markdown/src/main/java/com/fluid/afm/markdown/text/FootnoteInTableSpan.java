package com.fluid.afm.markdown.text;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.style.ReplacementSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class FootnoteInTableSpan extends ReplacementSpan {
    private final String footnote;

    public FootnoteInTableSpan(String index) {
        this.footnote = "[" + index + "]";
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, @Nullable Paint.FontMetricsInt fm) {
        return (int) (paint.measureText(footnote) + 0.5f);
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        canvas.drawText(footnote, x, y, paint);
    }
}
