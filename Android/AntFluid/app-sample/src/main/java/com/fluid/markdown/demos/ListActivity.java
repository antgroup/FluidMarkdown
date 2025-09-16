package com.fluid.markdown.demos;

import android.os.Bundle;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.R;


public class ListActivity extends AppCompatActivity {


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_list);
        String sampleString = getString(R.string.sample);
        MarkwonListAdapter adapter = new MarkwonListAdapter();
        findViewById(R.id.add).setOnClickListener(v -> {
            adapter.addData(new MarkdownData(sampleString));
        });
        findViewById(R.id.back).setOnClickListener(v -> {
            onBackPressed();
        });
        RecyclerView recyclerView = findViewById(R.id.recycler);
        recyclerView.setLayoutManager(new LinearLayoutManager( this, LinearLayoutManager.VERTICAL, false){{setStackFromEnd(true);}});
        recyclerView.setAdapter(adapter);
    }
}
