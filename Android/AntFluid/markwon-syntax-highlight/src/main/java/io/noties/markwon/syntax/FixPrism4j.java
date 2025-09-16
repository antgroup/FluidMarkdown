package io.noties.markwon.syntax;

import androidx.annotation.NonNull;

import java.util.ArrayList;
import java.util.List;

import io.noties.prism4j.GrammarLocator;
import io.noties.prism4j.Prism4j;
import io.noties.prism4j.TextImpl;

public class FixPrism4j extends Prism4j {
    public FixPrism4j(GrammarLocator grammarLocator) {
        super(grammarLocator);
    }

    @NonNull
    @Override
    public List<Node> tokenize(@NonNull String text, @NonNull Grammar grammar) {
        try {
            return super.tokenize(text, grammar);
        } catch (Throwable e) {
            List<Node> entries = new ArrayList<>();
            entries.add(new TextImpl(text));
            return entries;
        }
    }
}
