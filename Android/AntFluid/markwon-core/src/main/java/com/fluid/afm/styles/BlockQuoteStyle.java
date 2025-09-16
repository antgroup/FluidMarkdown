package com.fluid.afm.styles;

import com.fluid.afm.utils.Utils;


public class BlockQuoteStyle {
    private static final int LINE_WIDTH = Utils.dpToPx(4);
    private static final int LINE_MARGIN = Utils.dpToPx(24);
    private static final int BOTTOM_MARGIN = Utils.dpToPx(8);
    private int lineWidth = LINE_WIDTH;
    private int lineColor;
    private int lineCornerRadius = -1;
    private int lineMargin = LINE_MARGIN;
    private int bottomMargin = BOTTOM_MARGIN;

    private int leftMargin;
    private final ParagraphStyle paragraph = new ParagraphStyle();

    public static BlockQuoteStyle create() {
        return new BlockQuoteStyle();
    }

    public static BlockQuoteStyle create(int lineWidth, int lineColor, int lineCornerRadius, int lineMargin, int bottomMargin, int leftMargin, float fontSize, int fontColor, int paragraphSpacing) {
        return create().lineWidth(lineWidth).lineColor(lineColor).lineCornerRadius(lineCornerRadius).lineMargin(lineMargin).leftMargin(leftMargin).bottomMargin(bottomMargin).fontSize(fontSize).fontColor(fontColor).paragraphSpacing(paragraphSpacing);
    }

    public BlockQuoteStyle lineWidth(int lineWidth) {
        this.lineWidth = Math.max(0, lineWidth);
        return this;
    }

    public int lineWidth() {
        return lineWidth;
    }

    public BlockQuoteStyle lineColor(int lineColor) {
        this.lineColor = lineColor;
        return this;
    }

    public int lineColor() {
        return lineColor;
    }

    public BlockQuoteStyle lineCornerRadius(int lineCornerRadius) {
        this.lineCornerRadius = Math.max(0, lineCornerRadius);
        return this;
    }

    public int lineCornerRadius() {
        return lineCornerRadius;
    }

    public BlockQuoteStyle lineMargin(int lineMargin) {
        this.lineMargin = Math.max(0, lineMargin);
        return this;
    }

    public int lineMargin() {
        return lineMargin;
    }

    public BlockQuoteStyle bottomMargin(int bottomMargin) {
        this.bottomMargin = Math.max(0, bottomMargin);
        return this;
    }

    public int bottomMargin() {
        return bottomMargin;
    }

    public BlockQuoteStyle leftMargin(int leftMargin) {
        this.leftMargin = Math.max(0, leftMargin);
        return this;
    }

    public int leftMargin() {
        return leftMargin;
    }

    public BlockQuoteStyle fontSize(float fontSize) {
        paragraph.fontSize(fontSize);
        return this;
    }

    public float fontSize() {
        return paragraph.fontSize();
    }

    public BlockQuoteStyle fontColor(int fontColor) {
        paragraph.fontColor(fontColor);
        return this;
    }

    public int fontColor() {
        return paragraph.fontColor();
    }

    public BlockQuoteStyle paragraphSpacing(int paragraphSpacing) {
        paragraph.paragraphSpacing(paragraphSpacing);
        return this;
    }

    public int paragraphSpacing() {
        return paragraph.paragraphSpacing();
    }

}

