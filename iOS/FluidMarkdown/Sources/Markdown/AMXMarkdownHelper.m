// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownHelper.h"
#import <AntMarkDown/AntMarkDown.h>
#import "AMXMarkdownImageTextAttachment.h"
#import "AMTextStyles+CardUIPlugins.h"
#import "AMXMarkdownTextView.h"
#import "AMXMarkdownDefine.h"
AMStyleProvider AMCustomProvider(void) {
    return ^CMStyleAttributes * (NSInteger level) {
        CMStyleAttributes *styles = [[CMStyleAttributes alloc] init];
        [styles.stringAttributes addEntriesFromDictionary:@{
            NSParagraphStyleAttributeName: ({
            NSMutableParagraphStyle *paragraphStyles = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyles.tabStops = @[
                [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                location:1 + (level - 1) * 12
                                                 options:@{}],
                [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                location:30 + (level - 1) * 20
                                                 options:@{}],
            ];
            paragraphStyles.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyles.paragraphSpacingBefore = 8;
            paragraphStyles.lineSpacing = 0;
            paragraphStyles.firstLineHeadIndent = 0;
            paragraphStyles.headIndent = 30 + (level - 1) * 20;
            [paragraphStyles copy];
        }),
        }];
        [styles.paragraphStyleAttributes addEntriesFromDictionary:@{
            CMParagraphStyleAttributeListItemLabelIndent: [NSNull null],
            CMParagraphStyleAttributeMinimumLineHeight:@(kCUPLMarkdownTextLineHeight)
        }];
        return styles;
    };
}

@implementation AMXMarkdownHelper


+ (NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                defaultStyles:(AMTextStyles *)defaultStyles {
    if (![text isKindOfClass:NSString.class] || (text.length == 0)) {
        return nil;
    }
    AMTextStyles *styles = defaultStyles ?: [AMTextStyles cpl_cardDefaultTextStyles];
    if (styles) {
        @try {
            return [[text markdownToAttributedStringWithStyles_ant_mark:styles] mutableCopy];
        } @catch (NSException *exception) {
            CPLLogInfo(@"get attribute string failed: %@", exception.description);
        }
    }
    return nil;
}
+ (nullable NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                         defaultStyles:(nullable AMTextStyles *)defaultStyles
                                              delegate:(id<CMAttributedStringRendererDelegate>)delegate
                                              textView:(UITextView*)textView
{
    if (![text isKindOfClass:NSString.class] || (text.length == 0)) {
        return nil;
    }
    AMTextStyles *styles = defaultStyles ?: [AMTextStyles cpl_cardDefaultTextStyles];
    if (styles) {
        @try {
            return [[text markdownToAttributedStringWithStyles_ant_mark:styles delegate:delegate] mutableCopy];
        } @catch (NSException *exception) {
            CPLLogInfo(@"get attribute string failed: %@", exception.description);
            if ([textView isKindOfClass:[AMXMarkdownTextView class]] && ((AMXMarkdownTextView*)textView).textViewDelegate) {
                if ([((AMXMarkdownTextView*)textView).textViewDelegate respondsToSelector:@selector(onError:)]) {
                    NSError* error = [NSError errorWithDomain:@"AMStreamRender"
                                                         code:1002
                                                     userInfo:@{NSLocalizedDescriptionKey: exception.description}];
                    [((AMXMarkdownTextView*)textView).textViewDelegate onError:error];
                }
            }
        }
    }
    return nil;
}

+ (void)setImageAttachListener:(NSMutableAttributedString *)attrText
                      delegate:(id<AMXImageAttachmentProtocol>)delegate {
    [attrText enumerateAttribute:NSAttachmentAttributeName
                         inRange:NSMakeRange(0, attrText.length)
                         options:0
                      usingBlock:^(id value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[AMXMarkdownImageTextAttachment class]]) {
            AMXMarkdownImageTextAttachment *attachment = (AMXMarkdownImageTextAttachment *)value;
            attachment.imgDelegate = delegate;
            [attachment refreshImageIfNeed];
        }
    }];
}

