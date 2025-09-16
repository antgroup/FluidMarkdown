package com.fluid.afm.markdown.html;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.Layout;
import android.text.style.LeadingMarginSpan;

public class CustomIndentSpan implements LeadingMarginSpan {
    private final int indent;
    private final int firstLineIndent;

    public CustomIndentSpan(int indent) {
        this.indent = indent;
        this.firstLineIndent = indent;
    }
    public CustomIndentSpan(int indent, int firstLineIndent) {
        this.indent = indent;
        this.firstLineIndent = firstLineIndent;
    }


    @Override
    public int getLeadingMargin(boolean first) {
        return first ? firstLineIndent : indent;
    }

    @Override
    public void drawLeadingMargin(Canvas c, Paint p, int x, int dir, int top, int baseline, int bottom, CharSequence text, int start, int end, boolean first, Layout layout) {
    }
}
