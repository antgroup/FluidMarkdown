package com.fluid.afm;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.Layout;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.LeadingMarginSpan;
import android.view.View;
import android.widget.Toast;

import com.fluid.afm.utils.MDLogger;

import java.util.HashMap;
import java.util.Map;

import com.fluid.afm.span.CodeLanguageSpan;
import io.noties.markwon.ext.tables.R;
import io.noties.markwon.utils.SpanUtils;

public class BaseBlockTitleSpan implements LeadingMarginSpan {

    protected static final String TAG = BaseBlockTitleSpan.class.getSimpleName();

    protected final Rect rect = new Rect();
    protected Drawable copyIcon;
    protected Drawable magnifyIcon;

    protected final HashMap<Rect, CodeSpanModel> copyRectMap;
    protected final int parentHeight;
    protected final int textSize;
    protected int tableIndex;
    protected String blockTitle = "";

    public BaseBlockTitleSpan(Context context, int height, int textSize) {
        this.copyRectMap = new HashMap<>();
        this.parentHeight = height;
        this.textSize = textSize;
    }

    public BaseBlockTitleSpan(Context context, int height, int textSize, int tableIndex) {
        this.copyRectMap = new HashMap<>();
        this.parentHeight = height;
        this.textSize = textSize;
        this.tableIndex = tableIndex;
    }

    @Override
    public int getLeadingMargin(boolean b) {
        return 0;
    }

    @Override
    public void drawLeadingMargin(Canvas c, Paint p, int x, int dir, int top, int baseline, int bottom, CharSequence text, int start, int end, boolean first, Layout layout) {
        if (!SpanUtils.isSelfStart(start, text, this)) return;

        int save = c.save();
        try {
            final float oldStrokeWidth = p.getStrokeWidth();
            final int oldColor = p.getColor();
            final Paint.Style oldStyle = p.getStyle();
            final float oldTextSize = p.getTextSize();

            drawBackground(c, p, top, layout.getWidth());
            drawBorder(c, p, top, layout.getWidth());
            drawHeaderText(c, p, text, start, top, x);

            drawCopyIcon(c, p, start, end, top, layout.getWidth(), magnifyIcon != null);
            drawMagnifyIcon(c, p, start, end, top, layout.getWidth());

            p.setStrokeWidth(oldStrokeWidth);
            p.setColor(oldColor);
            p.setStyle(oldStyle);
            p.setTextSize(oldTextSize);
        } finally {
            c.restoreToCount(save);
        }
    }

    private void drawBorder(Canvas c, Paint p, int top, int layoutWidth) {
        if (!drawBorder()) {
            return;
        }
        applyBorderStyle(p);
        int saveCount = c.save();
        float radius = getBackgroundRadius();
        c.clipRect(0, 0, layoutWidth, top + rect.height());
        if (p.getStrokeWidth() > 0 && p.getStrokeWidth() <= 1) {
            p.setStrokeWidth(2);
        }
        float halfWidth = p.getStrokeWidth() / 2;
        c.drawRoundRect(rect.left + halfWidth , rect.top + halfWidth, rect.right - halfWidth, rect.bottom + radius +  p.getStrokeWidth(), radius, radius, p);
        c.restoreToCount(saveCount);
        p.setStyle(Paint.Style.FILL);
        p.setStrokeWidth(1);
    }

    protected boolean drawBorder() {
        return false;
    }
    protected void applyBorderStyle(Paint paint) {

    }
    protected int getBackgroundColor() {
        return Color.parseColor("#E7E7EC");
    }

    /**
     * draw background and border
     *
     * @param c
     * @param p
     * @param top
     * @param layoutWidth
     */
    protected void drawBackground(Canvas c, Paint p, int top, int layoutWidth) {
        float startX = 0;
        float startY = top + parentHeight;
        float stopX = startX + layoutWidth;
        // background
        p.setAlpha(1);
        p.setStyle(Paint.Style.FILL);
        rect.set(0, top, (int) stopX, (int) startY);
        p.setColor(getBackgroundColor());
        drawRectWithTopRound(c, p, rect.left, rect.top, rect.right, rect.bottom, getBackgroundRadius());
        // 画分割线
        if(drawLine()) {
            p.setStrokeWidth(getBorderWidth());
            p.setColor(getBorderColor());
            c.drawLine(startX, startY, stopX, startY, p);
        }
    }

    protected int getBorderColor() {
        return 0xFFD3D8E1;
    }
    protected int getBorderWidth() {
        return 3;
    }

    protected boolean drawLine() {
        return true;
    }

    protected int getBackgroundRadius() {
        return 24;
    }

    /**
     * draw text (Code title)
     *
     * @param c
     * @param p
     * @param text
     * @param start
     * @param top
     * @param x
     */
    private void drawHeaderText(Canvas c, Paint p, CharSequence text, int start, int top, int x) {
        blockTitle = getBlockTitle(text, start);
        Paint.FontMetricsInt fm = p.getFontMetricsInt();
        int textHeight = fm.bottom - fm.top;
        float centerY = (parentHeight - textHeight) / 2f - fm.top;
        p.setColor(getTextColor());
        boolean isbold = p.isFakeBoldText();
        p.setFakeBoldText(true);
        p.setTextSize(getTextSize());
        c.drawText(blockTitle, x + getHeaderTextLeftPadding(), top + centerY, p);
        p.setFakeBoldText(isbold);
    }

    protected float getTextSize() {
        return textSize;
    }
    protected int getTextColor() {
        return 0xFF13113E;
    }

    protected int getHeaderTextLeftPadding() {
        return 0;
    }

