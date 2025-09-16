package com.fluid.afm.styles;


public class ParagraphStyle {
   private float fontSize;
   private int fontColor;
   private int lineHeight;
   private int paragraphSpacing = -1;

    public static ParagraphStyle create() {
        return new ParagraphStyle();
    }

    public ParagraphStyle fontSize(float fontSize) {
        this.fontSize = Math.max(0, fontSize);
        return this;
    }

    public float fontSize() {
        return fontSize;
    }

    public ParagraphStyle fontColor(int fontColor) {
        this.fontColor = fontColor;
        return this;
    }

    public int fontColor() {
        return fontColor;
    }

    public ParagraphStyle lineHeight(int lineHeight) {
        this.lineHeight = Math.max(0, lineHeight);
        return this;
    }

    public int lineHeight() {
        return lineHeight;
    }

    public ParagraphStyle paragraphSpacing(int paragraphSpacing) {
        this.paragraphSpacing = Math.max(0, paragraphSpacing);
        return this;
    }

    public int paragraphSpacing() {
        return paragraphSpacing;
    }


}
