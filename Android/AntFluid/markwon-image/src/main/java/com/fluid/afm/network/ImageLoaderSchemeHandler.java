package com.fluid.afm.network;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.net.Uri;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.io.IOException;
import java.lang.ref.WeakReference;
import java.util.Arrays;
import java.util.Collection;

import io.noties.markwon.image.ImageItem;
import io.noties.markwon.image.SchemeHandler;
import com.fluid.afm.utils.Utils;

public class ImageLoaderSchemeHandler extends SchemeHandler {
    public static final String SCHEME_HTTP = "http";
    public static final String SCHEME_HTTPS = "https";
    private WeakReference<Context> mContextRef;

    @NonNull
    public static ImageLoaderSchemeHandler create(Context context) {
        return new ImageLoaderSchemeHandler(context);
    }

    @SuppressWarnings("WeakerAccess")
    ImageLoaderSchemeHandler(Context context) {
        mContextRef = new WeakReference<>(context);
    }

    @NonNull
    @Override
    public ImageItem handle(@NonNull String raw, @NonNull Uri uri, int width, int height) {

        final ImageItem imageItem;
        try {
            Context context = mContextRef.get();
            Drawable drawable = context == null ? null : Utils.loadImageSync(context, raw, width, height, null);
            if (drawable != null){
                imageItem = ImageItem.withResult(drawable);
            }else {
                throw new IOException("loadImageSync: null" + ", url: " + raw);
            }

        } catch (IOException | InterruptedException e) {
            throw new IllegalStateException("Exception obtaining network resource: " + raw, e);
        }

        return imageItem;
    }

    @NonNull
    @Override
    public Collection<String> supportedSchemes() {
        return Arrays.asList(SCHEME_HTTP, SCHEME_HTTPS);
    }

    @Nullable
    static String contentType(@Nullable String contentType) {

        if (contentType == null) {
            return null;
        }

        final int index = contentType.indexOf(';');
        if (index > -1) {
            return contentType.substring(0, index);
        }

        return contentType;
    }
}
