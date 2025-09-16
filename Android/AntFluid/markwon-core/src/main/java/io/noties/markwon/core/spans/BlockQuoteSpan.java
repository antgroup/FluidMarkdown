package io.noties.markwon.core.spans;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.text.Layout;
import android.text.Spanned;
import android.text.style.LeadingMarginSpan;

import androidx.annotation.NonNull;

import com.fluid.afm.styles.BlockQuoteStyle;

import io.noties.markwon.core.MarkwonTheme;

public class BlockQuoteSpan implements LeadingMarginSpan {

    private final MarkwonTheme theme;
    private final Rect rect = ObjectsPool.rect();
    private final Paint paint = ObjectsPool.paint();

    private int mLineWidth;
    private int mSpace;
    private int mLineCornerRadius;
    private int mLineColor;
    private int mBottomDistance;

    public BlockQuoteSpan(@NonNull MarkwonTheme theme) {
        this.theme = theme;
        applyStyles();
    }

    private void applyStyles() {
        BlockQuoteStyle blockQuoteStyle = theme.blockQuoteStyle();
        mLineWidth = blockQuoteStyle.lineWidth();
        mSpace = blockQuoteStyle.lineMargin() + blockQuoteStyle.lineWidth() + blockQuoteStyle.leftMargin();
        mLineCornerRadius = blockQuoteStyle.lineCornerRadius();
        mLineColor = blockQuoteStyle.lineColor();
        mBottomDistance = blockQuoteStyle.bottomMargin();
    }

    @Override
    public int getLeadingMargin(boolean first) {
        return mSpace;
    }

    @Override
    public void drawLeadingMargin(
            Canvas c,
            Paint p,
            int x,
            int dir,
            int top,
            int baseline,
            int bottom,
            CharSequence text,
            int start,
            int end,
            boolean first,
            Layout layout) {

        final int width = mLineWidth;
        paint.set(p);
        if (mLineColor != 0) {
            paint.setColor(mLineColor);
        } else {
            theme.applyBlockQuoteStyle(paint);
        }

        final int l = x + theme.blockQuoteStyle().leftMargin();
        final int r = l + (dir * width);
        final int left = Math.min(l, r);
        final int right = Math.max(l, r);

        if (selfEnd(end, text, this)) {
            rect.set(left, top, right, Math.max(bottom - theme.getParagraphBreakHeight() + mBottomDistance, top));
        } else if (bottom > top){
            rect.set(left, top, right, bottom);
        }

        // get span start/end
        final Spanned spanned = (Spanned) text;
        final int spanStart = spanned.getSpanStart(this);
        final int spanEnd = spanned.getSpanEnd(this);

        // is first/last line
        boolean isFirstLine = layout.getLineForOffset(start) == layout.getLineForOffset(spanStart);
        boolean isLastLine = layout.getLineForOffset(end) == layout.getLineForOffset(spanEnd);

        RectF rectF = new android.graphics.RectF(
                rect.left, rect.top, rect.right, rect.bottom
        );
        paint.setAlpha((int) (0.6f * 255));
        if (mLineCornerRadius > 0 && (isFirstLine || isLastLine)) {
            int save = c.save();
            if (isFirstLine) {
                c.clipRect(rectF);
                c.drawRoundRect(rectF.left, rectF.top, rectF.right, rectF.bottom + mLineCornerRadius, mLineCornerRadius, mLineCornerRadius, paint);
            } else { // last line
                if (rectF.bottom < rectF.top) {
                    rectF.set(rectF.left, rectF.top, rectF.right, rectF.top + mLineCornerRadius);
                }
                c.clipRect(rectF);
                c.drawRoundRect(rectF.left, rectF.top - mLineCornerRadius, rectF.right, rectF.bottom, mLineCornerRadius, mLineCornerRadius, paint);
            }
            c.restoreToCount(save);
        } else {
            c.drawRect(rectF, paint);
        }
    }

    private static boolean selfEnd(int end, CharSequence text, Object span) {
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanEnd == end || spanEnd == end - 1;
    }

}
