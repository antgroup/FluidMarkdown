package com.fluid.markdown.demos;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.R;
import com.fluid.afm.markdown.MarkdownParserFactory;
import com.fluid.afm.markdown.widget.PrinterMarkDownTextView;
import com.fluid.afm.styles.MarkdownStyles;

public class MarkdownHolder extends RecyclerView.ViewHolder {
    private final PrinterMarkDownTextView mMarkdownTextView;

    public MarkdownHolder(@NonNull View itemView) {
        super(itemView);
        mMarkdownTextView = itemView.findViewById(R.id.markdown);
        MarkdownStyles styles =  MarkdownStyles.getDefaultStyles();
        styles.linkStyle().icon("local://mipmap/link");
        mMarkdownTextView.init(styles, null);
    }

    public void bind(MarkdownData markdownData) {
        if (!markdownData.printData.hasBoundView) {
            mMarkdownTextView.setPrintData(markdownData.printData);
            mMarkdownTextView.startPrinting(markdownData.content);
        } else {
            mMarkdownTextView.restore(markdownData.printData);
        }
    }
}
