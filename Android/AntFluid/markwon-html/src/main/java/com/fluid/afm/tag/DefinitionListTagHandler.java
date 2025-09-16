package com.fluid.afm.tag;


import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Arrays;
import java.util.Collection;

import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.RenderProps;
import io.noties.markwon.html.HtmlTag;
import com.fluid.afm.spans.DefinitionListSpan;
import io.noties.markwon.html.tag.SimpleTagHandler;

public class DefinitionListTagHandler extends SimpleTagHandler {

    @Nullable
    @Override
    public Object getSpans(
            @NonNull MarkwonConfiguration configuration,
            @NonNull RenderProps renderProps,
            @NonNull HtmlTag tag) {
        final String tagName = tag.name();
        
        if ("dl".equals(tagName)) {
            return new DefinitionListSpan();
        } else if ("dt".equals(tagName)) {
            return new DefinitionListSpan.TermSpan();
        } else if ("dd".equals(tagName)) {
            return new DefinitionListSpan.DescriptionSpan();
        }
        
        return null;
    }

    @NonNull
    @Override
    public Collection<String> supportedTags() {
        return Arrays.asList("dl", "dt", "dd");
    }

    public static DefinitionListTagHandler create() {
        return new DefinitionListTagHandler();
    }
}