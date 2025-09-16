// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMTextStyles+CardUIPlugins.h"
#import <AntMarkDown/AntMarkDown.h>
#import "AMXMarkdownImageTextAttachment.h"
#import "AMXMarkdownImageAttachmentBuilder.h"
#import "AMXMarkdownCodeViewAttachment.h"
#import <AntMarkdown/CMTextAttributes.h>
#import "AMXFootnodeBuilder.h"
#import <AntMarkdown/AMUtils.h>
#import "AMXMarkdownDefine.h"
AMStyleProvider AMOrderListProviderForAISearch(void) {
    return ^CMStyleAttributes * (NSInteger level) {
        CMStyleAttributes *styles = [[CMStyleAttributes alloc] init];
        [styles.stringAttributes addEntriesFromDictionary:@{
            NSParagraphStyleAttributeName: ({
            NSMutableParagraphStyle *paragraphStyles = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyles.tabStops = @[
                [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                location:7 + (level - 1) * 20
                                                 options:@{}],
                [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                location:30 + (level - 1) * 20
                                                 options:@{}],
            ];
            paragraphStyles.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyles.paragraphSpacingBefore = 8;
            paragraphStyles.lineSpacing = 2;
            paragraphStyles.firstLineHeadIndent = 0;
            paragraphStyles.headIndent = 30 + (level - 1) * 20;
            [paragraphStyles copy];
        }),
        }];
        
        [styles.paragraphStyleAttributes addEntriesFromDictionary:@{
            CMParagraphStyleAttributeFirstLineHeadExtraIndent: @0,
            CMParagraphStyleAttributeHeadExtraIndent: @0,
            CMParagraphStyleAttributeListItemLabelIndent: [NSNull null],
            CMParagraphStyleAttributeListItemNumberFormat: @"\t%ld.",
            CMParagraphStyleAttributeListItemBulletString: @"\t●",
        }];
        return styles;
    };
}
AMStyleProvider AMUnorderListProviderForAISearch(void) {
    return ^CMStyleAttributes * (NSInteger level) {
        CMStyleAttributes *styles = [[CMStyleAttributes alloc] init];
        [styles.stringAttributes addEntriesFromDictionary:@{
            NSParagraphStyleAttributeName: ({
            NSMutableParagraphStyle *paragraphStyles = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyles.tabStops = @[
                [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentCenter
                                                location:13 + (level - 1) * 20
                                                 options:@{}],
                [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                location:23.5 + (level - 1) * 20
                                                 options:@{}],
            ];
            paragraphStyles.lineBreakMode = NSLineBreakByWordWrapping;
            paragraphStyles.paragraphSpacingBefore = 8;
            paragraphStyles.lineSpacing = 2;
            paragraphStyles.firstLineHeadIndent = 0;
            paragraphStyles.headIndent = 23.5 + (level - 1) * 20;
            [paragraphStyles copy];
        }),
        }];
        
        [styles.paragraphStyleAttributes addEntriesFromDictionary:@{
            CMParagraphStyleAttributeFirstLineHeadExtraIndent: @0,
            CMParagraphStyleAttributeHeadExtraIndent: @0,
            CMParagraphStyleAttributeListItemLabelIndent: [NSNull null],
            CMParagraphStyleAttributeListItemNumberFormat: @"\t%ld.",
            CMParagraphStyleAttributeListItemBulletString: @"\t●",
        }];
        return styles;
    };
}
@implementation AMTextStyles (CardUIPlugins)

