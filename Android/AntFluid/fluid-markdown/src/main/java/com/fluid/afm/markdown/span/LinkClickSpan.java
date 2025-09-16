package com.fluid.afm.markdown.span;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.style.LineBackgroundSpan;
import android.text.style.URLSpan;
import android.view.View;

import androidx.annotation.NonNull;

import com.fluid.afm.markdown.ElementClickEventCallback;
import com.fluid.afm.utils.ParseUtil;

import java.util.HashMap;
import java.util.Map;

import io.noties.markwon.RenderProps;
import io.noties.markwon.core.CoreProps;
import io.noties.markwon.core.MarkwonTheme;
import com.fluid.afm.span.IClickableSpan;


public class LinkClickSpan extends URLSpan implements IClickableSpan, LineBackgroundSpan {
    private final MarkwonTheme theme;
    private final String link;
    private final ElementClickEventCallback linkClickCallback;
    private int mTop = -1;
    private int mBottom;
    private final String decoration;
    private final int color;
    private final boolean isBold;



    public LinkClickSpan(String url, RenderProps props, MarkwonTheme theme, ElementClickEventCallback linkClickCallback) {
        super(url);
        this.theme = theme;
        this.link = url;
        this.linkClickCallback = linkClickCallback;
        String colorStr = CoreProps.COLOR.get(props);
        color = ParseUtil.parseColor(colorStr, 0);
        String fontWeight = CoreProps.FONT_WEIGHT.get(props);
        isBold = TextUtils.equals("bold", fontWeight);
        decoration = CoreProps.LINK_TEXT_DECORATION.get(props);

    }

    @Override
    public void onClick(View widget) {
        if (linkClickCallback != null) {
            Map<String, Object> param = new HashMap<>(2);
            param.put(ElementClickEventCallback.PARAM_KEY_LINK, link);
            param.put(ElementClickEventCallback.PARAM_KEY_SOURCE, ElementClickEventCallback.SOURCE_TYPE_LINK);
            if (linkClickCallback.onLinkClicked(param)) {
                return;
            }
        }
        super.onClick(widget);
    }

    @Override
    public void updateDrawState(@NonNull TextPaint ds) {
        ds.bgColor = Color.TRANSPARENT;
        theme.applyLinkStyle(ds, color, isBold, decoration);
    }

    @Override
    public String getUrl() {
        return link;
    }

    @Override
    public String getType() {
        return "link";
    }

    @Override
    public int getTop() {
        return mTop;
    }

    @Override
    public int getBottom() {
        return mBottom;
    }

    @Override
    public void drawBackground(@NonNull Canvas canvas, @NonNull Paint paint, int left, int right, int top, int baseline, int bottom, @NonNull CharSequence text, int start, int end, int lineNumber) {
        if (mTop == -1) {
            mTop = top;
        }
        if (bottom > mBottom) {
            mBottom = bottom;
        }
    }
}