    private void drawCopyIcon(Canvas c, Paint p, int start, int end, int top, int layoutWidth, boolean isDrawMagnifyIcon) {
        if (copyIcon == null) return;

        float w = (float) copyIcon.getBounds().width();
        float left = isDrawMagnifyIcon ? layoutWidth - (w + (w / 4F)) * 2 : layoutWidth - (w + (w / 4F));

        CodeBlockTitleSpan.CodeSpanModel copyModel = new CodeBlockTitleSpan.CodeSpanModel();
        copyModel.spanStart = start;
        copyModel.spanEnd = end;
        copyModel.clickRectType = CodeBlockTitleSpan.ClickRectType.TYPE_COPY;
        Rect copyRect = new Rect((int) left, top, (int) (left + w), top + parentHeight);
        copyRectMap.put(copyRect, copyModel);

        final int iconTopPadding = (parentHeight - copyIcon.getBounds().height()) / 2;
        c.save();
        c.translate(left, top + iconTopPadding);
        copyIcon.draw(c);
        c.restore();
    }

    private void drawMagnifyIcon(Canvas c, Paint p, int start, int end, int top, int layoutWidth) {
        if (magnifyIcon == null) return;

        int rightPadding = getIconRightMargin();
        float w = (float) magnifyIcon.getBounds().width();
        float left = layoutWidth - w - (w / 4F) - rightPadding;

        // 保存copy icon的坐标
        CodeBlockTitleSpan.CodeSpanModel magnifyModel = new CodeBlockTitleSpan.CodeSpanModel();
        magnifyModel.spanStart = start;
        magnifyModel.spanEnd = end;
        magnifyModel.clickRectType = CodeBlockTitleSpan.ClickRectType.TYPE_MAGNIFY;
        Rect magnifyRect = new Rect((int) left, top, (int) (left + w), top + parentHeight);
        copyRectMap.put(magnifyRect, magnifyModel);

        // 画magnify icon
        final int iconTopPadding = (parentHeight - magnifyIcon.getBounds().height()) / 2;
        c.save();
        c.translate(left, top + iconTopPadding);
        magnifyIcon.draw(c);
        c.restore();
    }

    protected int getIconRightMargin() {
        return 0;
    }

    private void drawRectWithTopRound(Canvas canvas, Paint paint,
                                      float left, float top, float right, float bottom,
                                      float radius) {
        Path path = new Path();
        path.moveTo(left, top + radius);
        path.arcTo(new RectF(left, top, left + 2 * radius, top + 2 * radius), 180, 90);
        path.lineTo(right - radius, top);
        path.arcTo(new RectF(right - 2 * radius, top, right, top + 2 * radius), 270, 90);
        path.lineTo(right, bottom);
        path.lineTo(left, bottom);
        path.lineTo(left, top + radius);
        path.close();

        canvas.drawPath(path, paint);
    }

    protected String getBlockTitle(CharSequence text, int start) {
        if (text instanceof Spanned) {
            CodeLanguageSpan[] codeLanguageSpans = ((Spanned) text).getSpans(start, text.length(), CodeLanguageSpan.class);
            if (codeLanguageSpans == null || codeLanguageSpans.length == 0) {
                return "Code";
            }
            return codeLanguageSpans[codeLanguageSpans.length - 1].getLanguage();
        }
        return "Code";
    }


    protected CodeBlockTitleSpan.CodeSpanModel whoClicked(int x, int y) {
        for (Map.Entry<Rect, CodeBlockTitleSpan.CodeSpanModel> entry : copyRectMap.entrySet()) {
            Rect key = entry.getKey();
            CodeBlockTitleSpan.CodeSpanModel value = entry.getValue();
            if (x >= key.left && x <= key.right && y >= key.top && y <= key.bottom) {
                return value;
            }
        }

        return null;
    }

    public boolean handleClickEvent(View widget, Spanned spanned, int x, int y) {
        return false;
    }

    /**
     * copy
     *
     * @param widget
     * @param codeContent
     */
    public void onCopyClicked(final View widget, final String codeContent) {
        if (TextUtils.isEmpty(codeContent)) {
            MDLogger.e(TAG, "onCopyClicked...code is null");
            Toast.makeText(widget.getContext(), R.string.copy_failed, Toast.LENGTH_SHORT).show();
            return;
        }

        MDLogger.d(TAG, "onCopyClicked...");
        ClipboardManager clipboard = (ClipboardManager)
                widget.getContext().getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData clip = ClipData.newPlainText("", codeContent);
        clipboard.setPrimaryClip(clip);
        Toast.makeText(widget.getContext(), R.string.copied, Toast.LENGTH_SHORT).show();
    }


    public void onMagnifyClicked(View widget, String content) {
        try {
            Intent intent = new Intent(widget.getContext(), Class.forName("com.fluid.afm.ui.MarkDownPreviewActivity"));
            intent.putExtras(getPreviewBundle(content));
            widget.getContext().startActivity(intent);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }

    protected Bundle getPreviewBundle( String content) {
        Bundle bundle = new Bundle();
        bundle.putString("content", content);
        return bundle;
    }


    public static class CodeSpanModel {
        public int spanStart;
        public int spanEnd;
        public ClickRectType clickRectType;

        @Override
        public String toString() {
            return spanStart + "," + spanEnd + ",clickRectType:" + clickRectType;
        }
    }

    public enum ClickRectType {
        /**
         * copy
         */
        TYPE_COPY,
        /**
         * magnify
         */
        TYPE_MAGNIFY
    }
}
