package com.fluid.afm.utils;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.drawable.Drawable;
import android.os.Handler;
import android.os.Looper;
import android.util.DisplayMetrics;
import android.view.View;

import androidx.annotation.NonNull;

import com.fluid.afm.ContextHolder;
import com.fluid.afm.handler.EventHandlerManager;

import org.commonmark.node.Node;

import java.util.concurrent.ThreadPoolExecutor;

import com.fluid.afm.func.Callback;

public class Utils {

    private static final String TAG = "Utils";
    public static final float FONT_HEIGHT_IN_LINE = 8f / 9f;
    public static final float FONT_SPACING_IN_LINE = 1f / 9f;

    private static final Handler MAIN_HANDLER = new Handler(Looper.getMainLooper());

    private static Integer screenWidth = null;
    private static Integer screenHeight = null;

    public static int dpToPx(float dp) {
        return dpToPx(ContextHolder.getContext(), dp);
    }

    public static int dpToPx(Context context, float dp) {
        if (context != null) {
            float density = context.getResources().getDisplayMetrics().density;
            return Math.round(dp * density);
        }
        MDLogger.i(TAG, "dpToPx context == null, return dp*2");
        return Math.round(dp * 2);
    }

    public static float rpxToPx(float rpx) {
        return rpxToPx(rpx, ContextHolder.getContext());
    }

    public static float rpxToPx(float rpx, Context context) {
        DisplayMetrics metrics = context.getResources().getDisplayMetrics();
        float screenWidth = metrics.widthPixels;
        return rpx * (screenWidth / 750f);
    }

    public static boolean isNumeric(String str) {
        return str != null && str.matches("[0-9]+");
    }

    public static boolean runOnUiThread(View view, Runnable runnable) {
        if (runnable == null) {
            return false;
        }

        try {
            if (Thread.currentThread().getId() == Looper.getMainLooper().getThread().getId()) {
                runnable.run();
            } else if (view != null) {
                view.post(runnable);
            } else {
                MAIN_HANDLER.post(runnable);
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    public static Drawable loadImageSync(Context context, String url, Drawable defaultDrawable) throws InterruptedException {
        Drawable drawable = EventHandlerManager.getImageHandler().loadImageSync(context, url);
        return drawable == null ? defaultDrawable : drawable;
    }
    public static Drawable loadImageSync(Context context, String url, int width, int height, Drawable defaultDrawable) throws InterruptedException {
        Drawable drawable = EventHandlerManager.getImageHandler().loadImageSync(context, url, width, height);
        return drawable == null ? defaultDrawable : drawable;
    }

    public static int getScreenWidth() {
        return getScreenWidth(ContextHolder.getContext());
    }

    public static int getScreenWidth(Context context) {
        if (screenWidth == null) {
            screenWidth = context.getResources().getDisplayMetrics().widthPixels;
        }
        return screenWidth;
    }

    public static int getScreenHeight() {
        return getScreenHeight(ContextHolder.getContext());
    }

    public static int getScreenHeight(Context context) {
        if (screenHeight == null) {
            screenHeight = context.getResources().getDisplayMetrics().heightPixels;
        }
        return screenHeight;
    }

    public static ThreadPoolExecutor acquireNormalThreadPoolExecutor() {
        return EventHandlerManager.getBackgroundTaskHandler().acquireNormalThreadPoolExecutor();
    }

    public static float getDensity(Context context) {
        if (context != null) {
            return context.getResources().getDisplayMetrics().density;
        }
        return 3;
    }

    public static void loadImageAsyn(Context context, final String url, final Callback<Drawable> callback) {
        EventHandlerManager.getImageHandler().loadImage(context, url, callback);
    }

    public static void loadImageAsyn(Context context, final String url, int width, int height, final Callback<Drawable> callback) {
        EventHandlerManager.getImageHandler().loadImage(context, url, width, height, callback);
    }

    public static Resources getResources() {
        return ContextHolder.getContext().getResources();
    }

    public static boolean isInTableNode(@NonNull Node node) {
        return isInTableNode(node, 0);
    }
    private static boolean isInTableNode(@NonNull Node node, int depth) {
        final Node parent = node.getParent();
        if (parent != null && parent.getClass().getSimpleName().equals("TableCell")) {
            return true;
        } else if (parent != null && depth < 5) {
            return isInTableNode(parent, depth + 1);
        }
        return false;
    }
}
