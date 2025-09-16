package io.noties.markwon.html.tag;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.fluid.afm.utils.MDLogger;

import org.commonmark.node.Link;

import java.util.Collection;
import java.util.Collections;

import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.RenderProps;
import io.noties.markwon.SpanFactory;
import io.noties.markwon.core.CoreProps;
import io.noties.markwon.html.CssInlineStyleParser;
import io.noties.markwon.html.CssProperty;
import io.noties.markwon.html.HtmlTag;

public class LinkHandler extends SimpleTagHandler {
    @Nullable
    @Override
    public Object getSpans(@NonNull MarkwonConfiguration configuration, @NonNull RenderProps renderProps, @NonNull HtmlTag tag) {
        final SpanFactory spanFactory = configuration.spansFactory().get(Link.class);
        if (spanFactory == null) {
            return null;
        }
        final String destination = tag.attributes().get("href");
        if (!TextUtils.isEmpty(destination)) {
            CoreProps.LINK_DESTINATION.set(
                    renderProps,
                    destination
            );
        }
        final String style = tag.attributes().get("style");
        if (!TextUtils.isEmpty(style)) {
            Iterable<CssProperty> styleProp = CssInlineStyleParser.create().parse(style);
            for (CssProperty property : styleProp) {
                switch (property.key()) {
                    case "color":
                        CoreProps.COLOR.set(
                                renderProps,
                                property.value()
                        );
                        break;
                    case "text-decoration":
                        CoreProps.LINK_TEXT_DECORATION.set(
                                renderProps,
                                property.value()
                        );
                        break;
                    case "font-weight":
                        CoreProps.FONT_WEIGHT.set(
                                renderProps,
                                property.value()
                        );
                        break;
                    default:
                        MDLogger.i("unexpected CSS property: %s", property.key());
                }
            }
        }
        CoreProps.SOURCE.set(
                renderProps,
                tag.name()
        );
        return spanFactory.getSpans(configuration, renderProps);
    }

    @NonNull
    @Override
    public Collection<String> supportedTags() {
        return Collections.singleton("a");
    }
}
