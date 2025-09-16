// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <CoreText/CoreText.h>

#import "AMTextStyles.h"
#import "AMUtils.h"
#import "AMDrawable.h"
#import "AMTextBackground.h"
NSMutableDictionary* stylesForId;
AMStyleProvider AMDefaultProvider(void) {
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

@interface AMTextStyles ()
@property (nonatomic) NSMutableDictionary<NSString *, CMStyleAttributes *> *classAttributes;
@property (nonatomic) NSMutableArray<id<CMHTMLElementTransformer> > *transformers;
@end

@implementation AMTextStyles

+ (instancetype)defaultStyles {
    AMTextStyles *styles = [[self alloc] init];
    
    [styles.baseTextAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: [UIFont systemFontOfSize:15],
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0x1F3B63],
    }];
    [styles.baseTextAttributes.fontAttributes addEntriesFromDictionary:@{
        
    }];
    [styles.baseTextAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeAlignment: @(NSTextAlignmentNatural),
        CMParagraphStyleAttributeParagraphSpacing: @4,
        CMParagraphStyleAttributeParagraphSpacingBefore: @4,
        CMParagraphStyleAttributeHeadExtraIndent: @0,
        CMParagraphStyleAttributeLineHeightMultiple: @1.08,
        CMParagraphStyleAttributeHyphenationFactor: @1,
        CMParagraphStyleAttributeLineBreakMode: @(NSLineBreakByWordWrapping),
    }];
    
    [styles.paragraphAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @10,
    }];
    
    [styles.orderedListAttributes.stringAttributes addEntriesFromDictionary:@{
        NSParagraphStyleAttributeName: ({
        NSMutableParagraphStyle *paragraphStyles = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyles.defaultTabInterval = 30;
        paragraphStyles.tabStops = @[
            [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentRight
                                            location:20
                                             options:@{}],
            [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                            location:20 + 6
                                             options:@{}],
        ];
        paragraphStyles.paragraphSpacingBefore = 10;
        paragraphStyles.paragraphSpacing = 0;
        paragraphStyles.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyles.lineSpacing = 2;
        paragraphStyles.firstLineHeadIndent = 0;
        paragraphStyles.headIndent = 26;
        [paragraphStyles copy];
    }),
    }];
    
    [styles.orderedListAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeFirstLineHeadExtraIndent: @0,
        CMParagraphStyleAttributeHeadExtraIndent: @0,
        CMParagraphStyleAttributeListItemLabelIndent: [NSNull null],
        CMParagraphStyleAttributeListItemNumberFormat: @"\t%ld.",
    }];
    
    [styles.orderedSublistAttributes.stringAttributes addEntriesFromDictionary:@{
        NSParagraphStyleAttributeName: ({
        NSMutableParagraphStyle *paragraphStyles = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyles.defaultTabInterval = 30;
        paragraphStyles.tabStops = @[
            [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentRight
                                            location:20 + 26
                                             options:@{}],
            [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                            location:20 + 26 + 6
                                             options:@{}],
        ];
        paragraphStyles.paragraphSpacingBefore = 10;
        paragraphStyles.paragraphSpacing = 0;
        paragraphStyles.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyles.lineSpacing = 2;
        paragraphStyles.firstLineHeadIndent = 0;
        paragraphStyles.headIndent = 20 + 26 + 6;
        [paragraphStyles copy];
    })
    }];
    
    [styles.orderedSublistAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeFirstLineHeadExtraIndent: @0,
        CMParagraphStyleAttributeHeadExtraIndent: @0,
        CMParagraphStyleAttributeListItemLabelIndent: [NSNull null],
        CMParagraphStyleAttributeListItemNumberFormat: @"\t%ld.",
    }];
    
    [styles.unorderedListAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeFirstLineHeadExtraIndent: @10,
        CMParagraphStyleAttributeHeadExtraIndent: @20,
        CMParagraphStyleAttributeListItemLabelIndent: @10,
        CMParagraphStyleAttributeListItemBulletString: @"\t●",
    }];
    
    [styles.unorderedSublistAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeFirstLineHeadExtraIndent: @20,
        CMParagraphStyleAttributeHeadExtraIndent: @36,
        CMParagraphStyleAttributeListItemLabelIndent: @16,
        CMParagraphStyleAttributeListItemBulletString: @"\t●",
    }];
    
    styles.ordererListAttributesProvider = AMDefaultProvider();
    styles.unordererListAttributesProvider = AMDefaultProvider();
    
    [styles.blockQuoteAttributes.stringAttributes addEntriesFromDictionary:@{
        AMBackgroundDrawableAttributeName: [AMTextBackground leftBorderColor:[UIColor colorWithHex_ant_mark:0xd1d9e0]
                                                                       width:4],
    }];
    [styles.blockQuoteAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeFirstLineHeadExtraIndent: @20,
        CMParagraphStyleAttributeHeadExtraIndent: @20,
        CMParagraphStyleAttributeParagraphSpacingBefore: @10,
        CMParagraphStyleAttributeParagraphSpacing: @10,
    }];
    
    [styles.listBulletAttributes.stringAttributes addEntriesFromDictionary:@{
        NSBaselineOffsetAttributeName: @3,
    }];
    
    [styles.listBulletAttributes.fontAttributes addEntriesFromDictionary:@{
        UIFontDescriptorSizeAttribute: @8,
    }];
    
    [styles.inlineCodeAttributes.stringAttributes addEntriesFromDictionary:@{
        AMBackgroundDrawableAttributeName: [AMTextBackground backgroundWithColor:[UIColor colorWithHex_ant_mark:0x1f1f3b63]
                                                                          radius:4
                                                                          insets:UIEdgeInsetsMake(6, 2, 0, 2)],
        NSForegroundColorAttributeName: [UIColor colorWithHex_ant_mark:0xFF1F3B63],
    }];
    [styles.inlineCodeAttributes.fontAttributes addEntriesFromDictionary:@{
        UIFontDescriptorNameAttribute: @"Menlo-Regular",
        UIFontDescriptorCascadeListAttribute: @[
            [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                UIFontDescriptorNameAttribute: @"Courier"
            }],
            [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                UIFontDescriptorNameAttribute: @"Courier New"
            }]
        ],
    }];
    [styles.inlineCodeAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeLineBreakMode: @(NSLineBreakByCharWrapping),
    }];
    
    [styles.codeBlockAttributes.stringAttributes addEntriesFromDictionary:@{
        NSFontAttributeName: [UIFont fontWithDescriptor:[UIFontDescriptor fontDescriptorWithFontAttributes:@{
            UIFontDescriptorNameAttribute: @"Courier",
            UIFontDescriptorCascadeListAttribute: @[
                [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                    UIFontDescriptorNameAttribute: @"Courier New"
                }],
                [UIFontDescriptor fontDescriptorWithFontAttributes:@{
                    UIFontDescriptorNameAttribute: @"Menlo"
                }],
            ]
        }]
                                                   size:13],
    }];
    [styles.codeBlockAttributes.fontAttributes addEntriesFromDictionary:@{
        
    }];
    [styles.codeBlockAttributes.paragraphStyleAttributes addEntriesFromDictionary:@{
        CMParagraphStyleAttributeHeadExtraIndent: @0,
        CMParagraphStyleAttributeFirstLineHeadExtraIndent: @0,
        CMParagraphStyleAttributeParagraphSpacingBefore: @0,
        CMParagraphStyleAttributeLineHeightMultiple: @1.4,
    }];
    
    [styles.tableHeaderAttributes.stringAttributes addEntriesFromDictionary:@{
        
    }];
    [styles.tableCellAttributes.fontAttributes addEntriesFromDictionary:@{
        UIFontDescriptorSizeAttribute: @13,
    }];
    
    return styles;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.classAttributes = [NSMutableDictionary new];
        self.transformers = [NSMutableArray array];
        
        self.orderedListItemAttributes = [[CMStyleAttributes alloc] init];
        self.unorderedListItemAttributes = [[CMStyleAttributes alloc] init];
        self.underlineAttributes = [[CMStyleAttributes alloc] init];
        self.strikethroughAttributes = [[CMStyleAttributes alloc] init];
        [self.strikethroughAttributes.stringAttributes addEntriesFromDictionary:@{
            NSStrikethroughStyleAttributeName: @(NSUnderlineStyleSingle),
        }];
        self.tableAttributes = [[CMStyleAttributes alloc] init];
        self.tableTitleAttributes = [[CMStyleAttributes alloc] init];
        self.tableHeaderAttributes = [self.strongAttributes copy];
        self.tableCellAttributes = [self.paragraphAttributes copy];
        
        self.listBulletAttributes = [[CMStyleAttributes alloc] init];
        
        self.footNoteRefAttributes = [self.linkAttributes copy];
        [self.footNoteRefAttributes.stringAttributes addEntriesFromDictionary:@{
            NSBaselineOffsetAttributeName: @6,
        }];
        [self.footNoteRefAttributes.fontAttributes addEntriesFromDictionary:@{
            UIFontDescriptorSizeAttribute: @10,
        }];
        
        self.footNoteAttributes = [self.orderedListItemAttributes copy];
        
    }
    return self;
}

