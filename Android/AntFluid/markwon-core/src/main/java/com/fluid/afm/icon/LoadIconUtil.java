package com.fluid.afm.icon;

import com.fluid.afm.utils.MDLogger;

import java.lang.ref.Reference;
import java.lang.ref.ReferenceQueue;
import java.lang.ref.WeakReference;
import java.util.concurrent.ConcurrentHashMap;

public class LoadIconUtil {

    public static final ConcurrentHashMap<DrawableWrapper.Data, WeakReference<DrawableWrapper>> CACHE = new ConcurrentHashMap<>();
    public static final ReferenceQueue<DrawableWrapper> QUEUE = new ReferenceQueue<>();

    public static DrawableWrapper getIcon(String url, int width, int height) {
        DrawableWrapper.Data data = new DrawableWrapper.Data(url, width, height, false);
        WeakReference<DrawableWrapper> cache = CACHE.get(data);
        DrawableWrapper drawableWrapper = cache == null ? null : cache.get();
        if (drawableWrapper == null) {
            drawableWrapper = new DrawableWrapper(data);
            cache = new WeakReference<>(drawableWrapper, QUEUE);
            CACHE.put(data, cache);
        }
        check();
        return drawableWrapper;
    }

    public static DrawableWrapper getIcon(String url, int width, int height, boolean round) {
        DrawableWrapper.Data data = new DrawableWrapper.Data(url, width, height, round);
        WeakReference<DrawableWrapper> cache = CACHE.get(data);
        DrawableWrapper drawableWrapper = cache == null ? null : cache.get();
        if (drawableWrapper == null) {
            drawableWrapper = new DrawableWrapper(data);
            cache = new WeakReference<>(drawableWrapper, QUEUE);
            CACHE.put(data, cache);
        }
        check();
        return drawableWrapper;
    }

    public static void check() {
        MDLogger.d("IconLink", " CACHE check: size:" + CACHE.size());
        Reference<? extends DrawableWrapper> wrapper;
        while ((wrapper = QUEUE.poll()) != null) {
            if (wrapper.get() != null) {
                MDLogger.d("IconLink", " CACHE released");
                CACHE.remove(wrapper.get().mData);
            }
        }
    }
}
