package com.fluid.afm;

import android.text.Layout;
import android.text.Spannable;
import android.text.method.LinkMovementMethod;
import android.text.method.MovementMethod;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.MDLogger;

import io.noties.markwon.image.AsyncDrawableSpan;

/**
 * @since 4.6.0
 */
public class MarkdownAwareMovementMethod implements MovementMethod {
    private static final String TAG = MarkdownAwareMovementMethod.class.getSimpleName();

    @NonNull
    public static MarkdownAwareMovementMethod wrap(@NonNull MovementMethod movementMethod) {
        return new MarkdownAwareMovementMethod(movementMethod);
    }

    /**
     * Wraps LinkMovementMethod
     */
    @NonNull
    public static MarkdownAwareMovementMethod create() {
        return new MarkdownAwareMovementMethod(LinkMovementMethod.getInstance());
    }

    public static boolean handleCodeBlockTouchEvent(
            @NonNull TextView widget,
            @NonNull Spannable buffer,
            @NonNull MotionEvent event) {
        // handle only action up (originally action down is used in order to handle selection,
        //  which tables do no have)
        if (event.getAction() != MotionEvent.ACTION_UP) {
            return false;
        }

        int x = (int) event.getX();
        int y = (int) event.getY();
        x -= widget.getTotalPaddingLeft();
        y -= widget.getTotalPaddingTop();
        x += widget.getScrollX();
        y += widget.getScrollY();

        final Layout layout = widget.getLayout();
        final int line = layout.getLineForVertical(y);
        final int off = layout.getOffsetForHorizontal(line, x);

        final CodeBlockTitleSpan[] spans = buffer.getSpans(off, off, CodeBlockTitleSpan.class);
        if (spans.length == 0) {
            return false;
        }

        return spans[0].handleClickEvent(widget, buffer, x, y);
    }

    public static boolean handleTableRowTouchEvent(
            @NonNull TextView widget,
            @NonNull Spannable buffer,
            @NonNull MotionEvent event) {
        // handle only action up (originally action down is used in order to handle selection,
        //  which tables do no have)
        if (event.getAction() != MotionEvent.ACTION_UP) {
            return false;
        }

        int x = (int) event.getX();
        int y = (int) event.getY();
        x -= widget.getTotalPaddingLeft();
        y -= widget.getTotalPaddingTop();
        x += widget.getScrollX();
        y += widget.getScrollY();

        final Layout layout = widget.getLayout();
        final int line = layout.getLineForVertical(y);
        final int off = layout.getOffsetForHorizontal(line, x);

        final TableBlockTitleBlockSpan[] spans = buffer.getSpans(off, off, TableBlockTitleBlockSpan.class);
        if (spans.length == 0) {
            return false;
        }

        MDLogger.d(TAG, "handleTableRowTouchEvent length:" + spans.length
                + ",line:" + line
                + ",off:" + off
                + ",x:" + x + ",y:" + y);

        return spans[0].handleClickEvent(widget, buffer, x, y);
    }

    private final MovementMethod wrapped;

    public MarkdownAwareMovementMethod(@NonNull MovementMethod wrapped) {
        this.wrapped = wrapped;
    }

    @Override
    public void initialize(TextView widget, Spannable text) {
        wrapped.initialize(widget, text);
    }

    @Override
    public boolean onKeyDown(TextView widget, Spannable text, int keyCode, KeyEvent event) {
        return wrapped.onKeyDown(widget, text, keyCode, event);
    }

    @Override
    public boolean onKeyUp(TextView widget, Spannable text, int keyCode, KeyEvent event) {
        return wrapped.onKeyUp(widget, text, keyCode, event);
    }

    @Override
    public boolean onKeyOther(TextView view, Spannable text, KeyEvent event) {
        return wrapped.onKeyOther(view, text, event);
    }

    @Override
    public void onTakeFocus(TextView widget, Spannable text, int direction) {
        wrapped.onTakeFocus(widget, text, direction);
    }

    @Override
    public boolean onTrackballEvent(TextView widget, Spannable text, MotionEvent event) {
        return wrapped.onTrackballEvent(widget, text, event);
    }

    @Override
    public boolean onTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
        // let wrapped handle first, then if super handles nothing, search for table row spans
        return wrapped.onTouchEvent(widget, buffer, event)
                || handleTableRowTouchEvent(widget, buffer, event)
                || handleCodeBlockTouchEvent(widget, buffer, event)
                || handleImageTouchEvent(widget, buffer, event);
    }

    private boolean handleImageTouchEvent(TextView widget, Spannable buffer, MotionEvent event) {
        if (event.getAction() != MotionEvent.ACTION_UP) {
            return false;
        }

        int x = (int) event.getX();
        int y = (int) event.getY();
        x -= widget.getTotalPaddingLeft();
        y -= widget.getTotalPaddingTop();
        x += widget.getScrollX();
        y += widget.getScrollY();

        final Layout layout = widget.getLayout();
        final int line = layout.getLineForVertical(y);
        final int off = layout.getOffsetForHorizontal(line, x);

        final AsyncDrawableSpan[] spans = buffer.getSpans(off, off, AsyncDrawableSpan.class);
        if (spans.length == 0) {
            return false;
        }
        for (AsyncDrawableSpan span : spans) {
            if (span.getTop() <= y && span.getBottom() >= y) {
                span.click();
            }
        }

        return false;
    }

    @Override
    public boolean onGenericMotionEvent(TextView widget, Spannable text, MotionEvent event) {
        return wrapped.onGenericMotionEvent(widget, text, event);
    }

    @Override
    public boolean canSelectArbitrarily() {
        return wrapped.canSelectArbitrarily();
    }
}
