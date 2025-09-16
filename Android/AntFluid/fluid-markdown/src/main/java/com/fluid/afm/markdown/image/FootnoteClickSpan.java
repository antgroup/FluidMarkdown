package com.fluid.afm.markdown.image;

import android.annotation.SuppressLint;
import android.text.style.ClickableSpan;
import android.view.View;

import androidx.annotation.NonNull;

import com.fluid.afm.markdown.ElementClickEventCallback;

public class FootnoteClickSpan extends ClickableSpan {
    private final ElementClickEventCallback mClickCallback;
    private final String mIndexSequence;

    public FootnoteClickSpan(String indexSequence, ElementClickEventCallback onClickCallback) {
        mIndexSequence = indexSequence;
        mClickCallback = onClickCallback;
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void onClick(@NonNull View widget) {
      if (mClickCallback != null) {
          mClickCallback.onFootnoteClicked(mIndexSequence);
      }
    }
}
