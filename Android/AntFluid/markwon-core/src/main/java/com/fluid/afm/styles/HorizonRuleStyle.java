package com.fluid.afm.styles;

import android.graphics.Paint;

public class HorizonRuleStyle {
    /**
     * return this;
     * height : 4px
     * color : #E2E5F3
     */

    private int height;
    private int color = 0;
    private final ParagraphStyle paragraph = new ParagraphStyle();
    private int paragraphSpacingBefore;

    public static HorizonRuleStyle create() {
        return new HorizonRuleStyle();
    }

    public static HorizonRuleStyle create(int height, int color, int paragraphSpacing, int paragraphSpacingBefore) {
        HorizonRuleStyle style = new HorizonRuleStyle();
        style.height = height;
        style.color = color;
        style.paragraph.paragraphSpacing(paragraphSpacing);
        style.paragraphSpacingBefore = paragraphSpacingBefore;
        return style;
    }

    public HorizonRuleStyle setHeight(int height) {
        this.height = Math.max(0, height);
        return this;
    }

    public HorizonRuleStyle setColor(int color) {
        this.color = color;
        return this;
    }

    public HorizonRuleStyle paragraphSpacing(int paragraphSpacing) {
        paragraph.paragraphSpacing(paragraphSpacing);
        return this;
    }

    public HorizonRuleStyle paragraphSpacingBefore(int paragraphSpacingBefore) {
        this.paragraphSpacingBefore = Math.max(0, paragraphSpacingBefore);
        return this;
    }

    public int paragraphSpacingBefore() {
        return paragraphSpacingBefore;
    }

    public int getHeight() {
        return height;
    }

    public int getColor() {
        return color;
    }

    public ParagraphStyle paragraph() {
        return paragraph;
    }

    public void apply(Paint paint) {
        if (color != 0) {
            paint.setColor(color);
        } else {
            paint.setColor(0xFFEEEEEE);
        }
        paint.setStyle(Paint.Style.FILL);
        if (height >= 0) {
            //noinspection SuspiciousNameCombination
            paint.setStrokeWidth(height);
        }
    }

}