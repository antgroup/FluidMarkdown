package io.noties.markwon.core.spans;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.text.Layout;
import android.text.TextPaint;
import android.text.TextUtils;

import androidx.annotation.IntRange;
import androidx.annotation.NonNull;

import com.fluid.afm.span.BaseIconTextSpan;
import com.fluid.afm.styles.TitleStyle;

import io.noties.markwon.core.MarkwonTheme;

/**
 * 标题
 */
public class HeadingSpan extends BaseIconTextSpan {

    private final MarkwonTheme theme;
    private final int level;
    private TitleStyle style;

    public HeadingSpan(@NonNull MarkwonTheme theme, @IntRange(from = 1, to = 6) int level) {
        super(theme.getTextView());
        this.theme = theme;
        this.level = level;
        style = theme.getTitleStyles(level - 1);
    }

    @Override
    protected String getImageUrl() {
        if (style != null) {
            return style.icon();
        }
        return "";
    }

    @Override
    protected void applyStyle(TextPaint paint) {
        style = theme.getTitleStyles(level - 1);
        style.apply(paint);
    }

    @Override
    public int getLeadingMargin(boolean first) {
        // no margin actually, but we need to access Canvas to draw break
        if (style != null && first && !TextUtils.isEmpty(style.icon())) {
            return realTextSize;
        }
        return 0;
    }

    @Override
    public void drawLeadingMargin(Canvas c, Paint p, int x, int dir, int top, int baseline, int bottom, CharSequence text, int start, int end, boolean first, Layout layout) {
        if (first && mDrawableWrapper != null && mDrawableWrapper.getDrawable() != null) {
            c.save();
            c.translate(x, baseline - iconOffset);
            mDrawableWrapper.getDrawable().draw(c);
            c.restore();
        }
    }

    /**
     * @since 4.2.0
     */
    public int getLevel() {
        return level;
    }





}
