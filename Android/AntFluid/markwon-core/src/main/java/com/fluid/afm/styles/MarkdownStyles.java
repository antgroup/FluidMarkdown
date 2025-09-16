package com.fluid.afm.styles;

import android.graphics.Color;
import android.graphics.Typeface;

import com.fluid.afm.utils.ParseUtil;

import java.util.Arrays;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

public class MarkdownStyles {
    /**
     * Paragraph style
     * Paragraph spacing applies to normal paragraphs, ordered lists, unordered lists, and tables
     */
    private ParagraphStyle paragraph = ParagraphStyle.create();
    /**
     * Horizontial rule style
     */
    private HorizonRuleStyle horizonRule = HorizonRuleStyle.create();
    /**
     * Link style
     */
    private LinkStyle link = LinkStyle.create();
    /**
     * Table style
     */
    private TableStyle table = TableStyle.create();
    /**
     * 标题样式,数组大小是6
     * TitleStyle.fontSize: 标题字体大小
     * TitleStyle.sizeType: 标题字体大小类型，0:系数, 标题字体大小 = 正文字体大小*fontSize; 1:px
     * 默认值： TitleStyle.fontSize = 1;TitleStyle.sizeType = 0
     *
     * Title style, array size is 6
     * TitleStyle.fontSize: title font size
     * TitleStyle.sizeType: title font size type, if sizeType is 0, title font size = paragraph font size*fontSize; if sizeType is 1  title font size = [fontSize]px
     */
    private TitleStyle[] titleStyles = TitleStyle.TITLE_DEFAULT_SIZES;
    /**
     * Ordered  style
     * key: level, value: style
     */
    private Map<Integer, OrderStyle> orderStyles = new ConcurrentHashMap<>();
    /**
     * Basic ordered list style
     * if Map<Integer, OrderBean> orderBeans has no corresponding level, use this style
     */
    private OrderStyle baseOrder = OrderStyle.create();
    /**
     * Bullet list style
     * key: level, value: style
     */
    private Map<Integer, BulletStyle> bulletStyles = new ConcurrentHashMap<>();
    /**
     * Basic bullet style
     * if Map<Integer, UnorderBean> unorderBeans has no corresponding level, use this style
     */
    private BulletStyle baseBullet = BulletStyle.create();

    /**
     * footnote style
     */
    private FootnoteStyle footnote = FootnoteStyle.create();
    /**
     * block quote style
     */
    private BlockQuoteStyle blockQuote = BlockQuoteStyle.create();

    /**
     * code style include code block and inline code
     */
    private CodeStyle code = CodeStyle.create();

    /**
     * underline style
     */
    private UnderlineStyle underline = UnderlineStyle.create(ParseUtil.parseDp("6rpx"), 0x7A1677FF);

    public MarkdownStyles() {
    }

    public MarkdownStyles paragraphStyle(ParagraphStyle paragraph) {
        this.paragraph = paragraph;
        return this;
    }

    public MarkdownStyles horizonRuleStyle(HorizonRuleStyle horizonRule) {
        this.horizonRule = horizonRule;
        return this;
    }

    public MarkdownStyles tableStyle(TableStyle table) {
        this.table = table;
        return this;
    }

    public MarkdownStyles setTitleStyles(TitleStyle[] titleStyles) {
        this.titleStyles = titleStyles;
        return this;
    }
    public MarkdownStyles setTitleStyle(int level, TitleStyle style) {
        if (level < 0 || level >= titleStyles.length) {
            return this;
        }
        if (this.titleStyles == TitleStyle.TITLE_DEFAULT_SIZES) {
            this.titleStyles = new TitleStyle[6];
            Arrays.fill(this.titleStyles, TitleStyle.TITLE_DEFAULT);
        }
        this.titleStyles[level] = style;
        return this;
    }

    public Map<Integer, OrderStyle> getOrderStylesMap() {
        return orderStyles;
    }

    public MarkdownStyles setOrderStyles(Map<Integer, OrderStyle> orderStyles) {
        this.orderStyles = orderStyles;
        return this;
    }

    public OrderStyle getBaseOrderStyle() {
        return baseOrder;
    }

    public MarkdownStyles setBaseOrderStyle(OrderStyle baseOrder) {
        this.baseOrder = baseOrder;
        return this;
    }

    public MarkdownStyles setBulletStyles(Map<Integer, BulletStyle> bulletStyles) {
        this.bulletStyles = bulletStyles;
        return this;
    }

    public BulletStyle getBaseBulletStyle() {
        return baseBullet;
    }

    public Map<Integer, BulletStyle> getBulletStylesMap() {
        return bulletStyles;
    }

    public MarkdownStyles baseBulletStyle(BulletStyle base) {
        this.baseBullet = base;
        return this;
    }

    public FootnoteStyle getFootnoteStyle() {
        return footnote;
    }

    public MarkdownStyles footnoteStyle(FootnoteStyle footnote) {
        this.footnote = footnote;
        return this;
    }

    public CodeStyle codeStyle() {
        return code;
    }
    public MarkdownStyles codeStyle(CodeStyle style) {
        this.code = style;
        return this;
    }
    public UnderlineStyle underlineStyle() {
        return underline;
    }
    public MarkdownStyles underlineStyle(UnderlineStyle style) {
        this.underline = style;
        return this;
    }

    public BlockQuoteStyle blockQuoteStyle() {
        return blockQuote;
    }

    public MarkdownStyles blockQuoteStyle(BlockQuoteStyle blockQuote) {
        this.blockQuote = blockQuote;
        return this;
    }

    public TitleStyle[] titleStyles() {
        return titleStyles;
    }

    public ParagraphStyle paragraphStyle() {
        return paragraph;
    }

