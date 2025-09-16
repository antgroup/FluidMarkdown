package com.fluid.afm.markdown.image;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.text.Spanned;

public class CustomImageSpan extends SuperscriptImageSpan {

    public CustomImageSpan(Drawable drawable) {
        super(drawable, ALIGN_CENTER);
    }

    @Override
    public void draw(Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, Paint paint) {
        if (!isSelf(start, end, text, this)) {
            return;
        }
        super.draw(canvas, text, start, end, x, top, y, bottom, paint);
    }
    private static boolean isSelf(int start, int end, CharSequence text, Object span) {
        final int spanStart = ((Spanned) text).getSpanStart(span);
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanStart <= start && spanEnd >= end - 1;
    }

}
