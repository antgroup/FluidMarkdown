// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CMHorizontalRuleAttachment.h"
#import "AMUtils.h"

@implementation CMHorizontalRuleAttachment

- (instancetype)init {
    self = [super init];
    if (self) {
        _lineColor = [CMColor lightGrayColor];
        _lineThickness = 1.0;
        _horizontalInset = 0.0;
        _verticalPadding = 6.0;
        _verticalPaddingBefore = 6.0;
        
        self.bounds = CGRectMake(0, 0, 1, _lineThickness + _verticalPadding + _verticalPaddingBefore);
        self.image = nil;
    }
    return self;
}

- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex {
    CGSize size = imageBounds.size;
    
    if (textContainer) {
        size.width = textContainer.size.width - textContainer.lineFragmentPadding * 2 - _horizontalInset * 2;
    }
    
    size.height = _lineThickness + _verticalPadding + _verticalPaddingBefore;
    
    AMUIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetStrokeColorWithColor(context, _lineColor.CGColor);
    CGContextSetLineWidth(context, _lineThickness);

    CGFloat yPosition = _verticalPaddingBefore + _lineThickness / 2.0;
    CGContextMoveToPoint(context, 0, yPosition);
    CGContextAddLineToPoint(context, size.width, yPosition);
    CGContextStrokePath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex {

    CGFloat width = textContainer.size.width - textContainer.lineFragmentPadding * 2 - _horizontalInset * 2;
    CGFloat height = _lineThickness + _verticalPadding + _verticalPaddingBefore;

    CGFloat x = _horizontalInset;

    CGFloat y = -_verticalPaddingBefore;
    
    return CGRectMake(x, y, width, height);
}

@end 
