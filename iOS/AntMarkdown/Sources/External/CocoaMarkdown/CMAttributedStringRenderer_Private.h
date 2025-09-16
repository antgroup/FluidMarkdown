// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CMAttributedStringRenderer.h"
#import "CMCascadingAttributeStack.h"
#import "CMParser.h"
#import "CMStack.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMAttributedStringRenderer () <CMParserDelegate>
{
@protected
    CMDocument *_document;
    CMTextAttributes *_attributes;
    CMCascadingAttributeStack *_attributeStack;
    CMStack *_HTMLStack;
    NSMutableDictionary *_tagNameToTransformerMapping;
    NSMutableAttributedString *_buffer;
    NSAttributedString *_attributedString;
    NSMutableArray*    _clickableObjs;
    NSMutableAttributedString * _tableCellBuffer;
	UIColor* paragraphColor;
    UIFont* paragraphFont;
    CGFloat paragrahpSpace;
    CGFloat paragrahpSpaceBofore;
    NSInteger quoteLevel;
}
@property (readonly) CMDocument *document;
@property (readonly) CMTextAttributes *attributes;
@property (readonly) CMCascadingAttributeStack *attributeStack;
@property (readonly) CMStack *HTMLStack;
@property (readonly) NSMutableDictionary *tagNameToTransformerMapping;
@property (readonly) NSMutableAttributedString *buffer;
@property (nonatomic, weak)id<CMAttributedStringRendererDelegate> delegate;

- (void)appendString:(NSString *)string;

- (NSTextAttachment *)imageAttachmentWithURL:(NSURL *)url title:(NSString *)title;

- (void)appendBulletString:(NSString *)string;

- (void)closeBlockForNode:(CMNode *)currentNode;

-(void)addClickableObjects:(CMNodeType)type data:(NSString*)data tag:(NSString*)tag;

-(NSInteger)getOrderListNumber;
@end

NS_ASSUME_NONNULL_END
