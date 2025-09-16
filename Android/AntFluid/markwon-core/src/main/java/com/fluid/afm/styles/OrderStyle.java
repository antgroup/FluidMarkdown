package com.fluid.afm.styles;

import com.fluid.afm.utils.ParseUtil;

/**
 * 有序列表
 * "unorder": {
 * "item1": {
 * "shape": {
 * "type": "circle",
 * "shapeSize": "7px",
 * "shapeColor": "#4744da"
 * },
 * "leadingSpacing": "6px"        * 		},
 * "itemBase": {
 * "shape": {
 * "type": "circle",
 * "size": "1.5px",
 * "color": "#13113e"
 * }
 * }
 */

public class OrderStyle {
    private int fontColor;
    private float fontSize;
    // only support icon & rectangle
    private Shape shape;
    private int leading;
    private int leadingSpacing;
    private boolean bold = true;

    public static OrderStyle create() {
        return new OrderStyle()
                .leading(ParseUtil.parseDp("12px"))
                .isBold(true)
                .leadingSpacing(ParseUtil.parseDp("12px"));
    }

    public OrderStyle orderFontColor(int fontColor) {
        this.fontColor = fontColor;
        return this;
    }

    public int orderFontColor() {
        return fontColor;
    }

    public OrderStyle orderFontSize(float fontSize) {
        this.fontSize = Math.max(0, fontSize);
        return this;
    }

    public float orderFontSize() {
        return fontSize;
    }

    public OrderStyle setShape(Shape shape) {
        this.shape = shape;
        return this;
    }

    public Shape shape() {
        return shape;
    }

    public OrderStyle leading(int leading) {
        this.leading = Math.max(0, leading);
        return this;
    }

    public int leading() {
        return leading;
    }

    public OrderStyle leadingSpacing(int leadingSpacing) {
        this.leadingSpacing = Math.max(0, leadingSpacing);
        return this;
    }

    public int leadingSpacing() {
        return leadingSpacing;
    }

    public OrderStyle isBold(boolean bold) {
        this.bold = bold;
        return this;
    }

    public boolean isBold() {
        return bold;
    }
}


