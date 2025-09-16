package com.fluid.afm.markdown.icon;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.TextUtils;
import android.text.style.ReplacementSpan;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.icon.DrawableWrapper;
import com.fluid.afm.icon.LoadIconUtil;
import com.fluid.afm.icon.LoadImageCallback;

import com.fluid.afm.utils.Utils;

public class IconSpan extends ReplacementSpan implements View.OnAttachStateChangeListener {
    private DrawableWrapper mDrawableWrapper;
    private final TextView mTextView;
    private LoadImageCallback mLoadImageCallback;
    private final String mSrc;
    protected float iconOffset;

    public IconSpan(TextView textView, String imageUrl) {
        mTextView = textView;
        mSrc = imageUrl;
        textView.addOnAttachStateChangeListener(this);
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, Paint.FontMetricsInt fm) {
        if (TextUtils.isEmpty(mSrc)) {
            return 0;
        }
        int textSize = (int) (paint.getFontMetrics().descent - paint.getFontMetrics().ascent + 0.5f);

        iconOffset = textSize * Utils.FONT_HEIGHT_IN_LINE;
        fetchImage(textSize);
        if (mDrawableWrapper.getDrawable() != null) {
            return mDrawableWrapper.getDrawable().getBounds().width();
        }
        return textSize;
    }

    private void fetchImage(int size) {
        mDrawableWrapper = LoadIconUtil.getIcon(mSrc, size, size, false);
        if (mDrawableWrapper.getDrawable() == null) {
            if (mLoadImageCallback == null) {
                mLoadImageCallback = new LoadImageCallback(mTextView);
            }
            mDrawableWrapper.load(mTextView.getContext(), mLoadImageCallback);
        }
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        // draw icon
        if (mDrawableWrapper.getDrawable() != null) {
            canvas.save();
            canvas.translate(x, y - Math.min(iconOffset, mDrawableWrapper.getDrawable().getBounds().height()));
            mDrawableWrapper.getDrawable().draw(canvas);
            canvas.restore();
        }
    }

    @Override
    public void onViewAttachedToWindow(View v) {
        /* no-op */
    }

    @Override
    public void onViewDetachedFromWindow(View v) {
        if (mDrawableWrapper != null) {
            mDrawableWrapper.cancel(mLoadImageCallback);
        }
        mTextView.removeOnAttachStateChangeListener(this);
    }

}