+ (void)transformParagraph:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config {
    [defalutStyle.paragraphAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeMinimumLineHeight:@([config getLineHeight:AMXElementTypeParagraph])
    }];
    [defalutStyle.paragraphAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @([config getSpacingConfig:AMXElementTypeParagraph].paragraphSpacingBefore)
    }];
    [defalutStyle.paragraphAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacing: @([config getSpacingConfig:AMXElementTypeParagraph].paragraphSpacing)
    }];
    [defalutStyle.paragraphAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: [config getFontConfig:AMXElementTypeParagraph].font,
    }];
    [defalutStyle.baseTextAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: [config getFontConfig:AMXElementTypeParagraph].font,
    }];
    [defalutStyle.paragraphAttributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName : [config getFontConfig:AMXElementTypeParagraph].fontColor
    }];
}
+ (void)transformTitle:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config {
    AMXFontConfig* font1 = [config getFontConfig:AMXElementTypeHeader1];
    [defalutStyle.h1Attributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName: font1.fontColor,
        NSKernAttributeName: @(0.25),
        NSFontAttributeName: font1.font
    }];
    AMXSpacingConfig* space1 = [config getSpacingConfig:AMXElementTypeHeader1];
    [defalutStyle.h1Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(space1.paragraphSpacingBefore),
        CMParagraphStyleAttributeParagraphSpacing: @(space1.paragraphSpacing)
    }];
    [defalutStyle.h1Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeMinimumLineHeight:@([config getLineHeight:AMXElementTypeHeader1])
    }];
    AMXFontConfig* font2 = [config getFontConfig:AMXElementTypeHeader2];
    [defalutStyle.h2Attributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName: font2.fontColor,
        NSKernAttributeName: @(0.25),
        NSFontAttributeName: font2.font
    }];
    AMXSpacingConfig* space2 = [config getSpacingConfig:AMXElementTypeHeader2];
    [defalutStyle.h2Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(space2.paragraphSpacingBefore),
        CMParagraphStyleAttributeParagraphSpacing: @(space2.paragraphSpacing)
    }];
    [defalutStyle.h2Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeMinimumLineHeight:@([config getLineHeight:AMXElementTypeHeader2])
    }];
    AMXFontConfig* font3 = [config getFontConfig:AMXElementTypeHeader3];
    [defalutStyle.h3Attributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName: font3.fontColor,
        NSKernAttributeName: @(0.25),
        NSFontAttributeName: font3.font
    }];
    AMXSpacingConfig* space3 = [config getSpacingConfig:AMXElementTypeHeader3];
    [defalutStyle.h3Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(space3.paragraphSpacingBefore),
        CMParagraphStyleAttributeParagraphSpacing: @(space3.paragraphSpacing)
    }];
    [defalutStyle.h3Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeMinimumLineHeight:@([config getLineHeight:AMXElementTypeHeader3])
    }];
    AMXFontConfig* font4 = [config getFontConfig:AMXElementTypeHeader4];
    [defalutStyle.h4Attributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName: font4.fontColor,
        NSKernAttributeName: @(0.25),
        NSFontAttributeName: font4.font
    }];
    AMXSpacingConfig* space4 = [config getSpacingConfig:AMXElementTypeHeader4];
    [defalutStyle.h4Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(space4.paragraphSpacingBefore),
        CMParagraphStyleAttributeParagraphSpacing: @(space4.paragraphSpacing)
    }];
    [defalutStyle.h4Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeMinimumLineHeight:@([config getLineHeight:AMXElementTypeHeader4])
    }];
    AMXFontConfig* font5 = [config getFontConfig:AMXElementTypeHeader5];
    [defalutStyle.h5Attributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName: font5.fontColor,
        NSKernAttributeName: @(0.25),
        NSFontAttributeName: font5.font
    }];
    AMXSpacingConfig* space5 = [config getSpacingConfig:AMXElementTypeHeader5];
    [defalutStyle.h5Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(space5.paragraphSpacingBefore),
        CMParagraphStyleAttributeParagraphSpacing: @(space5.paragraphSpacing)
    }];
    [defalutStyle.h5Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeMinimumLineHeight:@([config getLineHeight:AMXElementTypeHeader5])
    }];
    AMXFontConfig* font6 = [config getFontConfig:AMXElementTypeHeader6];
    [defalutStyle.h6Attributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName: font6.fontColor,
        NSKernAttributeName: @(0.25),
        NSFontAttributeName: font6.font
    }];
    AMXSpacingConfig* space6 = [config getSpacingConfig:AMXElementTypeHeader6];
    [defalutStyle.h6Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(space6.paragraphSpacingBefore),
        CMParagraphStyleAttributeParagraphSpacing: @(space6.paragraphSpacing)
    }];
    [defalutStyle.h6Attributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeMinimumLineHeight:@([config getLineHeight:AMXElementTypeHeader6])
    }];
    
}
+ (void)transformHRule:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config {
    [defalutStyle.horizontalRuleAttributes.stringAttributes addEntriesFromDictionary:@{CMHorizontalRuleThickness:@(config.hRuleConfig.height)}];
    [defalutStyle.horizontalRuleAttributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName : config.hRuleConfig.color
    }];
    AMXSpacingConfig* spacing = [config getSpacingConfig:AMXElementTypeHRule];
    [defalutStyle.horizontalRuleAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(spacing.paragraphSpacingBefore)
    }];
    [defalutStyle.horizontalRuleAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacing: @(spacing.paragraphSpacing)
    }];
}
+ (void)transformTable:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config {
    AMXTableStyleConfig* tableConfig = config.tableConfig;
    
    [defalutStyle.tableCellAttributes.stringAttributes addEntriesFromDictionary:@{@"defaultMaxWidth":@(tableConfig.columnMaxWidth)}];
    [defalutStyle.tableCellAttributes.stringAttributes addEntriesFromDictionary:@{@"firstMaxWidth":@(tableConfig.firstColumnMaxWidth)}];
    [defalutStyle.tableCellAttributes.stringAttributes addEntriesFromDictionary:@{@"cellPadding":@(tableConfig.contentStyle.padding)}];
    
    [defalutStyle.tableHeaderAttributes.stringAttributes addEntriesFromDictionary:@{@"contentBgColor":tableConfig.headerStyle.backgroundColor}];
    [defalutStyle.tableHeaderAttributes.stringAttributes addEntriesFromDictionary:@{NSBackgroundColorAttributeName:[UIColor clearColor]}];
    [defalutStyle.tableHeaderAttributes.fontAttributes addEntriesFromDictionary:@{
        UIFontDescriptorSizeAttribute: @(tableConfig.headerStyle.font.font.pointSize),
    }];
    [defalutStyle.tableHeaderAttributes.stringAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:tableConfig.headerStyle.font.fontColor}];
    [defalutStyle.tableCellAttributes.stringAttributes addEntriesFromDictionary:@{@"contentBgColor":tableConfig.contentStyle.backgroundColor}];
    [defalutStyle.tableCellAttributes.stringAttributes addEntriesFromDictionary:@{NSBackgroundColorAttributeName:[UIColor clearColor]}];
    [defalutStyle.tableCellAttributes.fontAttributes addEntriesFromDictionary:@{
        UIFontDescriptorSizeAttribute: @(tableConfig.contentStyle.font.font.pointSize),
    }];
    [defalutStyle.tableCellAttributes.stringAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:tableConfig.contentStyle.font.fontColor}];
    [defalutStyle.tableTitleAttributes.stringAttributes addEntriesFromDictionary:@{NSBackgroundColorAttributeName:tableConfig.titleBackgroundColor}];
    [defalutStyle.tableTitleAttributes.fontAttributes addEntriesFromDictionary:@{
        UIFontDescriptorSizeAttribute: @(tableConfig.titlefont.font.pointSize),
    }];
    [defalutStyle.tableTitleAttributes.stringAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:tableConfig.titlefont.fontColor}];
    AMXSpacingConfig* spacing = [config getSpacingConfig:AMXElementTypeTable];
    [defalutStyle.tableAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(spacing.paragraphSpacingBefore)
     }];
    [defalutStyle.tableAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacing: @(spacing.paragraphSpacing)
     }];
    [defalutStyle.tableAttributes.stringAttributes addEntriesFromDictionary:@{@"rowSpacing":@(tableConfig.rowSpacing)}];
    [defalutStyle.tableAttributes.stringAttributes addEntriesFromDictionary:@{@"columnSpacing":@(tableConfig.columnSpacing)}];
    [defalutStyle.tableAttributes.stringAttributes addEntriesFromDictionary:@{@"borderWidth":@(tableConfig.borderWidth)}];
     [defalutStyle.tableAttributes.stringAttributes addEntriesFromDictionary:@{@"operationIcon":tableConfig.operationIconPath}];
}
+ (void)transformOrderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config {
    NSDictionary* dic = [config getAllLevelOrderListConfigs];
    AMXSpacingConfig* space = [config getSpacingConfig:AMXElementTypeOrderedList];
    AMXFontConfig* font = [config getFontConfig:AMXElementTypeOrderedList];
    CGFloat lineHeight = [config getLineHeight:AMXElementTypeOrderedList];
    CGFloat firstLevelIndent = 0;
    NSMutableDictionary* arrayStrDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* arrayParaDic = [[NSMutableDictionary alloc] init];
    for (NSString* tmpKey in dic.allKeys) {
        NSInteger indexLevel = [tmpKey intValue];
        if (indexLevel > 0) {
            AMXListLevelConfig* listConfig = [dic objectForKey:tmpKey];
            if (indexLevel == 1) {
                firstLevelIndent = listConfig.symbolIndentation;
            }
            NSMutableDictionary* subStrDic = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* subParaDic = [[NSMutableDictionary alloc] init];
            [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeParagraphSpacingBefore:@(space.paragraphSpacingBefore)}];
            [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeParagraphSpacing:@(space.paragraphSpacing)}];
            [subStrDic addEntriesFromDictionary:@{NSForegroundColorAttributeName:font.fontColor}];
            [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeMinimumLineHeight:@(lineHeight)}];
            [subStrDic addEntriesFromDictionary:@{CMListLevelIndent:@(listConfig.symbolIndentation)}];
            if (listConfig.prefixType == AMXListPrefixTypeCharacter) {
                [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeListItemNumberFormat: listConfig.prefixSymbol}];
                
                [subStrDic addEntriesFromDictionary:@{CMListInternalSpace:@(listConfig.prefixSpacing),
                                            CMListSingleDigitSize:@(listConfig.symbolSize.width),
                                            CMListTwoDigitSize:@(listConfig.symbolSize.width + 9),
                                            CMListThreeDigitSize:@(listConfig.symbolSize.width + 18)}];
            } else {

                [subStrDic addEntriesFromDictionary:@{CMParagraphStyleAttributeListItemLabelIcon:listConfig.prefixSymbolPath}];
                
                [subStrDic addEntriesFromDictionary:@{CMListInternalSpace:@(listConfig.prefixSpacing),
                                            CMParagraphStyleAttributeListItemLabelIconSize:@(listConfig.symbolSize.width)}];
            }
            
            [arrayStrDic setObject:subStrDic forKey:tmpKey];
            [arrayParaDic setObject:subParaDic forKey:tmpKey];
        }
    }
    
    [defalutStyle.orderedListItemAttributes.stringAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:font.fontColor}];
    [defalutStyle.orderedListItemAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: font.font,
    }];
    
    AMStyleProvider styleProvide = AMCustomProvider();
    defalutStyle.ordererListAttributesProvider = ^CMStyleAttributes * _Nonnull(NSInteger level) {
        CMStyleAttributes *attr = styleProvide(level);
        NSString* subKey = [NSString stringWithFormat:@"%ld", (long)level];
        NSDictionary* indexParaDic = [arrayParaDic objectForKey:subKey];
        NSDictionary* indexStrDic = [arrayStrDic objectForKey:subKey];
        if (indexParaDic && [indexParaDic count] > 0) {
            [attr.paragraphStyleAttributes addEntriesFromDictionary:indexParaDic];
        }
        if (indexStrDic && [indexStrDic count] > 0) {
            [attr.stringAttributes addEntriesFromDictionary:indexStrDic];
        }

        return attr;
    };
}
+ (void)transformUnorderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config {
    NSDictionary* dic = [config getAllLevelUnorderListConfigs];
    AMXSpacingConfig* space = [config getSpacingConfig:AMXElementTypeUnorderedList];
    AMXFontConfig* font = [config getFontConfig:AMXElementTypeUnorderedList];
    CGFloat lineHeight = [config getLineHeight:AMXElementTypeUnorderedList];
    CGFloat firstLevelIndent = 0;
    CGFloat symbolSize = 0;
    NSMutableDictionary* arrayStrDic = [[NSMutableDictionary alloc] init];
    NSMutableDictionary* arrayParaDic = [[NSMutableDictionary alloc] init];
    for (NSString* tmpKey in dic.allKeys) {
        NSInteger indexLevel = [tmpKey intValue];
        if (indexLevel > 0) {
            AMXListLevelConfig* listConfig = [dic objectForKey:tmpKey];
            if (indexLevel == 1) {
                symbolSize = listConfig.symbolSize.width;
                firstLevelIndent = listConfig.symbolIndentation;
            }
            NSMutableDictionary* subStrDic = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* subParaDic = [[NSMutableDictionary alloc] init];
            [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeParagraphSpacingBefore:@(space.paragraphSpacingBefore)}];
            [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeParagraphSpacing:@(space.paragraphSpacing)}];
            [subStrDic addEntriesFromDictionary:@{NSForegroundColorAttributeName:font.fontColor}];
            [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeMinimumLineHeight:@(lineHeight)}];
            [subStrDic addEntriesFromDictionary:@{CMListLevelIndent:@(listConfig.symbolIndentation)}];
            if (listConfig.prefixType == AMXListPrefixTypeCharacter) {
                [subParaDic addEntriesFromDictionary:@{CMParagraphStyleAttributeListItemBulletString:listConfig.prefixSymbol}];
                
                [subStrDic addEntriesFromDictionary:@{CMListInternalSpace:@(listConfig.prefixSpacing),
                                            CMListSingleDigitSize:@(listConfig.symbolSize.width)}];
            } else {
                
                [subStrDic addEntriesFromDictionary:@{CMParagraphStyleAttributeListItemLabelIcon:listConfig.prefixSymbolPath}];
                
                [subStrDic addEntriesFromDictionary:@{CMListInternalSpace:@(listConfig.prefixSpacing),
                                            CMParagraphStyleAttributeListItemLabelIconSize:@(listConfig.symbolSize.width)}];
            }
            
            [arrayStrDic setObject:subStrDic forKey:tmpKey];
            [arrayParaDic setObject:subParaDic forKey:tmpKey];
        }
    }
    [defalutStyle.listBulletAttributes.fontAttributes addEntriesFromDictionary:@{
        UIFontDescriptorSizeAttribute: @(symbolSize),
    }];
    [defalutStyle.unorderedListItemAttributes.stringAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:font.fontColor}];
    [defalutStyle.unorderedListItemAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: font.font,
    }];

    AMStyleProvider styleProvide = AMCustomProvider();
    defalutStyle.unordererListAttributesProvider = ^CMStyleAttributes * _Nonnull(NSInteger level) {
        CMStyleAttributes *attr = styleProvide(level);
        NSString* subKey = [NSString stringWithFormat:@"%ld", (long)level];
        NSDictionary* indexParaDic = [arrayParaDic objectForKey:subKey];
        NSDictionary* indexStrDic = [arrayStrDic objectForKey:subKey];
        if (indexParaDic && [indexParaDic count] > 0) {
            [attr.paragraphStyleAttributes addEntriesFromDictionary:indexParaDic];
        }
        if (indexStrDic && [indexStrDic count] > 0) {
            [attr.stringAttributes addEntriesFromDictionary:indexStrDic];
        }

        return attr;
    };
}
+ (void)transformFootNote:(AMTextStyles *)defaultStyle customStyle:(AMXMarkdownStyleConfig *)config
{
    AMXFontConfig* font = [config getFontConfig:AMXElementTypeFootNote];
    [defaultStyle.footNoteAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: font.font,
    }];
    [defaultStyle.footNoteAttributes.stringAttributes addEntriesFromDictionary:@{
        @"labelSize": @(config.footNoteConfig.size.width),
    }];
    [defaultStyle.footNoteAttributes.stringAttributes addEntriesFromDictionary:@{
        NSBackgroundColorAttributeName : config.footNoteConfig.backgroundColor
    }];
    [defaultStyle.footNoteAttributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName : font.fontColor
    }];
   
}
+ (void)transformLink:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config textView:(UITextView*)textView
{
    AMXFontConfig* font = [config getFontConfig:AMXElementTypeLink];
    AMXLinkConfig* linkConfig = config.linkConfig;
    [defaultStyle.linkAttributes.stringAttributes addEntriesFromDictionary:@{
        NSForegroundColorAttributeName: font.fontColor,
        NSBaselineOffsetAttributeName: @(0.0)
    }];
    if (textView) {
        textView.linkTextAttributes = @{NSForegroundColorAttributeName:font.fontColor,NSUnderlineColorAttributeName:linkConfig.underLine ? font.fontColor : [UIColor clearColor]};
    }
  
    if (linkConfig.iconPath) {
        [defaultStyle.linkAttributes.stringAttributes addEntriesFromDictionary:@{CMLinkIconSpace:@(linkConfig.spacing)}];
        if (linkConfig.prefixOrSuffix == 1) {
            [defaultStyle.linkAttributes.stringAttributes addEntriesFromDictionary:@{CMLinkIconPrefix: linkConfig.iconPath}];
        } else if (linkConfig.prefixOrSuffix == 2) {
            [defaultStyle.linkAttributes.stringAttributes addEntriesFromDictionary:@{CMLinkIconSuffix: linkConfig.iconPath}];
        }
        
    }
}
+ (void)transformInlineCode:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config
{
    if (config.inlineCodeConfig.backgroundColor) {
        [defaultStyle.inlineCodeAttributes.stringAttributes addEntriesFromDictionary:@{
            AMBackgroundDrawableAttributeName: [AMTextBackground backgroundWithColor:config.inlineCodeConfig.backgroundColor
                                                                              radius:4
                                                                              insets:UIEdgeInsetsMake(5.5,2,-1,2)],
        }];
    }
    
    if (config.inlineCodeConfig.codeFont) {
        if (config.inlineCodeConfig.codeFont.font) {
            [defaultStyle.inlineCodeAttributes.fontAttributes addEntriesFromDictionary:@{
                UIFontDescriptorSizeAttribute: @(config.inlineCodeConfig.codeFont.font.pointSize)
            }];
        }
        
        if (config.inlineCodeConfig.codeFont.fontColor) {
            [defaultStyle.inlineCodeAttributes.stringAttributes addEntriesFromDictionary:@{
                NSForegroundColorAttributeName: config.inlineCodeConfig.codeFont.fontColor
            }];
        }
    }
}
+ (void)transformCodeBlock:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config
{
    AMXCodeBlockConfig* codeConfig = config.codeBlockConfig;
    if (codeConfig.titleBackgroundColor) {
        [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{@"headerBackgroundColor":codeConfig.titleBackgroundColor}];
    }
    if (codeConfig.titleFont) {
        [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{@"titleFont":codeConfig.titleFont.font}];
        [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{@"titleFontColor":codeConfig.titleFont.fontColor}];
    
    }
    if (codeConfig.borderColor) {
        [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{@"borderColor":codeConfig.borderColor}];
    }
    if (codeConfig.borderWidth) {
        [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{@"borderWidth":@(codeConfig.borderWidth)}];
    }
    if (codeConfig.backgroundColor) {
        [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{@"backgroundColor":codeConfig.backgroundColor}];
        [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{NSBackgroundColorAttributeName:codeConfig.backgroundColor}];
    }
    [defaultStyle.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{@"operationIcon":codeConfig.operationIconPath}];
    
}

