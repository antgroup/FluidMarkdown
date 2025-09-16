package com.fluid.afm.ui;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.R;

import org.commonmark.ext.gfm.tables.TableBlock;

import io.noties.markwon.Markwon;

public class MarkdownContentAdapter extends RecyclerView.Adapter<MarkdownContentAdapter.ViewHolder> {
    private final MarkdownTextAdapter textAdapter;


    public MarkdownContentAdapter(Markwon markwon, boolean isTable, int columnCount, TextView textView) {
        this.textAdapter = new MarkdownTextAdapter(markwon, isTable, columnCount, textView);
    }

    public void setContent(String content) {
        textAdapter.setContent(content);
        notifyDataSetChanged();
    }
    public void setTableBlockNode(TableBlock block) {
        textAdapter.setTableBlockNode( block);
        notifyDataSetChanged();
    }


    @Override
    public ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_markdown_content, parent, false);
        return new ViewHolder(view);
    }

    @Override
    public void onBindViewHolder(ViewHolder holder, int position) {
        holder.horizontalRecyclerView.setLayoutManager(new LinearLayoutManager(holder.itemView.getContext(), LinearLayoutManager.HORIZONTAL, false));
        holder.horizontalRecyclerView.setHasFixedSize(true);
        holder.horizontalRecyclerView.setItemViewCacheSize(1);
        holder.horizontalRecyclerView.setAdapter(textAdapter);
    }

    @Override
    public int getItemCount() {
        return 1;
    }

    static class ViewHolder extends RecyclerView.ViewHolder {
        final RecyclerView horizontalRecyclerView;

        ViewHolder(View itemView) {
            super(itemView);
            horizontalRecyclerView = itemView.findViewById(R.id.horizontalRecyclerView);
        }
    }
} 