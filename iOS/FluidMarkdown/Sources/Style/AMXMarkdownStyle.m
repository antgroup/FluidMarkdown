// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownStyle.h"
#import <AntMarkdown/AMUtils.h>
@implementation AMXFontConfig
@end

@implementation AMXSpacingConfig
@end

@implementation AMXListLevelConfig
+ (instancetype)defaultStyle:(NSInteger)level{
    AMXListLevelConfig* config = [AMXListLevelConfig new];
    config.prefixType = AMXListPrefixTypeCharacter;
    config.prefixSymbol = @"\t●";
    config.symbolIndentation = 0;
    return config;
}
@end
@implementation AMXTableCellStyle

@end
@implementation AMXTableStyleConfig
+ (instancetype)defaultStyle {
    AMXTableStyleConfig *config = [AMXTableStyleConfig new];
    AMXTableCellStyle* headerStyle = [AMXTableCellStyle new];
    
    AMXFontConfig* font = [AMXFontConfig new];
    font.font = [UIFont systemFontOfSize:13];
    font.fontColor = [AMUtils colorWithString:@"#333333"];
    
    headerStyle.font = font;
    headerStyle.backgroundColor = [AMUtils colorWithString:@"#1F3B630A"];
    headerStyle.padding = UIEdgeInsetsMake(8, 12, 8, 12);
    
    AMXFontConfig* titlefont = [AMXFontConfig new];
    titlefont.font = [UIFont systemFontOfSize:13];
    titlefont.fontColor = [AMUtils colorWithString:@"#999999"];
    config.titlefont = titlefont;
    config.titleBackgroundColor = [AMUtils colorWithString:@"#1F3B6314"];
    
    AMXTableCellStyle* contentStyle = [AMXTableCellStyle new];
    contentStyle.font = font;
    contentStyle.backgroundColor = [UIColor whiteColor];
    contentStyle.padding = UIEdgeInsetsMake(8, 12, 8, 12);
    
    config.headerStyle = headerStyle;
    config.contentStyle = contentStyle;
    
    config.borderWidth = 1;
    config.rowSpacing = 1;
    config.columnSpacing = 1;
    config.firstColumnMaxWidth = 90;
    config.columnMaxWidth = 210;
    config.maxWidth = 319;
    config.maxHeight = -1;
    config.operationIconPath = @"AntMarkdown/blow_up";

    return config;
}

@end
@implementation AMXHRuleConfig
+ (instancetype)defaultStyle {
    AMXHRuleConfig *config = [AMXHRuleConfig new];
    config.height = 2;
    config.color = [AMUtils colorWithString:@"#D6DEF2"];
    return config;
}

@end
@implementation AMXLinkConfig
+ (instancetype)defaultStyle {
    AMXLinkConfig *config = [AMXLinkConfig new];
    config.spacing = 1;
    config.underLine = NO;
    return config;
}

@end

@implementation AMXFootNoteConfig
+ (instancetype)defaultStyle {
    AMXFootNoteConfig *config = [AMXFootNoteConfig new];
    config.backgroundColor = [AMUtils colorWithString:@"#1f3b6314"];
    config.size = CGSizeMake(18, 18);
    return config;
}
@end

@implementation AMXBlockquoteStyle
+ (instancetype)defaultStyle {
    AMXBlockquoteStyle* config = [AMXBlockquoteStyle new];
    config.lineColor = [AMUtils colorWithString:@"#DFE1EC"];
    config.lineWidth = 2;
    config.indentation = 10;
    return config;
}
@end
@implementation AMXInlineCodeConfig : NSObject
+ (instancetype)defaultStyle {
    AMXInlineCodeConfig* config = [AMXInlineCodeConfig new];
    AMXFontConfig *codeFont = [[AMXFontConfig alloc] init];
    codeFont.fontColor = [AMUtils colorWithString:@"#333333"];
    
    UIFont* codeFont1 = [UIFont systemFontOfSize:15];
    codeFont.font = codeFont1;
    config.codeFont = codeFont;
    config.backgroundColor = [AMUtils colorWithString:@"#1F3B631E"];
    return config;
}
@end
@implementation AMXCodeBlockConfig : NSObject

