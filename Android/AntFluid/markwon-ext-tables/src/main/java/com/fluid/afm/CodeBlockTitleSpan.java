package com.fluid.afm;

import android.content.Context;
import android.graphics.Paint;
import android.os.Bundle;
import android.text.Spanned;
import android.view.View;

import androidx.annotation.Keep;
import androidx.appcompat.content.res.AppCompatResources;

import com.fluid.afm.utils.MDLogger;

import io.noties.markwon.core.MarkwonTheme;
import com.fluid.afm.span.CodeLanguageSpan;
import io.noties.markwon.ext.tables.R;
import com.fluid.afm.utils.Utils;

@Keep
public class CodeBlockTitleSpan extends BaseBlockTitleSpan {
    protected static final String TAG = CodeBlockTitleSpan.class.getSimpleName();

    private MarkwonTheme mMarkwonTheme;

    public CodeBlockTitleSpan(Context context, MarkwonTheme theme, int height, int textSize) {
        super(context, height, textSize);
        try {
            this.mMarkwonTheme = theme;
            magnifyIcon = AppCompatResources.getDrawable(context, R.drawable.icon_table_magnify_light);
            copyIcon = AppCompatResources.getDrawable(context, R.drawable.icon_table_copy_light);
            final int size = Utils.dpToPx(context, 22);
            copyIcon.setBounds(0, 0, size, size);
            magnifyIcon.setBounds(0, 0, size, size);
        } catch (Throwable e) {
            MDLogger.d(TAG, "CodeBlockHeaderSpan e:" + e);
        }
    }

    protected int getBackgroundRadius() {
        if (mMarkwonTheme != null && mMarkwonTheme.getCodeBackgroundRadius() >= 0) {
            return mMarkwonTheme.getCodeBackgroundRadius();
        }
        return 24;
    }

    public CodeBlockTitleSpan(Context context, int height, int textSize, int tableIndex) {
        super(context, height, textSize, tableIndex);
        try {
            copyIcon = AppCompatResources.getDrawable(context, R.drawable.icon_table_copy_light);
            if (copyIcon != null) {
                final int width = Utils.dpToPx(context, 22);
                copyIcon.setBounds(0, 0, width, width);
            }
        } catch (Throwable e) {
            MDLogger.e(TAG, e);
        }
    }

    @Override
    protected boolean drawBorder() {
        return mMarkwonTheme.codeStyle().isDrawBorder();
    }

    @Override
    protected void applyBorderStyle(Paint paint) {
        paint.setStyle(Paint.Style.STROKE);
        paint.setColor(mMarkwonTheme.codeStyle().borderColor());
        paint.setStrokeWidth(mMarkwonTheme.codeStyle().borderWidth());
    }

    protected String getBlockContent(ClickRectType clickRectType, Spanned spanned, int start) {
        StringBuilder stringBuilder = new StringBuilder();
        try {
            String code = spanned.subSequence(start, spanned.getSpanEnd(this)).toString().trim();
            if (clickRectType == ClickRectType.TYPE_MAGNIFY) {
                stringBuilder.append("```").append(blockTitle).append(code.replace("\u00A0", "")).append("```");
            } else if (clickRectType == ClickRectType.TYPE_COPY) {
                stringBuilder.append(code.replace("\u00A0", ""));
            }
        } catch (Exception e) {
            MDLogger.e(TAG, "getBlockContent", e);
        }
        return stringBuilder.toString();
    }

    @Override
    public boolean handleClickEvent(View widget, Spanned spanned, int x, int y) {
        CodeSpanModel spanModel = whoClicked(x, y);
        if (spanModel == null) {
            MDLogger.d(TAG, "handleClickEvent nobody clicked");
            return false;
        }
        MDLogger.d(TAG, "handleClickEvent:" + spanModel);
        String code = getBlockContent(spanModel.clickRectType, spanned, spanModel.spanStart);
        if (spanModel.clickRectType == ClickRectType.TYPE_COPY) {
            // copy clicked
            onCopyClicked(widget, code);
        } else if (spanModel.clickRectType == ClickRectType.TYPE_MAGNIFY) {
            // magnify clicked
            onMagnifyClicked(widget, code);
        }
        return true;
    }


    protected String getBlockTitle(CharSequence text, int start) {
        if (text instanceof Spanned) {
            CodeLanguageSpan[] codeLanguageSpans = ((Spanned) text).getSpans(start, text.length(), CodeLanguageSpan.class);
            if (codeLanguageSpans == null || codeLanguageSpans.length == 0) {
                return "";
            }
            return codeLanguageSpans[codeLanguageSpans.length - 1].getLanguage();
        }
        return "";
    }

    @Override
    protected int getTextColor() {
        if (mMarkwonTheme.codeStyle().titleFontColor() != 0) {
            return mMarkwonTheme.codeStyle().titleFontColor();
        }
        return super.getTextColor();
    }

    @Override
    protected float getTextSize() {
        if (mMarkwonTheme.codeStyle().titleFontSize() > 0) {
            return mMarkwonTheme.codeStyle().titleFontSize();
        }
        return super.getTextSize();
    }

    @Override
    protected int getBackgroundColor() {
        if (mMarkwonTheme.codeStyle().titleBackgroundColor() != 0) {
            return mMarkwonTheme.codeStyle().titleBackgroundColor();
        }
        return super.getBackgroundColor();
    }

    @Override
    protected int getBorderColor() {
        if (mMarkwonTheme.codeStyle().borderColor() != 0) {
            return mMarkwonTheme.codeStyle().borderColor();
        }
        return super.getBorderColor();
    }

    @Override
    protected int getBorderWidth() {
        return mMarkwonTheme.codeStyle().borderWidth();
    }

    protected Bundle getPreviewBundle(String content) {
        Bundle bundle = super.getPreviewBundle(content);
        bundle.putParcelable("codeStyle", mMarkwonTheme.codeStyle());
        bundle.putBoolean("isCode", true);
        return bundle;
    }

}
