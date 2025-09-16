// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMInlineTextAttachment : NSTextAttachment
@property (nonatomic, nullable) NSString *text;

- (instancetype)initWithSize:(CGSize)size;
- (instancetype)initWithText:(nullable NSString *)text size:(CGSize)size;

- (void)setNeedsUpdate;

- (BOOL)isEqualToAttachment:(CMInlineTextAttachment *)attach;

@end

NS_ASSUME_NONNULL_END
