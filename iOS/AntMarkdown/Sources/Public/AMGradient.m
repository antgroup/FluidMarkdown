// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMGradient.h"
#import "AMUtils.h"

@implementation AMGradient
{
    
}

+ (instancetype)gradientWithColors:(NSArray<UIColor *> *)colors {
    return [self gradientWithColors:colors locations:nil 
                         startPoint:CGPointMake(0.5, 0)
                           endPoint:CGPointMake(0.5, 1)];
}

+ (instancetype)gradientWithColors:(NSArray<UIColor *> *)colors 
                        startPoint:(CGPoint)start
                          endPoint:(CGPoint)end
{
    return [self gradientWithColors:colors locations:nil 
                         startPoint:start endPoint:end];
}

+ (instancetype)gradientWithColors:(NSArray<UIColor *> *)colors 
                         locations:(NSArray<NSNumber *> *)locations
                        startPoint:(CGPoint)start
                          endPoint:(CGPoint)end
{
    AMGradient *g = [self new];
    g.colors = colors;
    g.locations = locations;
    g.startPoint = start;
    g.endPoint = end;
    return g;
}

+ (instancetype)gradientWithColors:(NSArray<UIColor *> *)colors
                         locations:(NSArray<NSNumber *> *)locations
                            degree:(CGFloat)degree {
    AMGradient *g = [self new];
    g.colors = colors;
    g.locations = locations;
    g.degree = @(degree);
    return g;
}

- (void)drawInRect:(CGRect)rect clipEdges:(UIRectEdge)edges {
    
    CGPoint startPoint = self.startPoint;
    CGPoint endPoint = self.endPoint;
    if (self.degree != nil) {
        UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect: rect];
        UIBezierPath* rectangleRotatedPath = [rectanglePath copy];
        CGAffineTransform transform = CGAffineTransformMakeRotation(-self.degree.doubleValue / 180 * M_PI + M_PI_2);
        [rectangleRotatedPath applyTransform: transform];
        CGRect rectangleBounds = CGPathGetPathBoundingBox(rectangleRotatedPath.CGPath);
        transform = CGAffineTransformInvert(transform);
        
        startPoint = CGPointApplyAffineTransform(CGPointMake(CGRectGetMinX(rectangleBounds), CGRectGetMidY(rectangleBounds)), transform);
        endPoint = CGPointApplyAffineTransform(CGPointMake(CGRectGetMaxX(rectangleBounds), CGRectGetMidY(rectangleBounds)), transform);
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextClipToRect(context, rect);
    CGContextDrawLinearGradient(context, self.CGGradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
}

- (void)drawInRect:(CGRect)rect underlineStyle:(NSUnderlineStyle)type baselineOffset:(CGFloat)offset
{
    [self drawInRect:rect clipEdges:UIRectEdgeNone];
}

- (CGGradientRef)CGGradient {
    CGFloat locations[10] = {0};
    CGFloat *locationRef = NULL;
    const int maxCount = sizeof(locations) / sizeof(locations[0]);
    const bool needMalloc = self.locations.count > maxCount;
    if (self.locations.count > 0) {
        locationRef = needMalloc ? malloc(self.locations.count * sizeof(*locationRef)) : locations;
        [self.locations enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            locationRef[idx] = obj.doubleValue;
        }];
    }
    
    CGGradientRef gradient = CGGradientCreateWithColors(nil, (__bridge CFArrayRef)[self.colors mapWithBlock_ant_mark:^id _Nonnull(UIColor * _Nonnull obj) {
        return (id)obj.CGColor;
    }], locationRef);
    
    if (needMalloc) {
        free(locationRef);
    }
    return (CGGradientRef)CFAutorelease(gradient);
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
    
    return [self isEqualToGradient:(AMGradient *)object];
}

- (BOOL)isEqualToGradient:(AMGradient *)gradient
{
    return [self.colors isEqualToArray:gradient.colors]
    && (self.locations == gradient.locations || [self.locations isEqualToArray:gradient.locations])
    && CGPointEqualToPoint(self.startPoint, gradient.startPoint)
    && CGPointEqualToPoint(self.endPoint, gradient.endPoint)
    && self.degree == gradient.degree;
}

@end