- (CMStyleAttributes *)attributesForClass:(NSString *)className {
    CMStyleAttributes *attributes = self.classAttributes[className];
    if (!attributes) {
        attributes = [CMStyleAttributes new];
        self.classAttributes[className] = attributes;
    }
    return attributes;
}

- (void)setAttributes:(CMStyleAttributes *)attributes forClass:(NSString *)className {
    self.classAttributes[className] = attributes;
}

- (void)addFontAttributes:(NSDictionary<CMFontDescriptorAttributeName,id> *)fontAttributes forClass:(NSString *)className {
    CMStyleAttributes *attributes = [self attributesForClass:className];
    [attributes.fontAttributes addEntriesFromDictionary:fontAttributes];
}

- (void)addStringAttributes:(NSDictionary<NSAttributedStringKey,id> *)stringAttributes forClass:(NSString *)className {
    CMStyleAttributes *attributes = [self attributesForClass:className];
    [attributes.stringAttributes addEntriesFromDictionary:stringAttributes];
}

- (void)addParagraphStyleAttributes:(NSDictionary<CMParagraphStyleAttributeName,id> *)paragraphAttributes forClass:(NSString *)className {
    CMStyleAttributes *attributes = [self attributesForClass:className];
    [attributes.paragraphStyleAttributes addEntriesFromDictionary:paragraphAttributes];
}

