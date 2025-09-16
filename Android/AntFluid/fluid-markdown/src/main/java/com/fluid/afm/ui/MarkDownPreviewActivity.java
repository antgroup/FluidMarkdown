package com.fluid.afm.ui;

import android.annotation.SuppressLint;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;
import android.view.WindowManager;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.fluid.afm.R;
import com.fluid.afm.TableBlockTitleBlockSpan;
import com.fluid.afm.markdown.MarkdownParserFactory;
import com.fluid.afm.markdown.widget.PrinterMarkDownTextView;
import com.fluid.afm.styles.CodeStyle;
import com.fluid.afm.styles.MarkdownStyles;
import com.fluid.afm.styles.TableStyle;
import com.fluid.afm.utils.MDLogger;

import java.util.ArrayList;
import java.util.List;

import io.noties.markwon.Markwon;
import io.noties.markwon.MarkwonPlugin;
import io.noties.markwon.core.MarkwonTheme;
import io.noties.markwon.ext.tables.TablePlugin;

public class MarkDownPreviewActivity extends AppCompatActivity {
    public static final String TAG = "MarkDownPreviewActivity";
    private String markdownContent;
    private RecyclerView recyclerView;
    private MarkdownContentAdapter adapter;
    private Markwon markwon;
    private final Handler mainHandler = new Handler(Looper.getMainLooper());
    private TableStyle tableStyle;
    private CodeStyle codeStyle;
    private int columnCount = 0;
    private boolean isTable = false;

    @SuppressLint("SetTextI18n")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initLayout();
        initViews();
        if (getIntentParams()) {
            setContent(markdownContent);
        }
    }

    private void initLayout() {
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR);
        } else {
            getWindow().getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);
        }
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        getWindow().setStatusBarColor(Color.TRANSPARENT);
        WindowManager.LayoutParams attributes = getWindow().getAttributes();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            attributes.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(attributes);
        }
        setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        setContentView(R.layout.activity_magnify_table);
    }

    private void initViews() {
        View back = findViewById(R.id.back);
        recyclerView = findViewById(R.id.recyclerView);

        // 设置RecyclerView
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        recyclerView.setHasFixedSize(true);
        recyclerView.setItemViewCacheSize(1);
        recyclerView.setNestedScrollingEnabled(false); // 禁用嵌套滚动，避免冲突

        back.setOnClickListener(v -> onBackPressed());
    }

    private boolean getIntentParams() {
        Bundle launchParam = getIntent().getExtras();
        if (launchParam == null) {
            MDLogger.e(TAG, "Launch params is null");
            return false;
        }
        markdownContent = launchParam.getString("content", "");
        tableStyle = launchParam.getParcelable("tableStyle");
        codeStyle = launchParam.getParcelable("codeStyle");
        columnCount = launchParam.getInt("columnCount", 0);
        isTable = launchParam.getBoolean("isTable", false);
        if (TextUtils.isEmpty(markdownContent) && (!isTable || TableBlockTitleBlockSpan.getCurrentTableBlock() == null)) {
            MDLogger.e(TAG, "Both table_content and code_content are empty");
            return false;
        }

        MDLogger.d(TAG, "markdownContent = " + markdownContent +" TableBlockTitleBlockSpan.getCurrentTableBlock()=" + TableBlockTitleBlockSpan.getCurrentTableBlock());
        return true;
    }

    private void setContent(String content) {
        try {
            PrinterMarkDownTextView textView = null;
            if (markwon == null) {
                textView = new PrinterMarkDownTextView(this);
                MarkdownStyles style = MarkdownStyles.getDefaultStyles();
                if (tableStyle == null) {
                    tableStyle = style.tableStyle();
                } else {
                    style.tableStyle(tableStyle);
                }
                if (codeStyle != null) {
                    codeStyle.drawBorder(false);
                    style.codeStyle(codeStyle);
                }
                TablePlugin tablePlugin = TablePlugin.create(this, true);
                List<MarkwonPlugin> plugins = new ArrayList<>(MarkdownParserFactory.getPlugins(this, textView, tablePlugin));
                MarkwonTheme theme = MarkwonTheme.builderWithDefaults(this).setStyles(style).build(plugins);
                markwon = Markwon.builderWithPlugs(this, plugins).setMarkdownTheme(theme).build();
            }

            if (adapter == null) {
                adapter = new MarkdownContentAdapter(markwon, isTable, columnCount, textView);
                recyclerView.setAdapter(adapter);
            }
            if (TableBlockTitleBlockSpan.getCurrentTableBlock() != null) {
                adapter.setTableBlockNode(TableBlockTitleBlockSpan.getCurrentTableBlock());
            } else {
                adapter.setContent(content);
            }
        } catch (Throwable tr) {
            MDLogger.e(TAG, "Error initializing markwon: " + tr.getMessage(), tr);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        markwon = null;
        adapter = null;
        recyclerView.setAdapter(null);
        mainHandler.removeCallbacksAndMessages(null);
        TableBlockTitleBlockSpan.setCurrentTableBlock(null);
    }
}