+ (instancetype)defaultStyle {
    AMXCodeBlockConfig* config = [AMXCodeBlockConfig new];
    config.titleBackgroundColor = [AMUtils colorWithString:@"#1F3B6314"];
    
    AMXFontConfig *titleFont = [[AMXFontConfig alloc] init];
    titleFont.font = [UIFont boldSystemFontOfSize:AUFVS(13.0)];
    titleFont.fontColor = [AMUtils colorWithString:@"#999999"];
   
    config.titleFont = titleFont;
    config.borderWidth = 1;
    config.borderColor = [AMUtils colorWithString:@"#33333329"];
    config.operationIconPath = @"AntMarkdown/code_copy";
    return config;
}
@end
@implementation AMXUnderLineConfig : NSObject
+ (instancetype)defaultStyle {
    AMXUnderLineConfig* config = [AMXUnderLineConfig new];
    config.lineWidth = 6;
    config.lineOffset = 4;
    config.lineColor = [AMUtils colorWithString:@"#1677FF80"];
    return config;
}
@end
@interface AMXMarkdownStyleConfig()
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AMXFontConfig *> *fontConfigs;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, AMXSpacingConfig *> *spacingConfigs;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber*> *lineHeightConfigs;
@property (nonatomic, strong) NSMutableDictionary<NSString *, AMXListLevelConfig *> *orderListConfigs;
@property (nonatomic, strong) NSMutableDictionary<NSString *, AMXListLevelConfig *> *unorderListConfigs;
@end

@implementation AMXMarkdownStyleConfig
- (instancetype)init {
    if (self = [super init]) {
        _fontConfigs = [[NSMutableDictionary alloc] init];
        _spacingConfigs = [[NSMutableDictionary alloc] init];
        _lineHeightConfigs = [[NSMutableDictionary alloc] init];
        _orderListConfigs = [[NSMutableDictionary alloc] init];
        _unorderListConfigs = [[NSMutableDictionary alloc] init];
    }
    return self;
}
+ (instancetype)defaultConfig {
    AMXMarkdownStyleConfig *config = [[AMXMarkdownStyleConfig alloc] init];
    
    AMXFontConfig *defaultFont = [[AMXFontConfig alloc] init];
    defaultFont.font = [UIFont systemFontOfSize:AUFVS(15.0)];
    defaultFont.fontColor = [AMUtils colorWithString:@"#333333"];
  
    AMXFontConfig *defaultBoldFont = [[AMXFontConfig alloc] init];
    defaultBoldFont.font = [UIFont boldSystemFontOfSize:AUFVS(15.0)];
                             defaultBoldFont.fontColor = [AMUtils colorWithString:@"#333333"];
    [config setFontConfig:defaultFont forElementType:AMXElementTypeParagraph];
    [config setFontConfig:defaultBoldFont forElementType:AMXElementTypeHeader1];
    [config setFontConfig:defaultBoldFont forElementType:AMXElementTypeHeader2];
    [config setFontConfig:defaultBoldFont forElementType:AMXElementTypeHeader3];
    [config setFontConfig:defaultBoldFont forElementType:AMXElementTypeHeader4];
    [config setFontConfig:defaultBoldFont forElementType:AMXElementTypeHeader5];
    [config setFontConfig:defaultBoldFont forElementType:AMXElementTypeHeader6];
    [config setFontConfig:defaultFont forElementType:AMXElementTypeOrderedList];
    [config setFontConfig:defaultFont forElementType:AMXElementTypeUnorderedList];
    [config setFontConfig:defaultFont forElementType:AMXElementTypeBlockQuote];
    
    AMXFontConfig *codeBlockFont = [[AMXFontConfig alloc] init];
    codeBlockFont.font = [UIFont boldSystemFontOfSize:AUFVS(13.0)];
    defaultBoldFont.fontColor = [AMUtils colorWithString:@"#333333"];
    [config setFontConfig:defaultFont forElementType:AMXElementTypeCodeBlock];
    
    AMXFontConfig *defaultFootNoteFont = [[AMXFontConfig alloc] init];
    defaultFootNoteFont.font = [UIFont boldSystemFontOfSize:AUFVS(10.0)];
    defaultFootNoteFont.fontColor = [AMUtils colorWithString:@"#999999"];
    [config setFontConfig:defaultFootNoteFont forElementType:AMXElementTypeFootNote];
    
    AMXFontConfig *defaultLinkFont = [[AMXFontConfig alloc] init];
    defaultLinkFont.font = [UIFont systemFontOfSize:AUFVS(15.0)];
    defaultLinkFont.fontColor = [AMUtils colorWithString:@"#1677FF"];
    [config setFontConfig:defaultLinkFont forElementType:AMXElementTypeLink];
    
    AMXSpacingConfig *defaultSpacing = [[AMXSpacingConfig alloc] init];
    defaultSpacing.paragraphSpacingBefore = 10;
    defaultSpacing.paragraphSpacing = 0;
    defaultSpacing.lineSpacing = 0;

    for (NSInteger i = 0; i <= AMXElementTypeHRule; i++) {
        [config setSpacingConfig:defaultSpacing forElementType:i];
        [config setLineHeightConfig:AUFVS(24.0) forElementType:i];
    }
    AMXSpacingConfig *defaultTitleSpacing = [[AMXSpacingConfig alloc] init];
    defaultTitleSpacing.paragraphSpacingBefore = 14;
    defaultTitleSpacing.paragraphSpacing = 0;
    defaultTitleSpacing.lineSpacing = 0;
    for (NSInteger i = AMXElementTypeHeader1; i <= AMXElementTypeHeader6; i++) {
        [config setSpacingConfig:defaultTitleSpacing forElementType:i];
    }
    
    [config setSpacingConfig:defaultSpacing forElementType:AMXElementTypeCodeBlock];
    [config setLineHeightConfig:AUFVS(18.5) forElementType:AMXElementTypeCodeBlock];
    
    for (NSInteger i = 0; i <= 4; i++) {
        AMXListLevelConfig* orderListConfig = [AMXListLevelConfig defaultStyle:i];
        orderListConfig.symbolSize = CGSizeMake(13.5, 13.5);
        orderListConfig.prefixSpacing = 5;
        orderListConfig.prefixSymbol = @"\t%ld.";
        [config addOrderListConfig:orderListConfig forLevel:i];
    }
    for (NSInteger i = 0; i <= 4; i++) {
        AMXListLevelConfig* unorderListConfig = [AMXListLevelConfig defaultStyle:i];
        unorderListConfig.symbolSize = CGSizeMake(7, 7);
        unorderListConfig.prefixSpacing = 6;
        unorderListConfig.prefixSymbol = @"\t●";
        [config addUnorderListConfig:unorderListConfig forLevel:i];
    }
    AMXTableStyleConfig* tableConfig = [AMXTableStyleConfig defaultStyle];
    config.tableConfig = tableConfig;
    
    AMXHRuleConfig* hruleConfig = [AMXHRuleConfig defaultStyle];
    config.hRuleConfig = hruleConfig;

    AMXFootNoteConfig* footNoteConfig = [AMXFootNoteConfig defaultStyle];
    config.footNoteConfig = footNoteConfig;
    
    AMXLinkConfig* linkConfig = [AMXLinkConfig defaultStyle];
    config.linkConfig = linkConfig;
    
    AMXInlineCodeConfig* inlineCodeConfig = [AMXInlineCodeConfig defaultStyle];
    config.inlineCodeConfig = inlineCodeConfig;
    
    AMXCodeBlockConfig* codeBlockConfig = [AMXCodeBlockConfig defaultStyle];
    config.codeBlockConfig = codeBlockConfig;
    
    AMXUnderLineConfig* underlineConfig = [AMXUnderLineConfig defaultStyle];
    config.underlineConfig = underlineConfig;
    
    AMXBlockquoteStyle* blockQuote = [AMXBlockquoteStyle defaultStyle];
    config.blockQuoteConfig = blockQuote;
    
    return config;
}
- (void)setFontConfig:(AMXFontConfig *)config forElementType:(AMXElementType)type {
    self.fontConfigs[@(type)] = config;
}

