package com.fluid.afm;

import android.content.Context;
import android.content.Intent;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.os.Bundle;
import android.text.Spanned;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.content.res.AppCompatResources;

import com.fluid.afm.styles.TableStyle;
import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.Utils;

import org.commonmark.ext.gfm.tables.TableBlock;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.noties.markwon.ext.tables.R;

public class TableBlockTitleBlockSpan extends BaseBlockTitleSpan {
    private static final String TAG = "TableBlockTitleBlockSpan";
    private final int textLeftPadding;
    private final TableStyle mStyle;
    private int columnCount;
    private boolean countIndex = false;
    private TableBlock mTableBlock;
    private static TableBlock sCurrentTableBlock;

    public static void setCurrentTableBlock(TableBlock currentTableBlock) {
        sCurrentTableBlock = currentTableBlock;
    }

    public static TableBlock getCurrentTableBlock() {
        return sCurrentTableBlock;
    }

    public TableBlockTitleBlockSpan(Context context, int height, TableStyle style, int tableIndex, int columnCount, boolean countIndex, TableBlock tableBlock) {
        super(context, height, (int) style.title().fontSize(), tableIndex);
        this.countIndex = countIndex;
        try {
            magnifyIcon = AppCompatResources.getDrawable(context, R.drawable.icon_table_magnify_light);
            final int width = Utils.dpToPx(context, 20);
            magnifyIcon.setBounds(0, 0, width, width);
            this.columnCount = columnCount;
        } catch (Throwable e) {
            MDLogger.e(TAG, e);
        }
        mStyle = style;
        textLeftPadding = mStyle.cellLeftRightPadding();
        mTableBlock = tableBlock;
    }

    public void setTableBlock(TableBlock tableBlock) {
        mTableBlock = tableBlock;
    }

    @Override
    protected int getBackgroundColor() {
        return mStyle.title().backgroundColor();
    }

    protected boolean drawLine() {
        return false;
    }

    @Override
    protected float getTextSize() {
        return mStyle.title().fontSize();
    }

    @Override
    protected void drawBackground(Canvas c, Paint p, int top, int layoutWidth) {
        super.drawBackground(c, p, top, layoutWidth);
        if (!mStyle.drawBorder()) {
            return;
        }
        mStyle.applyTableBorderStyle(p);
        // 绘制圆角矩形的描边
        int saveCount = c.save();
        float radius = getBackgroundRadius(); // 圆角半径，应与 drawRectWithTopRound 中使用的值一致
        c.clipRect(0, 0, layoutWidth, top + rect.height());
        if (p.getStrokeWidth() > 0 && p.getStrokeWidth() <= 1) {
            p.setStrokeWidth(2);
        }
        float halfWidth = p.getStrokeWidth() / 2;
        c.drawRoundRect(rect.left + halfWidth, rect.top + halfWidth, rect.right - halfWidth, rect.bottom + radius + p.getStrokeWidth(), radius, radius, p);
        c.restoreToCount(saveCount);
        // 恢复Paint状态
        p.setStyle(Paint.Style.FILL); // 恢复为填充模式
        p.setStrokeWidth(1); // 恢复默认线宽
    }

    @Override
    protected boolean drawBorder() {
        return mStyle.drawBorder();
    }

    @Override
    protected void applyBorderStyle(Paint paint) {
        mStyle.applyTableBorderStyle(paint);
    }

    @Override
    protected int getBorderColor() {
        return mStyle.borderColor();
    }

    protected int getBackgroundRadius() {
        return mStyle.titleBackgroundRadius();
    }

    protected int getIconRightMargin() {
        return 16;
    }

    protected int getHeaderTextLeftPadding() {
        return textLeftPadding;
    }

    /**
     * 获取当前table block的语音类型
     *
     * @param text
     * @param start
     * @return
     */
    protected String getBlockTitle(CharSequence text, int start) {
        if (ContextHolder.getContext() != null) {
            return ContextHolder.getContext().getResources().getString(R.string.table);
        }
        return "Table";
    }

    @Override
    protected int getTextColor() {
        return mStyle.title().fontColor();
    }

    protected String getBlockContent(View view) {
        return getTableMarkdown(view);
    }

    @Override
    public boolean handleClickEvent(View widget, Spanned spanned, int x, int y) {
        CodeSpanModel spanModel = whoClicked(x, y);
        if (spanModel == null) {
            MDLogger.d(TAG, "handleClickEvent nobody clicked");
            return false;
        } else {
            MDLogger.d(TAG, "handleClickEvent:" + spanModel);
            String code = getBlockContent(widget);
            if (spanModel.clickRectType == CodeBlockTitleSpan.ClickRectType.TYPE_COPY) {
                onCopyClicked(widget, code);
            } else if (spanModel.clickRectType == CodeBlockTitleSpan.ClickRectType.TYPE_MAGNIFY) {
                onMagnifyClicked(widget, "");
            }
            return true;
        }
    }

    @Override
    public void onMagnifyClicked(View widget, String content) {
        try {
            Intent intent = new Intent(widget.getContext(), Class.forName("com.fluid.afm.ui.MarkDownPreviewActivity"));
            Bundle bundle = new Bundle();
            if (mTableBlock != null) {
                sCurrentTableBlock = mTableBlock;
            }
            if (mStyle != null) {
                bundle.putBoolean("hasTableStyle",true);
                bundle.putParcelable("tableStyle", mStyle);
            } else {
                bundle.putBoolean("hasTableStyle", false);
            }
            bundle.putInt("columnCount", columnCount);
            bundle.putBoolean("isTable", true);
            intent.putExtras(bundle);
            widget.getContext().startActivity(intent);
        } catch (ClassNotFoundException e) {
            throw new RuntimeException(e);
        }
    }
    protected Bundle getPreviewBundle(String content) {
        Bundle bundle = super.getPreviewBundle(content);
        bundle.putParcelable("tableStyle", mStyle);
        bundle.putInt("columnCount", columnCount);
        bundle.putBoolean("isTable", true);
        return bundle;
    }

    protected String getTableMarkdown(View view) {
        if (!(view instanceof TextView)) {
            return null;
        } else {
            String markdown = null;
            if (view instanceof IMarkdownLayer) {
                markdown = ((IMarkdownLayer) view).getOriginText();
            }
            if (TextUtils.isEmpty(markdown)) {
                return "";
            } else {
                String regex = "\\|[^\\n]*\\|(\\n\\|[:\\s\\-\\|]*\\|)+\\n(\\|[^\\n]*\\|\\n?)*";
                Pattern pattern = Pattern.compile(regex, Pattern.DOTALL);
                Matcher matcher = pattern.matcher(markdown);
                int index = tableIndex;
                String table = null;
                if (countIndex) {
                    while (index >= 0 && matcher.find()) {
                        table = matcher.group();
                        index--;
                    }
                } else if (matcher.find()) {
                    table = matcher.group();
                }
                MDLogger.d(TAG, "getTableMarkdown get table markdown: " + table);
                return table;
            }
        }
    }
}
