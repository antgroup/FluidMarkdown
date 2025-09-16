package com.fluid.afm.styles;

import android.graphics.Typeface;
import android.text.TextPaint;

public class TitleStyle {
    public static final TitleStyle TITLE_DEFAULT = new TitleStyle(1f);
    public static final TitleStyle[] TITLE_DEFAULT_SIZES = {
            TitleStyle.create(1.3f), TitleStyle.create(1.2f), TitleStyle.create(1.1f),
            TITLE_DEFAULT, TITLE_DEFAULT, TITLE_DEFAULT,
    };
    private String icon;
    private int sizeType; // 0 scale, 1 px
    private final ParagraphStyle paragraph = new ParagraphStyle();
    private Typeface typeface;
    private int paragraphSpacingBefore;

    public static TitleStyle create(float fontSize) {
        return new TitleStyle(fontSize);
    }
    public TitleStyle() {

    }

    public TitleStyle(float fontSize) {
        this.paragraph.fontSize(fontSize);
        sizeType = 0;
    }

    public TitleStyle fontSize(float fontSize) {
        this.paragraph.fontSize(fontSize);
        return this;
    }

    public TitleStyle icon(String icon) {
        this.icon = icon;
        return this;
    }

    public TitleStyle sizeType(int sizeType) {
        this.sizeType = sizeType;
        return this;
    }
    public TitleStyle paragraphSpacing(int paragraphSpacing) {
        paragraph.paragraphSpacing(paragraphSpacing);
        return this;
    }

    public TitleStyle paragraphSpacingBefore(int paragraphSpacingBefore) {
        this.paragraphSpacingBefore = Math.max(0, paragraphSpacingBefore);
        return this;
    }

    public int paragraphSpacingBefore() {
        return paragraphSpacingBefore;
    }
    public TitleStyle setTypeface(Typeface typeface) {
        this.typeface = typeface;
        return this;
    }

    public String icon() {
        return icon;
    }

    public ParagraphStyle paragraph() {
        return paragraph;
    }

    public void apply(TextPaint paint) {
        if (paragraph.fontColor() != 0) {
            paint.setColor(paragraph.fontColor());
        }
        float size = paragraph.fontSize();
        if (size > 0) {
            if (sizeType == 0) {
                paint.setTextSize(paint.getTextSize() * size);
            } else {
                paint.setTextSize(size);
            }
        }
        if (typeface != null) {
            paint.setTypeface(typeface);
        } else {
            paint.setFakeBoldText(true);
        }
    }
}
