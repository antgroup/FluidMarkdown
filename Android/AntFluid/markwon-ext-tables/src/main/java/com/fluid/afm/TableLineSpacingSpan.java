package com.fluid.afm;

import android.graphics.Paint;
import android.text.style.LineHeightSpan;

public class TableLineSpacingSpan implements LineHeightSpan {
    private final int reducedLineHeight;

    private final boolean header;

    public TableLineSpacingSpan(boolean header, int reducedLineHeight) {
        this.header = header;
        this.reducedLineHeight = reducedLineHeight;
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end,
                             int spanstartv,
                             int v, Paint.FontMetricsInt fm) {

    }
}
