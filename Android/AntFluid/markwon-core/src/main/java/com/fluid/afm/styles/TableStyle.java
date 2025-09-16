package com.fluid.afm.styles;

import android.graphics.Color;
import android.graphics.Paint;
import android.os.Parcel;
import android.os.Parcelable;
import android.text.TextPaint;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.ParseUtil;

import io.noties.markwon.utils.ColorUtils;
import com.fluid.afm.utils.Utils;

public class TableStyle implements Parcelable {
    protected static final int TABLE_BORDER_DEF_ALPHA = 75;
    public static final int DEFAULT_HEADER_TEXT_BACKGROUND_COLOR = 0xFFEDEFF2;

    private int maxWidth;
    private int maxHeight;
    private TableCell title = new TableCell();
    private TableCell header = new TableCell();
    ;
    private TableCell body = new TableCell();
    ;
    private int cellTopBottomPadding;
    private int cellLeftRightPadding = Utils.dpToPx(12);
    private float columnDefaultMaxWidth;
    private float columnFirstMaxWidth;
    private boolean drawBorder;
    private int borderColor;
    private int borderWidth = -1;
    private int tableBlockRadius = -1;

    private int textColor;
    private int titleBackgroundRadius;

    private int titleBarHeight = Utils.dpToPx(40);

    public TableStyle() {
        title.backgroundColor = Color.WHITE;
        body.fontColor = 0xFF333333;
        body.fontSize = 26;
        header.fontColor = 0xFF999999;
        header.fontSize = 26;
    }

    public static TableStyle create() {
        return new TableStyle().tableBlockRadius(ParseUtil.parseDp("24rpx"))
                .fontColor(0xFF333333)
                .titleFontColor(0xFF999999)
                .titleBackgroundColor(0xFFEDEFF3)
                .titleFontSize(ParseUtil.parseDp("30rpx"))
                .headerBackgroundColor(0xFFF6F7F9)
                .headerFontSize(ParseUtil.parseDp("26rpx"))
                .titleBackgroundRadius(ParseUtil.parseDp("24rpx"))
                .bodyBackgroundColor(Color.WHITE)
                .cellTopBottomPadding(ParseUtil.parseDp("6px"))
                .bodyFontSize(ParseUtil.parseDp("26rpx"))
                .drawBorder(true).borderColor(0xFFDEDEDE).borderWidth(ParseUtil.parseDp("1rpx"));
    }

    public TableStyle maxWidth(int maxWidth) {
        this.maxWidth = Math.max(0, maxWidth);
        return this;
    }

    public TableStyle maxHeight(int maxHeight) {
        this.maxHeight = Math.max(0, maxHeight);
        return this;
    }

    public TableStyle titleFontSize(float size) {
        this.title.fontSize = Math.max(0, size);
        return this;
    }

    public TableStyle titleBackgroundColor(int color) {
        this.title.backgroundColor = color;
        return this;
    }

    public TableStyle headerFontSize(float size) {
        this.header.fontSize = Math.max(0, size);
        return this;
    }

    public TableStyle headerBackgroundColor(int color) {
        this.header.backgroundColor = color;
        return this;
    }

    public TableStyle bodyFontSize(float size) {
        this.body.fontSize = Math.max(0, size);
        return this;
    }

    public TableStyle bodyBackgroundColor(int color) {
        this.body.backgroundColor = color;
        return this;
    }

    public TableStyle cellTopBottomPadding(int rowTopBottomPadding) {
        this.cellTopBottomPadding = Math.max(0, rowTopBottomPadding);
        return this;
    }

    public TableStyle columnDefaultMaxWidth(float columnDefaultMaxWidth) {
        this.columnDefaultMaxWidth = Math.max(0, columnDefaultMaxWidth);
        return this;
    }

    public TableStyle columnFirstMaxWidth(float columnFirstMaxWidth) {
        this.columnFirstMaxWidth = Math.max(0, columnFirstMaxWidth);
        return this;
    }

    public TableStyle drawBorder(boolean drawBorder) {
        this.drawBorder = drawBorder;
        return this;
    }

    public TableStyle borderColor(int borderColor) {
        this.borderColor = borderColor;
        return this;
    }

    public TableStyle borderWidth(int borderWidth) {
        this.borderWidth = Math.max(0, borderWidth);
        if (this.borderWidth == 1) {
            this.borderWidth = 2;
        }
        return this;
    }

    public TableStyle tableBlockRadius(int tableBlockRadius) {
        this.tableBlockRadius = Math.max(0, tableBlockRadius);
        return this;
    }

    public TableStyle fontColor(int color) {
        this.textColor = color;
        return this;
    }

    public TableStyle titleFontColor(int color) {
        this.title.fontColor = color;
        return this;
    }

    public int cellLeftRightPadding() {
        return cellLeftRightPadding;
    }

    public TableStyle cellLeftRightPadding(int cellLeftRightPadding) {
        this.cellLeftRightPadding = Math.max(0, cellLeftRightPadding);
        return this;
    }

    public TableStyle titleBackgroundRadius(int headerBackgroundRadius) {
        this.titleBackgroundRadius = Math.max(0, headerBackgroundRadius);
        return this;
    }

    public int maxWidth() {
        return maxWidth;
    }

    public int maxHeight() {
        return maxHeight;
    }

    public TableCell title() {
        return title;
    }

    public TableCell header() {
        return header;
    }

    public TableCell body() {
        return body;
    }

