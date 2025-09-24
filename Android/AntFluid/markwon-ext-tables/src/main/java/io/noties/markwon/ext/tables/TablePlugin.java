package io.noties.markwon.ext.tables;

import android.content.Context;
import android.text.Spanned;
import android.text.TextUtils;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.fluid.afm.StreamOutStateObserver;
import com.fluid.afm.TableBlockTitleBlockSpan;
import com.fluid.afm.TableLineSpacingSpan;
import com.fluid.afm.TopSpacingSpan;
import com.fluid.afm.span.ParagraphSpacingSpan;
import com.fluid.afm.styles.TableStyle;
import com.fluid.afm.utils.MDLogger;
import com.fluid.afm.utils.Utils;

import org.commonmark.Extension;
import org.commonmark.ext.gfm.tables.TableBlock;
import org.commonmark.ext.gfm.tables.TableBody;
import org.commonmark.ext.gfm.tables.TableCell;
import org.commonmark.ext.gfm.tables.TableHead;
import org.commonmark.ext.gfm.tables.TableRow;
import org.commonmark.ext.gfm.tables.internal.TableHtmlNodeRenderer;
import org.commonmark.ext.gfm.tables.internal.TableTextContentNodeRenderer;
import org.commonmark.node.Block;
import org.commonmark.node.Document;
import org.commonmark.node.Node;
import org.commonmark.parser.InlineParser;
import org.commonmark.parser.Parser;
import org.commonmark.parser.block.AbstractBlockParser;
import org.commonmark.parser.block.AbstractBlockParserFactory;
import org.commonmark.parser.block.BlockContinue;
import org.commonmark.parser.block.BlockStart;
import org.commonmark.parser.block.MatchedBlockParser;
import org.commonmark.parser.block.ParserState;
import org.commonmark.renderer.html.HtmlRenderer;
import org.commonmark.renderer.text.TextContentRenderer;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import io.noties.markwon.AbstractMarkwonPlugin;
import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.MarkwonSpansFactory;
import io.noties.markwon.MarkwonVisitor;
import io.noties.markwon.SpannableBuilder;
import io.noties.markwon.core.MarkwonTheme;

/**
 * @since 3.0.0
 */
public class TablePlugin extends AbstractMarkwonPlugin implements StreamOutStateObserver {
    private static final String TAG = "MD_TablePlugin";

    private final TableVisitor visitor;

    @NonNull
    public static TablePlugin create(@NonNull Context context, boolean isHideHeader) {
        return new TablePlugin(context, isHideHeader);
    }

    @NonNull
    public static TablePlugin create(Context context) {
        return new TablePlugin(context);
    }

    @SuppressWarnings("WeakerAccess")
    TablePlugin( Context context) {
        this.visitor = new TableVisitor(context);
    }

    TablePlugin(Context context, boolean isHideHeader) {
        this.visitor = new TableVisitor(context, isHideHeader);
    }

    @Override
    public void onStreamOutStateChanged(boolean isStreamingOutput) {
        visitor.setStreamingOutput(isStreamingOutput);
        if (!isStreamingOutput) {
            visitor.mTableSpanCache.clear();
        }
    }
    @Override
    public void configure(@NonNull Registry registry) {
        super.configure(registry);
    }

    @Override
    public void configureTheme(@NonNull MarkwonTheme.Builder builder) {
        super.configureTheme(builder);
    }

    @Override
    public void configureConfiguration(@NonNull MarkwonConfiguration.Builder builder) {
        super.configureConfiguration(builder);
    }

    @Override
    public void configureSpansFactory(@NonNull MarkwonSpansFactory.Builder builder) {
        super.configureSpansFactory(builder);
    }

    @NonNull
    @Override
    public String processMarkdown(@NonNull String markdown) {
        visitor.originMarkdown = markdown;
        return super.processMarkdown(markdown);
    }

    @Override
    public void afterRender(@NonNull Node node, @NonNull MarkwonVisitor visitor) {
        super.afterRender(node, visitor);
        MDLogger.d(TAG, "afterRender node.getNext = " + node.getNext());

    }

    @Override
    public void configureParser(@NonNull Parser.Builder builder) {
        builder.extensions(Collections.singleton(MyTablesExtension.create()));
    }

