package com.fluid.afm.handler;

public class EventHandlerManager {
    private static BackgroundTaskHandler sBackgroundTaskHandler;
    private static LogHandler sLogHandler;
    private static ImageHandler sImageHandler;

    public static BackgroundTaskHandler getBackgroundTaskHandler() {
        if (sBackgroundTaskHandler != null) {
           return sBackgroundTaskHandler;
        }
        return TaskHandlerInstanceHolder.INSTANCE;
    }

    public static void setBackgroundTaskHandler(BackgroundTaskHandler backgroundTaskHandler) {
        sBackgroundTaskHandler = backgroundTaskHandler;
    }

    public static LogHandler getLogHandler() {
        if (sLogHandler != null) {
            return sLogHandler;
        }
        return LogHandlerInstanceHolder.INSTANCE;
    }

    public static void setLogHandler(LogHandler logHandler) {
        sLogHandler = logHandler;
    }

    public static ImageHandler getImageHandler() {
        if (sImageHandler != null) {
            return sImageHandler;
        }
        return ImageHandlerInstanceHolder.INSTANCE;
    }

    public static void setImageHandler(ImageHandler imageHandler) {
        sImageHandler = imageHandler;
    }


    private static class TaskHandlerInstanceHolder {
        private static final BackgroundTaskHandler INSTANCE = new DefaultTaskHandler();
    }

    private static class LogHandlerInstanceHolder {
        private static final LogHandler INSTANCE = new DefaultLogHandler();
    }

    private static class ImageHandlerInstanceHolder {
        private static final DefualtImageHandler INSTANCE = new DefualtImageHandler();
    }

}
