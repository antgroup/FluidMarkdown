package com.fluid.afm.span;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.style.ReplacementSpan;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fluid.afm.icon.DrawableWrapper;
import com.fluid.afm.icon.LoadIconUtil;
import com.fluid.afm.icon.LoadImageCallback;
import com.fluid.afm.styles.LinkStyle;
import com.fluid.afm.utils.Utils;

import io.noties.markwon.core.MarkwonTheme;

public class LinkWithIconSpan extends ReplacementSpan {

    private LinkStyle mStyle;
    private final MarkwonTheme mMarkwonTheme;
    protected float mIconTop;
    protected float mIconStart;
    protected float mRealTextSize;

    protected DrawableWrapper mDrawableWrapper;

    private LoadImageCallback mLoadImageCallback;

    public LinkWithIconSpan(@NonNull MarkwonTheme theme) {
        mMarkwonTheme = theme;
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, @Nullable Paint.FontMetricsInt fm) {
        applyStyle(paint);
        int size = (int) (paint.measureText(text, start, end) + .5F);
        if (mStyle != null && !TextUtils.isEmpty(mStyle.icon())) {
            mIconStart = size + mStyle.space();
            return (int) (mIconStart + mRealTextSize);
        }
        return size;
    }

    private void applyStyle(Paint paint) {
        mStyle = mMarkwonTheme.getLinkStyles();
        if (paint instanceof TextPaint) {
            mMarkwonTheme.applyLinkStyle((TextPaint) paint, 0, false, null);
        } else {
            mMarkwonTheme.applyLinkStyle(paint);
        }
        mRealTextSize = paint.getTextSize();
        mIconTop = mRealTextSize * Utils.FONT_HEIGHT_IN_LINE;
        fetchImage();
    }

    private void fetchImage() {
        if (mMarkwonTheme.getTextView() == null) {
            return;
        }
        if (mDrawableWrapper == null) {
            int size = (int) mRealTextSize;
            mDrawableWrapper = LoadIconUtil.getIcon(mStyle.icon(), size, size);
        }
        if (mDrawableWrapper.getDrawable() == null) {
            if (mLoadImageCallback == null) {
                mLoadImageCallback = new LoadImageCallback(mMarkwonTheme.getTextView());
            }
            mDrawableWrapper.load(mMarkwonTheme.getTextView().getContext(), mLoadImageCallback);
        }
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        applyStyle(paint);
        canvas.drawText(text, start, end, x, y, paint);
        if (mDrawableWrapper != null && mDrawableWrapper.getDrawable() != null) {
            canvas.save();
            canvas.translate(x + mIconStart, y - mIconTop);
            mDrawableWrapper.getDrawable().draw(canvas);
            canvas.restore();
        }
    }
}
