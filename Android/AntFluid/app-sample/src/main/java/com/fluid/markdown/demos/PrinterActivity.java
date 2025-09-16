package com.fluid.markdown.demos;

import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.EditText;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.appcompat.widget.SwitchCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.R;
import com.fluid.afm.markdown.MarkdownParser;
import com.fluid.afm.markdown.MarkdownParserFactory;
import com.fluid.afm.markdown.widget.PrinterMarkDownTextView;
import com.fluid.afm.styles.MarkdownStyles;

public class PrinterActivity extends AppCompatActivity {

    private EditText mEditText;
    private boolean isAppend;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_printer);
        findViewById(R.id.back).setOnClickListener(v -> onBackPressed());
        mEditText = findViewById(R.id.editor);
        RecyclerView recyclerView = findViewById(R.id.recyclerView);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager( this, LinearLayoutManager.VERTICAL, false);
        recyclerView.setLayoutManager(linearLayoutManager);
        PrinterMarkDownTextView markDownTextView = new PrinterMarkDownTextView(this);
        linearLayoutManager.setStackFromEnd(true);
        recyclerView.setAdapter(new RecyclerView.Adapter() {
            @NonNull
            @Override
            public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                return new RecyclerView.ViewHolder(markDownTextView) {};
            }

            @Override
            public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {

            }

            @Override
            public int getItemCount() {
                return 1;
            }
        });

        markDownTextView.init(MarkdownStyles.getDefaultStyles(), null);
        markDownTextView.setPrintParams(25, 1);

        findViewById(R.id.start).setOnClickListener(v -> {
            String content = mEditText.getText().toString();
            if (!content.isEmpty()) {
                markDownTextView.startPrinting(content);
            }
        });
        SwitchCompat appendSwitch = findViewById(R.id.appendSwitch);
        isAppend = appendSwitch.isChecked();
        appendSwitch.setOnCheckedChangeListener((buttonView, isChecked) -> {
            isAppend = isChecked;
        });
        findViewById(R.id.append).setOnClickListener(v -> {
            String content = mEditText.getText().toString();
            if (!content.isEmpty()) {
                markDownTextView.appendPrinting(content, isAppend);
            }
        });

        findViewById(R.id.stop).setOnClickListener(v -> {
            markDownTextView.stopPrinting(getResources().getString(R.string.stopped));
        });
        findViewById(R.id.clear).setOnClickListener(v -> {
            mEditText.setText("");
        });

        findViewById(R.id.pause).setOnClickListener(v -> {
            markDownTextView.pause();
        });

        findViewById(R.id.resume).setOnClickListener(v -> {
            markDownTextView.resume();
        });

    }
}