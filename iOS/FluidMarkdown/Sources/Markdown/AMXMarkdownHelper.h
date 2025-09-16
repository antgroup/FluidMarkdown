// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "AMXMarkdownStyle.h"

@class AMTextStyles;
@protocol CMAttributedStringRendererDelegate;

NS_ASSUME_NONNULL_BEGIN

@protocol AMXImageAttachmentProtocol <NSObject>

- (nullable UIImage *)getImageFromCacheIfExist:(NSString *)url;

- (void)onImageLoadFinish:(UIImage *)image url:(NSString *)url;

@end

@interface AMXMarkdownHelper : NSObject


+ (nullable NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                         defaultStyles:(nullable AMTextStyles *)defaultStyles;
+ (nullable NSMutableAttributedString *)mdToAttrString:(NSString *)text
                                         defaultStyles:(nullable AMTextStyles *)defaultStyles
                                              delegate:(id<CMAttributedStringRendererDelegate>)delegate
                                              textView:(UITextView*)textView;
+ (void)setImageAttachListener:(NSMutableAttributedString *)attrText
                      delegate:(id<AMXImageAttachmentProtocol>)delegate;
+ (void)transformParagraph:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformTitle:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformHRule:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformTable:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformOrderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformUnorderList:(AMTextStyles*)defalutStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformFootNote:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformLink:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config textView:(UITextView*)textView;
+ (void)transformInlineCode:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformCodeBlock:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformUnderLine:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
+ (void)transformBlockQuote:(AMTextStyles*)defaultStyle customStyle:(AMXMarkdownStyleConfig*)config;
@end

NS_ASSUME_NONNULL_END
