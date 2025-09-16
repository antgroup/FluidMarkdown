// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMTextBackground.h"

@implementation AMBorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.lineCap = kCGLineCapButt;
    }
    return self;
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToBorder:(AMBorder *)object];
}

- (BOOL)isEqualToBorder:(AMBorder *)border
{
    return self.borderWidth == border.borderWidth
    && [self.borderColor isEqual:border.borderColor]
    && self.lineCap == border.lineCap;
}

@end

@implementation AMTextBackground

+ (instancetype)leftBorderColor:(UIColor *)color width:(CGFloat)width
{
    AMTextBackground *b = [self new];
    b.leftBorder = ({
        AMBorder *d = [AMBorder new];
        d.borderColor = color;
        d.borderWidth = width;
        d;
    });
    return b;
}

+ (instancetype)topBorderColor:(UIColor *)color width:(CGFloat)width
{
    AMTextBackground *b = [self new];
    b.topBorder = ({
        AMBorder *d = [AMBorder new];
        d.borderColor = color;
        d.borderWidth = width;
        d;
    });
    return b;
}

+ (instancetype)rightBorderColor:(UIColor *)color width:(CGFloat)width
{
    AMTextBackground *b = [self new];
    b.rightBorder = ({
        AMBorder *d = [AMBorder new];
        d.borderColor = color;
        d.borderWidth = width;
        d;
    });
    return b;
}

+ (instancetype)bottomBorderColor:(UIColor *)color width:(CGFloat)width
{
    AMTextBackground *b = [self new];
    b.bottomBorder = ({
        AMBorder *d = [AMBorder new];
        d.borderColor = color;
        d.borderWidth = width;
        d;
    });
    return b;
}

+ (instancetype)leftColor:(UIColor *)leftColor
                leftWidth:(CGFloat)leftWidth
                 topColor:(UIColor *)topColor
                 topWidth:(CGFloat)topWidth
               rightColor:(UIColor *)rightColor
               rightWidth:(CGFloat)rightWidth
              bottomColor:(UIColor *)bottomColor
              bottomWidth:(CGFloat)bottomWidth
{
    AMTextBackground *b = [self new];
    if (leftWidth > 0) {
        b.leftBorder = ({
            AMBorder *d = [AMBorder new];
            d.borderColor = leftColor;
            d.borderWidth = leftWidth;
            d;
        });
    }
    if (topWidth > 0) {
        b.topBorder = ({
            AMBorder *d = [AMBorder new];
            d.borderColor = topColor;
            d.borderWidth = topWidth;
            d;
        });
    }
    if (rightWidth > 0) {
        b.rightBorder = ({
            AMBorder *d = [AMBorder new];
            d.borderColor = rightColor;
            d.borderWidth = rightWidth;
            d;
        });
    }
    if (bottomWidth > 0) {
        b.bottomBorder = ({
            AMBorder *d = [AMBorder new];
            d.borderColor = bottomColor;
            d.borderWidth = bottomWidth;
            d;
        });
    }
    return b;
}

+ (instancetype)backgroundWithColor:(UIColor *)color radius:(CGFloat)radius
{
    return [self backgroundWithColor:color radius:radius insets:UIEdgeInsetsZero];
}

+ (instancetype)backgroundWithColor:(UIColor *)color radius:(CGFloat)radius insets:(UIEdgeInsets)insets
{
    AMTextBackground *b = [self new];
    b.backgroundColor = color;
    b.cornerRadius = radius;
    b.isInline = YES;
    b.contentInset = insets;
    return b;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isInline = NO;
    }
    return self;
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToBackground:(AMTextBackground *)object];
}

- (BOOL)isEqualToBackground:(AMTextBackground *)background
{
    return self.isInline == background.isInline
    && ((self.backgroundColor == background.backgroundColor) || [self.backgroundColor isEqual:background.backgroundColor])
    && self.cornerRadius == background.cornerRadius
    && ((self.leftBorder == background.leftBorder) || [self.leftBorder isEqualToBorder:background.leftBorder])
    && ((self.rightBorder == background.rightBorder) || [self.rightBorder isEqualToBorder:background.rightBorder])
    && ((self.topBorder == background.topBorder) || [self.topBorder isEqualToBorder:background.topBorder])
    && ((self.bottomBorder == background.bottomBorder) || [self.bottomBorder isEqualToBorder:background.bottomBorder]);
}

- (void)drawInRect:(CGRect)rect clipEdges:(UIRectEdge)edges
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    rect = UIEdgeInsetsInsetRect(rect, self.contentInset);
    if (self.cornerRadius > 0) {
        UIRectCorner corners = UIRectCornerAllCorners;
        if (edges & UIRectEdgeRight) {
            corners &= ~(UIRectCornerTopRight | UIRectCornerBottomRight);
        }
        if (edges & UIRectEdgeLeft) {
            corners &= ~(UIRectCornerTopLeft | UIRectCornerBottomLeft);
        }
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(self.cornerRadius, self.cornerRadius)];
        [path addClip];
        [self.backgroundColor setFill];
        [path fill];
    } else {
        [self.backgroundColor drawInRect:rect clipEdges:edges];
    }
    
    
    CGPoint points[2] = {0};
    if (self.leftBorder) {
        const CGFloat lineWidth = self.leftBorder.borderWidth;
        CGContextSetLineCap(context, self.leftBorder.lineCap);
        CGContextSetLineWidth(context, lineWidth);
        [self.leftBorder.borderColor setStroke];
        
        points[0] = points[1] = rect.origin;
        points[0].x += lineWidth / 2;
        points[1].x += lineWidth / 2;
        points[1].y = CGRectGetMaxY(rect);
        CGContextStrokeLineSegments(context, points, 2);
    }
    if (self.topBorder) {
        const CGFloat lineWidth = self.topBorder.borderWidth;
        CGContextSetLineCap(context, self.topBorder.lineCap);
        CGContextSetLineWidth(context, lineWidth);
        [self.topBorder.borderColor setStroke];
        
        points[0] = points[1] = rect.origin;
        points[0].y += lineWidth / 2;
        points[1].y += lineWidth / 2;
        points[1].x = CGRectGetMaxX(rect);
        CGContextStrokeLineSegments(context, points, 2);
    }
    if (self.rightBorder) {
        const CGFloat lineWidth = self.rightBorder.borderWidth;
        CGContextSetLineCap(context, self.rightBorder.lineCap);
        CGContextSetLineWidth(context, lineWidth);
        [self.rightBorder.borderColor setStroke];
        
        points[0] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
        points[1] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        points[0].x -= lineWidth / 2;
        points[1].x -= lineWidth / 2;
        CGContextStrokeLineSegments(context, points, 2);
    }
    if (self.bottomBorder) {
        const CGFloat lineWidth = self.bottomBorder.borderWidth;
        CGContextSetLineCap(context, self.bottomBorder.lineCap);
        CGContextSetLineWidth(context, lineWidth);
        [self.bottomBorder.borderColor setStroke];
        
        points[0] = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
        points[1] = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
        points[0].y -= lineWidth / 2;
        points[1].y -= lineWidth / 2;
        CGContextStrokeLineSegments(context, points, 2);
    }
}

@end
