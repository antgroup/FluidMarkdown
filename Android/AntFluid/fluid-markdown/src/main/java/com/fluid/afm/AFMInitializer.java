package com.fluid.afm;

import android.content.Context;

import androidx.annotation.Nullable;

import com.fluid.afm.handler.BackgroundTaskHandler;
import com.fluid.afm.handler.EventHandlerManager;
import com.fluid.afm.handler.ImageHandler;
import com.fluid.afm.handler.LogHandler;

public class AFMInitializer {
    public static void init(Context context,
                            @Nullable BackgroundTaskHandler backgroundTaskHandler,
                            @Nullable ImageHandler imageHandler,
                            @Nullable LogHandler logHandler) {
        ContextHolder.setContext(context);
        EventHandlerManager.setLogHandler(logHandler);
        EventHandlerManager.setBackgroundTaskHandler(backgroundTaskHandler);
        EventHandlerManager.setImageHandler(imageHandler);
    }
}
