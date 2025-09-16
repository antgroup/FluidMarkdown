// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// MarkdownElementType
typedef NS_ENUM(NSUInteger, AMXElementType) {
    AMXElementTypeParagraph,    // base paragraph
    AMXElementTypeHeader1,      // title 1
    AMXElementTypeHeader2,      // title 2
    AMXElementTypeHeader3,      // title 3
    AMXElementTypeHeader4,      // title 4
    AMXElementTypeHeader5,      // title 5
    AMXElementTypeHeader6,      // title 6
    AMXElementTypeUnorderedList,// unorder list
    AMXElementTypeOrderedList,  // order list
    AMXElementTypeTable,         // table
    AMXElementTypeBlockQuote,        // quote
    AMXElementTypeHRule,         // horizon rule
    AMXElementTypeLink,         // link
    AMXElementTypeFootNote,         // foot note
    AMXElementTypeInlineCode,         // inline code
    AMXElementTypeCodeBlock        // code block
};
typedef NS_ENUM(NSUInteger, AMXListPrefixType) {
    AMXListPrefixTypeCharacter,  // character
    AMXListPrefixTypeImage,      // image
};

@interface AMXFontConfig : NSObject
@property(nonatomic, strong) UIFont *font;
@property(nonatomic, strong)UIColor* fontColor;
@end

@interface AMXSpacingConfig : NSObject
@property(nonatomic, assign)CGFloat paragraphSpacing;
@property(nonatomic, assign)CGFloat lineSpacing;
@property(nonatomic, assign)CGFloat paragraphSpacingBefore;
@end

@interface AMXListLevelConfig : NSObject
@property (nonatomic, assign) AMXListPrefixType prefixType;
@property (nonatomic, assign) CGFloat symbolIndentation;  // the indentation of the prefix
@property (nonatomic, strong) NSString *prefixSymbol;   // effective when prefixType is AMXListPrefixTypeCharacter
@property (nonatomic, strong) NSString *prefixSymbolPath;  // effective when prefixType is AMXListPrefixTypeImage
@property (nonatomic,  assign) CGSize symbolSize;   //
@property (nonatomic,  assign) CGFloat prefixSpacing;   // interval between prefix and the first character
+ (instancetype)defaultStyle:(NSInteger)level;
@end

@interface AMXTableCellStyle : NSObject
@property (nonatomic, strong) AMXFontConfig *font;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) UIEdgeInsets padding;
@end

@interface AMXTableStyleConfig : NSObject
@property (nonatomic, assign) CGFloat rowSpacing;
@property (nonatomic, assign) CGFloat columnSpacing;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat maxWidth;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat firstColumnMaxWidth;
@property (nonatomic, assign) CGFloat columnMaxWidth;
@property (nonatomic, strong) NSString* operationIconPath;// bundleName/iconName
@property (nonatomic, strong) AMXFontConfig *titlefont;
@property (nonatomic, strong) UIColor *titleBackgroundColor;
@property (nonatomic, strong) AMXTableCellStyle *headerStyle; // header
@property (nonatomic, strong) AMXTableCellStyle *contentStyle; // content cell

+ (instancetype)defaultStyle;
@end

@interface AMXHRuleConfig : NSObject
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) CGFloat height;

+ (instancetype)defaultStyle;
@end

@interface AMXLinkConfig : NSObject
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, strong) NSString *iconPath;
@property (nonatomic, assign) BOOL underLine;
@property (nonatomic, assign) NSInteger prefixOrSuffix;// prefix is 1; suffix is 2

+ (instancetype)defaultStyle;
@end

@interface AMXFootNoteConfig : NSObject
@property (nonatomic, assign)CGSize size;
@property (nonatomic, strong)UIColor* backgroundColor;

+ (instancetype)defaultStyle;
@end

@interface AMXBlockquoteStyle : NSObject
@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat indentation;

+ (instancetype)defaultStyle;
@end

@interface AMXInlineCodeConfig : NSObject
@property(nonatomic, strong)UIColor* backgroundColor;
@property(nonatomic, strong)AMXFontConfig* codeFont;
+ (instancetype)defaultStyle;
@end

@interface AMXCodeBlockConfig : NSObject
@property(nonatomic, strong)UIColor* titleBackgroundColor;
@property(nonatomic, strong)AMXFontConfig *titleFont;
@property(nonatomic, strong)UIColor* backgroundColor;
@property(nonatomic, assign)CGFloat borderWidth;
@property(nonatomic, strong)UIColor* borderColor;
@property (nonatomic, strong) NSString* operationIconPath;// bundleName/iconName
+ (instancetype)defaultStyle;
@end

@interface AMXUnderLineConfig : NSObject
@property(nonatomic, strong)UIColor* lineColor;
@property(nonatomic, assign)CGFloat lineWidth;
@property(nonatomic, assign)CGFloat lineOffset;
+ (instancetype)defaultStyle;
@end

@interface AMXMarkdownStyleConfig : NSObject
@property(nonatomic, strong)AMXTableStyleConfig* tableConfig;
@property(nonatomic, strong)AMXHRuleConfig* hRuleConfig;
@property(nonatomic, strong)AMXFootNoteConfig* footNoteConfig;
@property(nonatomic, strong)AMXLinkConfig* linkConfig;
@property(nonatomic, strong)AMXInlineCodeConfig* inlineCodeConfig;
@property(nonatomic, strong)AMXCodeBlockConfig* codeBlockConfig;
@property(nonatomic, strong)AMXUnderLineConfig* underlineConfig;
@property(nonatomic, strong)AMXBlockquoteStyle* blockQuoteConfig;

// Global default config
+ (instancetype)defaultConfig;

// Font config with element type
- (void)setFontConfig:(AMXFontConfig *)config forElementType:(AMXElementType)type;

// Spacing config with element type
- (void)setSpacingConfig:(AMXSpacingConfig *)config forElementType:(AMXElementType)type;

// LineHeight config with element type
- (void)setLineHeightConfig:(CGFloat)lineHeight forElementType:(AMXElementType)type;

// The style of order list with level
- (void)addOrderListConfig:(AMXListLevelConfig *)config forLevel:(NSUInteger)level;

// The style of unorder list with level
- (void)addUnorderListConfig:(AMXListLevelConfig *)config forLevel:(NSUInteger)level;

- (AMXFontConfig*)getFontConfig:(AMXElementType)type;
- (AMXSpacingConfig*)getSpacingConfig:(AMXElementType)type;
- (CGFloat)getLineHeight:(AMXElementType)type;
- (NSDictionary*)getAllLevelOrderListConfigs;
- (AMXListLevelConfig *)getOrderListConfig:(NSUInteger)level;
- (NSDictionary*)getAllLevelUnorderListConfigs;
- (AMXListLevelConfig *)getUnorderListConfig:(NSUInteger)level;
@end

NS_ASSUME_NONNULL_END
