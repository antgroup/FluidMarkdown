package com.fluid.afm.styles;

public class LinkStyle {

    private int fontColor;
    private int space;
    private String icon;
    private boolean underline = true;
    private boolean isBold;

    public static LinkStyle create() {
        return new LinkStyle();
    }

    public static LinkStyle create(int fontColor, int space, String icon, boolean underline, boolean isBold) {
        LinkStyle style = new LinkStyle();
        style.fontColor = fontColor;
        style.space = space;
        style.icon = icon;
        style.underline = underline;
        style.isBold = isBold;
        return style;
    }

    public LinkStyle fontColor(int fontColor) {
        this.fontColor = fontColor;
        return this;
    }

    public int fontColor() {
        return fontColor;
    }

    public LinkStyle space(int space) {
        this.space = Math.max(0, space);
        return this;
    }

    public int space() {
        return space;
    }

    public LinkStyle icon(String icon) {
        this.icon = icon;
        return this;
    }

    public String icon() {
        return icon;
    }

    public LinkStyle underline(boolean underline) {
        this.underline = underline;
        return this;
    }

    public boolean underline( ) {
        return underline;
    }

    public LinkStyle isBold(boolean bold) {
        isBold = bold;
        return this;
    }

    public boolean isBold() {
        return isBold;
    }
}
