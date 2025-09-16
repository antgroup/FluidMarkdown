// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

@class AMTextStyles;
@protocol CMAttributedStringRendererDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (AntMarkdown)

- (instancetype)initWithFrame_ant_mark:(CGRect)frame;

- (instancetype)initWithFrame_ant_mark:(CGRect)frame delegate:(id<CMAttributedStringRendererDelegate>)delegate;

- (void)setAttributedText_ant_mark:(nullable NSAttributedString *)attributedText;

- (void)setAttributedTextPartialUpdate_ant_mark:(NSAttributedString *)attributedText;

- (void)setAttributedTextPartialUpdate_ant_mark:(NSAttributedString *)attributedText animated:(BOOL)animated;

- (void)setMarkdownText_ant_mark:(NSString *)text;

- (void)setMarkdownText_ant_mark:(NSString *)text styles:(AMTextStyles *)styles;

- (void)setMarkdownTextPartialUpdate_ant_mark:(NSString *)text styles:(AMTextStyles *)styles;

- (void)setMarkdownTextPartialUpdate_ant_mark:(NSString *)text styles:(AMTextStyles *)styles animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
