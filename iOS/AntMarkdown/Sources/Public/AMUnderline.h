// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <AntMarkdown/AMDrawable.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMUnderline : NSObject <AMUnderlineDrawable>

- (instancetype)initWithColor:(UIColor *)color lineWidth:(CGFloat)width offset:(CGFloat)offset;

@end

NS_ASSUME_NONNULL_END
