// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMBlockMathAttachment.h"
#import "IosMath.h"
#import "MTTypesetter.h"
#import "MTFontManager.h"
#import "AMUtils.h"

@implementation AMBlockMathAttachment
{
    MTMathList * _mathList;
    MTMathListDisplay * _displayList;
    AMMathStyle * _style;
    BOOL  _isImageZeroSize;
    NSAttributedString * _mathCodeAttrText;
}

- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti {
    return [self initWithText:nil style:nil];
}

- (instancetype)initWithDisplayList:(nullable MTMathListDisplay *)displayList style:(nullable AMMathStyle *)style  {
    displayList.textColor = style.textColor;
    const CGFloat contentHeight = displayList.ascent + displayList.descent;
    CGFloat totalHeight = style.height;
    if (totalHeight <= 0) {
        totalHeight = contentHeight;
    }
    self = [super initWithData:nil ofType:nil];
    if (self) {
        _displayList = displayList;
        _style = style;
  
        self.bounds = CGRectMake(0, 0, displayList.width, totalHeight + 1.5);
        
        CGRect rect = self.bounds;
        switch (style.verticalAlignment) {
            case UIControlContentVerticalAlignmentCenter: {
                rect.origin.y = -displayList.descent;
            }
                break;
            case UIControlContentVerticalAlignmentBottom: {
                rect.origin.y = -rect.size.height;
            }
                break;
            case UIControlContentVerticalAlignmentTop: {
                rect.origin.y = 0;
            }
                break;
            default:
                break;
        }
        self.bounds = rect;
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text style:(AMMathStyle *)style {
    NSError *error = nil;
    NSMutableString *mathText = [text mutableCopy];
    if ([mathText hasPrefix:@"\\["]) {
        [mathText deleteCharactersInRange:NSMakeRange(0, 2)];
    }
    if ([mathText hasSuffix:@"\\]"]) {
        [mathText deleteCharactersInRange:NSMakeRange(mathText.length - 2, 2)];
    }
    MTMathList *mathList = [MTMathListBuilder buildFromString:mathText ?: @""
                                                        error:&error];
    if (error) {
        self = [super initWithData:nil ofType:nil];
        if (self) {
            self.text = text;
            self.error = error;
            AMLogDebug(@"math parse error: %@", error);
        }
        return self;
    }
    
    style = style ?: [AMMathStyle defaultBlockStyle];
    
    @try {
        MTMathListDisplay *displayList = [MTTypesetter createLineForMathList:mathList
                                                                        font:[[MTFontManager fontManager] xitsFontWithSize:style.fontSize]
                                                                       style:kMTLineStyleDisplay];
        displayList.textColor = style.textColor;
        
        const CGFloat contentHeight = displayList.ascent + displayList.descent;
        CGFloat totalHeight = style.height;
        if (totalHeight <= 0) {
            totalHeight = contentHeight;
        }
        
        self = [super initWithData:nil ofType:nil];
        if (self) {
            self.text = text;
            _mathList = mathList;
            _displayList = displayList;
            _style = style;
            
            self.bounds = CGRectMake(0, 0, displayList.width, totalHeight);
            
            CGRect rect = self.bounds;
            switch (style.verticalAlignment) {
                case UIControlContentVerticalAlignmentCenter: {
                    rect.origin.y = -displayList.descent;
                }
                    break;
                case UIControlContentVerticalAlignmentBottom: {
                    rect.origin.y = -rect.size.height;
                }
                    break;
                case UIControlContentVerticalAlignmentTop: {
                    rect.origin.y = 0;
                }
                    break;
                default:
                    break;
            }
            self.bounds = rect;
        }
        return self;
    } @catch (NSException *exception) {
        self = [super initWithData:nil ofType:nil];
        if (self) {
            self.text = text;
            self.error = [[NSError alloc] initWithDomain:@"MathDisplayError" code:404 userInfo:exception.userInfo];
            AMLogDebug(@"math display exception: %@,text = %@", exception, text);
        }
        return self;
    }
}

+ (NSArray<AMBlockMathAttachment *> *)constructorBlockMathAttachmentWithText:(NSString *)text style:(AMMathStyle *)style {
    NSError *error = nil;
    NSMutableArray<AMBlockMathAttachment *> * attachList = [NSMutableArray new];
    NSMutableString *mathText = [text mutableCopy];
    if ([mathText hasPrefix:@"\\["]) {
        [mathText deleteCharactersInRange:NSMakeRange(0, 2)];
    }
    if ([mathText hasSuffix:@"\\]"]) {
        [mathText deleteCharactersInRange:NSMakeRange(mathText.length - 2, 2)];
    }
    MTMathList *totalMathList = [MTMathListBuilder buildFromString:mathText ?: @""
                                                             error:&error];
    
    if (error) {
        AMBlockMathAttachment *attachment = [[self alloc] initWithText:text style:style];
        return @[attachment];
    }
    
    style = style ?: [AMMathStyle defaultBlockStyle];
    
    @try {
        MTMathListDisplay *totalDisplayList = [MTTypesetter createLineForMathList:totalMathList
                                                                             font:[[MTFontManager fontManager] xitsFontWithSize:style.fontSize]
                                                                            style:kMTLineStyleDisplay];
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 65;
        if (totalDisplayList.width <= maxWidth) {
            AMBlockMathAttachment *attachment = [[self alloc] initWithDisplayList:totalDisplayList style:style];
            return @[attachment];
        }
        NSArray<NSNumber *> *segIndexs = [self getSegIndexWithDispayList:totalDisplayList];
        NSUInteger start = 0;
        for (NSNumber *segIndex in segIndexs) {
            NSUInteger index = [segIndex unsignedIntegerValue];
            NSMutableArray<MTMathAtom *> *atoms = [NSMutableArray new];
            for (NSUInteger i = start; i < index; i++) {
                [atoms addObject:totalMathList.atoms[i]];
            }
            start = index;
            MTMathList *realMathList = [MTMathList mathListWithAtomsArray:atoms];
            MTMathListDisplay *realDisplayList = [MTTypesetter createLineForMathList:realMathList
                                                                                font:[[MTFontManager fontManager] xitsFontWithSize:style.fontSize]
                                                                               style:kMTLineStyleDisplay];
            AMBlockMathAttachment *attachment = [[self alloc] initWithDisplayList:realDisplayList style:style];
            [attachList addObject:attachment];
        }

        NSUInteger lastIndex = [segIndexs.lastObject unsignedIntValue];
        if (lastIndex < totalMathList.atoms.count) {
            NSMutableArray<MTMathAtom *> *atoms = [NSMutableArray new];
            for (NSUInteger i = lastIndex; i < totalMathList.atoms.count; i++) {
                [atoms addObject:totalMathList.atoms[i]];
            }
            MTMathList *realMathList = [MTMathList mathListWithAtomsArray:atoms];
            MTMathListDisplay *realDisplayList = [MTTypesetter createLineForMathList:realMathList
                                                                                font:[[MTFontManager fontManager] xitsFontWithSize:style.fontSize]
                                                                               style:kMTLineStyleDisplay];
            AMBlockMathAttachment *attachment = [[self alloc] initWithDisplayList:realDisplayList style:style];
            [attachList addObject:attachment];
        }
        
    } @catch (NSException *exception) {
        AMBlockMathAttachment *attachment = [[self alloc] initWithText:text style:style];
        return @[attachment];
    }
    return [attachList copy];
}

+ (NSArray<NSNumber *> *)getSegIndexWithDispayList:(MTMathListDisplay *)displayList {
    NSMutableArray<NSNumber *> *segIndexs = [NSMutableArray new];
    CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 65;
    MTDisplay *preDisplay = nil;
    for (NSUInteger i = 0; i < displayList.subDisplays.count; i++) {
        MTDisplay *display = displayList.subDisplays[i];
        CGFloat currentDisplayEndPositionX = display.position.x + display.width;
        if (currentDisplayEndPositionX >= maxWidth) {
            [segIndexs addObject:@(preDisplay.range.location + preDisplay.range.length)];
            maxWidth += maxWidth;
        }
        if (display.range.location != 0) {
            preDisplay = display;
        }
    }
    return [segIndexs copy];
}

- (void)drawImage:(CGSize)size {
    
    // 绘制图片使用新的API，防止size=0 Crash，并且部分场景复用绘制失败（首次绘制宽度为0）
    UIGraphicsImageRenderer *re = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    self.image = [re imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;

        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        CGFloat totalHeight = size.height;
        CGFloat contentHeight = _displayList.ascent + _displayList.descent;
        
        CGFloat x = 0;
        switch (_style.horizontalAlignment) {
            case UIControlContentHorizontalAlignmentCenter:
                x = (size.width - _displayList.width) / 2;
                break;
            case UIControlContentHorizontalAlignmentRight:
                x = size.width - _displayList.width;
                break;
            case UIControlContentHorizontalAlignmentLeft:
                x = 0;
                break;
            default:
                break;
        }
        _displayList.position = CGPointMake(x, (totalHeight - contentHeight) / 2 + _displayList.descent);
        [_displayList draw:context];
    }];
}

- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)charIndex {
    const CGFloat width = textContainer.size.width - textContainer.lineFragmentPadding * 2;
    if (!self.image) {
        [self drawImage:CGSizeMake(width, self.bounds.size.height)];
    }
    return self.image;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer 
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    CGRect rect = [super attachmentBoundsForTextContainer:textContainer
                                     proposedLineFragment:lineFrag
                                            glyphPosition:position
                                           characterIndex:charIndex];
    
    CGFloat yPos = MAX(0, rect.origin.y);
    rect = CGRectMake(rect.origin.x, yPos, floor(rect.size.width), rect.size.height);
        
    const CGFloat width = textContainer.size.width - textContainer.lineFragmentPadding * 2;

    if ((floor(width) != floor(self.image.size.width)) && [NSThread isMainThread]) {
        [self drawImage:CGSizeMake(floor(width), self.bounds.size.height)];
    }
    
    return rect;
}

- (NSAttributedString *)attributedString
{
    if (self.error) {
        return [[NSAttributedString alloc] initWithString:self.text ?: @"" attributes:@{
            NSForegroundColorAttributeName: _style.textColor ?: [UIColor blackColor],
            NSFontAttributeName: _style.font ?: [UIFont systemFontOfSize:UIFont.systemFontSize],
        }];
    }
    return [NSAttributedString attributedStringWithAttachment:self];
}

@end
