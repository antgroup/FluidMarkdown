package com.fluid.afm.handler;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.SynchronousQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class DefaultTaskHandler implements BackgroundTaskHandler{
    private final ExecutorService executor = Executors.newCachedThreadPool();

    @Override
    public void execute(Runnable runnable) {
        executor.submit(runnable);
    }

    @Override
    public ThreadPoolExecutor acquireNormalThreadPoolExecutor() {
        return new ThreadPoolExecutor(0, Integer.MAX_VALUE,
                60L, TimeUnit.SECONDS,
                new SynchronousQueue<>());
    }

}