    @Override
    public void configureVisitor(@NonNull MarkwonVisitor.Builder builder) {
        visitor.configure(builder);
    }

    @Override
    public void beforeRender(@NonNull Node node) {
        // clear before rendering (as visitor has some internal mutable state)
        visitor.clear();
    }

    @Override
    public void beforeSetText(@NonNull TextView textView, @NonNull Spanned markdown) {
        TableRowsScheduler.unschedule(textView);
    }

    @Override
    public void afterSetText(@NonNull TextView textView) {
        TableRowsScheduler.schedule(textView);
    }

    private static class TableVisitor {
        public ConcurrentHashMap<Integer, Integer> mTableIndexMap = new ConcurrentHashMap<>(); // key: all content String index, value: table index

        public ConcurrentHashMap<Integer, List<TableRowSpan.Cell>> mPendingTableRow = new ConcurrentHashMap<>(); // key: table index, value: blockLength

        public ConcurrentHashMap<Integer, Integer> mTableblockLength = new ConcurrentHashMap<>(); // key: table index, value: blockLength

        public ConcurrentHashMap<Integer, Boolean> mTableIsHeader = new ConcurrentHashMap<>(); // key: table index

        public ConcurrentHashMap<Integer, Integer> mTableRows = new ConcurrentHashMap<>(); // key: table index
        public ConcurrentHashMap<Integer, List<TableRowSpan>> mPendingTableRowSpanList = new ConcurrentHashMap<>(); // key: table index

        private final int tableReducedLineHeight = Utils.dpToPx(2);

        private final WeakReference<Context> contextRef;
        public ConcurrentHashMap<Integer, Integer> mTableStartIndex = new ConcurrentHashMap<>(); // key: table index
        private boolean isHideTitle;

        public ConcurrentHashMap<Integer, ConcurrentHashMap<String, TableRowSpan>> mTableSpanCache = new ConcurrentHashMap<>(); // key: table index

        private boolean mIsStreamingOutput = false;
        private int tableCount = 0;
        private int maxContentIndex = -1;
        private String originMarkdown;
        private final ConcurrentHashMap<Integer, TableBlockTitleBlockSpan> mTitleBlockSpans = new ConcurrentHashMap<>();

        TableVisitor(Context context) {
            this.contextRef = new WeakReference<>(context);
        }

        TableVisitor(Context context, boolean isHideTitle) {
            this.isHideTitle = isHideTitle;
            this.contextRef = new WeakReference<>(context);
        }

        public boolean isStreamingOutput() {
            return mIsStreamingOutput;
        }

        public void setStreamingOutput(boolean streamingOutput) {
            mIsStreamingOutput = streamingOutput;
        }

        void clear() {
            mTableblockLength.clear();
            mTableIsHeader.clear();
            mTableRows.clear();
            mPendingTableRow.clear();
        }

        void configure(@NonNull MarkwonVisitor.Builder builder) {
            builder
                    // @since 4.1.1 we use TableBlock instead of TableBody to add new lines
                    .on(TableBlock.class, (visitor, tableBlock) -> {
                        visitor.blockStart(tableBlock);
                        final int length = visitor.length();
                        if (!mTableIndexMap.containsKey(visitor.length())) {
                            mTableblockLength.put(tableCount, length);
                            mTableStartIndex.put(tableCount, length);
                            mTableIndexMap.put(length, tableCount++);
                        }
                        visitor.visitChildren(tableBlock);

                        // @since 4.3.1 apply table span for the full table
                        visitor.setSpans(length, new TableSpan());

                        visitor.blockEnd(tableBlock);
                        boolean isDocumentLast = tableBlock.getNext() == null && tableBlock.getParent() instanceof Document;
                        if (!isDocumentLast) {
                            int index = visitor.length();
                            visitor.builder().append('\n').append('\u00a0');
                            visitor.setSpans(index + 1, new ParagraphSpacingSpan((int) (visitor.configuration().theme().getParagraphBreakHeight() * 1.6f)));
                        }
                    }).on(TableBody.class, (visitor, tableBody) -> {

                        final int length = visitor.length();
                        int tableIndex = getTableIndex(length);
                        visitor.visitChildren(tableBody);
                        mTableRows.put(tableIndex, 0);
                    }).on(TableRow.class, this::visitRow).on(TableHead.class, this::visitRow).on(TableCell.class, (visitor, tableCell) -> {
                        final int length = visitor.length();
                        int tableIndex = getTableIndex(length);
                        visitor.visitChildren(tableCell);
                        List<TableRowSpan.Cell> pendingTableRow = mPendingTableRow.get(tableIndex);
                        if (pendingTableRow == null) {
                            pendingTableRow = new ArrayList<>(2);
                            mPendingTableRow.put(tableIndex, pendingTableRow);
                        }

                        pendingTableRow.add(new TableRowSpan.Cell(tableCellAlignment(tableCell.getAlignment()), visitor.builder().removeFromEnd(length)));
                        mTableIsHeader.put(tableIndex, tableCell.isHeader());
                    });
        }

