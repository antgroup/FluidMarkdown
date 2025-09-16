// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMLayoutManager+Quote.h"
#import "AMTextBackground.h"
#import "AMTextStyles.h"

@implementation AMQuoteLayoutContext
@end

@implementation AMLayoutManager (Quote)

- (BOOL)handleQuoteDraw:(CGContextRef)context
           quoteContext:(AMQuoteLayoutContext *)quoteContext
               drawable:(id<AMDrawable>)drawable
                  range:(NSRange)range {
    if (![drawable isKindOfClass:AMTextBackground.class] ||
        !((AMTextBackground *)drawable).isQuote) {
        return NO;
    }
    
    NSMutableDictionary<CMParagraphStyleAttributeName, id> *quoteParaStyle = [AMTextStyles getAMStylesWithId:self.styleId].blockQuoteAttributes.paragraphStyleAttributes;
    
    CGFloat firstHeadIndent = [self _getSizeValue:quoteParaStyle
                                              key:CMParagraphStyleAttributeFirstLineHeadExtraIndent
                                       defaultVal:10];
    
    CGFloat headIndent = [self _getSizeValue:quoteParaStyle
                                         key:CMParagraphStyleAttributeHeadExtraIndent
                                  defaultVal:10];
    
    if (firstHeadIndent != headIndent) {
        return NO;
    }
    
    __block BOOL success = YES;
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
        
        NSInteger iFirstHeadIndent = firstHeadIndent;
        CGFloat gap =(bounds.origin.x - usedRect.origin.x);
        BOOL hasOtherContent = ((gap > firstHeadIndent) ||
                                (bounds.origin.x < usedRect.origin.x) ||
                                (((NSInteger)bounds.origin.x) % iFirstHeadIndent > 0) ||
                                (((NSInteger)gap) % iFirstHeadIndent) > 0);
        
        NSInteger quoteLevel = (usedRect.origin.x / firstHeadIndent);
        
        if (quoteContext.originY == bounds.origin.y && quoteContext.level == quoteLevel) {
            return;
        }
        if (!hasOtherContent) {
            quoteContext.originX = bounds.origin.x;
            quoteContext.level = quoteLevel;
        }
        
        if (quoteLevel > 0) {
            CGContextSaveGState(context);
            for (NSInteger index = 0; index < quoteContext.level; ++index) {
                CGFloat w = bounds.size.width;
                CGFloat h = rect.size.height;
                CGFloat x = (quoteContext.originX - (index + 1) * firstHeadIndent);;
                CGFloat y = rect.origin.y;
                if (index == 0) {
                    y = bounds.origin.y;
                }
                CGRect newBounds = CGRectMake(x, y, w, h);
                [drawable drawInRect:newBounds clipEdges:edges];
            }
            CGContextRestoreGState(context);
        } else {
            success = NO;
        }
    }];
    return success;
}

- (CGFloat)_getSizeValue:(NSDictionary *)dic key:(NSString *)key defaultVal:(CGFloat)defaultVal {
    if (![dic isKindOfClass:NSDictionary.class] ||
        ![key isKindOfClass:NSString.class] ||
        ![dic[key] isKindOfClass:NSNumber.class]) {
        return defaultVal;
    }
    return [dic[key] floatValue];
}

@end
