// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMLayoutManager.h"
#import "AMDrawable.h"
#import "AMViewAttachment.h"
#import "AMLayoutManager+Quote.h"
#import "AMIconLinkAttachment.h"
#import "AMImageTextAttachment.h"

@implementation AMLayoutManager

- (void)drawBackgroundForGlyphRange:(NSRange)glyphsToShow
                            atPoint:(CGPoint)origin
{
    [super drawBackgroundForGlyphRange:glyphsToShow atPoint:origin];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, origin.x, origin.y);
    
    NSRange charactorRange = [self characterRangeForGlyphRange:glyphsToShow
                                              actualGlyphRange:NULL];
    
    AMQuoteLayoutContext *quoteContext = [AMQuoteLayoutContext new];
    [self.textStorage enumerateAttribute:AMBackgroundDrawableAttributeName
                                 inRange:charactorRange
                                 options:0
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value conformsToProtocol:@protocol(AMDrawable)]) {
            id<AMDrawable> drawable = (id<AMDrawable>)value;
            BOOL isInline = YES;
            if ([drawable respondsToSelector:@selector(isInline)]) {
                isInline = [drawable isInline];
            }
            
            if ([self handleQuoteDraw:context
                         quoteContext:quoteContext
                             drawable:drawable
                                range:range]) {
                return;
            }
            
            if (isInline) {
                [self enumerateLineFragmentsForGlyphRange:range
                                               usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
                    NSRange intersectRange = NSIntersectionRange(range, glyphRange);
                    CGRect bounds = [self boundingRectForGlyphRange:intersectRange inTextContainer:textContainer];
                    UIRectEdge edges = UIRectEdgeNone;
                    if (NSEqualRanges(intersectRange, range)) {
                        edges = UIRectEdgeNone;
                    } else if (intersectRange.location == range.location && intersectRange.length < range.location) {
                        edges = UIRectEdgeRight;
                    } else if (intersectRange.location > range.location && NSMaxRange(intersectRange) < NSMaxRange(range)) {
                        edges = UIRectEdgeRight | UIRectEdgeLeft;
                    } else if (intersectRange.location > range.location && NSMaxRange(intersectRange) == NSMaxRange(range)) {
                        edges = UIRectEdgeLeft;
                    }
                    CGContextSaveGState(context);
                    [drawable drawInRect:bounds clipEdges:edges];
                    CGContextRestoreGState(context);
                }];
            } else {
                __block CGRect bounds = CGRectNull;
                [self enumerateLineFragmentsForGlyphRange:range
                                               usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
                    if (CGRectIsNull(bounds)) {
                        bounds = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, textContainer.lineFragmentPadding, 0, textContainer.lineFragmentPadding));
                    } else {
                        bounds = CGRectUnion(bounds, UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, textContainer.lineFragmentPadding, 0, textContainer.lineFragmentPadding)));
                    }
                }];
                CGContextSaveGState(context);
                [drawable drawInRect:bounds clipEdges:UIRectEdgeNone];
                CGContextRestoreGState(context);
            }
        }
    }];
    CGContextRestoreGState(context);
}

- (void)drawStrikethroughForGlyphRange:(NSRange)glyphRange
                     strikethroughType:(NSUnderlineStyle)strikethroughVal
                        baselineOffset:(CGFloat)baselineOffset
                      lineFragmentRect:(CGRect)lineRect
                lineFragmentGlyphRange:(NSRange)lineGlyphRange
                       containerOrigin:(CGPoint)containerOrigin
{
    [super drawStrikethroughForGlyphRange:glyphRange
                        strikethroughType:strikethroughVal
                           baselineOffset:baselineOffset
                         lineFragmentRect:lineRect
                   lineFragmentGlyphRange:lineGlyphRange
                          containerOrigin:containerOrigin];
}