- (NSArray<id<CMHTMLElementTransformer>> *)elementTransformers
{
    return [self.transformers copy];
}

- (void)addTransformer:(id<CMHTMLElementTransformer>)transformer
{
    [self.transformers addObject:transformer];
}

- (void)registerImageAttachmentBuilder:(nonnull id<AMImageAttachmentBuilder>)builder {
    _imageBuilder = builder;
}

- (void)registerTableBlockAttachmentBuilder:(nonnull id<AMTableAttachmentBuilder>)builder {
    _tableBuilder = builder;
}

- (void)registerCodeBlockAttachmentBuilder:(nonnull id<AMCodeAttachmentBuilder>)builder {
    _codeBuilder = builder;
}

- (void)registerFootnoteRefBuilder:(id<AMFootnoteRefBuilder>)builder
{
    _footnoteRefBuilder = builder;
}
+ (void)setAMStylesWithId:(NSString*)styleId styles:(AMTextStyles*)styles
{
    if (!stylesForId) {
        stylesForId = [[NSMutableDictionary alloc] init];
    }
    stylesForId[styleId] = styles;
}
+ (instancetype)getAMStylesWithId:(NSString*)styleId
{
    if (!stylesForId) {
        stylesForId = [[NSMutableDictionary alloc] init];
    }
    return [stylesForId objectForKey:styleId];
}
+ (void)removeAMStylesWithId:(NSString*)styleId
{
    if (!stylesForId) {
        stylesForId = [[NSMutableDictionary alloc] init];
    }
    [stylesForId removeObjectForKey:styleId];
}
@end