    public HorizonRuleStyle horizonRuleStyle() {
        return horizonRule;
    }

    public LinkStyle linkStyle() {
        return link;
    }

    public MarkdownStyles linkStyle(LinkStyle link) {
        this.link = link;
        return this;
    }

    public TableStyle tableStyle() {
        return table;
    }

    public static MarkdownStyles getDefaultStyles() {
        MarkdownStyles styles = new MarkdownStyles();
        styles
                // paragraph style
                .paragraphStyle(ParagraphStyle.create()
                        .fontSize(ParseUtil.parseDp("30rpx"))
                        .fontColor(0xFF333333)
                        .lineHeight(ParseUtil.parseDp("48rpx"))
                        .paragraphSpacing(ParseUtil.parseDp("10px"))
                )
                // horizon rule style
                .horizonRuleStyle(HorizonRuleStyle.create(ParseUtil.parseDp("0.5px"), 0xFFE2E5F3, ParseUtil.parseDp("16px"), ParseUtil.parseDp("6px")))
                // link style
                .linkStyle(LinkStyle.create()
                        .underline(false)
                        .fontColor(0xFF1296DB))
                // ordered list style
                .setBaseOrderStyle(OrderStyle.create()
                        .leading(ParseUtil.parseDp("1px"))
                        .isBold(true)
                        .leadingSpacing(ParseUtil.parseDp("5px")))
                // bullet list style
                .baseBulletStyle(BulletStyle.create()
                        .leading(ParseUtil.parseDp("1px"))
                        .leadingSpacing(ParseUtil.parseDp("8px"))
                        .setShape(new Shape().setColor(0xFF13113E).setType(Shape.SHAPE_CIRCLE).setSize(ParseUtil.parseDp("5px"))))
                // footnote style
                .footnoteStyle(FootnoteStyle.create(0xFF999999, 0x141F3B63)
                        .isBold(true)
                        .size(ParseUtil.parseDp("32rpx"))
                        .fontSize(ParseUtil.parseDp("20rpx")))
                // blockquote style
                .blockQuoteStyle(BlockQuoteStyle.create()
                        .lineColor(0xFFEEEEEE)
                        .fontColor(0xFF999999)
                        .lineWidth(ParseUtil.parseDp("4px"))
                        .lineCornerRadius(ParseUtil.parseDp("2px"))
                        .lineMargin(ParseUtil.parseDp("40rpx")))
                // table style
                .tableStyle(TableStyle.create()
                        .tableBlockRadius(ParseUtil.parseDp("24rpx"))
                        .fontColor(0xFF333333)
                        .titleFontColor(0xFF999999)
                        .titleBackgroundColor(0xFFEDEFF3)
                        .titleFontSize(ParseUtil.parseDp("30rpx"))
                        .headerBackgroundColor(0xFFF6F7F9)
                        .headerFontSize(ParseUtil.parseDp("26rpx"))
                        .titleBackgroundRadius(ParseUtil.parseDp("24rpx"))
                        .bodyBackgroundColor(Color.WHITE)
                        .cellTopBottomPadding(ParseUtil.parseDp("6px"))
                        .bodyFontSize(ParseUtil.parseDp("26rpx"))
                        .drawBorder(true).borderColor(0xFFDEDEDE).borderWidth(ParseUtil.parseDp("1rpx")))
                // code block + inline code style
                .codeStyle(CodeStyle.create()
                        .inlineFontColor(0xFF2980B9)
                        .inlineFontSize(ParseUtil.parseDp("30rpx"))
                        .inlineCodeBackgroundColor(0x1E1F3B63)
                        .inlineCodeBackgroundRadius(ParseUtil.parseDp("8rpx"))
                        .inlinePaddingHorizontal(ParseUtil.parseDp("4rpx"))
                        .inlinePaddingVertical(ParseUtil.parseDp("3rpx"))
                        .codeFontColor(0xFF333333)
                        .codeFontSize(ParseUtil.parseDp("26rpx"))
                        .titleFontColor(0xFF999999)
                        .titleFontSize(ParseUtil.parseDp("26rpx"))
                        .borderColor(0xFFDEDEDE)
                        .borderWidth(ParseUtil.parseDp("1rpx"))
                        .lightIcon(true)
                        .drawBorder(true)
                        .codeTypeface(Typeface.MONOSPACE))
                // underline style
                .underlineStyle(UnderlineStyle.create(ParseUtil.parseDp("12rpx"), 0x7A1677FF))
                // title style
                .setTitleStyle(0, TitleStyle.create(1.3f)
                        .paragraphSpacing(ParseUtil.parseDp("10px"))
                        .paragraphSpacingBefore(ParseUtil.parseDp("4px")))
                .setTitleStyle(1, TitleStyle.create(1.2f).paragraphSpacing(ParseUtil.parseDp("10px"))
                        .paragraphSpacingBefore(ParseUtil.parseDp("4px")))
                .setTitleStyle(2, TitleStyle.create(1.1f).paragraphSpacing(ParseUtil.parseDp("10px"))
                        .paragraphSpacingBefore(ParseUtil.parseDp("4px")))
                .setTitleStyle(3, TitleStyle.create(1.f).paragraphSpacing(ParseUtil.parseDp("10px"))
                        .paragraphSpacingBefore(ParseUtil.parseDp("4px")))
                .setTitleStyle(4, TitleStyle.create(1.f).paragraphSpacing(ParseUtil.parseDp("10px"))
                        .paragraphSpacingBefore(ParseUtil.parseDp("4px")))
                .setTitleStyle(5, TitleStyle.create(1.f).paragraphSpacing(ParseUtil.parseDp("10px"))
                        .paragraphSpacingBefore(ParseUtil.parseDp("4px")));
        return styles;
    }

}
