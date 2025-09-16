package com.fluid.markdown.demos;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.R;

import java.util.ArrayList;
import java.util.List;

public class MarkwonListAdapter extends RecyclerView.Adapter<MarkdownHolder>{
    private final List<MarkdownData> mData = new ArrayList<>();

    @NonNull
    @Override
    public MarkdownHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View contentView = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.list_item, parent, false);
        return new MarkdownHolder(contentView);
    }

    @Override
    public int getItemCount() {
        return mData.size();
    }

    @Override
    public void onBindViewHolder(@NonNull MarkdownHolder holder, int position) {
        holder.bind(mData.get(position));
    }

    public void addData(MarkdownData markdownData) {
        mData.add(markdownData);
        notifyItemInserted(mData.size() - 1);
        notifyItemChanged(mData.size() - 1, mData.size());
    }
}
