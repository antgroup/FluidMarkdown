package com.fluid.afm.markdown.model;

import androidx.annotation.NonNull;

import java.util.Objects;

public class EventModel {
    public String type;
    public String url;
    public String content;
    public boolean visible;

    public EventModel(String type, String url, String content, boolean visible) {
        this.type = type;
        this.url = url;
        this.content = content;
        this.visible = visible;
    }

    @NonNull
    @Override
    public String toString() {
        return "EventModel{" +
                "type='" + type + '\'' +
                ", url='" + url + '\'' +
                ", content='" + content + '\'' +
                ", visible=" + visible +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof EventModel)) return false;
        EventModel that = (EventModel) o;
        return visible == that.visible && Objects.equals(type, that.type) && Objects.equals(url, that.url) && Objects.equals(content, that.content);
    }

}
