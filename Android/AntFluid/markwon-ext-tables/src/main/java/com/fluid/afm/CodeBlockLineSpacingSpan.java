package com.fluid.afm;

import android.graphics.Paint;
import android.text.Spanned;

public class CodeBlockLineSpacingSpan extends TopSpacingSpan {
    private final int reducedLineHeight;
    private final int firstLastLineReducedHeight;

    public CodeBlockLineSpacingSpan(int topLineSpacingHeight, int reducedLineHeight) {
        super(topLineSpacingHeight);
        this.reducedLineHeight = reducedLineHeight;
        this.firstLastLineReducedHeight = (int) ((reducedLineHeight - 0.5f) * 6);
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end,
                             int spanstartv,
                             int v, Paint.FontMetricsInt fm) {
        super.chooseHeight(text, start, end, spanstartv, v, fm);
        fm.ascent += (reducedLineHeight / 2);
        fm.descent -= (reducedLineHeight / 2);

        if (selfStart(start, text, this)) {
            fm.top += firstLastLineReducedHeight;
            fm.ascent += firstLastLineReducedHeight;
        } else if (selfEnd(start, text, this)) {
            fm.bottom -= firstLastLineReducedHeight;
            fm.descent -= firstLastLineReducedHeight;
        }
    }

    private boolean selfEnd(int end, CharSequence text, Object span) {
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanEnd == end || spanEnd == end - 1;
    }
}
