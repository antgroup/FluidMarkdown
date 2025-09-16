// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMGradientLayer : CAGradientLayer

@property(nonatomic,assign) BOOL isFadeComplete;

@property(nonatomic,assign) NSUInteger lineIndex;

@end

NS_ASSUME_NONNULL_END
