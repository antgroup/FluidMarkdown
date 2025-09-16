package com.fluid.afm.handler;

import android.util.Log;

public class DefaultLogHandler implements LogHandler {

    public void i(String tag, String msg) {
        Log.i(tag, msg);
    }

    public void e(String tag, String msg) {
        Log.e(tag, msg);
    }

    public void e(String tag, Throwable tr) {
        Log.e(tag, tr.toString());
    }

    public void e(String tag, String msg, Throwable tr) {
        Log.e(tag, msg + ":", tr);
    }

    public void d(String tag, String msg) {
        Log.d(tag, msg);
    }

    public void v(String tag, String msg) {
        Log.v(tag, msg);
    }

    public void w(String tag, String msg) {
        Log.w(tag, msg);
    }

    public void w(String tag, Throwable tr) {
        Log.w(tag, tr);
    }

}
