package com.fluid.afm;

import android.annotation.SuppressLint;
import android.content.Context;

public class ContextHolder {

    @SuppressLint("StaticFieldLeak")
    private static Context sContext;

    public static void setContext(Context context) {
        sContext = context.getApplicationContext();
    }

    public static Context getContext() {
        return sContext;
    }
}