        private int getTableIndex(int contentIndex) {
            if (mTableIndexMap.size() <= 1) {
                return 0;
            }
            int max = 0;
            Set<Map.Entry<Integer, Integer>> entrySet = mTableIndexMap.entrySet();
            for (Map.Entry<Integer, Integer> entry : entrySet) {
                if (entry.getKey() <= contentIndex && max < entry.getValue()) {
                    max = entry.getValue();
                }
            }
            return max;
        }

        private void visitRow(@NonNull MarkwonVisitor visitor, @NonNull Node node) {
            final int length = visitor.length();
            visitor.visitChildren(node);
            TableStyle style = visitor.configuration().theme().getTableStyle();

            final SpannableBuilder builder = visitor.builder();
            // @since 2.0.0
            // we cannot rely on hasNext(TableHead) as it's not reliable
            // we must apply new line manually and then exclude it from tableRow span
            int tableIndex = getTableIndex(length);
            List<TableRowSpan.Cell> pendingTableRow = mPendingTableRow.get(tableIndex);
            Boolean tableRowIsHeader = mTableIsHeader.get(tableIndex);
            if (tableRowIsHeader == null) {
                tableRowIsHeader = false;
            }
            Integer tableRows = mTableRows.get(tableIndex);
            if (tableRows == null) {
                tableRows = 0;
            }
            if (pendingTableRow != null) {
                final boolean addNewLine;
                {
                    final int builderLength = builder.length();
                    addNewLine = builderLength > 0 && '\n' != builder.charAt(builderLength - 1);
                }
                if (addNewLine) {
                    visitor.forceNewLine();
                }
                boolean useCachedSpan = false;
                MDLogger.d(TAG, "===== maxIndex is=" + maxContentIndex);
                if (maxContentIndex == -1) {
                    maxContentIndex = length;
                }
                if (length <= maxContentIndex) {
                    useCachedSpan = true;
                } else {
                    maxContentIndex = length;
                    MDLogger.d(TAG, "===== update maxIndex=" + length);
                }

                // @since 1.0.4 Replace table char with non-breakable space
                // we need this because if table is at the end of the text, then it will be
                // trimmed from the final result
                builder.append('\u00a0');
                for (TableRowSpan.Cell cell : pendingTableRow) {
                    MDLogger.d(TAG, "cell.text =" + cell.text + " TextUtils.isEmpty(cell.text) = " + TextUtils.isEmpty(cell.text));
                }
                TableRowSpan cachedSpan = getCachedSpan(tableIndex, length);
                MDLogger.d(TAG, " isStreamingOutput = " + isStreamingOutput() + " useCachedSpan = " + useCachedSpan + " length = " + length + " tableIndex=" + tableIndex);
                final int start = addNewLine ? length + 1 : length;
                if (useCachedSpan && cachedSpan != null && !isHideTitle) {
                    MDLogger.d(TAG, "get rowSpanCache span = " + cachedSpan);
                    final TableRowSpan span = getCachedSpan(tableIndex, length);

                    cacheAndUpdateTableCurrentMaxNumber(tableIndex, span);
                    updateCachedTableCurrentMaxNumber(tableIndex);

                    tableRows = tableRowIsHeader ? 0 : tableRows + 1;
                    mTableRows.put(tableIndex, tableRows);
                    if (tableRowIsHeader) {
                        final int headerHeight = style.titleBarHeight();
                        visitor.setSpans(start, new TopSpacingSpan(headerHeight));
                        if (!isHideTitle) {
                            final TableBlockTitleBlockSpan titleSpan = mTitleBlockSpans.get(tableIndex);
                            if (titleSpan != null) {
                                visitor.setSpans(start, titleSpan);
                                TableBlock tableBlock = getTableBlock(node);
                                if (tableBlock != null) {
                                    titleSpan.setTableBlock(tableBlock);
                                }
                            }
                        }
                    }
                    visitor.setSpans(start, new TableLineSpacingSpan(tableRowIsHeader, tableReducedLineHeight));
                    visitor.setSpans(start, span);
                } else {
                    boolean isCreateNewSpan;
                    int value = maxContentIndex;
                    isCreateNewSpan = !isStreamingOutput() || (length < value || ((length == value) && findCurrentTableEnd(tableIndex)));
                    if (isCreateNewSpan) {
                        Integer blockLength = mTableblockLength.get(tableIndex);
                        if (blockLength == null) {
                            blockLength = length;
                        }
                        if (blockLength != length) {
                            tableRowIsHeader = false;
                            mTableIsHeader.put(tableIndex, false);
                        }
                        final TableRowSpan span = new TableRowSpan(style, pendingTableRow, tableRowIsHeader, isHideTitle, tableRows % 2 == 1, tableRows);
                        MDLogger.d(TAG, "new span");

                        cacheAndUpdateTableCurrentMaxNumber(tableIndex, span);
                        if (!isStreamingOutput()) {
                            updateCachedTableCurrentMaxNumber(tableIndex);
                        }

                        tableRows = tableRowIsHeader ? 0 : tableRows + 1;
                        mTableRows.put(tableIndex, tableRows);
                        if (tableRowIsHeader) {
                            final int headerHeight = style.titleBarHeight();
                            visitor.setSpans(start, new TopSpacingSpan(headerHeight));
                            if (!isHideTitle) {
                                MDLogger.d(TAG, " tableIndex = " + tableIndex);
                                TableBlock tableBlock =  getTableBlock(node);

                                TableBlockTitleBlockSpan titleBlockSpan = new TableBlockTitleBlockSpan(contextRef.get(), headerHeight, style, tableIndex, pendingTableRow.size(), true, tableBlock);
                                mTitleBlockSpans.put(tableIndex, titleBlockSpan);
                                visitor.setSpans(start, titleBlockSpan);
                            }
                        }

                        visitor.setSpans(start, new TableLineSpacingSpan(tableRowIsHeader, tableReducedLineHeight));
                        visitor.setSpans(start, span);
                        boolean cacheSpan = isStreamingOutput();
                        if (cacheSpan) {
                            MDLogger.d(TAG, "rowSpanCache put " + "length = " + length + " span = " + span);
                            cacheSpan(tableIndex, length, span);
                        }
                    }
                }
                mPendingTableRow.remove(tableIndex);
            }
        }
        private TableBlock getTableBlock(Node node) {
            if (node instanceof TableBlock) {
                return (TableBlock) node;
            } else if (node == null) {
                return null;
            }
            return getTableBlock(node.getParent());
        }


