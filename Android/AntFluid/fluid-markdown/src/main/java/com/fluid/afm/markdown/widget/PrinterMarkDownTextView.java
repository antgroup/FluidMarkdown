package com.fluid.afm.markdown.widget;

import android.content.Context;
import android.content.ContextWrapper;
import android.graphics.Color;
import android.graphics.Rect;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.CharacterStyle;
import android.text.style.ForegroundColorSpan;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewParent;

import androidx.annotation.NonNull;
import androidx.appcompat.widget.AppCompatTextView;
import androidx.lifecycle.DefaultLifecycleObserver;
import androidx.lifecycle.LifecycleOwner;
import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.IMarkdownLayer;
import com.fluid.afm.icon.LoadIconUtil;
import com.fluid.afm.markdown.ElementClickEventCallback;
import com.fluid.afm.markdown.MarkdownParser;
import com.fluid.afm.markdown.MarkdownParserFactory;
import com.fluid.afm.markdown.model.EventModel;
import com.fluid.afm.markdown.span.OpacitySpan;
import com.fluid.afm.span.IClickableSpan;
import com.fluid.afm.styles.MarkdownStyles;
import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.Utils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import io.noties.markwon.image.AsyncDrawableSpan;

public class PrinterMarkDownTextView extends AppCompatTextView implements IMarkdownLayer, DefaultLifecycleObserver, TextWatcher {
    private static final String TAG = "PrinterMarkDownTextView";
    public static final String END_MESSAGE = "(stopped）";
    private static final Handler MAIN_HANDLER = new Handler(Looper.getMainLooper());

    private static final int GRADIANT_COUNT = 10;
    protected MarkdownParser mMarkdownParser;
    private MarkdownStyles mMarkdownStyles;
    private ElementClickEventCallback mElementClickEventCallback;
    protected String mOriginText;
    private int mExposureNodeCount;
    private boolean initialedScrollerWatcher = false;
    private IClickableSpan[] mClickableSpans;
    private List<EventModel> mEventModels = new ArrayList<>();

    private int mInterval = 25;
    private int mChunkSize = 1;
    private SizeChangedListener mSizeChangedListener;
    private PrintingEventListener mPrintingEventListener;
    private boolean isPrinting;
    private boolean isStopByUser;
    private int mCurrentPrintIndex;
    private SpannableStringBuilder mParsedContentText;
    private final Runnable mPrintTask = () -> printing(mCurrentPrintIndex, mChunkSize);
    private String mEndMessage = END_MESSAGE;
    private boolean isDestroyed;
    private OpacitySpan[] mGradiantSpans;
    private int mHeight;
    private int maxWidth = 0;
    private boolean isStarted;
    private MarkDownPrintData mPrintData;

    public PrinterMarkDownTextView(Context context) {
        this(context, null);
    }