- (void)setSpacingConfig:(AMXSpacingConfig *)config forElementType:(AMXElementType)type {
    self.spacingConfigs[@(type)] = config;
}
- (void)setLineHeightConfig:(CGFloat)lineHeight forElementType:(AMXElementType)type {
    self.lineHeightConfigs[@(type)] = [NSNumber numberWithFloat:lineHeight];
}
- (void)addOrderListConfig:(AMXListLevelConfig *)config forLevel:(NSUInteger)level {
    NSMutableDictionary *mutableConfigs = [self.orderListConfigs mutableCopy];
    mutableConfigs[[NSString stringWithFormat:@"%ld", level]] = config;
    self.orderListConfigs = [mutableConfigs copy];
}
- (void)addUnorderListConfig:(AMXListLevelConfig *)config forLevel:(NSUInteger)level {
    NSMutableDictionary *mutableConfigs = [self.unorderListConfigs mutableCopy];
    mutableConfigs[[NSString stringWithFormat:@"%ld", level]] = config;
    self.unorderListConfigs = [mutableConfigs copy];
}
- (AMXFontConfig*)getFontConfig:(AMXElementType)type {
    return [self.fontConfigs objectForKey:@(type)];
}
- (AMXSpacingConfig*)getSpacingConfig:(AMXElementType)type {
    return [self.spacingConfigs objectForKey:@(type)];
}
- (CGFloat)getLineHeight:(AMXElementType)type {
    return [[self.lineHeightConfigs objectForKey:@(type)] floatValue];
}
- (NSDictionary*)getAllLevelOrderListConfigs {
    return [self.orderListConfigs mutableCopy];
}
- (AMXListLevelConfig *)getOrderListConfig:(NSUInteger)level {
    return [self.orderListConfigs objectForKey:[NSString stringWithFormat:@"%ld", level]];;
}
- (NSDictionary*)getAllLevelUnorderListConfigs {
    return [self.unorderListConfigs mutableCopy];
}
- (AMXListLevelConfig *)getUnorderListConfig:(NSUInteger)level {
    return [self.unorderListConfigs objectForKey:[NSString stringWithFormat:@"%ld", level]];;
}
@end
