package com.fluid.afm.markdown.html;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.text.style.BackgroundColorSpan;
import android.text.style.ForegroundColorSpan;

import androidx.annotation.NonNull;
import androidx.appcompat.content.res.AppCompatResources;

import com.fluid.afm.R;
import com.fluid.afm.markdown.ElementClickEventCallback;
import com.fluid.afm.markdown.image.SuperscriptImageSpan;
import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.ParseUtil;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import io.noties.markwon.MarkwonVisitor;
import io.noties.markwon.SpannableBuilder;
import io.noties.markwon.html.CssInlineStyleParser;
import io.noties.markwon.html.CssProperty;
import io.noties.markwon.html.HtmlTag;
import io.noties.markwon.html.MarkwonHtmlRenderer;
import io.noties.markwon.html.TagHandler;
import com.fluid.afm.utils.Utils;

public class HtmlSpanTagHandler extends TagHandler {
    private static final String TAG = "HtmlSpanTagHandler";

    private static final String DEFAULT_POI_COLOR = "#0E489A";
    private static final String CLASS_POI = "poi";
    private static final String CLASS_RELATED_ENTITY = "related-entity";
    private static final String CLASS_VOICE_TEXT = "voicetext";
    private static final String ATTRIBUTE_COLOR = "color";
    private static final String ATTRIBUTE_BACKGROUND_COLOR = "background-color";
    private static final String CLASS_HIGHLIGHT = "highlight";

    private final Context context;
    private final ElementClickEventCallback mElementClickEventCallback;

    public HtmlSpanTagHandler(Context context, ElementClickEventCallback clickedInterface) {
        this.context = context;
        mElementClickEventCallback = clickedInterface;
    }

    private void handleInner(@NonNull MarkwonVisitor visitor,
                             @NonNull MarkwonHtmlRenderer renderer,
                             @NonNull HtmlTag tag) {
        if (tag.isBlock()) {
            visitChildren(visitor, renderer, tag.getAsBlock());
        }

        handleSpans(visitor, tag);
    }

    @Override
    public void handle(@NonNull MarkwonVisitor visitor,
                       @NonNull MarkwonHtmlRenderer renderer,
                       @NonNull HtmlTag tag) {
        handleInner(visitor, renderer, tag);
    }