    public int cellTopBottomPadding() {
        return cellTopBottomPadding;
    }

    public int rowLeftRightPadding() {
        return cellLeftRightPadding;
    }

    public float columnDefaultMaxWidth() {
        return columnDefaultMaxWidth;
    }

    public float columnFirstMaxWidth() {
        return columnFirstMaxWidth;
    }

    public boolean drawBorder() {
        return drawBorder;
    }

    public int borderColor() {
        return borderColor;
    }

    public int borderWidth() {
        return borderWidth;
    }

    public int tableBlockRadius() {
        return tableBlockRadius;
    }

    public int getTextColor() {
        return textColor;
    }

    public int titleBackgroundRadius() {
        return titleBackgroundRadius;
    }
    public int titleBarHeight() {
        return titleBarHeight;
    }
    public TableStyle titleBarHeight(int titleBarHeight) {
        this.titleBarHeight = Math.max(0, titleBarHeight);
        return this;
    }

    public void applyTableBorderStyle(@NonNull Paint paint) {
        final int color;
        if (borderColor() != 0) {
            color = borderColor();
        } else {
            color = ColorUtils.applyAlpha(paint.getColor(), TABLE_BORDER_DEF_ALPHA);
        }
        if (borderWidth() > 0) {
            paint.setStrokeWidth(borderWidth());
        }
        paint.setColor(color);
        // @since 4.3.1 before it was STROKE... change to FILL as we draw border differently
        paint.setStyle(Paint.Style.STROKE);
    }


    public void applyTableEvenRowStyle(@NonNull Paint paint) {
        // by default to background to even row
        handleBodyStyle(paint);
    }


    public void applyTableTextStyle(@NonNull TextPaint textPaint, boolean isHead) {
        if (isHead) {
            textPaint.setFakeBoldText(true);
            textPaint.setTextSize(header().fontSize());
            textPaint.setColor(getTextColor());
        } else {
            textPaint.setTextSize(body().fontSize());
            textPaint.setColor(getTextColor());
        }
    }

    public void applyTableHeaderRowStyle(@NonNull Paint paint) {
        if (header().backgroundColor() != 0) {
            paint.setColor(header().backgroundColor());
        } else {
            paint.setColor(DEFAULT_HEADER_TEXT_BACKGROUND_COLOR);
        }
        if (header().fontSize() > 0) {
            paint.setTextSize(header().fontSize());
        }
        paint.setStyle(Paint.Style.FILL);
    }

    public void applyTableOddRowStyle(@NonNull Paint paint) {
        handleBodyStyle(paint);
    }

    private void handleBodyStyle(@NonNull Paint paint) {
        paint.setColor(body().backgroundColor());
        if (borderWidth() >= 0) {
            paint.setStrokeWidth(borderWidth());
        }
        if (body().fontSize() > 0) {
            paint.setTextSize(body().fontSize());
        }
        paint.setStyle(Paint.Style.FILL);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(maxWidth);
        dest.writeInt(maxHeight);
        dest.writeInt(cellTopBottomPadding);
        dest.writeInt(cellLeftRightPadding);
        dest.writeFloat(columnDefaultMaxWidth);
        dest.writeFloat(columnFirstMaxWidth);
        dest.writeInt(title.backgroundColor);
        dest.writeFloat(title.fontSize);
        dest.writeInt(header.backgroundColor);
        dest.writeFloat(header.fontSize);
        dest.writeInt(body.backgroundColor);
        dest.writeFloat(body.fontSize);
        dest.writeInt(drawBorder ? 1 : 0);
        dest.writeInt(borderColor);
        dest.writeInt(borderWidth);
        dest.writeInt(tableBlockRadius);
        dest.writeInt(textColor);
        dest.writeInt(cellLeftRightPadding);
    }

    protected TableStyle(Parcel in) {
        maxWidth = in.readInt();
        maxHeight = in.readInt();
        cellTopBottomPadding = in.readInt();
        cellLeftRightPadding = in.readInt();
        columnDefaultMaxWidth = in.readFloat();
        columnFirstMaxWidth = in.readFloat();
        title = new TableStyle.TableCell();
        title.backgroundColor = in.readInt();
        title.fontSize = in.readFloat();
        header = new TableStyle.TableCell();
        header.backgroundColor = in.readInt();
        header.fontSize = in.readFloat();
        body = new TableStyle.TableCell();
        body.backgroundColor = in.readInt();
        body.fontSize = in.readFloat();
        drawBorder = in.readInt() == 1;
        borderColor = in.readInt();
        borderWidth = in.readInt();
        tableBlockRadius = in.readInt();
        textColor = in.readInt();
        cellLeftRightPadding = in.readInt();
    }

    public static final Creator<TableStyle> CREATOR = new Creator<>() {
        @Override
        public TableStyle createFromParcel(Parcel in) {
            return new TableStyle(in);
        }

        @Override
        public TableStyle[] newArray(int size) {
            return new TableStyle[size];
        }
    };

    public static class TableCell {
        private int backgroundColor;
        private float fontSize;
        private int fontColor;

        public TableCell() {

        }

        public int backgroundColor() {
            return backgroundColor;
        }

        public float fontSize() {
            return fontSize;
        }

        public int fontColor() {
            return fontColor;
        }

        public TableCell(int backgroundColor, float fontSize) {
            this.backgroundColor = backgroundColor;
            this.fontSize = fontSize;
        }
    }
}