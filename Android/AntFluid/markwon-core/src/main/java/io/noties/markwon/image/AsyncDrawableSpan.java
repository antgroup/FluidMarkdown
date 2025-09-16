
package io.noties.markwon.image;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.Spanned;
import android.text.style.LineHeightSpan;
import android.text.style.ReplacementSpan;
import android.util.Log;
import android.widget.TextView;

import androidx.annotation.IntDef;
import androidx.annotation.IntRange;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

import io.noties.markwon.core.MarkwonTheme;

import com.fluid.afm.func.IImageClickCallback;
import com.fluid.afm.span.IClickableSpan;
import io.noties.markwon.core.spans.TextViewSpan;
import io.noties.markwon.utils.SpanUtils;

@SuppressWarnings("WeakerAccess")
public class AsyncDrawableSpan extends ReplacementSpan implements LineHeightSpan, IClickableSpan {

    @Override
    public String getLiteral() {
        return IClickableSpan.super.getLiteral();
    }

    @IntDef({ALIGN_BOTTOM, ALIGN_BASELINE, ALIGN_CENTER, ALIGN_TEXT_BOTTOM})
    @Retention(RetentionPolicy.SOURCE)
    @interface Alignment {
    }

    public static final String TAG = "AsyncDrawableSpan";
    public static final int ALIGN_BOTTOM = 0;
    public static final int ALIGN_BASELINE = 1;
    public static final int ALIGN_CENTER = 2; // will only center if drawable height is less than text line height
    public static final int ALIGN_TEXT_BOTTOM = 3;

    private final MarkwonTheme theme;
    private final AsyncDrawable drawable;
    private final int alignment;
    private final boolean replacementTextIsLink;
    private int mTop;
    private int mBottom;
    private boolean clickable = true;
    private IImageClickCallback mClickCallback;
    private String imageDescription;
    public AsyncDrawableSpan(
            @NonNull MarkwonTheme theme,
            @NonNull AsyncDrawable drawable,
            @Alignment int alignment,
            boolean replacementTextIsLink,
            IImageClickCallback clickCallback) {
        this.theme = theme;
        this.drawable = drawable;
        this.alignment = alignment;
        this.replacementTextIsLink = replacementTextIsLink;
        mClickCallback = clickCallback;
        Log.d(TAG, "this.replacementTextIsLink = " + this.replacementTextIsLink);
        // @since 4.2.1 we do not set intrinsic bounds
        //  at this point they will always be 0,0-1,1, but this
        //  will trigger another invalidation when we will have bounds
    }

    public AsyncDrawableSpan(
            @NonNull MarkwonTheme theme,
            @NonNull AsyncDrawable drawable,
            @Alignment int alignment,
            boolean replacementTextIsLink, boolean clickable) {
        this.theme = theme;
        this.drawable = drawable;
        this.alignment = alignment;
        this.replacementTextIsLink = replacementTextIsLink;
        this.clickable = clickable;
        Log.d(TAG, "this.replacementTextIsLink = " + this.replacementTextIsLink);
        // @since 4.2.1 we do not set intrinsic bounds
        //  at this point they will always be 0,0-1,1, but this
        //  will trigger another invalidation when we will have bounds
    }

    @Override
    public String getUrl() {
        return clickable && drawable != null ? drawable.getDestination() : "";
    }

    @Override
    public String getType() {
        return clickable ? "image" : "";
    }

    @Override
    public int getTop() {
        return mTop;
    }

    @Override
    public int getBottom() {
        return mBottom;
    }

    public void click() {
        if (clickable && mClickCallback != null) {
            mClickCallback.imageClicked(drawable.getDestination(), imageDescription);
        }
    }

    public boolean isClickable() {
        return clickable;
    }

