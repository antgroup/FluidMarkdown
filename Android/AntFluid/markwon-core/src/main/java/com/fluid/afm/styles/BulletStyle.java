package com.fluid.afm.styles;


public class BulletStyle {
    private Shape shape;
    private int leadingSpacing = -1;
    private int leading;
    public static BulletStyle create() {
        return new BulletStyle();
    }

    public BulletStyle setShape(Shape shape) {
        this.shape = shape;
        return this;
    }

    public BulletStyle leadingSpacing(int leadingSpacing) {
        this.leadingSpacing = Math.max(0, leadingSpacing);
        return this;
    }

    public BulletStyle leading(int leading) {
        this.leading = Math.max(0, leading);
        return this;
    }

    public Shape shape() {
        return shape;
    }

    public int leadingSpacing() {
        return leadingSpacing;
    }

    public int leading() {
        return leading;
    }
}
