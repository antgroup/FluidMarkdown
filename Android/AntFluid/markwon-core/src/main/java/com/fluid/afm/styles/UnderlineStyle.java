package com.fluid.afm.styles;

import com.fluid.afm.utils.Utils;

public class UnderlineStyle {
    private int height = Utils.dpToPx(6);
    private int color = 0x7A1677FF;

    public static UnderlineStyle create(int height, int color) {
        return new UnderlineStyle().setColor(color).setHeight(height);
    }

    public int getHeight() {
        return height;
    }

    public int getColor() {
        return color;
    }

    public UnderlineStyle setHeight(int height) {
        this.height = Math.max(0, height);
        return this;
    }

    public UnderlineStyle setColor(int color) {
        this.color = color;
        return this;
    }
}
