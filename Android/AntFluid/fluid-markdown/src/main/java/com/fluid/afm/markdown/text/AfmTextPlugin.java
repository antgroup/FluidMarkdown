package com.fluid.afm.markdown.text;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.SpannableStringBuilder;
import android.text.Spanned;

import androidx.annotation.NonNull;
import androidx.appcompat.content.res.AppCompatResources;

import com.fluid.afm.R;
import com.fluid.afm.markdown.ElementClickEventCallback;
import com.fluid.afm.markdown.image.CustomImageSpan;
import com.fluid.afm.markdown.image.FootnoteClickSpan;
import com.fluid.afm.markdown.image.FootnoteSpan;
import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.Utils;
import com.vdurmont.emoji.Emoji;
import com.vdurmont.emoji.EmojiManager;

import org.commonmark.ext.gfm.tables.TableCell;
import org.commonmark.node.Text;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.noties.markwon.AbstractMarkwonPlugin;
import io.noties.markwon.MarkwonVisitor;

public class AfmTextPlugin extends AbstractMarkwonPlugin {
    private static final String TAG = AfmTextPlugin.class.getSimpleName();
    private final Context context;
    private final int singleLineHeight;
    private ElementClickEventCallback customClickListener;

    public AfmTextPlugin(Context context) {
        this.context = context;
        singleLineHeight = Utils.dpToPx(context, 16);
    }

    public AfmTextPlugin setCustomClickListener(ElementClickEventCallback callback) {
        customClickListener = callback;
        return this;
    }

    public void configureVisitor(@NonNull MarkwonVisitor.Builder builder) {
        builder.on(Text.class, (visitor, textNode) -> {
            String markdown = textNode.getLiteral();
            Pattern EMOJI_PATTERN = Pattern.compile(":(\\w+):");
            Matcher emojiMatch = EMOJI_PATTERN.matcher(markdown);
            StringBuilder sb = new StringBuilder();
            int lastIndex = 0;
            while (emojiMatch.find()) {
                sb.append(markdown, lastIndex, emojiMatch.start());
                String emojiCode = emojiMatch.group(1);
                String emoji = getEmoji(emojiCode);
                sb.append(emoji);
                lastIndex = emojiMatch.end();
            }
            sb.append(markdown, lastIndex, markdown.length());
            String newMarkdown = sb.toString();
            Pattern pattern = Pattern.compile("\\[\\^(.*?)]");
            Matcher matcher = pattern.matcher(newMarkdown);
            SpannableStringBuilder spannable = new SpannableStringBuilder(newMarkdown);

            while (matcher.find()) {
                int start = matcher.start();
                int end = matcher.end();
                String index = matcher.group(1);
                int leftMargin = Utils.dpToPx(context, 4);
                MDLogger.d(TAG, "index = " + index);
                if ("\"".equals(index) || "”".equals(index)) {
                    MDLogger.d(TAG, "get \" or ” ");
                    Drawable drawable = AppCompatResources.getDrawable(context, R.drawable.quotes_pic);
                    if (drawable != null) {
                        drawable.setBounds(leftMargin, 0, singleLineHeight + leftMargin, singleLineHeight);
                    }
                    CustomImageSpan imageSpan = new CustomImageSpan(drawable);
                    spannable.setSpan(imageSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                } else if (textNode.getParent() instanceof TableCell) {
                    FootnoteInTableSpan span = new FootnoteInTableSpan(index);
                    spannable.setSpan(span, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                } else {
                    FootnoteSpan footnoteSpan = new FootnoteSpan(index, visitor.configuration().theme().footnoteStyle());
                    spannable.setSpan(footnoteSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                }
                end =  index == null ? end : Math.min(start + index.length(), end);
                spannable.setSpan(new FootnoteClickSpan(index, customClickListener),
                        start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
            }
            MDLogger.d(TAG, "spannable = " + spannable);
            // Set modified text
            visitor.builder().append(spannable);

        });
    }

    private String getEmoji(String emojiCode) {
        Emoji emoji = EmojiManager.getForAlias(emojiCode);
        if (emoji != null) {
            return emoji.getUnicode();
        }
        return ":" + emojiCode + ":";
    }

    @androidx.annotation.NonNull
    @Override
    public String processMarkdown(@androidx.annotation.NonNull String markdown) {
        return super.processMarkdown(markdown);
    }
}