    @Override
    public int getSize(
            @NonNull Paint paint,
            CharSequence text,
            @IntRange(from = 0) int start,
            @IntRange(from = 0) int end,
            @Nullable Paint.FontMetricsInt fm) {

        // if we have no async drawable result - we will just render text
        final int size;
        if (drawable.hasResult()) {

            final Rect rect = drawable.getBounds();

            if (fm != null) {
                fm.ascent = -rect.bottom;
                fm.descent = 0;

                fm.top = fm.ascent;
                fm.bottom = 0;
            }

            size = rect.right;

        } else {

            // we will apply style here in case if theme modifies textSize or style (affects metrics)
            if (replacementTextIsLink) {
                theme.applyLinkStyle(paint);
            }

            // NB, no specific text handling (no new lines, etc)
            size = (int) (paint.measureText(text, start, end) + .5F);
        }

        return size;
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end, int spanstartv, int lineHeight, Paint.FontMetricsInt fm) {
        if (fm == null) {
            return;
        }
        if (!drawable.hasResult()) {
            return;
        }
        if (!SpanUtils.isSelf(start, end, text, this)) {
            return;
        }
        int drawableLineHeight = drawable.getBounds().height() + theme.getParagraphBreakHeight();
        if (text instanceof Spanned) {
            final Spanned spanned = (Spanned) text;
            final TextView textView = TextViewSpan.textViewOf(spanned);
            if (textView != null) {
                float multiplier = textView.getLineSpacingMultiplier();
                if (multiplier > 0) {
                    drawableLineHeight = (int) (drawableLineHeight / multiplier);
                }
            }
        }
        final int originHeight = fm.descent - fm.ascent;
        if (originHeight <= 0) {
            return;
        }
        final float ratio = drawableLineHeight * 1.0f / originHeight;
        fm.descent = Math.round(fm.descent * ratio);
        fm.ascent = fm.descent - drawableLineHeight;
    }

    @Override
    public void draw(
            @NonNull Canvas canvas,
            CharSequence text,
            @IntRange(from = 0) int start,
            @IntRange(from = 0) int end,
            float x,
            int top,
            int y,
            int bottom,
            @NonNull Paint paint) {

        // @since 4.4.0 use SpanUtils instead of `canvas.getWidth`
        drawable.initWithKnownDimensions(
                SpanUtils.width(canvas, text),
                paint.getTextSize()
        );

        final AsyncDrawable drawable = this.drawable;

        if (drawable.hasResult()) {

            final int b = bottom - drawable.getBounds().bottom;
            final int save = canvas.save();
            try {
                int translationY;
                if (ALIGN_CENTER == alignment) {
                    translationY = (top - paint.getFontMetricsInt().bottom * 2) + ((paint.getFontMetricsInt().bottom * 4 + bottom - top - drawable.getBounds().height()) / 2);
                } else if (ALIGN_BASELINE == alignment) {
                    translationY = b - paint.getFontMetricsInt().bottom;
                } else if (ALIGN_TEXT_BOTTOM == alignment) {
                    final int textHeight = paint.getFontMetricsInt().bottom - paint.getFontMetricsInt().top;
                    final int lineHeight = bottom - top;
                    final int paddingBottom = lineHeight - textHeight;
                    final int calibrate = 5;
                    translationY = b - paddingBottom + calibrate;
                } else {
                    translationY = b;
                }
                canvas.translate(x, translationY);
                drawable.draw(canvas);
                mTop = translationY;
                mBottom = translationY + drawable.getBounds().height();
            } finally {
                canvas.restoreToCount(save);
            }
        } else {
            // will it make sense to have additional background/borders for an image replacement?
            // let's focus on main functionality and then think of it

            final float textY = textCenterY(top, bottom, paint);
            if (replacementTextIsLink) {
                theme.applyLinkStyle(paint);
            }

            // NB, no specific text handling (no new lines, etc)
            canvas.drawText(text, start, end, x, textY, paint);
        }
        imageDescription = text.subSequence(start, end).toString();
    }

    @NonNull
    public AsyncDrawable getDrawable() {
        return drawable;
    }

    private static float textCenterY(int top, int bottom, @NonNull Paint paint) {
        // @since 1.1.1 it's `top +` and not `bottom -`
        return (int) (top + ((bottom - top) / 2) - ((paint.descent() + paint.ascent()) / 2.F + .5F));
    }
}