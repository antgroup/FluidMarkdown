// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CMTaskCheckAttachment.h"

@interface CMTaskCheckAttachment ()

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat marigin;

@end

@implementation CMTaskCheckAttachment

- (instancetype)init {
    self = [super init];
    if (self) {
        _borderColor = [CMColor lightGrayColor];
        _borderWidth = 3.0;
        _backgroundColor = [CMColor systemGreenColor];
        _cornerRadius = 3.0;
        _horizontalPadding = 2.0;
        _verticalPadding = 5.0;
        _lineHeight = 0;
        _marigin = 2.0;
        
        self.bounds = CGRectMake(0, 0, 15, 15);
        self.image = nil;
    }
    return self;
}

- (nullable UIImage *)imageForBounds:(CGRect)imageBounds
                       textContainer:(nullable NSTextContainer *)textContainer
                      characterIndex:(NSUInteger)charIndex {
    CGRect checkRect = CGRectMake(_horizontalPadding,
                                  imageBounds.origin.y - imageBounds.size.height + 3 * _marigin,
                                  imageBounds.size.width - 2 * _marigin - 2 * _horizontalPadding ,
                                  imageBounds.size.height - 2 * _marigin);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

    UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:checkRect
                                                           cornerRadius:_cornerRadius];
    [roundedRect addClip];
    
    if (self.checked) {
        [_backgroundColor setFill];
        [roundedRect fill];

        CGContextSetLineWidth(context, 2.0);
        CGFloat checkIndent = _cornerRadius;
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextMoveToPoint(context,
                             checkRect.origin.x + checkIndent,
                             checkRect.origin.y + checkRect.size.height / 2);
        CGContextAddLineToPoint(context,
                                checkRect.origin.x + checkRect.size.width / 3,
                                checkRect.origin.y + checkRect.size.height - checkIndent);
        CGContextAddLineToPoint(context,
                                checkRect.origin.x + checkRect.size.width - checkIndent,
                                checkRect.origin.y + checkIndent);
        CGContextStrokePath(context);
    } else {
        CGContextSetStrokeColorWithColor(context, _borderColor.CGColor);
        CGContextSetLineWidth(context, _borderWidth);
        CGContextAddPath(context, roundedRect.CGPath);
        CGContextStrokePath(context);
    }
    
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    CGFloat defaultSize = 18.0f;
    CGFloat size = (_lineHeight > 0) ? _lineHeight : defaultSize;
    return CGRectMake(0, 0, size + _horizontalPadding * 2, size);
}

@end
