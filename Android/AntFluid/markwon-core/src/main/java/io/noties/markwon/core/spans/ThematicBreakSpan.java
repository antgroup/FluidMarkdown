package io.noties.markwon.core.spans;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.Layout;
import android.text.Spanned;
import android.text.style.LeadingMarginSpan;
import android.text.style.LineHeightSpan;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.styles.HorizonRuleStyle;

import io.noties.markwon.core.MarkwonTheme;

public class ThematicBreakSpan implements LeadingMarginSpan, LineHeightSpan {

    private final MarkwonTheme theme;
    private final Rect rect = ObjectsPool.rect();
    private final Paint paint = ObjectsPool.paint();
    private HorizonRuleStyle mStyle;
    private  float textViewMultiplier = 1.0f;

    public ThematicBreakSpan(@NonNull MarkwonTheme theme) {
        this.theme = theme;
        mStyle = theme.getHorizonRule();
    }

    @Override
    public int getLeadingMargin(boolean first) {
        return 0;
    }

    @Override
    public void drawLeadingMargin(Canvas c, Paint p, int x, int dir, int top, int baseline, int bottom, CharSequence text, int start, int end, boolean first, Layout layout) {
        int lineTop;
        if (mStyle.paragraph().paragraphSpacing() <= 0 && mStyle.paragraphSpacingBefore() <= 0) {
            lineTop = top + ((bottom - top) / 2) - mStyle.getHeight() / 2;
        } else if (mStyle.paragraphSpacingBefore() > 0) {
            lineTop = (int) (top + mStyle.paragraphSpacingBefore() / textViewMultiplier);
        } else {
            lineTop = bottom - mStyle.paragraph().paragraphSpacing();
        }

        paint.set(p);
        if (mStyle.getColor() == 0 || mStyle.getHeight() < 0) {
            theme.applyThematicBreakStyle(paint);
        } else {
            mStyle.apply(paint);
        }

        final int height = (int) (paint.getStrokeWidth() + .5F);

        final int left;
        final int right;
        if (dir > 0) {
            left = x;
            right = c.getWidth();
        } else {
            left = x - c.getWidth();
            right = x;
        }

        rect.set(left, lineTop, right, lineTop + height);
        c.drawRect(rect, paint);
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end, int spanstartv, int lh, Paint.FontMetricsInt fm) {
        if (mStyle != null && (mStyle.paragraph().paragraphSpacing() > 0 || mStyle.paragraphSpacingBefore() > 0 || mStyle.getHeight() > 3) && selfStart(start, text, this)) {
            int lineHeight = (fm.descent - fm.ascent);
            int targetHeight = mStyle.paragraph().paragraphSpacing() + mStyle.paragraphSpacingBefore() + mStyle.getHeight();
            if (text instanceof Spanned) {
                final Spanned spanned = (Spanned) text;
                final TextView textView = TextViewSpan.textViewOf(spanned);
                if (textView != null) {
                    float multiplier = textView.getLineSpacingMultiplier();
                    if (multiplier > 0) {
                        targetHeight = (int) (targetHeight / multiplier);
                        textViewMultiplier = multiplier;
                    }
                }
            }
            final float ratio = targetHeight * 1.0f / lineHeight;
            fm.descent = Math.round(fm.descent * ratio);
            fm.ascent = fm.descent - targetHeight;
        }
    }

    private static boolean selfStart(int start, CharSequence text, Object span) {
        final int spanStart = ((Spanned) text).getSpanStart(span);
        return spanStart == start;
    }

}
