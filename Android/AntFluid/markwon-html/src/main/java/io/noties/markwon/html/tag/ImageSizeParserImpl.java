package io.noties.markwon.html.tag;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.VisibleForTesting;

import com.fluid.afm.utils.MDLogger;

import java.util.Map;

import io.noties.markwon.html.CssInlineStyleParser;
import io.noties.markwon.html.CssProperty;
import io.noties.markwon.image.ImageSize;
import io.noties.markwon.image.ImageSizeResolverDef;
import com.fluid.afm.utils.Utils;

class ImageSizeParserImpl implements ImageHandler.ImageSizeParser {

    private final CssInlineStyleParser inlineStyleParser;

    ImageSizeParserImpl(@NonNull CssInlineStyleParser inlineStyleParser) {
        this.inlineStyleParser = inlineStyleParser;
    }

    @Override
    public ImageSize parse(@NonNull Map<String, String> attributes) {

        // strictly speaking percents when specified directly on an attribute
        // are not part of the HTML spec (I couldn't find any reference)

        ImageSize.Dimension width = null;
        ImageSize.Dimension height = null;

        // okay, let's first check styles
        final String style = attributes.get("style");
        if (!TextUtils.isEmpty(style)) {
            String key;
            for (CssProperty cssProperty : inlineStyleParser.parse(style)) {
                key = cssProperty.key();
                if ("width".equals(key)) {
                    width = dimension(cssProperty.value());
                } else if ("height".equals(key)) {
                    height = dimension(cssProperty.value());
                }
                if (width != null && height != null) {
                    break;
                }
            }
        }

        if (width != null
                && height != null) {
            width = rpxToPx(width);
            height = rpxToPx(height);
            return new ImageSize(width, height);
        }

        // check tag attributes
        if (width == null) {
            width = dimension(attributes.get("width"));
        }

        if (height == null) {
            height = dimension(attributes.get("height"));
        }

        if (width == null
                && height == null) {
            return null;
        }
        width = rpxToPx(width);
        height = rpxToPx(height);
        return new ImageSize(width, height);
    }

    private ImageSize.Dimension rpxToPx(@Nullable ImageSize.Dimension side) {
        MDLogger.d("ImageSizeParserImpl", "parse before convert: " + side);
        ImageSize.Dimension result = side;
        try {
            if (side != null && side.value != 0 && ImageSizeResolverDef.UNIT_RPX.equalsIgnoreCase(side.unit)) {
                result = new ImageSize.Dimension(Utils.rpxToPx(side.value), ImageSizeResolverDef.UNIT_PX);
            }
        } catch (Exception e) {
            MDLogger.e("ImageSizeParserImpl", "throwable e = " + e.getMessage());
        }
        MDLogger.d("ImageSizeParserImpl", "after convert parse: " + result);
        return result;
    }


    @Nullable
    @VisibleForTesting
    ImageSize.Dimension dimension(@Nullable String value) {

        if (TextUtils.isEmpty(value)) {
            return null;
        }

        final int length = value.length();

        for (int i = length - 1; i > -1; i--) {

            if (Character.isDigit(value.charAt(i))) {

                try {
                    final float val = Float.parseFloat(value.substring(0, i + 1));
                    final String unit;
                    if (i == length - 1) {
                        // no unit info
                        unit = null;
                    } else {
                        unit = value.substring(i + 1, length);
                    }
                    return new ImageSize.Dimension(val, unit);
                } catch (NumberFormatException e) {
                    // value cannot not be represented as a float
                    return null;
                }
            }
        }

        return null;
    }
}