+ (instancetype)cpl_cardDefaultTextStyles {
    AMTextStyles *style = [AMTextStyles defaultStyles];
    style.baseTextAttributes = [[CMStyleAttributes alloc] init];
    [style registerImageAttachmentBuilder:[[AMXMarkdownImageAttachmentBuilder alloc] init]];
    
    [style registerCodeBlockAttachmentBuilder:[[AMXMarkdownCodeViewAttachment alloc] init]];

    [style cpl_registerDefaultCssClass];
    
    [style registerFootnoteRefBuilder:[[AMXFootnodeBuilder alloc] init]];
    [style.footNoteRefAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: [UIFont systemFontOfSize: 12.0],
        NSBaselineOffsetAttributeName: @(6),
        NSForegroundColorAttributeName:[AMUtils colorWithString:@"0x0e489a"]}];

    [style.baseTextAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: kCUPLMarkdownTextFont,
        NSForegroundColorAttributeName:kCUPLMarkdownCommonTextColor,
        NSKernAttributeName: @(0.25)
    }];
    
    [style.paragraphAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{ CMParagraphStyleAttributeParagraphSpacingBefore: @12,
        CMParagraphStyleAttributeMinimumLineHeight:@(kCUPLMarkdownTextLineHeight),
        CMParagraphStyleAttributeLineBreakMode:@(NSLineBreakByWordWrapping),
     }];
    
    [style.imageParagraphAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{ CMParagraphStyleAttributeParagraphSpacingBefore: @12,
        CMParagraphStyleAttributeAlignment: @(NSTextAlignmentLeft),
        CMParagraphStyleAttributeLineSpacing:@(0)}];

    [style.linkAttributes.stringAttributes addEntriesFromDictionary:@{ 
        NSForegroundColorAttributeName: [AMUtils colorWithString:@"#1677FF"],
        NSBaselineOffsetAttributeName: @(0.0)
    }];
    
    [style.h1Attributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: kCUPLMarkdownTextBoldFont,
        NSForegroundColorAttributeName:kCUPLMarkdownCommonTextColor,
        NSKernAttributeName: @(0.25)
    }];
    [style.h2Attributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: kCUPLMarkdownTextBoldFont,
        NSForegroundColorAttributeName:kCUPLMarkdownCommonTextColor,
        NSKernAttributeName: @(0.25)
    }];
    [style.h3Attributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: kCUPLMarkdownTextBoldFont,
        NSForegroundColorAttributeName:kCUPLMarkdownCommonTextColor,
        NSKernAttributeName: @(0.25)
    }];
    [style.h4Attributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: kCUPLMarkdownTextBoldFont,
        NSForegroundColorAttributeName:kCUPLMarkdownCommonTextColor,
        NSKernAttributeName: @(0.25)
    }];
    [style.h5Attributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: kCUPLMarkdownTextBoldFont,
        NSForegroundColorAttributeName:kCUPLMarkdownCommonTextColor,
        NSKernAttributeName: @(0.25)
    }];
    [style.h6Attributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: kCUPLMarkdownTextBoldFont,
        NSForegroundColorAttributeName:kCUPLMarkdownCommonTextColor,
        NSKernAttributeName: @(0.25)
    }];

    AMStyleProvider styleProvide = AMDefaultProvider();

    style.ordererListAttributesProvider = ^CMStyleAttributes * _Nonnull(NSInteger level) {
        CMStyleAttributes *attr = styleProvide(level);
        [attr.paragraphStyleAttributes addEntriesFromDictionary:@{
            CMParagraphStyleAttributeListItemLabelIndent: [NSNull null],
            CMParagraphStyleAttributeListItemBulletString: @"\t●",
            CMParagraphStyleAttributeListItemNumberFormat: @"\t%ld.",
            CMParagraphStyleAttributeMinimumLineHeight:@(kCUPLMarkdownTextLineHeight)
        }];
        return attr;
    };
    
    style.unordererListAttributesProvider = ^CMStyleAttributes * _Nonnull(NSInteger level) {
        CMStyleAttributes *attr = styleProvide(level);
        [attr.paragraphStyleAttributes addEntriesFromDictionary:@{
            CMParagraphStyleAttributeListItemLabelIndent: [NSNull null],
            CMParagraphStyleAttributeListItemBulletString: @"\t●",
            CMParagraphStyleAttributeListItemNumberFormat: @"\t%ld.",
            CMParagraphStyleAttributeMinimumLineHeight:@(kCUPLMarkdownTextLineHeight)
        }];
        return attr;
    };
    
    [style.orderedListItemAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeListItemParagraphPrefix:@"\t\t",
    }];
    
    if (!style.unorderedListItemAttributes) {
        style.unorderedListItemAttributes = [[CMStyleAttributes alloc] init];
    }
    [style.unorderedListItemAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeListItemParagraphPrefix:@"\t\t",
    }];
        
    return style;
}
- (void)cpl_registerDefaultCssClass {
    [self addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0xe62c3b],
    }
                       forClass:@"up"];
    [self addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0xe62c3b],
    }
                       forClass:@"markdown-red-color"];
    [self addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x0e9976],
    }
                       forClass:@"down"];
    [self addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x0e9976],
    }
                       forClass:@"markdown-green-color"];

    [self addStringAttributes:@{
        AMUnderlineDrawableAttributeName: [[AMUnderline alloc] initWithColor:[AMUtils colorWithString:@"#1677FF52"] lineWidth:6 offset:4],
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
        NSUnderlineColorAttributeName: [UIColor clearColor],
    }
                     forClass:@"highlight"];
    
    [self addStringAttributes:@{
        AMUnderlineDrawableAttributeName: [[AMUnderline alloc] initWithColor:[AMUtils colorWithString:@"#1677FF52"] lineWidth:6 offset:4],
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
        NSUnderlineColorAttributeName: [UIColor clearColor],
    }
                       forClass:@"poi"];
    [self addStringAttributes:@{
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x0E489A],
    }
                       forClass:@"related-entity"];
}

@end
