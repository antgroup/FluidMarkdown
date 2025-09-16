package com.fluid.afm.utils;

import com.fluid.afm.handler.EventHandlerManager;

public class MDLogger {
    private static final String PREFIX_TAG = "markdown";

    public static void i(String tag, String msg) {
        EventHandlerManager.getLogHandler().i(PREFIX_TAG, tag + ":" + msg);
    }

    public static void e(String tag, String msg) {
        EventHandlerManager.getLogHandler().e(PREFIX_TAG, tag + ":" + msg);
    }

    public static void e(String tag, Throwable tr) {
        EventHandlerManager.getLogHandler().e(PREFIX_TAG, tag + ":",  tr);
    }

    public static void e(String tag, String msg, Throwable tr) {
        EventHandlerManager.getLogHandler().e(PREFIX_TAG, tag + ":" + msg + ":", tr);
    }

    public static void d(String tag, String msg) {
        EventHandlerManager.getLogHandler().d(PREFIX_TAG, tag + ":" + msg);
    }

    public static void v(String tag, String msg) {
        EventHandlerManager.getLogHandler().v(PREFIX_TAG, tag + ":" + msg);
    }

    public static void w(String tag, String msg) {
        EventHandlerManager.getLogHandler().w(PREFIX_TAG, tag + ":" + msg);
    }

    public static void w(String tag, Throwable tr) {
        EventHandlerManager.getLogHandler().w(PREFIX_TAG, tag + ":" + tr);
    }

}
