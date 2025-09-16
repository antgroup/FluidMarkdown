package com.fluid.afm.markdown.iconlink;

import android.graphics.Color;
import android.text.TextPaint;
import android.text.TextUtils;
import android.text.style.URLSpan;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fluid.afm.markdown.ElementClickEventCallback;
import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.ParseUtil;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;

import io.noties.markwon.MarkwonVisitor;
import io.noties.markwon.SpannableBuilder;
import io.noties.markwon.html.CssInlineStyleParser;
import io.noties.markwon.html.CssProperty;
import io.noties.markwon.html.HtmlTag;
import io.noties.markwon.html.MarkwonHtmlRenderer;
import io.noties.markwon.html.TagHandler;

public class IconLinkSpanHandler extends TagHandler {
    private final TextView mTextView;
    private final ElementClickEventCallback mnClickLCallback;

    public IconLinkSpanHandler(TextView textView, @Nullable ElementClickEventCallback onClickLCallback2) {
        mTextView = textView;
        mnClickLCallback = onClickLCallback2;
    }

    @Override
    public void handle(MarkwonVisitor visitor, MarkwonHtmlRenderer renderer, HtmlTag tag) {
        final String style = tag.attributes().get("style");
        int textColor = 0;
        int bgColor = 0;
        float fontSize = 0;
        if (!TextUtils.isEmpty(style)) {
            for (CssProperty property : CssInlineStyleParser.create().parse(style)) {
                switch (property.key()) {
                    case "color":
                        textColor = ParseUtil.parseColorWithRGBA(property.value());
                        break;
                    case "font-size":
                        fontSize = ParseUtil.parseDp(mTextView.getContext(), property.value(), 0);
                        break;
                    case "background-color":
                        bgColor = ParseUtil.parseColorWithRGBA(property.value());
                        break;
                    default:
                        MDLogger.i("unexpected CSS property: %s", property.key());
                }
            }
        }

        final String src = tag.attributes().get("src");
        final String link = tag.attributes().get("link");
        final String destination = visitor.configuration().imageDestinationProcessor().process(src);
        IconLinkSpan iconSpan = new IconLinkSpan(mTextView, destination,
                bgColor, textColor, fontSize, link);
        if (!TextUtils.isEmpty(link)) {
            URLSpan clickableSpan = new URLSpan(link) {
                @Override
                public void onClick(@NonNull View widget) {
                    boolean result = false;
                    if (mnClickLCallback != null) {
                        HashMap<String, Object> param = new HashMap<>(2);
                        param.put(ElementClickEventCallback.PARAM_KEY_LINK, link);
                        param.put(ElementClickEventCallback.PARAM_KEY_SOURCE, ElementClickEventCallback.SOURCE_TYPE_ICON_LINK);
                        result = mnClickLCallback.onLinkClicked(param);
                    }
                    if (!result) {
                        super.onClick(widget);
                    }
                }
                @Override
                public void updateDrawState(TextPaint ds) {
                    ds.bgColor = Color.TRANSPARENT;
                    ds.setUnderlineText(false);
                }
            };
            SpannableBuilder.setSpans(visitor.builder(), new Object[]{iconSpan, clickableSpan}, tag.start(), tag.end());
        } else {
            SpannableBuilder.setSpans(visitor.builder(), new Object[]{iconSpan}, tag.start(), tag.end());
        }

    }

    @Override
    public Collection<String> supportedTags() {
        return Collections.singleton("iconlink");
    }
}
