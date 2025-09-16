package com.fluid.afm.handler;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;

import java.io.BufferedInputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import com.fluid.afm.ContextHolder;
import com.fluid.afm.func.Callback;

public class DefualtImageHandler implements ImageHandler {
    @Override
    public void loadImage(Context context, String url, final Callback<Drawable> callback) {
        EventHandlerManager.getBackgroundTaskHandler().execute(() -> {
            Drawable drawable = loadImageSync(context, url);
            if (drawable != null) {
                callback.onSuccess(drawable);
            } else {
                callback.onFail();
            }
        });
    }

    @Override
    public void loadImage(Context context, String url, int width, int height, Callback<Drawable> callback) {
        EventHandlerManager.getBackgroundTaskHandler().execute(() -> {
            Drawable drawable;
            if (width > 0 && height > 0) {
                drawable = loadImageSync(context, url, width, height);
            } else {
                drawable = loadImageSync(context, url);
            }
            if (drawable != null) {
                callback.onSuccess(drawable);
            } else {
                callback.onFail();
            }
        });
    }

    @Override
    public Drawable loadImageSync(Context context, String raw) {
        try {
            final URL url = new URL(raw);
            final HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.connect();
            final int responseCode = connection.getResponseCode();
            if (responseCode >= 200 && responseCode < 300) {
                final InputStream inputStream = new BufferedInputStream(connection.getInputStream());
                final Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
                return new BitmapDrawable(ContextHolder.getContext().getResources(), bitmap);
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public Drawable loadImageSync(Context context, String raw, int width, int height) {
        try {
            final URL url = new URL(raw);
            final HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.connect();
            final int responseCode = connection.getResponseCode();
            if (responseCode >= 200 && responseCode < 300) {
                final InputStream inputStream = new BufferedInputStream(connection.getInputStream());
                Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
                if (width > 0 && height > 0 && (bitmap.getWidth() != width || bitmap.getHeight() != height)) {
                    int imgWidth = bitmap.getWidth();
                    int imgHeight = bitmap.getHeight();
                    float scale = Math.max((float) height / imgHeight, (float) width / imgWidth);
                    int newWidth = Math.round(imgWidth * scale);
                    int newHeight = Math.round(imgHeight * scale);
                    Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true);
                    int xCrop = (newWidth - width) / 2;
                    int yCrop = (newHeight - height) / 2;
                    bitmap = Bitmap.createBitmap(scaledBitmap, xCrop, yCrop, width, height);
                }
                return new BitmapDrawable(ContextHolder.getContext().getResources(), bitmap);
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
        return null;
    }

}
