package com.fluid.afm.spans;

import android.graphics.Typeface;
import android.text.Layout;
import android.text.style.LeadingMarginSpan;
import android.text.style.StyleSpan;


public class DefinitionListSpan implements LeadingMarginSpan {
    private static final int MARGIN = 24; // dp

    @Override
    public int getLeadingMargin(boolean first) {
        return MARGIN;
    }

    @Override
    public void drawLeadingMargin(android.graphics.Canvas canvas, android.graphics.Paint paint,
                                 int x, int dir, int top, int baseline, int bottom,
                                 CharSequence text, int start, int end, boolean first,
                                 Layout layout) {
    }

    public static class TermSpan extends StyleSpan {
        public TermSpan() {
            super(Typeface.BOLD);
        }
    }


    public static class DescriptionSpan implements LeadingMarginSpan {
        private static final int DESCRIPTION_MARGIN = 48; // dp

        @Override
        public int getLeadingMargin(boolean first) {
            return DESCRIPTION_MARGIN;
        }

        @Override
        public void drawLeadingMargin(android.graphics.Canvas canvas, android.graphics.Paint paint,
                                     int x, int dir, int top, int baseline, int bottom,
                                     CharSequence text, int start, int end, boolean first,
                                     Layout layout) {
        }
    }
} 