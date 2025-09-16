package com.fluid.afm.markdown.code;

import static io.noties.markwon.core.MarkwonTheme.CODE_BLOCK_HEADER_HEIGHT;

import android.content.Context;

import androidx.annotation.NonNull;

import com.fluid.afm.CodeBlockLineSpacingSpan;
import com.fluid.afm.CodeBlockTitleSpan;
import com.fluid.afm.markdown.text.RoundedBackgroundSpan;

import org.commonmark.node.Code;
import org.commonmark.node.FencedCodeBlock;
import org.commonmark.node.Node;

import io.noties.markwon.AbstractMarkwonPlugin;
import io.noties.markwon.MarkwonSpansFactory;
import io.noties.markwon.MarkwonVisitor;
import io.noties.markwon.core.MarkwonTheme;

public class CodeBlockPlugin extends AbstractMarkwonPlugin {

    private static final String TAG = "CodeBlockPlugin";
    private final Context context;
    private final Boolean showCodeBlockHeader;

    CodeBlockPlugin(@NonNull Context context, boolean showCodeBlockHeader) {
        this.context = context;
        this.showCodeBlockHeader = showCodeBlockHeader;
    }
    @NonNull
    @Override
    public String processMarkdown(@NonNull String markdown) {
        return super.processMarkdown(markdown);
    }

    @Override
    public void configureSpansFactory(@NonNull MarkwonSpansFactory.Builder builder) {
        if (showCodeBlockHeader) {
            builder.appendFactory(FencedCodeBlock.class, (configuration, props) -> new CodeBlockTitleSpan(context, configuration.theme(), CODE_BLOCK_HEADER_HEIGHT, configuration.theme().codeStyle().titleFontSize()));
            builder.appendFactory(FencedCodeBlock.class, (configuration, props) -> new CodeBlockLineSpacingSpan(CODE_BLOCK_HEADER_HEIGHT, 0));
            builder.appendFactory(Code.class, (configuration, props) -> {
                MarkwonTheme markwonTheme = configuration.theme();
                return new RoundedBackgroundSpan(markwonTheme,
                        markwonTheme.getCodeBackgroundRadius());
            });
        }
    }

    @Override
    public void configureVisitor(MarkwonVisitor.Builder builder) {
        builder.blockHandler(new BlockHandlerNoAdditionalNewLines());
    }

    public static CodeBlockPlugin create(Context context, boolean showCodeBlockHeader) {
        return new CodeBlockPlugin(context, showCodeBlockHeader);
    }
}

class BlockHandlerNoAdditionalNewLines implements MarkwonVisitor.BlockHandler {

    public BlockHandlerNoAdditionalNewLines() {
    }

    @Override
    public void blockStart(@NonNull MarkwonVisitor visitor, @NonNull Node node) {
        // ensure that content rendered on a new line
        visitor.ensureNewLine();
    }

    @Override
    public void blockEnd(@NonNull MarkwonVisitor visitor, @NonNull Node node) {
        /* no-op */
    }
}
