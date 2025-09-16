package com.fluid.afm.span;

import android.text.TextPaint;
import android.text.TextUtils;
import android.text.style.LeadingMarginSpan;
import android.text.style.MetricAffectingSpan;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.icon.DrawableWrapper;
import com.fluid.afm.icon.LoadIconUtil;
import com.fluid.afm.icon.LoadImageCallback;

public abstract class BaseIconTextSpan extends MetricAffectingSpan implements LeadingMarginSpan {


    protected TextView mTextView;

    protected int realTextSize;
    protected DrawableWrapper mDrawableWrapper;

    private LoadImageCallback mLoadImageCallback;
    protected float iconOffset;

    public BaseIconTextSpan(TextView textView) {
        mTextView = textView;
    }

    @Override
    public void updateMeasureState(@NonNull TextPaint textPaint) {
        handleStyle(textPaint);
    }

    @Override
    public void updateDrawState(TextPaint tp) {
        handleStyle(tp);
    }

    private void handleStyle(TextPaint paint) {
        applyStyle(paint);
        realTextSize = (int) (paint.getTextSize() + 0.5f);
        if (!TextUtils.isEmpty(getImageUrl())) {
            fetchImage();
        }
        iconOffset = getIconSize() * 8 / 9f;
    }
    private void fetchImage() {
        if (mTextView == null) {
            return;
        }
        if (mDrawableWrapper == null) {
            int size = getIconSize();
            mDrawableWrapper = LoadIconUtil.getIcon(getImageUrl(), size, size);
        }
        if (mDrawableWrapper.getDrawable() == null) {
            if (mLoadImageCallback == null) {
                mLoadImageCallback = new LoadImageCallback(mTextView);
            }
            mDrawableWrapper.load(mTextView.getContext(), mLoadImageCallback);
        }
    }


    protected abstract String getImageUrl();
    protected int getIconSize() {
        return realTextSize;
    }

    protected abstract void applyStyle(TextPaint paint);
}