        private void cacheAndUpdateTableCurrentMaxNumber(int tableIndex, TableRowSpan span) {
            List<TableRowSpan> pendingTableRowList = mPendingTableRowSpanList.get(tableIndex);
            if (pendingTableRowList == null) {
                pendingTableRowList = new ArrayList<>();
                mPendingTableRowSpanList.put(tableIndex, pendingTableRowList);
            }
            pendingTableRowList.add(span);
            Integer tableRows = mTableRows.get(tableIndex);
            if (tableRows == null) {
                tableRows = 0;
            }
            for (TableRowSpan rowSpan : pendingTableRowList) {
                if (rowSpan == null) continue;
                rowSpan.updateCurrentMaxRows(tableRows);
            }
        }

        private void updateCachedTableCurrentMaxNumber(int tableIndex) {
            if (getSpanCache(tableIndex).isEmpty()) {
                return;
            }
            Integer tableRows = mTableRows.get(tableIndex);
            if (tableRows == null) {
                tableRows = 0;
            }
            ConcurrentHashMap<String, TableRowSpan> spanCache = getSpanCache(tableIndex);
            Integer tableStartIndex = mTableStartIndex.get(tableIndex);
            if (tableStartIndex == null) {
                tableStartIndex = 0;
            }
            for (Map.Entry<String, TableRowSpan> entry : spanCache.entrySet()) {
                String key = entry.getKey();
                if (TextUtils.isEmpty(key)) {
                    continue;
                }
                try {
                    final int keyLength = Integer.parseInt(key);
                    if (keyLength < tableStartIndex) {
                        MDLogger.d(TAG, "has render keyLength = " + keyLength + " tableStartIndex = " + tableStartIndex);
                    } else {
                        TableRowSpan rowSpan = entry.getValue();
                        rowSpan.updateCurrentMaxRows(tableRows);
                    }
                } catch (Throwable e) {
                    MDLogger.e(TAG, "updateCachedTableCurrentMaxNumber..e:", e);
                }
            }
        }

