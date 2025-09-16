// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface AMIconLinkAttachment : NSTextAttachment
@property (nonatomic, nullable) NSAttributedString *text;

- (instancetype)initWithText:(nullable NSAttributedString *)text url:(NSString*)url bgColor:(UIColor*)bgColor textColor:(UIColor*)textColor subFont:(UIFont*)subFont baseFont:(UIFont*)baseFont;
- (void)setNeedsUpdate;

- (BOOL)isEqualToAttachment:(AMIconLinkAttachment *)attach;
@end

NS_ASSUME_NONNULL_END