+ (void)transformUnderLine:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config
{
    AMXUnderLineConfig* underlineConfig = config.underlineConfig;
    if (underlineConfig.lineColor) {
        [defaultStyle.underlineAttributes.stringAttributes addEntriesFromDictionary:@{NSForegroundColorAttributeName:underlineConfig.lineColor}];
    }
    [defaultStyle.underlineAttributes.stringAttributes addEntriesFromDictionary:@{
                                                                                  @"lineWidth":@(underlineConfig.lineWidth),
                                                                                  @"lineOffset":@(underlineConfig.lineOffset)}];
}
+ (void)transformBlockQuote:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config
{
    AMXBlockquoteStyle* blockQuote = config.blockQuoteConfig;
    if (blockQuote) {
        [defaultStyle.blockQuoteAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
            CMParagraphStyleAttributeFirstLineHeadExtraIndent: @(blockQuote.indentation)
        }];
        [defaultStyle.blockQuoteAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
            CMParagraphStyleAttributeHeadExtraIndent: @(blockQuote.indentation)
        }];
        
        [defaultStyle.blockQuoteAttributes.stringAttributes addEntriesFromDictionary:@{
            AMBackgroundDrawableAttributeName: [AMTextBackground leftBorderColor:blockQuote.lineColor                    width:blockQuote.lineWidth],
        }];
        
    }
    AMXFontConfig* font = [config getFontConfig:AMXElementTypeBlockQuote];
    if (font) {
        [defaultStyle.blockQuoteAttributes.stringAttributes addEntriesFromDictionary:@{
            NSForegroundColorAttributeName : font.fontColor
        }];
        [defaultStyle.blockQuoteAttributes.stringAttributes addEntriesFromDictionary:@{NSFontAttributeName:font.font}];
    }
    AMXSpacingConfig* spaceConfig = [config getSpacingConfig:AMXElementTypeBlockQuote];
    if (spaceConfig) {
        [defaultStyle.blockQuoteAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{CMParagraphStyleAttributeParagraphSpacing:@(spaceConfig.paragraphSpacing),CMParagraphStyleAttributeParagraphSpacingBefore:@(spaceConfig.paragraphSpacingBefore)}];
    }
}
@end
