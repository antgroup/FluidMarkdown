// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AMDrawable <NSObject>

- (void)drawInRect:(CGRect)rect clipEdges:(UIRectEdge)edges;

@optional
- (BOOL)isInline;

@end

@protocol AMUnderlineDrawable <NSObject>

- (void)drawInRect:(CGRect)rect underlineStyle:(NSUnderlineStyle)type baselineOffset:(CGFloat)offset;

@end

/**
 * value is any AMDrawable
 */
UIKIT_EXTERN NSAttributedStringKey const AMBackgroundDrawableAttributeName;
UIKIT_EXTERN NSAttributedStringKey const AMUnderlineDrawableAttributeName;

@interface UIImage (AMDrawable) <AMDrawable>

@end

@interface UIColor (AMDrawable) <AMDrawable>

@end

@interface CALayer (AMDrawable) <AMDrawable>

@end

NS_ASSUME_NONNULL_END
