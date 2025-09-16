package io.noties.markwon.utils;

import android.graphics.Canvas;
import android.text.Layout;
import android.text.Spanned;
import android.widget.TextView;

import androidx.annotation.NonNull;

import io.noties.markwon.core.spans.TextLayoutSpan;
import io.noties.markwon.core.spans.TextViewSpan;

/**
 * @since 4.4.0
 */
public abstract class SpanUtils {

    public static int width(Canvas canvas, @NonNull CharSequence cs) {
        // Layout
        // TextView
        // canvas
        if (cs instanceof Spanned) {
            final Spanned spanned = (Spanned) cs;

            // if we are displayed with layout information -> use it
            final Layout layout = TextLayoutSpan.layoutOf(spanned);
            if (layout != null) {
                return layout.getWidth();
            }

            // if we have TextView -> obtain width from it (exclude padding)
            final TextView textView = TextViewSpan.textViewOf(spanned);
            if (textView != null) {
                return textView.getWidth() - textView.getPaddingLeft() - textView.getPaddingRight();
            }
        }
        // else just use canvas width
        if (canvas != null) {
            return canvas.getWidth();
        }
        return 0;
    }

    public static boolean isSelfEnd(int end, CharSequence text, Object span) {
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanEnd == end || spanEnd == end - 1;
    }

    public static boolean isSelfStart(int start, CharSequence text, Object span) {
        final int spanStart = ((Spanned) text).getSpanStart(span);
        return spanStart == start;
    }

    public static boolean isSelf(int start, int end, CharSequence text, Object span) {
        final int spanStart = ((Spanned) text).getSpanStart(span);
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanStart <= start && spanEnd >= end - 1;
    }
}
