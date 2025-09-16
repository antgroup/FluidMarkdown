package com.fluid.afm.handler;

public interface LogHandler {
    void i(String tag, String msg);
    void e(String tag, String msg);
    void e(String tag, Throwable tr);
    void e(String tag, String msg, Throwable tr);
    void d(String tag, String msg);
    void v(String tag, String msg);
    void w(String tag, String msg);
    void w(String tag, Throwable tr);
}
