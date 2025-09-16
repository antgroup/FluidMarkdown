// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "AMDrawable.h"

NSAttributedStringKey const AMBackgroundDrawableAttributeName = @"AMBackgroundDrawableAttributeName";
NSAttributedStringKey const AMUnderlineDrawableAttributeName = @"AMUnderlineDrawableAttributeName";

@implementation UIImage (AMDrawable)

- (void)drawInRect:(CGRect)rect clipEdges:(UIRectEdge)edges {
    [self drawInRect:rect];
}

@end

@implementation UIColor (AMDrawable)

- (void)drawInRect:(CGRect)rect clipEdges:(UIRectEdge)edges {
    [self setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

@end

@implementation CALayer (AMDrawable)

- (void)drawInRect:(CGRect)rect clipEdges:(UIRectEdge)edges {
    [self drawInContext:UIGraphicsGetCurrentContext()];
}

@end
