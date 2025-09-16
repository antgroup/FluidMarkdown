package com.fluid.afm.styles;

import static java.lang.annotation.RetentionPolicy.SOURCE;

import androidx.annotation.IntDef;

import java.lang.annotation.Retention;

public class FootnoteStyle {
    public static final int STYLE_CIRCLE = 0;
    public static final int STYLE_RECTANGLE = 1;
    private int backgroundColor = 0x1E1677FF;
    private int textColor = 0xFF0E489A;
    private boolean bold = false;
    private float fontSize = 20f;
    private float size;
    private int style;
    private float radius;

    public static FootnoteStyle create() {
        return new FootnoteStyle();
    }

    public static FootnoteStyle create(int textColor, int backgroundColor) {
        return new FootnoteStyle().textColor(textColor).backgroundColor(backgroundColor);
    }

    public FootnoteStyle backgroundColor(int backgroundColor) {
        this.backgroundColor = backgroundColor;
        return this;
    }

    public int backgroundColor() {
        return backgroundColor;
    }

    public float fontSize() {
        return fontSize;
    }

    public FootnoteStyle size(float size) {
        this.size = Math.max(0, size);
        return this;
    }

    public float size() {
        return size;
    }

    public FootnoteStyle fontSize(float fontSize) {
        this.fontSize = Math.max(0, fontSize);
        return this;
    }

    public FootnoteStyle textColor(int textColor) {
        this.textColor = textColor;
        return this;
    }

    public int textColor() {
        return textColor;
    }

    public FootnoteStyle isBold(boolean bold) {
        this.bold = bold;
        return this;
    }

    public boolean isBold() {
        return bold;
    }


    public FootnoteStyle style(@Style int style) {
        this.style = style;
        return this;
    }

    @Style
    public int style() {
        return style;
    }

    public FootnoteStyle radius(float radius) {
        this.radius = Math.max(0, radius);
        return this;
    }

    public float radius() {
        return radius;
    }

    @Retention(SOURCE)
    @IntDef({STYLE_CIRCLE, STYLE_RECTANGLE})
    public @interface Style {
    }
}
