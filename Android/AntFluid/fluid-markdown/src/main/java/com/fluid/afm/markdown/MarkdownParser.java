package com.fluid.afm.markdown;

import android.content.Context;
import android.graphics.Paint;
import android.os.Build;
import android.os.SystemClock;
import android.util.TypedValue;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.ContextHolder;
import com.fluid.afm.StreamOutStateObserver;
import com.fluid.afm.markdown.code.CodeBlockPlugin;
import com.fluid.afm.markdown.widget.PrinterMarkDownTextView;
import com.fluid.afm.styles.MarkdownStyles;
import com.fluid.afm.utils.MDLogger;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.noties.markwon.AbstractMarkwonPlugin;
import io.noties.markwon.Markwon;
import io.noties.markwon.MarkwonPlugin;
import io.noties.markwon.core.CorePlugin;
import io.noties.markwon.core.MarkwonTheme;
import io.noties.markwon.inlineparser.MarkwonInlineParser;
import io.noties.markwon.inlineparser.MarkwonInlineParserPlugin;

public class MarkdownParser {

    public static final String TAG = "MarkdownParser";
    private Markwon.Builder mMarkwonBuilder;
    private Markwon mMarkwon;
    private final PrinterMarkDownTextView mTextView;
    private final List<StreamOutStateObserver> mStreamOutStateObservers = new ArrayList<>();
    private MarkdownStyles mProductStyles;
    private MarkwonTheme mMarkwonTheme;

    public MarkdownParser(Context context, List<AbstractMarkwonPlugin> plugins, PrinterMarkDownTextView textView, MarkdownStyles styles) {
        this.mTextView = textView;
        mProductStyles = styles;
        init(context, plugins);
    }

    public void updateMarkdownStyles(MarkdownStyles styles) {
        if (styles == null) {
            return;
        }
        mProductStyles = styles;
        if (mMarkwonTheme != null) {
            mMarkwonTheme.updateStyles(styles);
        }
        if (mTextView == null) {
            return;
        }
        updateTextViewStyle(styles);
        mTextView.setText(mTextView.getText());
    }

    private void updateTextViewStyle(MarkdownStyles styles) {
        if (styles == null) {
            return;
        }
        if (styles.paragraphStyle().fontSize() > 0) {
            mTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, styles.paragraphStyle().fontSize());
        }
        if (styles.paragraphStyle().lineHeight() > 0) {
            mTextView.setLineSpacing(0, 1.f);
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                mTextView.setFallbackLineSpacing(false);
            }
            Paint.FontMetrics fontMetrics = mTextView.getPaint().getFontMetrics();
            mTextView.setLineSpacing(styles.paragraphStyle().lineHeight() - (fontMetrics.bottom- fontMetrics.top), 1f);
        }
        if (styles.paragraphStyle().fontColor() != 0) {
            mTextView.setTextColor(styles.paragraphStyle().fontColor());
        }
    }

    public void setPrintingState(boolean isPrinting) {
        try {
            for (StreamOutStateObserver observer : mStreamOutStateObservers) {
                observer.onStreamOutStateChanged(isPrinting);
            }
        } catch (Exception e) {
            MDLogger.e(TAG, "delieverIsAnimationFinish error", e);
        }
    }

    private void init(final Context context, List<AbstractMarkwonPlugin> customPlugins) {
        if(ContextHolder.getContext() == null) {
            ContextHolder.setContext(context.getApplicationContext());
        }
        List<MarkwonPlugin> plugins = new ArrayList<>();
        if (customPlugins != null) {
            plugins.addAll(customPlugins);
        }
        for (Object obj : plugins) {
            if (obj instanceof StreamOutStateObserver) {
                mStreamOutStateObservers.add((StreamOutStateObserver) obj);
            }
        }
        plugins.addAll(getDefaultPlugins(context));
        mMarkwonBuilder = Markwon.builderWithPlugs(context, plugins);
        mMarkwonTheme = MarkwonTheme.emptyBuilder().setStyles(mProductStyles).setTextView(mTextView).build(plugins);
        mMarkwonBuilder.setMarkdownTheme(mMarkwonTheme);
        mMarkwon = mMarkwonBuilder.build();
        updateTextViewStyle(mProductStyles);
    }

    private ArrayList<AbstractMarkwonPlugin> getDefaultPlugins(final Context context) {
        long startTime = SystemClock.elapsedRealtime();
        ArrayList<AbstractMarkwonPlugin> plugins = new ArrayList<>(4);
        plugins.add(CorePlugin.create(context));
        plugins.add(CodeBlockPlugin.create(context, true));
        plugins.add(new AbstractMarkwonPlugin() {

            @NonNull
            @Override
            public String processMarkdown(@NonNull String markdown) {
                String regex = "\\${1,2}\\s*\\\\bm\\{([A-Za-z]{1,9})\\}\\s*\\${1,2}";
                Pattern pattern = Pattern.compile(regex);
                Matcher matcher = pattern.matcher(markdown);
                StringBuffer output = new StringBuffer();
                while (matcher.find()) {
                    String content = matcher.group(1);
                    matcher.appendReplacement(output, "***" + content + "***");
                }
                matcher.appendTail(output);
                return super.processMarkdown(output.toString());
            }

        });
        plugins.add(MarkwonInlineParserPlugin.create(MarkwonInlineParser.factoryBuilder()));
        MDLogger.d(TAG, "addPlugin costTime=" + (SystemClock.elapsedRealtime() - startTime));
        return plugins;
    }

    public TextView getTextView() {
        return mTextView;
    }

    public void setTextSetter(Markwon.TextSetter setter) {
        mMarkwonBuilder.textSetter(setter);
    }

    public Markwon getMarkwon() {
        return mMarkwon;
    }
}