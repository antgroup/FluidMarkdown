package com.fluid.afm.markdown.html;

import android.text.TextPaint;
import android.text.style.URLSpan;
import android.view.View;

import androidx.annotation.NonNull;

import com.fluid.afm.markdown.ElementClickEventCallback;
import com.fluid.afm.utils.MDLogger;

public class SpanTextClickableSpan extends URLSpan {
    private static final String TAG = SpanTextClickableSpan.class.getSimpleName();

    private final ClickableTextType clickableTextType;
    private final String url;
    private final String entityId;
    private final ElementClickEventCallback mElementClickEventCallback;

    public SpanTextClickableSpan(ClickableTextType type, String url, String entityId, ElementClickEventCallback clickedInterface) {
        super(url);
        this.clickableTextType = type;
        this.url = url;
        this.entityId = entityId;
        mElementClickEventCallback = clickedInterface;
    }

    @Override
    public void updateDrawState(TextPaint ds) {
        ds.setColor(ds.linkColor);
        ds.setUnderlineText(false);
    }

    @Override
    public void onClick(@NonNull View widget) {
        MDLogger.d(TAG, "onClick...type:" + clickableTextType
                + ",entityId=" + entityId
                + ",url=" + url);
        if (mElementClickEventCallback != null && mElementClickEventCallback.onTextClickableSpanClicked(widget, url, entityId, clickableTextType)) {
            return;
        }
        super.onClick(widget);
    }

    public enum ClickableTextType {

        TYPE_POI,

        TYPE_RELATED_ENTITY
    }
}