        @TableRowSpan.Alignment
        private static int tableCellAlignment(TableCell.Alignment alignment) {
            final int out;
            if (alignment != null) {
                switch (alignment) {
                    case CENTER:
                        out = TableRowSpan.ALIGN_CENTER;
                        break;
                    case RIGHT:
                        out = TableRowSpan.ALIGN_RIGHT;
                        break;
                    default:
                        out = TableRowSpan.ALIGN_LEFT;
                        break;
                }
            } else {
                out = TableRowSpan.ALIGN_LEFT;
            }
            return out;
        }

        /**
         * 找到当前originMarkdown的字符串最后一行
         */
        private boolean findCurrentTableEnd(int tableIndex) {
            try {
                List<TableRowSpan.Cell> pendingTableRow = mPendingTableRow.get(tableIndex);
                if (pendingTableRow == null || pendingTableRow.isEmpty()) {
                    return false;
                }

                final int lastIndex = originMarkdown.lastIndexOf("|\n|");
                if (lastIndex == -1) {
                    return false;
                }

                String lastColumn = originMarkdown.substring(lastIndex + 3);
                if (TextUtils.isEmpty(lastColumn)) {
                    return false;
                }

                final int lastSeparatorIndex = lastColumn.lastIndexOf("|");
                if (lastSeparatorIndex == -1) {
                    return false;
                }

                String columnContent = lastColumn.substring(0, lastSeparatorIndex);
                String[] columns = columnContent.split("\\|");
                return pendingTableRow.size() <= columns.length;
            } catch (Throwable e) {
                MDLogger.e(TAG, "findCurrentTableEnd..e:", e);
            }
            return false;
        }

        private TableRowSpan getCachedSpan(int tableIndex, int length) {
            return getSpanCache(tableIndex).get(String.valueOf(length));
        }

        private void cacheSpan(int tableIndex, int length, TableRowSpan span) {
            getSpanCache(tableIndex).put(String.valueOf(length), span);
        }

        private ConcurrentHashMap<String, TableRowSpan> getSpanCache(int tableIndex) {
            ConcurrentHashMap<String, TableRowSpan> cache = mTableSpanCache.get(tableIndex);
            if (cache == null) {
                cache = new ConcurrentHashMap<>();
                mTableSpanCache.put(tableIndex, cache);
            }
            return cache;
        }
    }

    public static class MyTablesExtension implements Parser.ParserExtension, HtmlRenderer.HtmlRendererExtension, TextContentRenderer.TextContentRendererExtension {
        private MyTablesExtension() {
        }

        public static Extension create() {
            return new MyTablesExtension();
        }

        public void extend(Parser.Builder parserBuilder) {
            parserBuilder.customBlockParserFactory(new MyTableBlockParser.Factory());
        }

        public void extend(HtmlRenderer.Builder rendererBuilder) {
            rendererBuilder.nodeRendererFactory(TableHtmlNodeRenderer::new);
        }

