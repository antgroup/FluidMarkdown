package com.fluid.afm.span;

import android.graphics.Paint;
import android.text.Spanned;
import android.text.style.LineHeightSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Px;

import com.fluid.afm.utils.Utils;

/**
 * @since 4.0.0
 */
public class ParagraphSpacingSpan implements LineHeightSpan {

    @NonNull
    public static ParagraphSpacingSpan create(@Px int spacing) {
        return new ParagraphSpacingSpan(spacing);
    }

    private int spacing;

    public ParagraphSpacingSpan(@Px int spacing) {
        this.spacing = spacing;
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end, int spanstartv, int v, Paint.FontMetricsInt fm) {
        if (selfEnd(end, text, this)) {
            final int originHeight = fm.descent - fm.ascent;
            // If original height is not positive, do nothing.
            if (originHeight <= 0) {
                return;
            }
            int realSpacing = (int) (0.5f + spacing - originHeight * Utils.FONT_SPACING_IN_LINE);
            final float ratio = realSpacing * 1.0f / originHeight;
            fm.descent = Math.round(fm.descent * ratio);
            fm.ascent = fm.descent - spacing;
        }
    }

    private static boolean selfEnd(int end, CharSequence text, Object span) {
        // this is some kind of interesting magic here... only the last
        // span will receive correct _end_ argument, but previous spans
        // receive it tilted by one (1). Most likely it's just a new-line character... and
        // if needed we could check for that
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanEnd == end || spanEnd == end - 1;
    }


}
