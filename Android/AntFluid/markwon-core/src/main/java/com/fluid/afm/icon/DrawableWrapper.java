package com.fluid.afm.icon;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import androidx.core.graphics.drawable.RoundedBitmapDrawable;
import androidx.core.graphics.drawable.RoundedBitmapDrawableFactory;

import com.fluid.afm.utils.MDLogger;

import java.lang.ref.WeakReference;
import java.util.Objects;
import java.util.concurrent.ConcurrentHashMap;

import com.fluid.afm.utils.Utils;
import com.fluid.afm.func.Callback;

public class DrawableWrapper {
    private static final String TAG = "DrawableWrapper";
    public Data mData;
    private boolean isLoaded;
    private Drawable mDrawable;

    private final ConcurrentHashMap<Integer, LoadImageCallback> mCallbackMaps = new ConcurrentHashMap<>();

    public DrawableWrapper(Data data) {
        mData = data;
    }

    public Drawable getDrawable() {
        return mDrawable;
    }

    public void load(Context context, LoadImageCallback callback) {
        if (isLoaded) {
            if (mDrawable != null) {
                callback.onSuccess(mDrawable);
                return;
            }
            mCallbackMaps.put(callback.hashCode(), callback);
            return;
        }
        mCallbackMaps.put(callback.hashCode(), callback);
        isLoaded = true;
        Utils.loadImageAsyn(context, mData.url, mData.width, mData.height, new IconCallback(this));
    }

    public void onLoadSuccess(Drawable drawable) {
        if (drawable == null) {
            onLoadFailed();
            return;
        }
        MDLogger.i(TAG, "load success. url=" + mData.url);

        try {
            if (drawable instanceof BitmapDrawable && ((BitmapDrawable) drawable).getBitmap() != null) {
                Bitmap bm = ((BitmapDrawable) drawable).getBitmap();
                RoundedBitmapDrawable roundDrawable = RoundedBitmapDrawableFactory.create(null, bm);
                roundDrawable.setCornerRadius(mData.round ? bm.getWidth() / 2f : 0);
                roundDrawable.setBounds(0, 0, bm.getWidth(), bm.getHeight());
                mDrawable = roundDrawable;
            } else {
                mDrawable = drawable;
            }
        } catch (Throwable e) { // 本地包： java.lang.NoClassDefFoundError: Failed resolution of: Landroid/support/v4/graphics/drawable/RoundedBitmapDrawableFactory;兼容一下
            MDLogger.e(TAG, e);
            mDrawable = drawable;
        }
        for (LoadImageCallback callback : mCallbackMaps.values()) {
            callback.onSuccess(drawable);
        }
    }

    public void onLoadFailed() {
        isLoaded = false;
        MDLogger.e("DrawableWrapper", "load failed. url=" + mData.url);
    }

    public void cancel(LoadImageCallback callback) {
        if (callback != null) {
            mCallbackMaps.remove(callback.hashCode());
        }
        LoadIconUtil.check();
    }

    public static class Data {
        public String url;

        public int width, height;
        public boolean round;

        public Data(String url, int width, int height, boolean round) {
            this.url = url;
            this.width = width;
            this.height = height;
            this.round = round;
        }

        @Override
        public boolean equals(Object object) {
            if (this == object) return true;
            if (!(object instanceof Data)) return false;
            Data data = (Data) object;
            return width == data.width && height == data.height && Objects.equals(url, data.url) && round == data.round;
        }

        @Override
        public int hashCode() {
            return Objects.hash(url, width, height);
        }
    }

    private static class IconCallback implements Callback<Drawable> {
        WeakReference<DrawableWrapper> mReference;

        public IconCallback(DrawableWrapper drawableWrapper) {
            mReference = new WeakReference<>(drawableWrapper, LoadIconUtil.QUEUE);
        }

        @Override
        public void onSuccess(Drawable drawable) {
            if (mReference.get() != null) {
                mReference.get().onLoadSuccess(drawable);
            }
        }

        @Override
        public void onFail() {
            if (mReference.get() != null) {
                mReference.get().onLoadFailed();
            }
        }
    }
}