        public void extend(TextContentRenderer.Builder rendererBuilder) {
            rendererBuilder.nodeRendererFactory(TableTextContentNodeRenderer::new);
        }

        public static class MyTableBlockParser extends AbstractBlockParser {
            private final TableBlock block;
            private final List<CharSequence> bodyLines;
            private List<TableCell.Alignment> columns;
            private List<String> headerCells;
            private boolean nextIsSeparatorLine;
            private final boolean isInParagraph;
            private int lineCount = 0;

            private MyTableBlockParser(List<TableCell.Alignment> columns, List<String> headerCells, boolean isInParagraph) {
                this.block = new TableBlock();
                this.bodyLines = new ArrayList<>();
                this.nextIsSeparatorLine = true;
                this.columns = columns != null ? columns : (new ArrayList<>());
                this.headerCells = headerCells != null ? headerCells : (new ArrayList<>());
                this.isInParagraph = isInParagraph;
            }

            public boolean canHaveLazyContinuationLines() {
                return true;
            }

            public Block getBlock() {
                return this.block;
            }

            public BlockContinue tryContinue(ParserState state) {
                if (invalidData) {
                    return BlockContinue.none();
                }
                return state.getLine().toString().contains("|") ? BlockContinue.atIndex(state.getIndex()) : BlockContinue.none();
            }

            boolean invalidData = false;

            public void addLine(CharSequence line) {
                lineCount++;
                if (isInParagraph) {
                    if (lineCount == 1) {
                        headerCells = MyTableBlockParser.split(line);
                        if (headerCells.isEmpty()) {
                            invalidData = true;
                            MDLogger.e(TAG, "no header cells:" + line);
                        }
                    } else if (lineCount == 2) {
                        columns = MyTableBlockParser.parseSeparator(line);
                        if (columns == null) {
                            columns = new ArrayList<>();
                        }
                        int headCellSize = headerCells == null ? 0 : headerCells.size();
                        if (columns.isEmpty() || columns.size() < headCellSize) {
                            invalidData = true;
                            MDLogger.e(TAG, "no colum:" + line);
                        }

                    } else {
                        this.bodyLines.add(line);
                    }
                    return;
                }

                if (this.nextIsSeparatorLine) {
                    this.nextIsSeparatorLine = false;
                } else {
                    if (columns == null || columns.isEmpty()) {
                        columns = MyTableBlockParser.parseSeparator(line);
                        return;
                    }
                    this.bodyLines.add(line);
                }

            }

            public void parseInlines(InlineParser inlineParser) {
                try {
                    int headerColumns = this.headerCells.size();
                    Node head = new TableHead();
                    this.block.appendChild(head);
                    TableRow headerRow = new TableRow();
                    head.appendChild(headerRow);

                    for (int i = 0; i < headerColumns; ++i) {
                        String cell = this.headerCells.get(i);
                        TableCell tableCell = this.parseCell(cell, i, inlineParser);
                        tableCell.setHeader(true);
                        headerRow.appendChild(tableCell);
                    }

                    Node body = null;

                    TableRow row;
                    for (Iterator<CharSequence> var14 = this.bodyLines.iterator(); var14.hasNext(); body.appendChild(row)) {
                        CharSequence rowLine = var14.next();
                        List<String> cells = split(rowLine);
                        row = new TableRow();

                        for (int i = 0; i < headerColumns; ++i) {
                            String cell = i < cells.size() ? cells.get(i) : "";
                            TableCell tableCell = this.parseCell(cell, i, inlineParser);
                            row.appendChild(tableCell);
                        }

                        if (body == null) {
                            body = new TableBody();
                            this.block.appendChild(body);
                        }
                    }
                } catch (Exception e) {
                    MDLogger.e(TAG, e);
                }
            }

            private TableCell parseCell(String cell, int column, InlineParser inlineParser) {
                TableCell tableCell = new TableCell();
                if (column < this.columns.size()) {
                    tableCell.setAlignment(this.columns.get(column));
                }

                inlineParser.parse(cell.trim(), tableCell);
                return tableCell;
            }

