package com.fluid.afm.markdown;

import android.view.View;

import com.fluid.afm.markdown.html.SpanTextClickableSpan;
import com.fluid.afm.markdown.model.EventModel;

import java.util.List;
import java.util.Map;

public interface ElementClickEventCallback {
    String PARAM_KEY_LINK = "link";
    String PARAM_KEY_SOURCE = "source";
    String SOURCE_TYPE_LINK= "link";
    String SOURCE_TYPE_ICON_LINK= "iconlink";

    default boolean onLinkClicked(Map<String, Object> params) { return false;}
    default void onFootnoteClicked(String index) { }

    default void onImageClicked(String url, String description) {}
    default boolean onTextClickableSpanClicked(View widget, String link, String entityID, SpanTextClickableSpan.ClickableTextType type)  { return false;}

    default void exposureSpmBehavior(List<EventModel> models) {}
}
