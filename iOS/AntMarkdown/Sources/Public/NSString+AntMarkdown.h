// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@class AMTextStyles;
@protocol CMAttributedStringRendererDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (AntMarkdown)

- (NSAttributedString *)markdownToAttributedString_ant_mark;
- (NSAttributedString *)markdownToAttributedStringWithStyles_ant_mark:(AMTextStyles *)styles;
- (NSAttributedString *)markdownToAttributedStringWithStyles_ant_mark:(AMTextStyles *)styles delegate:(nullable id<CMAttributedStringRendererDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
