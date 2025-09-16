package com.fluid.afm.markdown.html;

import android.os.SystemClock;
import android.text.SpannableStringBuilder;
import android.text.Spanned;
import android.text.TextUtils;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.utils.MDLogger;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.noties.markwon.html.HtmlPlugin;

public class CustomHtmlPlugin extends HtmlPlugin {
    private static final String TAG = CustomHtmlPlugin.class.getSimpleName();

    CustomHtmlPlugin() {
        super();
    }

    public static CustomHtmlPlugin create() {
        return new CustomHtmlPlugin();
    }

    @NonNull
    @Override
    public String processMarkdown(@NonNull String markdown) {
        markdown = super.processMarkdown(markdown);
        markdown = modifyHighlightData(markdown);
        markdown = appendPoiAndRelatedEntityData(markdown);
        markdown = handleFormulaCompat(markdown);
        return markdown;
    }

    @Override
    public void beforeSetText(@NonNull TextView textView, @NonNull Spanned markdown) {
        super.beforeSetText(textView, markdown);

        try {
            if (markdown instanceof SpannableStringBuilder) {
                int tableIndex = markdown.toString().indexOf("| |-");
                if (tableIndex == -1) {
                    tableIndex = markdown.toString().indexOf("||-");
                }
                if (tableIndex == -1) {
                    tableIndex = markdown.toString().indexOf("| |:");
                }
                if (tableIndex != -1) {
                    ((SpannableStringBuilder) markdown).insert(tableIndex + 2, "\n");
                }
            }
        } catch (Throwable e) {
            MDLogger.e(TAG, "beforeSetText...e:" + e);
        }
    }
    private String modifyHighlightData(String markdown) {
        long startTime = SystemClock.elapsedRealtime();
        try {
            // Regular expression to match <span> tags with class="highlight" or class='highlight'
            String regex = "<span\\s+[^>]*class=[\"|']highlight[\"|'][^>]*>(.*?)</span>";

            // Compile the regex
            Pattern pattern = Pattern.compile(regex);

            // Create a matcher object
            Matcher matcher = pattern.matcher(markdown);
            // Find all matches
            int groupIndex = 0;
            while (matcher.find()) {
                // Print the content inside the <span> tag
                String span = matcher.group();
                ++groupIndex;
                if (TextUtils.isEmpty(span)) {
                    MDLogger.d(TAG, "span is null");
                    continue;
                }

                String spanContent = span.substring(span.indexOf('>') + 1, span.lastIndexOf('<'));
                if (!TextUtils.isEmpty(spanContent) && spanContent.length() > 1) {
                    StringBuilder afterSpan = new StringBuilder();
                    char[] spanArray = spanContent.toCharArray();
                    for (char c : spanArray) {
                        String single = span.replace(spanContent, String.valueOf(c));
                        afterSpan.append(single);
                    }
                    MDLogger.d(TAG, "modifyHighlightData afterSpan=" + afterSpan);
                    markdown = markdown.replace(span, afterSpan);
                }
            }

            final long costTime = (SystemClock.elapsedRealtime() - startTime);
            if (costTime > 5) {
                MDLogger.d(TAG, "modifyHighlightData end cost:" + costTime);
            }
        } catch (Throwable e) {
            MDLogger.e(TAG, "modifyHighlightData...e:" + e);
        }

        return markdown;
    }

    private String appendPoiAndRelatedEntityData(String markdown) {
        long startTime = SystemClock.elapsedRealtime();
        try {
            // Regular expression to match <span> tags with class="highlight" or class='highlight'
            String regex = "<span\\s+[^>]*class=\"(poi|related-entity)\"[^>]*>(.*?)</span>";

            // Compile the regex
            Pattern pattern = Pattern.compile(regex);

            // Create a matcher object
            Matcher matcher = pattern.matcher(markdown);
            // Find all matches
            int groupIndex = 0;
            while (matcher.find()) {
                // Print the content inside the <span> tag
                String span = matcher.group();
                ++groupIndex;
                if (TextUtils.isEmpty(span)) {
                    MDLogger.d(TAG, "append span is null");
                    continue;
                }

                String spanContent = span.substring(span.indexOf('>') + 1, span.lastIndexOf('<'));
                MDLogger.d(TAG, "appendPoiAndRelatedEntityData spanContent=" + spanContent + ", span=" + span);
                if (!TextUtils.isEmpty(spanContent)) {
                    String afterSpan = span.replace("</span>", " </span>");
                    markdown = markdown.replace(span, afterSpan);
                }
            }

            final long costTime = (SystemClock.elapsedRealtime() - startTime);
            if (costTime > 5) {
                MDLogger.d(TAG, "appendPoiAndRelatedEntityData end cost:" + costTime);
            }
        } catch (Throwable e) {
            MDLogger.e(TAG, "appendPoiAndRelatedEntityData...e:" + e);
        }

        return markdown;
    }

    private String handleFormulaCompat(String markdown) {
        try {
            // Regular expression to match formula \[a+b=c\]
            String formulaRegex = "(\\\\\\(.*?\\\\\\)|\\\\\\[[\\s\\S]*?\\\\\\])";

            // Compile the regex
            Pattern pattern = Pattern.compile(formulaRegex, Pattern.DOTALL);

            // Create a matcher object
            Matcher matcher = pattern.matcher(markdown);
            // Find all matches
            while (matcher.find()) {
                // find [a + b =3]
                String formula = matcher.group();
                if (TextUtils.isEmpty(formula)) {
                    MDLogger.d(TAG, "formula is null");
                    continue;
                }

                try {
                    String content = formula.substring(2, formula.length() - 2);
                    if (TextUtils.isEmpty(content) || TextUtils.isEmpty(content.trim())) {
                        MDLogger.d(TAG, "handleFormulaCompat do not handle formula=" + formula);
                        continue;
                    }
                } catch (Throwable e) {
                    MDLogger.e(TAG, "handleFormulaCompat e=" + e);
                }

                String afterFormula = formula;
                if (formula.startsWith("\\[")) {
                    afterFormula = formula.replace("\\[", "$$")
                            .replace("\\]", "$$");
                    markdown = markdown.replace(formula, afterFormula);
                } else {
                    afterFormula = formula.replace("\\(", "$")
                            .replace("\\)", "$");
                    markdown = markdown.replace(formula, afterFormula);
                }

                MDLogger.d(TAG, "handleFormulaCompat afterFormula:" + afterFormula);
            }
        } catch (Throwable e) {
            MDLogger.e(TAG, "handleFormulaCompat...e:" + e);
        }
        return markdown;
    }
}