    public void handleSpans(@NonNull MarkwonVisitor visitor,
                            @NonNull HtmlTag tag) {
        final String style = tag.attributes().get("style");
        final String classAttr = tag.attributes().get("class");

        if (!TextUtils.isEmpty(style)) {
            int color = 0;
            int backgroundColor = 0;

            for (CssProperty property : CssInlineStyleParser.create().parse(style)) {
                switch (property.key()) {
                    case ATTRIBUTE_COLOR:
                        color = ParseUtil.parseColor(property.value());
                        break;

                    case ATTRIBUTE_BACKGROUND_COLOR:
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

            SpannableBuilder.setSpans(visitor.builder(), spans.toArray(), tag.start(), tag.end());
        } else if (!TextUtils.isEmpty(classAttr)) {
            int color = 0;
            switch (classAttr) {
                case "markdown-green-color":
                    color = ParseUtil.parseColor("#0e9976");
                    break;

                case "markdown-red-color":
                    color = ParseUtil.parseColor("#e62c3b");
                    break;

                case CLASS_HIGHLIGHT:
                    final List<Object> spans = new ArrayList<>(2);
                    spans.add(new CustomUnderlineSpan(Color.parseColor("#521677FF"),
                            Utils.dpToPx(context, 11)));
                    SpannableBuilder.setSpans(visitor.builder(), spans.toArray(), tag.start(), tag.end());
                    return;
                case CLASS_POI:
                    setClassPoiSpans(visitor, tag);
                    return;
                case CLASS_RELATED_ENTITY:
                    setClassRelatedEntitySpans(visitor, tag);
                    return;

                case CLASS_VOICE_TEXT:
                    final List<Object> spansVoice = new ArrayList<>();
                    spansVoice.add(new ForegroundColorSpan(0xFF1A65FF));
                    spansVoice.add(new BackgroundColorSpan(0xFFF4F8FF));
                    SpannableBuilder.setSpans(visitor.builder(), spansVoice.toArray(), tag.start(), tag.end());
                    return;

            }

            final List<Object> spans = new ArrayList<>(2);
            if (color != 0) {
                spans.add(new ForegroundColorSpan(color));
                SpannableBuilder.setSpans(visitor.builder(), spans.toArray(), tag.start(), tag.end());
            }
        }
    }
    @NonNull
    @Override
    public Collection<String> supportedTags() {
        return Collections.singleton("span");
    }

    /**
     *  class="poi" span
     *
     */
    private void setClassPoiSpans(@NonNull MarkwonVisitor visitor, @NonNull HtmlTag tag) {
        int color;
        final List<Object> poiSpans = new ArrayList<>(3);
        final String colorAttr = tag.attributes().get(ATTRIBUTE_COLOR);
        if (TextUtils.isEmpty(colorAttr)) {
            // 默认色
            color = Color.parseColor(DEFAULT_POI_COLOR);
        } else {
            color = ParseUtil.parseColor(colorAttr);
        }
        poiSpans.add(new ForegroundColorSpan(color));

        final String hrefAttr = tag.attributes().get("href");
        poiSpans.add(new SpanTextClickableSpan(SpanTextClickableSpan.ClickableTextType.TYPE_POI,
                hrefAttr, null, mElementClickEventCallback));

        MDLogger.d(TAG, "poi color:" + color
                + ",start:" + tag.start()
                + ",end:" + tag.end() + ",href=" + hrefAttr);

        SpannableBuilder.setSpans(visitor.builder(), poiSpans.toArray(), tag.start(), tag.end() - 1);

        Drawable poiSuperscriptDrawable = getPoiSuperscriptDrawable();
        if (poiSuperscriptDrawable != null) {
            final int w = Utils.dpToPx(context, 12);
            poiSuperscriptDrawable.setBounds(0, 0, w, w);
            final List<Object> drawableSpans = new ArrayList<>(2);
            drawableSpans.add(new SuperscriptImageSpan(poiSuperscriptDrawable));
            drawableSpans.add(new SpanTextClickableSpan(SpanTextClickableSpan.ClickableTextType.TYPE_POI,
                    hrefAttr, "", null));
            SpannableBuilder.setSpans(visitor.builder(), drawableSpans.toArray(),
                    tag.end() - 1, tag.end());
        }
    }

    /**
     * class="related-entity" span
     */
    private void setClassRelatedEntitySpans(@NonNull MarkwonVisitor visitor, @NonNull HtmlTag tag) {
        int color;
        final List<Object> entitySpans = new ArrayList<>(3);

        final String entityIdAttr = tag.attributes().get("data-entity-id");

        final String entityColorAttr = tag.attributes().get(ATTRIBUTE_COLOR);
        if (TextUtils.isEmpty(entityColorAttr)) {
            color = Color.parseColor(DEFAULT_POI_COLOR);
        } else {
            color = ParseUtil.parseColor(entityColorAttr);
        }
        entitySpans.add(new ForegroundColorSpan(color));
        entitySpans.add(new SpanTextClickableSpan(SpanTextClickableSpan.ClickableTextType.TYPE_RELATED_ENTITY,
                null, entityIdAttr, mElementClickEventCallback));

        MDLogger.d(TAG, "entity color:" + color
                + ",start:" + tag.start()
                + ",end:" + tag.end() + ",entityIdAttr=" + entityIdAttr);

        SpannableBuilder.setSpans(visitor.builder(), entitySpans.toArray(), tag.start(), tag.end() - 1);

        Drawable superscriptDrawable = getRelatedEntitySuperscriptDrawable();
        if (superscriptDrawable != null) {
            final int w = Utils.dpToPx(context, 12);
            superscriptDrawable.setBounds(0, 0, w, w);
            final List<Object> drawableSpans = new ArrayList<>(2);
            drawableSpans.add(new SuperscriptImageSpan(superscriptDrawable));
            drawableSpans.add(new SpanTextClickableSpan(SpanTextClickableSpan.ClickableTextType.TYPE_RELATED_ENTITY,
                    null, entityIdAttr, mElementClickEventCallback));
            SpannableBuilder.setSpans(visitor.builder(), drawableSpans.toArray(),
                    tag.end() - 1, tag.end());
        }
    }

    private Drawable getPoiSuperscriptDrawable() {
        if (context == null) {
            return null;
        }
        return AppCompatResources.getDrawable(context, R.drawable.chat_span_poi);
    }

    private Drawable getRelatedEntitySuperscriptDrawable() {
        if (context == null) {
            return null;
        }

        return AppCompatResources.getDrawable(context, R.drawable.chat_span_related_entity);
    }
}
