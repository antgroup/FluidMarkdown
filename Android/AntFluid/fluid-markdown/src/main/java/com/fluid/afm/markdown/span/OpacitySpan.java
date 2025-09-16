package com.fluid.afm.markdown.span;

import android.text.TextPaint;
import android.text.style.CharacterStyle;
import android.text.style.UpdateAppearance;

public class OpacitySpan extends CharacterStyle
        implements UpdateAppearance {

    private final int opacity;

    public OpacitySpan(int opacity) {
        this.opacity = opacity;
    }

    @Override
    public void updateDrawState(TextPaint tp) {
        tp.setAlpha(opacity);
    }
}
