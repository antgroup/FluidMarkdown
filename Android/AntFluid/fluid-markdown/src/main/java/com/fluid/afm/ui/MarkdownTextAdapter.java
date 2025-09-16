package com.fluid.afm.ui;

import android.text.Spanned;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.R;
import com.fluid.afm.markdown.widget.PrinterMarkDownTextView;

import org.commonmark.ext.gfm.tables.TableBlock;

import io.noties.markwon.Markwon;
import com.fluid.afm.utils.Utils;

public class MarkdownTextAdapter extends RecyclerView.Adapter<MarkdownTextAdapter.ViewHolder> {
    private String content;
    private final Markwon markwon;
    private final boolean isTable;
    private final int columnCount;
    private int tableWidth;
    private final TextView mTextView;
    private Spanned spanned;

    public MarkdownTextAdapter(Markwon markwon, boolean isTable, int columnCount, TextView textView) {
        this.markwon = markwon;
        this.isTable = isTable;
        this.columnCount = columnCount;
        mTextView = textView;
        if (mTextView != null) {
            mTextView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
            int padding = Utils.dpToPx(16);
            mTextView.setPadding(padding, padding, padding, padding);
        }
    }

    public void setContent(String content) {
        this.content = content;
        notifyDataSetChanged();
    }

    public void setTableBlockNode(TableBlock block) {
        spanned = markwon.render(block);
        notifyDataSetChanged();
    }

    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View view = mTextView == null ? LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_markdown_text, parent, false) : mTextView;

        ViewHolder viewHolder = new ViewHolder(view);
        if (isTable) {
            if (tableWidth == 0) {
                if (columnCount >= 6) {
                    int screenW = parent.getContext().getResources().getDisplayMetrics().widthPixels;
                    tableWidth = (int) (screenW / 5.5f) * columnCount;
                } else {
                    tableWidth = ViewGroup.LayoutParams.MATCH_PARENT;
                }
            }
            ViewGroup.LayoutParams params = viewHolder.textView.getLayoutParams();
            if (params == null) {
                params = new ViewGroup.LayoutParams(tableWidth, ViewGroup.LayoutParams.WRAP_CONTENT);
            }
            params.width = tableWidth;
            viewHolder.textView.setMaxWidthForMeasure(tableWidth > 0 ? tableWidth : parent.getMeasuredWidth());
            viewHolder.textView.setLayoutParams(params);
        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        if (spanned != null) {
            markwon.setParsedMarkdown(holder.textView, spanned);
        } else if (content != null) {
            markwon.setMarkdown(holder.textView, content);
        }
    }

    @Override
    public int getItemCount() {
        return 1;
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        final PrinterMarkDownTextView textView;

        ViewHolder(View itemView) {
            super(itemView);
            if (itemView instanceof TextView) {
                textView = (PrinterMarkDownTextView) itemView;
            } else {
                textView = itemView.findViewById(R.id.mk_textView);
            }
        }
    }
} 