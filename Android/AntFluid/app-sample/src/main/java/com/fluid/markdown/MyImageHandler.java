package com.fluid.markdown;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.res.ResourcesCompat;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.bumptech.glide.request.target.SimpleTarget;
import com.bumptech.glide.request.transition.Transition;
import com.fluid.afm.handler.ImageHandler;

import com.fluid.afm.ContextHolder;
import com.fluid.afm.utils.Utils;
import com.fluid.afm.func.Callback;

public class MyImageHandler implements ImageHandler {
    @Override
    public void loadImage(Context context, String url, Callback<Drawable> callback) {
        if (url.startsWith("local://")) {
            Drawable drawable = loadDrawableResource(context, url, 0, 0);
            if (drawable != null) {
                callback.onSuccess(drawable);
            }
            return;
        }
        int defaultW = context.getResources().getDisplayMetrics().widthPixels - Utils.dpToPx(context, 24);
        Glide.with(context).load(url).apply(new RequestOptions().override(defaultW)).into(new SimpleTarget<Drawable>() {
            @Override
            public void onResourceReady(@NonNull Drawable resource, @Nullable Transition<? super Drawable> transition) {
                callback.onSuccess(resource);
            }
        });
    }

    private static Drawable loadDrawableResource(Context context, String url, int width, int height) {
        Uri uri = Uri.parse(url);
        String host = uri.getHost();
        String path = uri.getPathSegments().get(0);
        int resourceId = getResourceIdByName(context.getPackageName(), host, path);
        if (resourceId != 0) {
            Drawable drawable = ResourcesCompat.getDrawable(context.getResources(), resourceId, null);
            if (drawable instanceof BitmapDrawable
                    && width > 0 && height > 0
                    && (((BitmapDrawable) drawable).getBitmap().getWidth() != width ||((BitmapDrawable) drawable).getBitmap().getHeight() != height)) {
            Bitmap bitmap = ((BitmapDrawable) drawable).getBitmap();
                    int imgWidth = bitmap.getWidth();
                    int imgHeight = bitmap.getHeight();
                    float scale = Math.max((float) height / imgHeight, (float) width / imgWidth);
                    int newWidth = Math.round(imgWidth * scale);
                    int newHeight = Math.round(imgHeight * scale);
                    Bitmap scaledBitmap = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, true);
                    int xCrop = (newWidth - width) / 2;
                    int yCrop = (newHeight - height) / 2;
                    bitmap = Bitmap.createBitmap(scaledBitmap, xCrop, yCrop, width, height);
                return new BitmapDrawable(ContextHolder.getContext().getResources(), bitmap);
            }
            return drawable;
        }
        return null;
    }
    private static int getResourceIdByName(String packageName, String className, String name) {

        Class<?> r;
        int id = 0;
        try {
            r = Class.forName(packageName + ".R");
            Class<?>[] classes = r.getClasses();
            Class<?> desireClass = null;
            for (int i = 0; i < classes.length; i++) {
                if (classes[i].getName().split("\\$")[1].equals(className)) {
                    desireClass = classes[i];
                    break;
                }
            }
            if (desireClass != null) id = desireClass.getField(name).getInt(desireClass);
        } catch (ClassNotFoundException | IllegalAccessException | NoSuchFieldException | SecurityException | IllegalArgumentException e) {
            e.printStackTrace();
        }
        return id;
    }

    @Override
    public void loadImage(Context context, String url, int width, int height, Callback<Drawable> callback) {
        if (url.startsWith("local://")) {
            Drawable drawable = loadDrawableResource(context, url, width, height);
            if (drawable != null) {
                callback.onSuccess(drawable);
            }
            return;
        }
        Glide.with(context).load(url).apply(new RequestOptions().override(width, height)).into(new SimpleTarget<Drawable>() {
            @Override
            public void onResourceReady(@NonNull Drawable resource, @Nullable Transition<? super Drawable> transition) {
                callback.onSuccess(resource);
            }
        });
    }

    @Override
    public Drawable loadImageSync(Context context, String url) {
        if (url.startsWith("local://")) {
            return loadDrawableResource(context, url, 0, 0);
        }
        int defaultW = context.getResources().getDisplayMetrics().widthPixels - Utils.dpToPx(context, 24);
        try {
            return Glide.with(context).asDrawable().load(url).into(defaultW, defaultW).get();
        } catch (Throwable e) {
        }
        return null;
    }

    @Override
    public Drawable loadImageSync(Context context, String url, int width, int height) {
        if (url.startsWith("local://")) {
            return loadDrawableResource(context, url, width, height);
        }
        try {
            return Glide.with(context).asDrawable().load(url).into(width,  height).get();
        } catch (Throwable e) {
        }
        return null;
    }
}
