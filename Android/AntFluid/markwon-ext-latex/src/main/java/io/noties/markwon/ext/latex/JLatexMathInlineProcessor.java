package io.noties.markwon.ext.latex;

import androidx.annotation.Nullable;

import org.commonmark.node.Node;

import java.util.regex.Pattern;

import io.noties.markwon.inlineparser.InlineProcessor;

/**
 * @since 4.3.0
 */
class JLatexMathInlineProcessor extends InlineProcessor {

    // support single $ character
    private static final Pattern RE = Pattern.compile("(\\${2}|\\${1})([\\s\\S]+?)\\1");

    @Override
    public char specialCharacter() {
        return '$';
    }

    @Nullable
    @Override
    protected Node parse() {
        final String latex = match(RE);
        if (latex == null) {
            return null;
        }

        // support single $ character
        int dollarCount = latex.startsWith("$$") ? 2 : 1;
        final JLatexMathNode node = new JLatexMathNode();
        node.latex(latex.substring(dollarCount, latex.length() - dollarCount));

        return node;
    }
}
