package com.fluid.afm.markdown.html;

import android.content.Context;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fluid.afm.utils.MDLogger;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.RenderProps;
import io.noties.markwon.html.CssInlineStyleParser;
import io.noties.markwon.html.CssProperty;
import io.noties.markwon.html.HtmlTag;
import io.noties.markwon.html.tag.SimpleTagHandler;
import com.fluid.afm.utils.Utils;

public class HtmlParaTagHandler extends SimpleTagHandler {
    private static final String TAG = "HtmlParaTagHandler";

    private static final String ATTRIBUTE_INDENT = "indent";
    private static final String ATTRIBUTE_FIRST_LINE_INDENT = "first-line-indent";
    private final Context context;

    public HtmlParaTagHandler(Context context) {
        this.context = context;
    }

    @Nullable
    @Override
    public Object getSpans(@androidx.annotation.NonNull MarkwonConfiguration configuration, @androidx.annotation.NonNull RenderProps renderProps, @androidx.annotation.NonNull HtmlTag tag) {
        try {
            final String style = tag.attributes().get("style");

            if (!TextUtils.isEmpty(style)) {
                int indent = -1;
                int firstLineIndent = -1;

                for (CssProperty property : CssInlineStyleParser.create().parse(style)) {
                    switch (property.key()) {
                        case ATTRIBUTE_INDENT:
                            String indentValue = property.value();
                            if (indentValue.endsWith("rpx")) {
                                String rpxValue = indentValue.substring(0, indentValue.length() - 3);
                                indent = (int) Utils.rpxToPx(Float.parseFloat(rpxValue), context);
                            } else if (indentValue.endsWith("dp")) {
                                String dpValue = indentValue.substring(0, indentValue.length() - 2);
                                indent = Utils.dpToPx(context, Float.parseFloat(dpValue));
                            } else if (indentValue.endsWith("px")) {
                                String pxValue = indentValue.substring(0, indentValue.length() - 2);
                                indent = Integer.parseInt(pxValue);
                            } else {
                                MDLogger.i(TAG, "Unexpected unit: key=" + property.key() + ", value=" + indentValue);
                            }
                            break;
                        case ATTRIBUTE_FIRST_LINE_INDENT:
                            String firstLineValue = property.value();
                            if (firstLineValue.endsWith("rpx")) {
                                String rpxValue = firstLineValue.substring(0, firstLineValue.length() - 3);
                                firstLineIndent = (int) Utils.rpxToPx(Float.parseFloat(rpxValue), context);
                            } else if (firstLineValue.endsWith("dp")) {
                                String dpValue = firstLineValue.substring(0, firstLineValue.length() - 2);
                                firstLineIndent = Utils.dpToPx(context, Float.parseFloat(dpValue));
                            } else if (firstLineValue.endsWith("px")) {
                                String pxValue = firstLineValue.substring(0, firstLineValue.length() - 2);
                                firstLineIndent = Integer.parseInt(pxValue);
                            } else {
                                MDLogger.i(TAG, "Unexpected unit: key=" + property.key() + ", value=" + firstLineValue);
                            }
                            break;
                        default:
                            MDLogger.i(TAG, "Unexpected CSS property: key=" + property.key());
                    }
                }

                MDLogger.d(TAG, "handleSpans: style=" + style + ", indent=" + indent);

                final List<Object> spans = new ArrayList<>(3);
                if (indent >= 0 && firstLineIndent >= 0) {
                    spans.add(new CustomIndentSpan(indent, firstLineIndent));
                } else if (indent >= 0) {
                    spans.add(new CustomIndentSpan(indent));
                }

                return spans.toArray();
            }
        } catch (Exception e) {
            MDLogger.e(TAG, "handleSpans error: " + e.getMessage());
        }

        return null;
    }

    @NonNull
    @Override
    public Collection<String> supportedTags() {
        return Collections.singleton("para");
    }
}
