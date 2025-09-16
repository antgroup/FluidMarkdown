package com.fluid.afm.span;

import android.graphics.Paint;
import android.text.Spanned;
import android.text.style.LineHeightSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Px;

/**
 * @since 4.0.0
 */
public class HeadingTopOrBottomSpacingSpan implements LineHeightSpan {

    @NonNull
    public static HeadingTopOrBottomSpacingSpan create(@Px int spacing) {
        return new HeadingTopOrBottomSpacingSpan(spacing);
    }

    private int spacing;

    public HeadingTopOrBottomSpacingSpan(@Px int spacing) {
        this.spacing = spacing;
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end, int spanstartv, int v, Paint.FontMetricsInt fm) {
        if (selfEnd(end, text, this)) {
            // let's just add what we want

            final int originHeight = fm.descent - fm.ascent;
            // If original height is not positive, do nothing.
            if (originHeight <= 0) {
                return;
            }
            final float ratio = spacing * 1.0f / originHeight;
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
