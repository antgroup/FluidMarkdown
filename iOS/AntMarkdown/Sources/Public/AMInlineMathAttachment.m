// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMInlineMathAttachment.h"
#import "IosMath.h"
#import "MTTypesetter.h"
#import "MTFontManager.h"
#import "AMUtils.h"
#import "CMTextAttributes.h"
#import "CMCascadingAttributeStack.h"

@implementation AMMathStyle

- (CGFloat)fontSize
{
    return self.font.pointSize;
}

+ (instancetype)defaultStyle {
    AMMathStyle *style = [self new];
    style.font = [UIFont systemFontOfSize:20];
    style.verticalAlignment = UIControlContentVerticalAlignmentCenter;
    style.textColor = [UIColor blackColor];
    return style;
}

+ (instancetype)defaultBlockStyle {
    AMMathStyle *style = [self new];
    style.font = [UIFont systemFontOfSize:24];
    style.verticalAlignment = UIControlContentVerticalAlignmentCenter;
    style.horizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    style.textColor = [UIColor blackColor];
    style.paragraphStyle =  [NSParagraphStyle paragraphStyleWithCMAttributes:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(12)
        ,CMParagraphStyleAttributeParagraphSpacing: @0
        ,CMParagraphStyleAttributeFirstLineHeadExtraIndent:@(0)
        ,CMParagraphStyleAttributeHeadExtraIndent:@(0)
        ,CMParagraphStyleAttributeTailExtraIndent:@(0)
    }];
    style.paragraphStyleBreakLine = [NSParagraphStyle paragraphStyleWithCMAttributes:@{
        CMParagraphStyleAttributeParagraphSpacingBefore: @(0)
        ,CMParagraphStyleAttributeParagraphSpacing: @0
        ,CMParagraphStyleAttributeMaximumLineHeight: @1
        ,CMParagraphStyleAttributeFirstLineHeadExtraIndent:@(0)
        ,CMParagraphStyleAttributeHeadExtraIndent:@(0)
        ,CMParagraphStyleAttributeTailExtraIndent:@(0)
    }];
    return style;
}

@end

@implementation AMInlineMathAttachment
{
    MTMathList * _mathList;
    MTMathListDisplay * _displayList;
    NSAttributedString * _mathCodeAttrText;
    BOOL  _isImageZeroSize;
}

- (instancetype)initWithText:(NSString *)text style:(AMMathStyle *)style {
    NSError *error = nil;
    NSMutableString *mathText = [text mutableCopy];
    if ([mathText hasPrefix:@"\\("]) {
        [mathText deleteCharactersInRange:NSMakeRange(0, 2)];
    }
    if ([mathText hasSuffix:@"\\)"]) {
        [mathText deleteCharactersInRange:NSMakeRange(mathText.length - 2, 2)];
    }
    MTMathList *mathList = [MTMathListBuilder buildFromString:mathText ?: @""
                                                        error:&error];
    // 如果发生错误,绘制原公式文本
    if (error) {
        NSAttributedString* attrText = [[NSAttributedString alloc]initWithString:text attributes:@{
            NSFontAttributeName:[UIFont systemFontOfSize:style.fontSize],
            NSForegroundColorAttributeName:style.textColor?:[UIColor blackColor],
        }];
        self = [super initWithText:text size:CGSizeZero];
        if (self) {
            self.error = error;
            _mathCodeAttrText = attrText;
        }
        return self;
    }
    
    style = style ?: [AMMathStyle defaultStyle];
    
    @try {
        MTMathListDisplay *displayList = [MTTypesetter createLineForMathList:mathList
                                                                        font:[[MTFontManager fontManager] xitsFontWithSize:style.fontSize]
                                                                       style:kMTLineStyleText];
        displayList.textColor = style.textColor;
        
        const CGFloat contentHeight = displayList.ascent + displayList.descent;
        CGFloat totalHeight = style.height;
        if (totalHeight <= 0) {
            totalHeight = contentHeight;
        }
        displayList.position = CGPointMake(0, (totalHeight - contentHeight) / 2 + displayList.descent);
        
        self = [super initWithText:text size:CGSizeMake(displayList.width, totalHeight)];
        if (self) {
            _mathList = mathList;
            _displayList = displayList;
            
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
            self.error = [NSError errorWithDomain:@"MathDisplayError"
                                             code:404
                                         userInfo:exception.userInfo];
            
            AMLogDebug(@"math display line exception: %@,text = %@", exception,text);

        }
        return self;
    }
}

- (void)drawImage {
    const CGSize size = self.bounds.size;
    UIGraphicsImageRenderer *re = [[UIGraphicsImageRenderer alloc] initWithSize:size];
    self.image = [re imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        CGContextRef context = rendererContext.CGContext;
        CGContextTranslateCTM(context, 0, size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        [_displayList draw:context];
    }];
}

- (UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex
{
    if (!self.image && [NSThread isMainThread]) {
        [self drawImage];
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
    const CGFloat width = rect.size.width;

    if ((ceil(width) != ceil(self.image.size.width)) && [NSThread isMainThread]) {
       [self drawImage];
    }

    if (!self.image) {
        [self drawImage];
    }

    if(_isImageZeroSize)
    {
        rect.size = CGSizeZero;
    }
    return rect;
}

- (NSAttributedString *)attributedString
{
    if(self.error)
    {
        return [[NSAttributedString alloc] initWithString:@" "];
    }
    return [NSAttributedString attributedStringWithAttachment:self];
}

@end
