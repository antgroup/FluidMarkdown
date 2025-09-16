package io.noties.markwon.html.tag;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Collection;

import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.MarkwonVisitor;
import io.noties.markwon.RenderProps;
import io.noties.markwon.SpannableBuilder;
import io.noties.markwon.html.HtmlTag;
import io.noties.markwon.html.MarkwonHtmlRenderer;
import io.noties.markwon.html.TagHandler;

public abstract class SimpleTagHandler extends TagHandler {
    private String tagContent = "";

    @Nullable
    public abstract Object getSpans(
            @NonNull MarkwonConfiguration configuration,
            @NonNull RenderProps renderProps,
            @NonNull HtmlTag tag);

    @NonNull
    @Override
    public abstract Collection<String> supportedTags();


    @Override
    public void handle(@NonNull MarkwonVisitor visitor, @NonNull MarkwonHtmlRenderer renderer, @NonNull HtmlTag tag) {
        // @since 4.5.0 check if tag is block one and visit children
        if (tag.isBlock()) {
            visitChildren(visitor, renderer, tag.getAsBlock());
        }
        if (tag.end() > tag.start() && tag.start() >= 0 && tag.end() <= visitor.builder().length()) {
            tagContent = visitor.builder().subSequence(tag.start(), tag.end()).toString();
        }
        final Object spans = getSpans(visitor.configuration(), visitor.renderProps(), tag);
        if (spans != null) {
            SpannableBuilder.setSpans(visitor.builder(), spans, tag.start(), tag.end());
        }
    }

    protected String getTagContent() {
        return tagContent;
    }
}
