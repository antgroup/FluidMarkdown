package com.fluid.afm.handler;

import java.util.concurrent.ThreadPoolExecutor;

public interface BackgroundTaskHandler {
    void execute(Runnable runnable);
    ThreadPoolExecutor acquireNormalThreadPoolExecutor();
}
