package com.fluid.afm.markdown.iconlink;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.text.TextPaint;
import android.text.style.LineHeightSpan;
import android.text.style.ReplacementSpan;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.icon.DrawableWrapper;
import com.fluid.afm.icon.LoadIconUtil;
import com.fluid.afm.icon.LoadImageCallback;
import com.fluid.afm.span.IClickableSpan;
import com.fluid.afm.utils.Utils;

import io.noties.markwon.utils.SpanUtils;
public class IconLinkSpan extends ReplacementSpan implements LineHeightSpan, View.OnAttachStateChangeListener, IClickableSpan {

    private static final int _10_6DP = Utils.dpToPx(10.67f);
    private static final int _1_5DP = Utils.dpToPx(1.5f);
    private static final int _3DP = Utils.dpToPx(3f);
    private static final int RIGHT_PADDING = _3DP;
    private static final int LEFT_PADDING = _1_5DP;
    private static final int ICON_DISTANCE = _1_5DP;
    private static final int CORNER_RADIUS = _10_6DP;
    private static final int LEFT_RIGHT_MARGIN = _1_5DP;
    private static final float VERTICAL_PADDING_RATIO = 0.2f;
    private int mLineHeight = 0;
    private DrawableWrapper mDrawableWrapper;
    private final TextView mTextView;
    private final Path mPath = new Path();
    private boolean mFetched = false;
    private final int mBackgroundColor;
    private final int mTextColor;
    private final float mFontSize;
    private float mIconSize;
    private final String mSrcUrl;
    private int mInnerLineHeight;
    private final Rect mBgRect = new Rect();
    private LoadImageCallback mLoadImageCallback;
    private final String mLink;
    private int mTop;
    private int mBottom;
    public IconLinkSpan(TextView textView, String imageUrl, int backgroundColor, int textColor, float fontSize, String link) {
        mTextView = textView;
        mFontSize = fontSize;
        mBackgroundColor = backgroundColor;
        mTextColor = textColor;
        mSrcUrl = imageUrl;
        mLink = link;
        textView.addOnAttachStateChangeListener(this);
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, Paint.FontMetricsInt fm) {
        if (mLineHeight == 0) {
            mLineHeight = (int) (paint.getFontMetrics().descent - paint.getFontMetrics().ascent);
        }
        float oldSize = paint.getTextSize();

        if (mFontSize > 0) {
            paint.setTextSize(mFontSize);
            mInnerLineHeight = (int) (paint.getFontMetrics().descent - paint.getFontMetrics().ascent);
        } else {
            mInnerLineHeight = mLineHeight;
        }

        mIconSize = mInnerLineHeight * 1.05f;
        if (!mFetched) {
            mFetched = true;
            fetchImage((int) mIconSize);
        } else if (mDrawableWrapper.getDrawable() != null) {
            Rect imgBounds = mDrawableWrapper.getDrawable().getBounds();
            mIconSize = imgBounds.width();
        }
        float textW = paint.measureText(text, start, end);
        int size = (int) (textW + LEFT_RIGHT_MARGIN + mIconSize + LEFT_RIGHT_MARGIN + ICON_DISTANCE);
        if (mBackgroundColor != 0) {
            int paddingV = (int) (mInnerLineHeight * VERTICAL_PADDING_RATIO);
            int bgW = (int) (LEFT_PADDING + RIGHT_PADDING + textW + mIconSize + ICON_DISTANCE);
            size = bgW + LEFT_RIGHT_MARGIN + LEFT_RIGHT_MARGIN;
            mBgRect.set(0, 0, bgW, mInnerLineHeight + paddingV + paddingV);
        }
        if (mFontSize > 0) {
            paint.setTextSize(oldSize);
        }

        return size;
    }

    private void fetchImage(int size) {
        mDrawableWrapper = LoadIconUtil.getIcon(mSrcUrl, size, size, true);
        if (mDrawableWrapper.getDrawable() == null) {
            if (mLoadImageCallback == null) {
                mLoadImageCallback = new LoadImageCallback(mTextView);
            }
            mDrawableWrapper.load(mTextView.getContext(), mLoadImageCallback);
        }
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        mTop = top;
        mBottom = y;
        int originalColor = paint.getColor();
        float finalX = x + LEFT_RIGHT_MARGIN;
        mPath.reset();
        if (mFontSize > 0) {
            paint.setTextSize(mFontSize);
        }
        Paint.Style oldStyle = paint.getStyle();
        float rectTop = y + mInnerLineHeight * 1f / 9f - mIconSize;
        // draw background
        if (mBackgroundColor != 0) {
            paint.setColor(mBackgroundColor);
            paint.setStyle(Paint.Style.FILL);
            int vp = (int) ((mBgRect.height() - mInnerLineHeight) / 2f);
            mPath.addRoundRect(finalX, rectTop - vp,
                    finalX + mBgRect.width(),
                    rectTop  + mBgRect.height(),
                    CORNER_RADIUS, CORNER_RADIUS, Path.Direction.CW);
            canvas.drawPath(mPath, paint);
            paint.setStyle(oldStyle);
            finalX += LEFT_PADDING;
        }
        // draw icon
        if (mDrawableWrapper.getDrawable() != null) {
            canvas.save();
            canvas.translate(finalX, rectTop);
            mDrawableWrapper.getDrawable().draw(canvas);
            canvas.restore();
        }
        paint.setStyle(oldStyle);
        float oldSize = paint.getTextSize();
        if (mTextColor != 0) {
            paint.setColor(mTextColor);
        } else {
            paint.setColor(originalColor);
        }
        // draw text x: left-margin + left-padding + icon + spacing
        canvas.drawText(text, start, end, finalX + mIconSize + ICON_DISTANCE, y, paint);

        if (mTextColor != 0) {
            paint.setColor(originalColor);
        }
        if (mFontSize > 0) {
            paint.setTextSize(oldSize);
        }
    }

    @Override
    public void chooseHeight(CharSequence text, int start, int end, int spanstartv, int lineHeight, Paint.FontMetricsInt fm) {
        if (mBgRect.height() <= mLineHeight) {
            return;
        }
        if (fm == null) {
            return;
        }
        if (SpanUtils.isSelf(start, end, text, this)) { // adjust line height that contains the span
            if (mBgRect.height() > fm.bottom - fm.top) { // span height is higher than line height
                int delta = ((mBgRect.height() - (fm.bottom - fm.top))) / 2;
                fm.top -= delta;
                fm.bottom += delta;
                fm.ascent -= delta;
                fm.descent += delta;
            }
        }
    }

    @Override
    public void updateDrawState(TextPaint ds) {
        super.updateDrawState(ds);
    }

    @Override
    public void onViewAttachedToWindow(@NonNull View v) {
        /* no-op */
    }

    @Override
    public void onViewDetachedFromWindow(@NonNull View v) {
        if (mDrawableWrapper != null) {
            mDrawableWrapper.cancel(mLoadImageCallback);
        }
        mTextView.removeOnAttachStateChangeListener(this);
    }

    @Override
    public String getUrl() {
        return mLink;
    }

    @Override
    public String getType() {
        return "iconlink";
    }

    @Override
    public int getTop() {
        return mTop;
    }

    @Override
    public int getBottom() {
        return mBottom;
    }
}
