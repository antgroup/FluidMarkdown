// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMUnderline.h"

@implementation AMUnderline
{
    UIColor     * _color;
    CGFloat       _width, _offset;
}

- (instancetype)initWithColor:(UIColor *)color lineWidth:(CGFloat)width offset:(CGFloat)offset
{
    self = [super init];
    if (self) {
        _color = color;
        _width = width;
        _offset = offset;
    }
    return self;
}

- (void)drawInRect:(CGRect)rect underlineStyle:(NSUnderlineStyle)type baselineOffset:(CGFloat)offset
{
    rect.origin.y = CGRectGetMaxY(rect) - _width;
    rect.size.height = _width;
    rect = CGRectOffset(rect, 0, _offset);
    [_color setFill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, rect);
}

@end
