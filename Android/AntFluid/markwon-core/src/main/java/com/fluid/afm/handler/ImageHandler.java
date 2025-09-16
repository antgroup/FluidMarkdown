package com.fluid.afm.handler;

import android.content.Context;
import android.graphics.drawable.Drawable;

import com.fluid.afm.func.Callback;

public interface ImageHandler {
    void loadImage(Context context, String url, final Callback<Drawable> callback);

    void loadImage(Context context, String url, int width, int height, final Callback<Drawable> callback);

    Drawable loadImageSync(Context context, String url);

    public Drawable loadImageSync(Context context, String raw, int width, int height);

}
