// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/CMInlineTextAttachment.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMMathStyle : NSObject
@property (nonatomic) UIFont *font;
@property (nonatomic, readonly) CGFloat fontSize;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIControlContentVerticalAlignment verticalAlignment;
@property (nonatomic) UIControlContentHorizontalAlignment horizontalAlignment;
@property (nonatomic) CGFloat height;   // Default 0. Auto
@property (nonatomic,copy) NSParagraphStyle* paragraphStyle;

@property (nonatomic,copy) NSParagraphStyle* paragraphStyleBreakLine;

+ (instancetype)defaultStyle;

+ (instancetype)defaultBlockStyle;

@end

@interface AMInlineMathAttachment : CMInlineTextAttachment

@property (nonatomic, nullable, strong) NSError *error;

- (instancetype)initWithText:(nullable NSString *)text
                       style:(AMMathStyle *)style NS_DESIGNATED_INITIALIZER;

- (NSAttributedString *)attributedString;

@end

NS_ASSUME_NONNULL_END