    public PrinterMarkDownTextView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public PrinterMarkDownTextView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            setFallbackLineSpacing(false);
        }
        if (context instanceof LifecycleOwner) {
            ((LifecycleOwner) context).getLifecycle().addObserver(this);
        } else if (context instanceof ContextWrapper) {
            Context realContext = ((ContextWrapper) context).getBaseContext();
            if (realContext instanceof LifecycleOwner) {
                ((LifecycleOwner) realContext).getLifecycle().addObserver(this);
            }
        }

        setHighlightColor(Color.TRANSPARENT);
        addTextChangedListener(this);
        setOnLongClickListener(v -> true);
    }

    public void init(@NonNull MarkdownStyles styles, ElementClickEventCallback callback) {
        mMarkdownStyles = styles;
        mElementClickEventCallback = callback;
        mMarkdownParser = MarkdownParserFactory.create(getContext(), this, styles, callback);
    }

    public void setPrintParams(int interval, int chunkSize) {
        if (mInterval > 0) {
            mInterval = interval;
        }
        if(chunkSize > 0) {
            mChunkSize = chunkSize;
        }
    }

    public void handleExposureSpm() {
        handleSpm();
    }

    public void setMarkdownText(@NonNull String markdown) {
        if (mMarkdownParser == null) {
            MDLogger.e(TAG, "PrinterMarkDownTextView is not initialized. Please call init() first.");
            return;
        }
        mOriginText = markdown;
        setMinHeight(0);
        mMarkdownParser.getMarkwon().setMarkdown(this, markdown);
    }

    public void startPrinting(String content) {
        startPrinting(content, 0);
    }

    public boolean isStarted() {
        return isStarted;
    }

    public void startPrinting(String content, int startIndex) {
        if (mMarkdownParser == null) {
            MDLogger.e(TAG, "PrinterMarkDownTextView is not initialized. Please call init() first.");
            return;
        }
        if (isStarted) {
            MDLogger.e(TAG, "appendPrinting printing has started!");
            return;
        }
        setMinHeight(0);
        mCurrentPrintIndex = 0;
        isPrinting = true;
        isStopByUser = false;
        mOriginText = content;
        isStarted = true;
        if (startIndex <= 0) {
            startIndex = 0;
        }

        mMarkdownParser.setPrintingState(true);
        mParsedContentText = new SpannableStringBuilder(mMarkdownParser.getMarkwon().toMarkdown(mOriginText));
        printing(startIndex, mChunkSize);
        if (mPrintingEventListener != null) {
            mPrintingEventListener.onPrintStart();
        }
        if (mPrintData != null) {
            mPrintData.isStopByUser = false;
            mPrintData.isPrinting = isPrinting;
            mPrintData.originalText = mOriginText;
            mPrintData.parsedMarkdownText = mParsedContentText;
            mPrintData.interval = mInterval;
            mPrintData.chunkSize = mChunkSize;
        }

    }
    public void appendPrinting(String content) {
        appendPrinting(content, true);
    }

    public void appendPrinting(String content, boolean append) {
        if (!isStarted) {
            MDLogger.e(TAG, "appendPrinting printing has not started!");
            return;
        }
        if (append) {
            mOriginText += content;
        } else {
            mOriginText = content;
        }

        mParsedContentText = new SpannableStringBuilder(mMarkdownParser.getMarkwon().toMarkdown(mOriginText));
        isStopByUser = false;
        isPrinting = true;
        printing(mCurrentPrintIndex, mChunkSize);
        if (mPrintData != null) {
            mPrintData.isPrinting = isPrinting;
            mPrintData.originalText = mOriginText;
            mPrintData.parsedMarkdownText = mParsedContentText;
        }
    }
    public void setPrintData(MarkDownPrintData printData) {
        mPrintData = printData;
    }

    public MarkDownPrintData getPrintData() {
        return mPrintData;
    }

    public void stopPrinting(String endMessage) {
        if (!isStarted) {
            MDLogger.e(TAG, "appendPrinting printing has not started!");
            return;
        }
        isStarted = false;
        if (!isPrinting) {
            return;
        }
        mEndMessage = endMessage;
        isStopByUser = true;
        MAIN_HANDLER.removeCallbacks(mPrintTask);
        isPrinting = false;
        mMarkdownParser.setPrintingState(false);
        if (!TextUtils.isEmpty(endMessage)) {
            mEndMessage = endMessage;
        }
        clearGradient();
        boolean printAll = mCurrentPrintIndex >= mParsedContentText.length() - 1;
        SpannableStringBuilder span = handleSpan(mParsedContentText, mCurrentPrintIndex, printAll ? null : mEndMessage);
        if (!printAll) {
            setEndMessageStyle(span);
        }
        setTextSafely(span);
        if (mPrintingEventListener != null) {
            mPrintingEventListener.onPrintStop(printAll);
        }
        if (mPrintData != null) {
            mPrintData.showingText = span;
            mPrintData.isPrinting = isPrinting;
            mPrintData.isStopByUser = isStopByUser;
        }
    }

    public void restore(MarkDownPrintData markDownData) {
        MDLogger.d(TAG, "restore-markDownData:" + markDownData);
        if (markDownData == null || TextUtils.isEmpty(markDownData.showingText)) {
            return;
        }
        if (mPrintData == markDownData) {
            return;
        }
        mPrintData = markDownData;
        setMinHeight(0);
        mParsedContentText = mPrintData.parsedMarkdownText;
        mCurrentPrintIndex = mPrintData.currentIndex;
        mChunkSize = mPrintData.chunkSize;
        mInterval = mPrintData.interval;
        isPrinting = mPrintData.isPrinting;
        isStopByUser = mPrintData.isStopByUser;
        setTextSafely(mPrintData.showingText);
        mOriginText = mPrintData.originalText;
        if (isPrinting && !isStopByUser) {
            printing(mCurrentPrintIndex, mChunkSize);
        }
        handleSpm();
    }

    public void setSizeChangedListener(SizeChangedListener listener) {
        mSizeChangedListener = listener;
    }

    public void setPrintingEventListener(PrintingEventListener listener) {
        mPrintingEventListener = listener;
    }

    public void pause() {
        if (!isStarted) {
            MDLogger.e(TAG, "appendPrinting printing has not started!");
            return;
        }
        isPrinting = false;
        mMarkdownParser.setPrintingState(false);
        MAIN_HANDLER.removeCallbacks(mPrintTask);
        if (mPrintingEventListener != null) {
            mPrintingEventListener.onPrintPaused(mCurrentPrintIndex);
        }
    }

    public void resume() {
        resume(mCurrentPrintIndex);
    }

    public void resume(int index) {
        if (!isStarted) {
            MDLogger.e(TAG, "appendPrinting printing has not started!");
            return;
        }
        if (isPrinting) {
            return;
        }
        isStopByUser = false;
        isPrinting = true;
        if (index <= mParsedContentText.length()) {
            mMarkdownParser.setPrintingState(true);
            printing(mCurrentPrintIndex, mChunkSize);
        }
        if (mPrintingEventListener != null) {
            mPrintingEventListener.onPrintResumed();
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        int newHeight = getMeasuredHeight();
        if (newHeight != mHeight ) {
            if (mSizeChangedListener != null) {
                mSizeChangedListener.onSizeChanged(getMeasuredWidth(), newHeight);
            }
            if(newHeight > mHeight) {
                setMinHeight(newHeight);
            }
            mHeight = newHeight;
        }
    }

    private void printing(int start, int chunkSize) {
        if (isDestroyed) {
            return;
        }
        int end = start + chunkSize;
        if (end >= mParsedContentText.length()) {
            MDLogger.i(TAG, "end >= spannablePrintText.length()");
            isPrinting = false;
            mMarkdownParser.setPrintingState(false);
            setTextSafely(mParsedContentText);
            onStopPrinting();
        } else {
            SpannableStringBuilder newSpannable = handleSpan(mParsedContentText, end);
            if (newSpannable == null) {
                return;
            }
            mCurrentPrintIndex = end;
            gradiantColorAnimateText(mCurrentPrintIndex, newSpannable);
            setTextSafely(newSpannable);
            if (!isStopByUser) {
                MAIN_HANDLER.removeCallbacks(mPrintTask);
                MAIN_HANDLER.postDelayed(mPrintTask, mInterval);
            } else {
                MAIN_HANDLER.removeCallbacks(mPrintTask);
                MDLogger.i(TAG, "printing---isStopByUser==true");
                isPrinting = false;
                onStopPrinting();
            }
        }
        if (mPrintData != null) {
            mPrintData.currentIndex = mCurrentPrintIndex;
        }

    }

    private void clearGradient() {
        if (mGradiantSpans == null) {
            return;
        }
        mParsedContentText.removeSpan(OpacitySpan.class);
    }

    /**
     * 实现渐变打字的动画
     */
    private void gradiantColorAnimateText(int endIndex, SpannableStringBuilder spannableStringBuilder) {
        if (endIndex == mParsedContentText.length()) {
            return;
        }
        if (mGradiantSpans == null) {
            mGradiantSpans = new OpacitySpan[GRADIANT_COUNT];
            for (int i = 0; i < GRADIANT_COUNT; i++) {
                int alpha = (int) (255f * i / GRADIANT_COUNT);
                mGradiantSpans[GRADIANT_COUNT - i - 1] = new OpacitySpan(alpha);
            }
        }

        for (int i = 0; i < GRADIANT_COUNT; i++) {
            int textIndex = endIndex - i - 1;
            if (textIndex < 0) {
                break;
            }
            spannableStringBuilder.setSpan(mGradiantSpans[GRADIANT_COUNT - i - 1], textIndex, textIndex + 1, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        }
    }

    private SpannableStringBuilder handleSpan(SpannableStringBuilder source, int end) {
        return handleSpan(source, end, "");
    }

    private SpannableStringBuilder handleSpan(SpannableStringBuilder source, int end, String endTag) {
        SpannableStringBuilder newSpannable;
        if (TextUtils.isEmpty(endTag)) {
            newSpannable = new SpannableStringBuilder(source.subSequence(0, end));
        } else {
            newSpannable = new SpannableStringBuilder(source.subSequence(0, end)).append(endTag);
        }
        CharacterStyle[] spans = source.getSpans(0, end, CharacterStyle.class);
        if (spans == null) {
            return null;
        }
        for (CharacterStyle span : spans) {
            if (span == null) {
                continue;
            }
            int spanStart = source.getSpanStart(span);
            int spanEnd = source.getSpanEnd(span);
            int flags = source.getSpanFlags(span);

            newSpannable.setSpan(span, spanStart, Math.min(spanEnd, end), flags);
        }

        return newSpannable;
    }

    private void onStopPrinting() {
        if (mPrintingEventListener != null) {
            mPrintingEventListener.onPrintStop(mParsedContentText == null || mCurrentPrintIndex == mParsedContentText.length());
        }
    }

    private void setEndMessageStyle(SpannableStringBuilder span) {
        if (TextUtils.isEmpty(mEndMessage)) {
            return;
        }
        // 设置颜色
        span.setSpan(
                new ForegroundColorSpan(Color.parseColor("#999999")),
                span.length() - mEndMessage.length(),
                span.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
        );
        // 设置字体大小
        span.setSpan(
                new AbsoluteSizeSpan(Utils.dpToPx(getContext(), 13), false),
                span.length() - mEndMessage.length(),
                span.length(),
                Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
        );
    }

    public void onDestroy() {
        LoadIconUtil.check();
        isDestroyed = true;
        mPrintData = null;
    }

    @Override
    public void onDestroy(@NonNull LifecycleOwner l) {
        onDestroy();
    }


    public void setMarkdownStyles(MarkdownStyles markdownStyles) {
        if (mMarkdownParser != null) {
            mMarkdownStyles = markdownStyles;
            mMarkdownParser.updateMarkdownStyles(markdownStyles);
        }
    }

    public void setTextSafely(SpannableStringBuilder spanned) {
        if (mMarkdownParser != null) {
            mMarkdownParser.getMarkwon().setParsedMarkdown(this, spanned);
        }
        if (mPrintData != null && spanned != null) {
            mPrintData.showingText = spanned;
        }
    }

    public void setMaxWidthForMeasure(int maxWidth) {
        this.maxWidth = maxWidth;
    }

    @Override
    public int getViewMaxWidth() {
        return maxWidth;
    }

    @Override
    public String getOriginText() {
        return mOriginText;
    }

    @Override
    public void beforeTextChanged(CharSequence s, int start, int count, int after) {
        /* no-op */

    }

    @Override
    public void onTextChanged(CharSequence s, int start, int before, int count) {
        /* no-op */
    }

    @Override
    public void afterTextChanged(Editable s) {
        if (mElementClickEventCallback == null) {
            return;
        }
        CharSequence str = getText();
        if (!(str instanceof Spannable)) {
            return;
        }
        Spanned spanned = (Spanned) str;
        if (spanned.length() == 0) {
            return;
        }
        IClickableSpan[] clickableSpans = spanned.getSpans(0, spanned.length(), IClickableSpan.class);
        if (clickableSpans == null || clickableSpans.length == mExposureNodeCount) {
            return;
        }
        mClickableSpans = clickableSpans;
        handleScrollerSpm();
        mExposureNodeCount = clickableSpans.length;
        post(() -> handleSpm(clickableSpans));
    }

    private void handleScrollerSpm() {
        if (initialedScrollerWatcher || mClickableSpans == null) {
            return;
        }
        initialedScrollerWatcher = true;
        View scroller = findScroller(getParent());
        if (scroller instanceof RecyclerView) {
            ((RecyclerView)scroller).addOnScrollListener(new RecyclerView.OnScrollListener() {
                @Override
                public void onScrollStateChanged(RecyclerView recyclerView, int state) {
                    super.onScrollStateChanged(recyclerView, state);
                    if (state == RecyclerView.SCROLL_STATE_IDLE) {
                        handleSpm(mClickableSpans);
                    }
                }
            });
        } else if (scroller != null) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                scroller.setOnScrollChangeListener((v, scrollX, scrollY, oldScrollX, oldScrollY) -> handleSpm(mClickableSpans));
            }

        }
    }

    private View findScroller(ViewParent child) {
        ViewParent parent = child.getParent();
        if (parent instanceof View && (parent instanceof RecyclerView || ((View)parent).isScrollContainer())) {
            return (View) parent;
        } else if (parent == null) {
            return null;
        }
        return findScroller(parent);
    }

    private void handleSpm() {
        if (mClickableSpans == null || mClickableSpans.length == 0) {
            return;
        }
        handleSpm(mClickableSpans);
    }
    private void handleSpm(IClickableSpan[] spans) {
        if (spans == null || spans.length == 0) {
            return;
        }
        Rect rect = new Rect();
        boolean isVisible = getGlobalVisibleRect(rect);
        MDLogger.d(TAG, "updateEventLogList:rect:" + rect + " rect isVisible:" + isVisible);

        int startY = 0;
        int endY = 0;
        if (isVisible) {
            int[] pos = new int[2];
            getLocationOnScreen(pos);
            startY = rect.top - pos[1];
            endY = startY + rect.height();
            MDLogger.d(TAG, "updateEventLogList:location:" + Arrays.toString(pos) + ",startY:" + startY + ",endY:" + endY);
        }
        List<EventModel> models = new ArrayList<>();
        for (IClickableSpan span : spans) {
            if (span instanceof AsyncDrawableSpan && !((AsyncDrawableSpan) span).isClickable()) {
                return;
            }
            boolean visible = (span.getTop() > startY && span.getTop() < endY) // visible Top
                    || span.getBottom() > startY && span.getBottom() < endY; // visible Bottom
            MDLogger.d(TAG, "updateEventLogList:" + span.getClass().getSimpleName() + " span.getTop():" + span.getTop() + ", span.getBottom()" + span.getBottom() + ",visible:" + visible);
            models.add(new EventModel(span.getType(), span.getUrl(), span.getLiteral(), visible));
        }
        if (models.equals( mEventModels)) {
            return;
        }
        this.mEventModels = models;
        if (mElementClickEventCallback != null) {
            mElementClickEventCallback.exposureSpmBehavior(models);
        }
    }

    public int getPrintIndex() {
        return mCurrentPrintIndex;
    }

    public interface SizeChangedListener {
        void onSizeChanged(int width, int height);
    }

    public interface PrintingEventListener {
        void onPrintStart();

        void onPrintStop(boolean printAll);
        void onPrintPaused(int index);

        void onPrintResumed();
    }
    public static class MarkDownPrintData {
        public int chunkSize;
        public int interval;
        public boolean isPrinting;
        public boolean isStopByUser;
        public String originalText;
        public SpannableStringBuilder showingText; // showingData
        public SpannableStringBuilder parsedMarkdownText; // fullData
        public int currentIndex;
        public boolean hasBoundView;

        @Override
        public String toString() {
            return "MarkDownPrintData{" +
                    "chunkSize=" + chunkSize +
                    ", speed=" + interval +
                    ", isPrinting=" + isPrinting +
                    ", showingText='" + showingText + '\'' +
                    ", printingText='" + parsedMarkdownText + '\'' +
                    ", currentIndex=" + currentIndex +
                    ", createdView=" + hasBoundView +
                    '}';
        }
    }

}
