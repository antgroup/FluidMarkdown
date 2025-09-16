package com.fluid.afm.markdown.image;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.drawable.Drawable;
import android.text.style.ImageSpan;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.Utils;

public class SuperscriptImageSpan extends ImageSpan {
    public static final int ALIGN_TOP = 0x10;
    public static final int ALIGN_CENTER = 2;

    public SuperscriptImageSpan(@NonNull Drawable drawable) {
        super(drawable, ALIGN_TOP);
    }

    public SuperscriptImageSpan(Drawable drawable, int verticalAlignment) {
        super(drawable, verticalAlignment);
    }

    @Override
    public void draw(Canvas canvas, CharSequence text,
                     int start, int end, float x,
                     int top, int y, int bottom, Paint paint) {
        Drawable b = getDrawable();
        canvas.save();
        float transY = bottom - b.getBounds().bottom;
        if (mVerticalAlignment == ALIGN_BASELINE) {
            transY -= paint.getFontMetricsInt().descent;
        } else if (mVerticalAlignment == ALIGN_CENTER) {
            float delta = (b.getBounds().height() - paint.getTextSize() ) / 2;
            float textTop = y - paint.getTextSize() * Utils.FONT_HEIGHT_IN_LINE;
            transY = textTop - delta;
        } else if (mVerticalAlignment == ALIGN_BOTTOM) {
            transY = bottom - b.getBounds().bottom;
        } else {
            transY = top;
        }

        canvas.translate(x, transY);
        b.draw(canvas);
        canvas.restore();
    }
}

