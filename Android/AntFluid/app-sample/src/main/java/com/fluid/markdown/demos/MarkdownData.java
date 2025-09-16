package com.fluid.markdown.demos;

import com.fluid.afm.markdown.widget.PrinterMarkDownTextView;

public class MarkdownData {
    public String content;
    public PrinterMarkDownTextView.MarkDownPrintData printData;

    public MarkdownData(String content) {
        this.content = content;
        printData = new PrinterMarkDownTextView.MarkDownPrintData();
    }

}
