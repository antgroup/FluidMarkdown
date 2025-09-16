// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import <AntMarkdown/AMTextStyles.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMAttributedStringRenderer : CMAttributedStringRenderer
@property (readonly) AMTextStyles *attributes;

- (instancetype)initWithDocument:(CMDocument *)document attributes:(AMTextStyles *)attributes;

- (instancetype)initWithDocument:(CMDocument *)document attributes:(AMTextStyles *)attributes delegate:(nullable id<CMAttributedStringRendererDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
