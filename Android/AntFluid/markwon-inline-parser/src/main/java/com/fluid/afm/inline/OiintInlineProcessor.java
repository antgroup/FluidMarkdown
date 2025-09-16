package com.fluid.afm.inline;

import org.commonmark.node.Node;
import org.commonmark.node.Text;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import io.noties.markwon.inlineparser.InlineProcessor;
import io.noties.markwon.node.OiintNode;
public class OiintInlineProcessor extends InlineProcessor {
    private static final Pattern PATTERN = Pattern.compile("^\\$\\\\oiint\\$");
    @Override
    public char specialCharacter() {
        return '$';
    }
    @Override
    protected Node parse() {
        final String matched = match(PATTERN);
        if (matched == null) return null;
        final Matcher matcher = PATTERN.matcher(matched);
        if (!matcher.find()) return null;
        final OiintNode parent = new OiintNode();
        parent.appendChild(new Text("\u222F")); // character ∯
        return parent;
    }
}