- (void)drawUnderlineForGlyphRange:(NSRange)glyphRange
                     underlineType:(NSUnderlineStyle)underlineVal
                    baselineOffset:(CGFloat)baselineOffset
                  lineFragmentRect:(CGRect)lineRect
            lineFragmentGlyphRange:(NSRange)lineGlyphRange
                   containerOrigin:(CGPoint)containerOrigin
{
    [super drawUnderlineForGlyphRange:glyphRange
                        underlineType:underlineVal
                       baselineOffset:baselineOffset
                     lineFragmentRect:lineRect
               lineFragmentGlyphRange:lineGlyphRange
                      containerOrigin:containerOrigin];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    NSRange charactorRange = [self characterRangeForGlyphRange:glyphRange
                                              actualGlyphRange:NULL];
    
    [self.textStorage enumerateAttribute:AMUnderlineDrawableAttributeName
                                 inRange:charactorRange
                                 options:0
                              usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value conformsToProtocol:@protocol(AMUnderlineDrawable)]) {
            id<AMUnderlineDrawable> drawable = (id<AMUnderlineDrawable>)value;
            CGRect bounds = [self boundingRectForGlyphRange:range inTextContainer:[self textContainerForGlyphAtIndex:range.location effectiveRange:NULL]];
            CGPoint location = [self locationForGlyphAtIndex:range.location];
            CGContextSaveGState(context);
            [drawable drawInRect:CGRectMake(lineRect.origin.x + containerOrigin.x + location.x, lineRect.origin.y + containerOrigin.y, bounds.size.width, location.y)
                  underlineStyle:underlineVal
                  baselineOffset:baselineOffset];
            CGContextRestoreGState(context);
        }
    }];
    CGContextRestoreGState(context);
}

- (void)drawGlyphsForGlyphRange:(NSRange)glyphsToShow atPoint:(CGPoint)origin
{
    [super drawGlyphsForGlyphRange:glyphsToShow atPoint:origin];
    
    NSRange charactorRange = [self characterRangeForGlyphRange:glyphsToShow
                                              actualGlyphRange:NULL];
    if (!self.locArray) {
        self.locArray = [[NSMutableArray alloc] init];
    }
    if (!self.attachmentDic) {
        self.attachmentDic = [[NSMutableDictionary alloc] init];
    }
    
    
    [self.textStorage enumerateAttributesInRange:charactorRange options:0 usingBlock:^(NSDictionary<NSAttributedStringKey, id> *attrs, NSRange range, BOOL *stop) {
        if ([attrs.allKeys containsObject:NSAttachmentAttributeName]) {
            NSObject* attrValue = [attrs objectForKey:NSAttachmentAttributeName];
            if ([attrValue isKindOfClass:[AMIconLinkAttachment class]] || [attrValue isKindOfClass:[AMImageTextAttachment class]]) {
                ;
                if ([self.attachmentDic objectForKey:[NSString stringWithFormat:@"%p",attrValue]]) {
                    return;
                }
                CGRect rect = [self boundingRectForGlyphRange:range
                                              inTextContainer:[self textContainerForGlyphAtIndex:range.location
                                                                                  effectiveRange:NULL]];
                rect.origin.x += origin.x;
                rect.origin.y += origin.y;
                [self.locArray addObject:[NSValue valueWithCGRect:rect]];
                [self.attachmentDic setObject:attrValue forKey:[NSString stringWithFormat:@"%p",attrValue]];
            } else if ([attrValue conformsToProtocol:@protocol(AMViewAttachment)]) {
                id<AMViewAttachment> attach = (id<AMViewAttachment>)attrValue;
                
                CGRect rect = [self boundingRectForGlyphRange:range
                                              inTextContainer:[self textContainerForGlyphAtIndex:range.location
                                                                                  effectiveRange:NULL]];
                rect.origin.x += origin.x;
                rect.origin.y += origin.y;
                attach.view.frame = rect;
                attach.view.hidden = NO;
            }
        } else if ([attrs.allKeys containsObject:NSLinkAttributeName]) {
            if ([self.attachmentDic objectForKey:[NSString stringWithFormat:@"%p",[attrs objectForKey:NSLinkAttributeName]]]) {
                return;
            }
            CGRect rect = [self boundingRectForGlyphRange:range
                                          inTextContainer:[self textContainerForGlyphAtIndex:range.location
                                                                              effectiveRange:NULL]];
            rect.origin.x += origin.x;
            rect.origin.y += origin.y;
            [self.locArray addObject:[NSValue valueWithCGRect:rect]];
            [self.attachmentDic setObject:[attrs objectForKey:NSLinkAttributeName] forKey:[NSString stringWithFormat:@"%p",[attrs objectForKey:NSLinkAttributeName]]];
        }
    }];
    
    if (self.delegate) {
        [self.delegate notifyNodeLocation:self.locArray];
    }
}

@end
