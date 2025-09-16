package com.fluid.afm.span;

public interface IClickableSpan {
    String getUrl();
    String getType();

    int getTop();
    int getBottom();
    default String getLiteral() {
        return "";
    }

}