            private static List<String> split(CharSequence input) {
                String line = input.toString().trim();
                if (line.startsWith("|")) {
                    line = line.substring(1);
                }

                List<String> cells = new ArrayList<>();
                StringBuilder sb = new StringBuilder();

                for (int i = 0; i < line.length(); ++i) {
                    char c = line.charAt(i);
                    switch (c) {
                        case '\\':
                            if (i + 1 < line.length() && line.charAt(i + 1) == '|') {
                                sb.append('|');
                                ++i;
                                break;
                            }

                            sb.append('\\');
                            break;
                        case '|':
                            cells.add(sb.toString());
                            sb.setLength(0);
                            break;
                        default:
                            sb.append(c);
                    }
                }

                if (sb.length() > 0) {
                    cells.add(sb.toString());
                }

                return cells;
            }

            private static List<TableCell.Alignment> parseSeparator(CharSequence s) {
                List<TableCell.Alignment> columns = new ArrayList<>();
                int pipes = 0;
                boolean valid = false;
                int i = 0;

                while (i < s.length()) {
                    char c = s.charAt(i);
                    switch (c) {
                        case '\t':
                        case ' ':
                            ++i;
                            break;
                        case '-':
                        case ':':
                            if (pipes == 0 && !columns.isEmpty()) {
                                return null;
                            }

                            boolean left = false;
                            boolean right = false;
                            if (c == ':') {
                                left = true;
                                ++i;
                            }

                            boolean haveDash;
                            for (haveDash = false; i < s.length() && s.charAt(i) == '-'; haveDash = true) {
                                ++i;
                            }

                            if (!haveDash) {
                                return null;
                            }

                            if (i < s.length() && s.charAt(i) == ':') {
                                right = true;
                                ++i;
                            }

                            columns.add(getAlignment(left, right));
                            pipes = 0;
                            break;
                        case '|':
                            ++i;
                            ++pipes;
                            if (pipes > 1) {
                                return null;
                            }

                            valid = true;
                            break;
                        default:
                            return null;
                    }
                }

                if (!valid) {
                    return null;
                } else {
                    return columns;
                }
            }

            private static TableCell.Alignment getAlignment(boolean left, boolean right) {
                if (left && right) {
                    return TableCell.Alignment.CENTER;
                } else if (left) {
                    return TableCell.Alignment.LEFT;
                } else {
                    return right ? TableCell.Alignment.RIGHT : null;
                }
            }

            @Override
            public boolean isContainer() {
                return super.isContainer();
            }

            @Override
            public boolean canContain(Block childBlock) {
                return super.canContain(childBlock);
            }

            public static class Factory extends AbstractBlockParserFactory {
                public Factory() {
                }

                public BlockStart tryStart(ParserState state, MatchedBlockParser matchedBlockParser) {
                    CharSequence line = state.getLine();
                    CharSequence paragraph = matchedBlockParser.getParagraphContent();
                    if (paragraph != null && paragraph.toString().contains("|") && !paragraph.toString().contains("\n")) {
                        CharSequence separatorLine = line.subSequence(state.getIndex(), line.length());
                        List<TableCell.Alignment> columns = MyTableBlockParser.parseSeparator(separatorLine);
                        if (columns != null && !columns.isEmpty()) {
                            List<String> headerCells = MyTableBlockParser.split(paragraph);
                            if (columns.size() >= headerCells.size()) {
                                return BlockStart.of(new MyTableBlockParser(columns, headerCells, false)).atIndex(state.getIndex()).replaceActiveBlockParser();
                            }
                        }
                    } else if (paragraph != null) {
                        if (line.toString().stripLeading().startsWith("|")) {
                            List<String> headerCells = MyTableBlockParser.split(line);
                            if (!headerCells.isEmpty()) {
                                return BlockStart.of(new MyTableBlockParser(null, null, true)).atIndex(state.getIndex());
                            }
                        }
                    } else if (line != null && line.toString().stripLeading().startsWith("|") && line.toString().endsWith("|")) {
                        List<String> headerCells = MyTableBlockParser.split(line);
                        if (headerCells.size() > 1) {
                            return BlockStart.of(new MyTableBlockParser(null, null, true)).atIndex(state.getIndex());
                        }
                    }

                    return BlockStart.none();
                }
            }
        }
    }

}
