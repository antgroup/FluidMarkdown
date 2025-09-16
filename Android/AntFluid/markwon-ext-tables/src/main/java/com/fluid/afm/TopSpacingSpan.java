package com.fluid.afm;

import android.graphics.Paint;
import android.text.Spanned;
import android.text.style.LineHeightSpan;

public class TopSpacingSpan implements LineHeightSpan {

    private final int height;

    public TopSpacingSpan(int height) {
        this.height = height;
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end,
                             int spanstartv,
                             int v, Paint.FontMetricsInt fm) {
        if (selfStart(start, text, this)) {
            fm.top -= height;
            fm.ascent -= height;
        }
    }

    protected boolean selfStart(int start, CharSequence text, Object span) {
        // this is some kind of interesting magic here... only the last
        // span will receive correct _end_ argument, but previous spans
        // receive it tilted by one (1). Most likely it's just a new-line character... and
        // if needed we could check for that
        final int spanStart = ((Spanned) text).getSpanStart(span);
        return spanStart == start;
    }
}
