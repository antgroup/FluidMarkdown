package com.fluid.afm.styles;

import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.Utils;

public class CodeStyle implements Parcelable {

    private int inlineFontColor = 0xFF333333;
    private int inlineFontSize = Utils.dpToPx(15);
    private int inlineBackgroundColor = 0x1E1F3B63;
    private int inlineBackgroundRadius = Utils.dpToPx(4);
    private int inlinePaddingVertical = Utils.dpToPx(1.5f);
    private int inlinePaddingHorizontal = Utils.dpToPx(4);
    private int codeFontColor = 0xFF333333;
    private int codeFontSize = Utils.dpToPx(13);
    private int codeBackgroundColor = Color.WHITE;
    private int codeBackgroundRadius = Utils.dpToPx(12);
    private int titleFontColor = 0xFF999999;
    private int titleBackgroundColor = 0xFFEDEFF3;
    private int titleFontSize = Utils.dpToPx(13);
    private int borderColor = 0xFFDEDEDE;
    private int borderWidth = Utils.dpToPx(0.5f);
    private boolean lightIcon = true;
    private boolean drawBorder = true;
    private Typeface codeTypeface = Typeface.MONOSPACE;
    private int blockLeading = Utils.dpToPx(8);
    private boolean showTitle = true;

    public CodeStyle() {

    }

    protected CodeStyle(Parcel in) {
        inlineFontColor = in.readInt();
        inlineFontSize = in.readInt();
        inlineBackgroundColor = in.readInt();
        inlineBackgroundRadius = in.readInt();
        inlinePaddingVertical = in.readInt();
        inlinePaddingHorizontal = in.readInt();
        codeFontColor = in.readInt();
        codeFontSize = in.readInt();
        codeBackgroundColor = in.readInt();
        codeBackgroundRadius = in.readInt();
        titleFontColor = in.readInt();
        titleBackgroundColor = in.readInt();
        titleFontSize = in.readInt();
        borderColor = in.readInt();
        borderWidth = in.readInt();
        lightIcon = in.readByte() != 0;
        drawBorder = in.readByte() != 0;
        blockLeading = in.readInt();
    }

    public static final Creator<CodeStyle> CREATOR = new Creator<>() {
        @Override
        public CodeStyle createFromParcel(Parcel in) {
            return new CodeStyle(in);
        }

        @Override
        public CodeStyle[] newArray(int size) {
            return new CodeStyle[size];
        }
    };

    public static CodeStyle create() {
        return new CodeStyle();
    }

    public int inlineBackgroundColor() {
        return inlineBackgroundColor;
    }

    public CodeStyle inlineCodeBackgroundColor(int inlineBackgroundColor) {
        this.inlineBackgroundColor = inlineBackgroundColor;
        return this;
    }

    public int inlineBackgroundRadius() {
        return inlineBackgroundRadius;
    }

    public CodeStyle inlineCodeBackgroundRadius(int inlineBackgroundRadius) {
        this.inlineBackgroundRadius = Math.max(0, inlineBackgroundRadius);
        return this;
    }

    public boolean isLightIcon() {
        return lightIcon;
    }

    public CodeStyle lightIcon(boolean lightIcon) {
        this.lightIcon = lightIcon;
        return this;
    }

    public CodeStyle inlineFontColor(int color) {
        inlineFontColor = color;
        return this;
    }

    public int inlineFontColor() {
        return inlineFontColor;
    }

    public CodeStyle inlinePaddingVertical(int padding) {
        inlinePaddingVertical = Math.max(0, padding);
        return this;
    }

    public int inlinePaddingVertical() {
        return inlinePaddingVertical;
    }

    public CodeStyle inlinePaddingHorizontal(int padding) {
        inlinePaddingHorizontal = Math.max(0, padding);
        return this;
    }

    public int inlinePaddingHorizontal() {
        return inlinePaddingHorizontal;
    }

    public CodeStyle codeFontColor(int color) {
        codeFontColor = color;
        return this;
    }

    public int codeFontColor() {
        return codeFontColor;
    }

    public CodeStyle codeFontSize(int size) {
        codeFontSize = Math.max(0, size);
        return this;
    }

    public int codeFontSize() {
        return codeFontSize;
    }

    public CodeStyle codeBackgroundColor(int color) {
        codeBackgroundColor = color;
        return this;
    }

    public int codeBackgroundColor() {
        return codeBackgroundColor;
    }

    public CodeStyle codeBackgroundRadius(int radius) {
        codeBackgroundRadius = Math.max(0, radius);
        return this;
    }

    public int codeBackgroundRadius() {
        return codeBackgroundRadius;
    }

    public CodeStyle titleFontColor(int color) {
        titleFontColor = color;
        return this;
    }

    public int titleFontColor() {
        return titleFontColor;
    }

    public CodeStyle titleFontSize(int size) {
        titleFontSize = Math.max(0, size);
        return this;
    }

    public int titleFontSize() {
        return titleFontSize;
    }

    public CodeStyle drawBorder(boolean drawBorder) {
        this.drawBorder = drawBorder;
        return this;
    }

    public boolean isDrawBorder() {
        return drawBorder;
    }

    public CodeStyle borderColor(int color) {
        borderColor = color;
        return this;
    }

    public int borderColor() {
        return borderColor;
    }

    public CodeStyle borderWidth(int width) {
        borderWidth = Math.max(0, width);
        if (this.borderWidth == 1) {
            this.borderWidth = 2;
        }
        return this;
    }

    public int borderWidth() {
        return borderWidth;
    }

    public CodeStyle titleBackgroundColor(int color) {
        titleBackgroundColor = color;
        return this;
    }

    public int titleBackgroundColor() {
        return titleBackgroundColor;
    }

    public CodeStyle codeTypeface(Typeface typeface) {
        this.codeTypeface = typeface;
        return this;
    }

    public Typeface codeTypeface() {
        return codeTypeface;
    }

    public CodeStyle inlineFontSize(int size) {
        inlineFontSize = Math.max(0, size);
        return this;
    }

    public int inlineFontSize() {
        return inlineFontSize;
    }

    public CodeStyle blockLeading(int leading) {
        blockLeading = Math.max(0, leading);
        return this;
    }

    public int blockLeading() {
        return blockLeading;
    }

    public boolean isShowTitle() {
        return showTitle;
    }

    public void setShowTitle(boolean showTitle) {
        this.showTitle = showTitle;
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel dest, int flags) {
        dest.writeInt(inlineFontColor);
        dest.writeInt(inlineFontSize);
        dest.writeInt(inlineBackgroundColor);
        dest.writeInt(inlineBackgroundRadius);
        dest.writeInt(inlinePaddingVertical);
        dest.writeInt(inlinePaddingHorizontal);
        dest.writeInt(codeFontColor);
        dest.writeInt(codeFontSize);
        dest.writeInt(codeBackgroundColor);
        dest.writeInt(codeBackgroundRadius);
        dest.writeInt(titleFontColor);
        dest.writeInt(titleBackgroundColor);
        dest.writeInt(titleFontSize);
        dest.writeInt(borderColor);
        dest.writeInt(borderWidth);
        dest.writeByte((byte) (lightIcon ? 1 : 0));
        dest.writeByte((byte) (drawBorder ? 1 : 0));
        dest.writeInt(blockLeading);
    }
}

