package com.fluid.afm.markdown.image;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.style.ReplacementSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fluid.afm.styles.FootnoteStyle;

import io.noties.markwon.utils.SpanUtils;
import com.fluid.afm.utils.Utils;

public class FootnoteSpan extends ReplacementSpan {
    private static final int SPACE = Utils.dpToPx(2);
    private static final int SIZE = Utils.dpToPx(16);
    private final String mIndexSequence;
    private final FootnoteStyle mStyle;

    public FootnoteSpan(String indexSequence, FootnoteStyle style) {
        this.mIndexSequence = indexSequence;
        mStyle = style;
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, @Nullable Paint.FontMetricsInt fm) {
        if (mStyle.style() == FootnoteStyle.STYLE_RECTANGLE) {
            float oldSize = paint.getTextSize();
            boolean oldBold = paint.isFakeBoldText();
            paint.setTextSize(mStyle.fontSize());
            paint.setFakeBoldText(mStyle.isBold());
            float textW = paint.measureText(mIndexSequence);
            float result = mStyle.size();
            if (textW > SIZE) {
                result = textW + SPACE + SPACE;
            }
            paint.setTextSize(oldSize);
            paint.setFakeBoldText(oldBold);
            return (int) (result + 0.5f);
        }
        if (mStyle.size() > 0) {
            return (int) (mStyle.size() + SPACE + SPACE);
        }
        return SIZE + SPACE + SPACE;
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        if (!SpanUtils.isSelf(start, end, text, this)) {
            return;
        }
        float oldSize = paint.getTextSize();
        int oldColor = paint.getColor();
        int saveCount = canvas.save();
        boolean oldBold = paint.isFakeBoldText();

        if (mStyle.backgroundColor() != 0) {
            paint.setColor(mStyle.backgroundColor());
        }
        float shapeSize = mStyle.size() > 0 ? mStyle.size() : SIZE;
        float lineHeight = paint.getFontMetrics().descent - paint.getFontMetrics().ascent;
        float middleY = y - lineHeight / 2f + Utils.FONT_SPACING_IN_LINE * lineHeight;
        float transY = middleY - shapeSize / 2f;
        canvas.translate(x + SPACE, transY);
        if (mStyle.fontSize() > 0) {
            paint.setTextSize(mStyle.fontSize());
        }
        float textW = paint.measureText(mIndexSequence);
        if (mStyle.style() == FootnoteStyle.STYLE_RECTANGLE) {
            if (textW > shapeSize) {
                shapeSize = textW + SPACE + SPACE;
            }
            canvas.drawRoundRect(0, 0, shapeSize, shapeSize, mStyle.radius(), mStyle.radius(), paint);
        } else {
            canvas.drawCircle(shapeSize / 2f, shapeSize / 2f, shapeSize / 2f, paint);
        }
        canvas.restoreToCount(saveCount);
        if (mStyle.textColor() != 0) {
            paint.setColor(mStyle.textColor());
        } else {
            paint.setColor(oldColor);
        }
        if (mStyle.isBold()) {
             paint.setFakeBoldText(true);
        }
        float textHeight = paint.descent() - paint.ascent();
        float offsetY = (lineHeight - textHeight) / 2;
        float startX = SPACE + x + (shapeSize - textW) / 2;
        canvas.drawText(mIndexSequence, startX, y - offsetY, paint);
        paint.setTextSize(oldSize);
        paint.setColor(oldColor);
        paint.setFakeBoldText(oldBold);
    }
}
