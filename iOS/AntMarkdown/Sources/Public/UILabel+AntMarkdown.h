// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

@class AMTextStyles;

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (AntMarkdown)

- (void)setAttributedText_ant_mark:(NSAttributedString *)attributedText;

- (void)setMarkdownText_ant_mark:(NSString *)text;

- (void)setMarkdownText_ant_mark:(NSString *)text styles:(AMTextStyles *)styles;

@end

NS_ASSUME_NONNULL_END
