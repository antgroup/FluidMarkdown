package com.fluid.afm.markdown.icon;

import android.widget.TextView;

import java.util.Collection;
import java.util.Collections;

import io.noties.markwon.MarkwonVisitor;
import io.noties.markwon.SpannableBuilder;
import io.noties.markwon.html.HtmlTag;
import io.noties.markwon.html.MarkwonHtmlRenderer;
import io.noties.markwon.html.TagHandler;

public class IconSpanHandler extends TagHandler {
    private final TextView mTextView;

    public IconSpanHandler(TextView textView) {
        mTextView = textView;
    }

    @Override
    public void handle(MarkwonVisitor visitor, MarkwonHtmlRenderer renderer, HtmlTag tag) {
        final String src = tag.attributes().get("src");
        IconSpan iconSpan = new IconSpan(mTextView, src);
        if (tag.end() > tag.start()) {
            SpannableBuilder.setSpans(visitor.builder(), new Object[]{iconSpan}, tag.start(), tag.end());
        } else {
            visitor.builder().spannableStringBuilder().insert(tag.start(), String.valueOf('\u00a0'));
            SpannableBuilder.setSpans(visitor.builder(), new Object[]{iconSpan}, tag.start(), tag.start() + 1);
        }
    }

    @Override
    public Collection<String> supportedTags() {
        return Collections.singleton("icon");
    }
}
