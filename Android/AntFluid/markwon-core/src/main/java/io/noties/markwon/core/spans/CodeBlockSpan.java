package io.noties.markwon.core.spans;

import static io.noties.markwon.core.MarkwonTheme.CODE_BLOCK_HEADER_HEIGHT;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.text.Layout;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.style.LeadingMarginSpan;
import android.text.style.MetricAffectingSpan;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.MDLogger;

import io.noties.markwon.core.MarkwonTheme;
import io.noties.markwon.utils.LeadingMarginUtils;
import io.noties.markwon.utils.SpanUtils;

/**
 * @since 3.0.0 split inline and block spans
 */
public class CodeBlockSpan extends MetricAffectingSpan implements LeadingMarginSpan {
    private static final String TAG = "MYA_CodeBlockSpan";

    private final MarkwonTheme theme;
    private final Rect rect = ObjectsPool.rect();
    private final Paint paint = ObjectsPool.paint();
    private final int radius;
    private int leftOffset;
    private BulletListItemSpan bulletListItemSpan;
    private OrderedListItemSpan orderedListItemSpan;

    public CodeBlockSpan(@NonNull MarkwonTheme theme) {
        this.theme = theme;
        this.radius = theme.getCodeBackgroundRadius();
        this.leftOffset = 0;
    }

    public void setListItemSpan(BulletListItemSpan bulletListItemSpan,
                                      OrderedListItemSpan orderedListItemSpan) {
        this.bulletListItemSpan = bulletListItemSpan;
        this.orderedListItemSpan = orderedListItemSpan;
    }

    @Override
    public void updateMeasureState(TextPaint p) {
        apply(p);
    }

    @Override
    public void updateDrawState(TextPaint ds) {
        apply(ds);
    }

    private void apply(TextPaint p) {
        theme.applyCodeBlockTextStyle(p);
    }

    @Override
    public int getLeadingMargin(boolean first) {
        if (bulletListItemSpan != null) {
            leftOffset = bulletListItemSpan.getLeadingMarginIfUsed();
        } else if (orderedListItemSpan != null) {
            leftOffset = orderedListItemSpan.getLeadingMarginIfUsed();
        }
        if (leftOffset != 0) {
            MDLogger.d(TAG, "getLeadingMargin leftOffset=" + leftOffset
                    + ",bulletListItemSpan=" + bulletListItemSpan
                    + ",orderedListItemSpan=" + orderedListItemSpan);
        }
        return theme.codeStyle().blockLeading() - leftOffset;
    }

    @Override
    public void drawLeadingMargin(Canvas c, Paint p, int x, int dir, int top, int baseline, int bottom, CharSequence text, int start, int end, boolean first, Layout layout) {
        if (!SpanUtils.isSelf(start, end, text, this)) {
            return;
        }
        paint.setStyle(Paint.Style.FILL);
        paint.setColor(theme.getCodeBlockBackgroundColor(p));

        int left;
        final int right;
        if (dir > 0) {
            left = 0;
            right = layout.getWidth();
        } else {
            left = x - layout.getWidth();
            right = x;
        }
        left -= leftOffset;
        left = Math.max(0, left);

        final boolean lastLine = selfEnd(end, text, this);

        final boolean firstLine = LeadingMarginUtils.selfStart(start, text, this);
        if (lastLine) {
            // draw bottom
            Paint.FontMetricsInt fontMetrics = p.getFontMetricsInt();
            final int fontHeight = fontMetrics.bottom - fontMetrics.top;
            final int lineHeight = bottom - top;
            if (lineHeight < fontHeight) {
                bottom += (fontHeight - lineHeight / 2 );
                MDLogger.d(TAG, "drawLeadingMargin bottom=" + bottom
                        + ", fontHeight=" + fontHeight
                        + ", lineHeight=" + lineHeight);
            }
            // reduce last line height
            bottom -= lineHeight / 2;
            drawRectWithBottomRound(c, paint, left, top, right, bottom, radius);
        } else if (firstLine) {
            // draw top
            if(theme.codeStyle().isShowTitle()) {
                rect.set(left, top + CODE_BLOCK_HEADER_HEIGHT, right, bottom);
                c.drawRect(rect, paint);
            } else {
                drawRectWithTopRound(c, paint, left, top, right, bottom, radius);
            }
        } else {
            // draw middle left and right line
            rect.set(left, top, right, bottom);
            c.drawRect(rect, paint);
        }
        if (theme.codeStyle().isDrawBorder()) {
            paint.setStyle(Paint.Style.STROKE);
            paint.setColor(theme.codeStyle().borderColor());
            paint.setStrokeWidth(theme.codeStyle().borderWidth());
            float halfStrokeWidth = paint.getStrokeWidth() / 2;
            int saveCount = c.save();
            if (firstLine) {
                if(theme.codeStyle().isShowTitle()) {
                    c.clipRect(left, top + CODE_BLOCK_HEADER_HEIGHT + halfStrokeWidth, right, bottom);
                } else {
                    c.clipRect(left, top + radius + halfStrokeWidth, right, bottom);
                }
            } else {
                c.clipRect(left, top, right, bottom);
            }
            if (lastLine) {
                c.drawRoundRect(left + halfStrokeWidth, top - paint.getStrokeWidth() - radius, right - halfStrokeWidth, bottom - paint.getStrokeWidth(), radius, radius, paint);
            } else {
                c.drawRect(left + halfStrokeWidth, top - paint.getStrokeWidth(), right - halfStrokeWidth, bottom + paint.getStrokeWidth(), paint);
            }
            c.restoreToCount(saveCount);
            paint.setStyle(Paint.Style.FILL);
        }
    }

    private void drawRectWithTopRound(Canvas canvas, Paint paint,
                      float left, float top, float right, float bottom,
                      float radius) {
        int count = canvas.save();
        canvas.clipRect(left, top, right, bottom);
        canvas.drawRoundRect(left, top, right, bottom + radius, radius, radius, paint);
        canvas.restoreToCount(count);
    }

    private void drawRectWithBottomRound(Canvas canvas, Paint paint,
                                         float left, float top, float right, float bottom,
                                         float radius) {
        int count = canvas.save();
        canvas.clipRect(left, top, right, bottom);
        canvas.drawRoundRect(left, top - radius, right, bottom, radius, radius, paint);
        canvas.restoreToCount(count);
    }

    private boolean selfEnd(int end, CharSequence text, Object span) {
        final int spanEnd = ((Spanned) text).getSpanEnd(span);
        return spanEnd == end || spanEnd == end - 1;
    }
}
