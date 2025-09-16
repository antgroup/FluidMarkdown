package com.fluid.afm.icon;

import android.graphics.drawable.Drawable;
import android.os.Looper;
import android.widget.TextView;

import java.lang.ref.WeakReference;

import com.fluid.afm.func.Callback;

public class LoadImageCallback implements Callback<Drawable> {
    private final WeakReference<TextView> mReference;

    public LoadImageCallback(TextView textView) {
        mReference = new WeakReference<>(textView);
    }

    @Override
    public void onSuccess(Drawable drawable) {
        if(mReference.get() != null) {
            TextView textView = mReference.get();
            if (Looper.myLooper() == Looper.getMainLooper()) {
                // textView.invalidate() 不足以触发 Span 的重绘
                textView.setText(textView.getText());
            } else {
                textView.postInvalidate();
            }
        }
        LoadIconUtil.check();
    }

    @Override
    public void onFail() {
        LoadIconUtil.check();
    }
}