@interface AMBuilderBlock () <AMTableAttachmentBuilder, AMCodeAttachmentBuilder, AMImageAttachmentBuilder, AMFootnoteRefBuilder>
@property (nonatomic, copy) id(^builderBlock)(void);
@end

@implementation AMBuilderBlock

+ (id<AMTableAttachmentBuilder>)tableBuilder:(NSTextAttachment<AMViewAttachment> * _Nonnull (^)(CMTable * _Nonnull, AMTextStyles * _Nonnull))block
{
    AMBuilderBlock *builder = [self new];
    builder.builderBlock = (id(^)(void))block;
    return builder;
}

+ (id<AMCodeAttachmentBuilder>)codeBuilder:(NSTextAttachment<AMViewAttachment> * _Nonnull (^)(NSString * _Nonnull, NSString * _Nullable, AMTextStyles * _Nonnull))block
{
    AMBuilderBlock *builder = [self new];
    builder.builderBlock = (id(^)(void))block;
    return builder;
}

+ (id<AMFootnoteRefBuilder>)footnoteBuilder:(NSAttributedString * _Nonnull (^)(NSString * _Nonnull, NSString * _Nonnull, NSInteger, AMTextStyles * _Nonnull))block
{
    AMBuilderBlock *builder = [self new];
    builder.builderBlock = (id(^)(void))block;
    return builder;
}

+ (id<AMImageAttachmentBuilder>)imageBuilder:(NSTextAttachment * _Nonnull (^)(NSURL * _Nonnull, NSString * _Nullable, AMTextStyles * _Nonnull))block
{
    AMBuilderBlock *builder = [self new];
    builder.builderBlock = (id(^)(void))block;
    return builder;
}

- (nonnull NSTextAttachment<AMViewAttachment> *)buildWithTable:(nonnull CMTable *)table 
                                                        styles:(nonnull AMTextStyles *)styles {
    return ((NSTextAttachment<AMViewAttachment> *(^)(CMTable * _Nonnull, AMTextStyles * _Nonnull))self.builderBlock)(table, styles);
}

- (nonnull NSTextAttachment<AMViewAttachment> *)buildWithCode:(nonnull NSString *)code language:(nullable NSString *)language styles:(nonnull AMTextStyles *)styles { 
    return ((NSTextAttachment<AMViewAttachment> *(^)(NSString * _Nonnull, NSString * _Nullable, AMTextStyles * _Nonnull))self.builderBlock)(code, language, styles);
}

- (nonnull NSTextAttachment *)buildWithURL:(nonnull NSURL *)url title:(nullable NSString *)title styles:(nonnull AMTextStyles *)styles { 
    return ((NSTextAttachment * _Nonnull (^)(NSURL * _Nonnull, NSString * _Nullable, AMTextStyles * _Nonnull))self.builderBlock)(url, title, styles);
}

- (nonnull NSAttributedString *)buildWithReference:(nonnull NSString *)reference title:(nonnull NSString *)title index:(NSInteger)index styles:(nonnull AMTextStyles *)styles { 
    return ((NSAttributedString * _Nonnull (^)(NSString * _Nonnull, NSString * _Nonnull, NSInteger, AMTextStyles * _Nonnull))self.builderBlock)(reference, title, index, styles);
}

@end
