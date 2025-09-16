package com.fluid.afm.styles;

/**
 * "shape": {
 * "type": "circle",
 * "size": "1.5px",
 * "color": "#13113e"
 * }
 */
public class Shape {
    public static final int SHAPE_CIRCLE = 0;
    public static final int SHAPE_RECT = 1;
    public static final int SHAPE_ICON = 2;
    public static final int SHAPE_RING = 3;
    public static final int SHAPE_RECT_OUTLINE = 4;
    private int type = -1; // 0 circle 1 rect 3  icon
    private int size = 15;
    private int color;
    private String icon;
    private int radius;
    private int lineWidth = 2;

    public static Shape create(int type, int size, int color) {
        Shape shape = new Shape();
        shape.type = type;
        shape.size = size;
        shape.color = color;
        return shape;
    }

    public static Shape create(int type, int size, String icon) {
        Shape shape = new Shape();
        shape.type = type;
        shape.size = size;
        shape.icon = icon;
        return shape;
    }

    public Shape setType(int type) {
        this.type = type;
        return this;
    }

    public Shape setSize(int size) {
        if (size >= 0) {
            this.size = size;
        }
        return this;
    }

    public Shape setColor(int color) {
        this.color = color;
        return this;
    }

    public Shape setIcon(String icon) {
        this.icon = icon;
        return this;
    }

    public Shape setBorderRadius(int borderRadius) {
        this.radius = borderRadius;
        return this;
    }
    public Shape setLineWidth(int lineWidth) {
        this.lineWidth = lineWidth;
        return this;
    }

    public int type() {
        return type;
    }

    public int size() {
        return size;
    }

    public int color() {
        return color;
    }

    public String icon() {
        return icon;
    }

    public int radius() {
        return radius;
    }

    public int lineWidth() {
        return lineWidth;
    }
}
