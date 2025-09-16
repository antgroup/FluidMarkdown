package com.fluid.afm.markdown.html;

import android.graphics.Color;
import android.graphics.Typeface;
import android.text.TextUtils;
import android.text.style.BackgroundColorSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.ParseUtil;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.RenderProps;
import com.fluid.afm.span.AntUnderlineSupportMulLinesSpan;
import io.noties.markwon.html.CssInlineStyleParser;
import io.noties.markwon.html.CssProperty;
import io.noties.markwon.html.HtmlTag;
import io.noties.markwon.html.tag.SimpleTagHandler;

public class HtmlMarkTagHandler extends SimpleTagHandler {

    private static final String TAG = "HtmlMarkTagHandler";
    private int mBackgroundColor = 0xFFFFF2B3;
    private int backgroundHeight = 30;
    private String fontWeight = "normal";

    public HtmlMarkTagHandler() {
    }

    @Override
    public Object getSpans(@NonNull MarkwonConfiguration configuration, @NonNull RenderProps renderProps, @NonNull HtmlTag tag) {
        final String style = tag.attributes().get("style");
        final String classAttr = tag.attributes().get("class");
        if (!TextUtils.isEmpty(style)) {
            int color = 0;
            int backgroundColor = 0;

            for (CssProperty property : CssInlineStyleParser.create().parse(style)) {
                switch (property.key()) {
                    case "color":
                        color = ParseUtil.parseColor(property.value());
                        break;

                    case "background-color":
                        backgroundColor = ParseUtil.parseColor(property.value());
                        break;

                    default:
                        MDLogger.i("unexpected CSS property: %s", property.key());
                }
            }

            final List<Object> spans = new ArrayList<>(3);
            if (color != 0) {
                spans.add(new ForegroundColorSpan(color));
            }
            if (backgroundColor != 0) {
                spans.add(new BackgroundColorSpan(backgroundColor));
            }

            return spans.toArray();
        } else if (!TextUtils.isEmpty(classAttr)) {
            int color = 0;
            switch (classAttr) {

                case "markdown-green-color":
                case "down":
                    color = Color.parseColor("#0e9976");
                    break;

                case "markdown-red-color":
                case "up":
                    color = Color.parseColor("#e62c3b");
                    break;

                case "highlight":
                    String markTagStyles = "";
                    MDLogger.i(TAG, "mark---markTagStyles: " + markTagStyles);
                    try {
                        if (!TextUtils.isEmpty(markTagStyles)) {
                            JSONObject markTagStylesJson = new JSONObject(markTagStyles);
                            mBackgroundColor = ParseUtil.parseColor(markTagStylesJson.optString("backgroundColor"), mBackgroundColor);
                            backgroundHeight = ParseUtil.parseDp(markTagStylesJson.optString("backgroundHeight"), backgroundHeight);
                            String weight = markTagStylesJson.optString("fontWeight");
                            if (!TextUtils.isEmpty(weight)) {
                                fontWeight = weight;
                            }
                        }
                    } catch (Throwable e) {
                        MDLogger.e(TAG, "markTagStyles error: " + e.getMessage());
                    }
                    final List<Object> spans = new ArrayList<>();
                    if ("bold".equals(fontWeight)) {
                        StyleSpan boldSpan = new StyleSpan(Typeface.BOLD); // 加粗样式
                        spans.add(boldSpan);
                    }
                    spans.add(new AntUnderlineSupportMulLinesSpan(mBackgroundColor, backgroundHeight));
                    return spans.toArray();
            }
            final List<Object> spans = new ArrayList<>();
            if (color != 0) {
                spans.add(new ForegroundColorSpan(color));
                return spans.toArray();
            }
        } else {
            // 针对<mark>默认文本高亮</mark>样式默认处理
            final List<Object> spans = new ArrayList<>(1);
            spans.add(new TextHeightBackgroundSpan(mBackgroundColor));
            return spans.toArray();
        }

        return null;
    }

    @NonNull
    @Override
    public Collection<String> supportedTags() {
        return Collections.singleton("mark");
    }
}
