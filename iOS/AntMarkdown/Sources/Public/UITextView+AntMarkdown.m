// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "UITextView+AntMarkdown.h"
#import "NSString+AntMarkdown.h"
#import "CocoaMarkdown.h"
#import "AMTextStyles.h"
#import "AMAttributedStringRenderer.h"
#import "AMHTMLTransformer.h"
#import "AMLayoutManager.h"
#import "AMViewAttachment.h"
#import "AMUtils.h"
#import "AMGradientLayer.h"
#import "AMCodeViewAttachment.h"

@interface _AMAnimationDelegate : NSObject <CAAnimationDelegate>
@property (nonatomic, copy) void(^didStartBlock)(CAAnimation *anim);
@property (nonatomic, copy) void(^didEndBlock)(CAAnimation *anim, BOOL flag);
@end

@implementation _AMAnimationDelegate

+ (instancetype)delegateWithStart:(void(^)(CAAnimation *anim))start end:(void(^)(CAAnimation *anim, BOOL flag))end {
    _AMAnimationDelegate *obj = [_AMAnimationDelegate new];
    obj.didStartBlock = start;
    obj.didEndBlock = end;
    return obj;
}

+ (instancetype)delegateWithEnd:(void(^)(CAAnimation *anim, BOOL flag))end {
    _AMAnimationDelegate *obj = [_AMAnimationDelegate new];
    obj.didEndBlock = end;
    return obj;
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    !self.didStartBlock ?: self.didStartBlock(anim);
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    !self.didEndBlock ?: self.didEndBlock(anim, flag);
}

@end

@implementation UITextView (AntMarkdown)

- (instancetype)initWithFrame_ant_mark:(CGRect)frame {
    NSTextContainer *container = [[NSTextContainer alloc] init];
    AMLayoutManager *mgr = [AMLayoutManager new];
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    [storage addLayoutManager:mgr];
    [mgr addTextContainer:container];
    
    self = [self initWithFrame:frame textContainer:container];
    if (self) {
        self.editable = NO;
        self.selectable = NO;
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        if (@available(iOS 16.0, *)) {
            self.findInteractionEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}
- (instancetype)initWithFrame_ant_mark:(CGRect)frame delegate:(id<CMAttributedStringRendererDelegate>)delegate {
    NSTextContainer *container = [[NSTextContainer alloc] init];
    AMLayoutManager *mgr = [AMLayoutManager new];
    mgr.delegate = delegate;
    NSTextStorage *storage = [[NSTextStorage alloc] init];
    [storage addLayoutManager:mgr];
    [mgr addTextContainer:container];
    
    self = [self initWithFrame:frame textContainer:container];
    if (self) {
        self.editable = NO;
        self.selectable = NO;
        self.textContainerInset = UIEdgeInsetsZero;
        self.textContainer.lineFragmentPadding = 0;
        if (@available(iOS 16.0, *)) {
            self.findInteractionEnabled = NO;
        } else {
            // Fallback on earlier versions
        }
    }
    
    return self;
}
- (void)setAttributedTextPartialUpdate_ant_mark:(NSAttributedString *)attributedText
{
    [self setAttributedTextPartialUpdate_ant_mark:attributedText animated:NO];
}

- (void)setAttributedTextPartialUpdate_ant_mark:(NSAttributedString *)attributedText animated:(BOOL)animated {
    const NSUInteger textLength = self.textStorage.length;
    
    __block NSUInteger location = 0;
    // find the diffrent location,from ending to beginning
    [self.textStorage enumerateAttributesInRange:NSMakeRange(0, MIN(textLength, attributedText.length))
                                       options:NSAttributedStringEnumerationReverse
                                    usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if ([[attributedText attributedSubstringFromRange:range] isEqualToAttributedString:[self.textStorage attributedSubstringFromRange:range]]) {
            location = NSMaxRange(range);
            *stop = YES;
        }
    }];
    
    // update at the diffrent point
    [self.textStorage beginEditing];
    if (attributedText.length > location) {
        [attributedText enumerateAttributesInRange:NSMakeRange(location, attributedText.length - location)
                                           options:0
                                        usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            NSRange currentRange = range;
            // the length of the string is long enough, replace it
            if (self.textStorage.mutableString.length > range.location) {
                NSDictionary<NSAttributedStringKey,id> * currentAttrs = [self.textStorage attributesAtIndex:range.location
                                                                                      longestEffectiveRange:&currentRange
                                                                                                    inRange:NSMakeRange(range.location, MIN(range.length, self.textStorage.length - range.location))];
                NSTextAttachment *oldAttach = currentAttrs[NSAttachmentAttributeName];
                NSTextAttachment *newAttach = attrs[NSAttachmentAttributeName];
                
                if ((range.location < currentRange.location || NSMaxRange(range) > NSMaxRange(currentRange)) || ![currentAttrs includesDictionary_ant_mark:attrs]) {
                    BOOL shouldReplace = YES;
                    if ([oldAttach conformsToProtocol:@protocol(AMAttachmentUpdatable)]) {
                        id<AMAttachmentUpdatable> attach = (id<AMAttachmentUpdatable>)oldAttach;
                        if ([attach respondsToSelector:@selector(updateAttachmentFromAttachment:)] &&
                            [newAttach isKindOfClass:attach.class]) {
                            shouldReplace = currentRange.length != range.length;
                          
                            if ([attach isKindOfClass:AMCodeViewAttachment.class]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [attach updateAttachmentFromAttachment:newAttach];
                                });
                            } else {
                                [attach updateAttachmentFromAttachment:newAttach];
                            }
                        }
                    }
                    
                    if (shouldReplace) {
                        if ([oldAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                            id<AMViewAttachment> attach = (id<AMViewAttachment>)oldAttach;
                            UIView<AMViewAttachment> *view = [attach view];
                            if (view.superview == self) {
                                if ([view respondsToSelector:@selector(setAttachment:)]) {
                                    view.attachment = nil;
                                }
                                [view removeFromSuperview];
                            }
                        }
                        NSRange rangeToReplace = NSMakeRange(range.location, self.textStorage.length - range.location);
                        
                        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                                     inRange:rangeToReplace
                                                     options:0
                                                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
                            NSTextAttachment *oldAttach = value;
                            if ([oldAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                                id<AMViewAttachment> attach = (id<AMViewAttachment>)oldAttach;
                                UIView<AMViewAttachment> *view = [attach view];
                                if (view.superview == self) {
                                    if ([view respondsToSelector:@selector(setAttachment:)]) {
                                        view.attachment = nil;
                                    }
                                    [view removeFromSuperview];
                                }
                            }
                        }];
                        
                        [self.textStorage replaceCharactersInRange:rangeToReplace
                                              withAttributedString:[attributedText attributedSubstringFromRange:range]];
                        
                        if ([newAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                            id<AMViewAttachment> attach = (id<AMViewAttachment>)newAttach;
                            UIView<AMViewAttachment> *view = [attach view];
                            if (view) {
                                if ([view respondsToSelector:@selector(setAttachment:)]) {
                                    view.attachment = attach;
                                }
                                view.hidden = YES;
                                if (view.superview != self) {
                                    [self addSubview:view];
                                }
                            }
                        }
                    }
                }
            } else {    // the length of the string is not long enough, append it
                [self.textStorage appendAttributedString:[attributedText attributedSubstringFromRange:range]];
                
                NSTextAttachment *newAttach = attrs[NSAttachmentAttributeName];
                if ([newAttach conformsToProtocol:@protocol(AMViewAttachment)]) {
                    id<AMViewAttachment> attach = (id<AMViewAttachment>)newAttach;
                    UIView<AMViewAttachment> *view = [attach view];
                    if (view) {
                        if ([view respondsToSelector:@selector(setAttachment:)]) {
                            view.attachment = attach;
                        }
                        view.hidden = YES;
                        if (view.superview != self) {
                            [self addSubview:view];
                        }
                    }
                }
            }
        }];
    }
    if (attributedText.length < self.textStorage.length) {
        NSRange rangeToDelete = NSMakeRange(attributedText.length, self.textStorage.length - attributedText.length);
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                     inRange:rangeToDelete
                                     options:0
                                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
                id<AMViewAttachment> attach = (id<AMViewAttachment>)value;
                UIView<AMViewAttachment> *view = [attach view];
                if (view.superview == self) {
                    if ([view respondsToSelector:@selector(setAttachment:)]) {
                        view.attachment = nil;
                    }
                    [view removeFromSuperview];
                }
            }
        }];
        [self.textStorage deleteCharactersInRange:rangeToDelete];
    }
    [self.textStorage endEditing];

    
    NSInteger totalCount = [attributedText length];
    if (animated) {
        CALayer *mask = self.layer.mask;
        if (!mask) {
            mask = [CALayer layer];
            mask.actions = @{
                KEYPATH(CALayer *, bounds): [NSNull null],
                KEYPATH(CALayer *, position): [NSNull null],
                KEYPATH(CALayer *, frame): [NSNull null],
                KEYPATH(CALayer *, sublayerTransform): [NSNull null],
                @"transition": [NSNull null],
            };
            self.layer.mask = mask;
            
            CALayer *sub = [CALayer layer];
            sub.backgroundColor = [UIColor blackColor].CGColor;
            sub.actions = @{
                KEYPATH(CALayer *, bounds): [NSNull null],
                KEYPATH(CALayer *, position): [NSNull null],
                KEYPATH(CALayer *, frame): [NSNull null],
                @"transition": [NSNull null],
            };
            [mask addSublayer:sub];
        }
        CALayer *firstSublayer = mask.sublayers.firstObject;
        // make a black canvas，the mask part is not transparent
        mask.frame = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.bounds.size.width, self.bounds.size.height);
        // sublayer transform
        mask.sublayerTransform = CATransform3DMakeTranslation(self.contentOffset.x, -self.contentOffset.y, 0);
        // compute change area
        NSRange changedRange = NSMakeRange(location, self.textStorage.length - location);
        NSLog(@"=fade= begin animated totalCount = %ld, changedRange = %@",totalCount, NSStringFromRange(changedRange));
        if (changedRange.length == 0) {
            firstSublayer.frame = self.layer.mask.bounds;
        }
        __block BOOL hasViewAttachment = NO;
        [self.textStorage enumerateAttribute:NSAttachmentAttributeName
                                     inRange:changedRange
                                     options:NSAttributedStringEnumerationReverse
                                  usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
                hasViewAttachment = YES;
                *stop = YES;
            }
        }];
        
        __block NSInteger lineIndex = 0;
        // traverse area in each line
        [self.layoutManager enumerateLineFragmentsForGlyphRange:changedRange
                                                     usingBlock:^(CGRect rect, CGRect usedRect, NSTextContainer * _Nonnull textContainer, NSRange glyphRange, BOOL * _Nonnull stop) {
            
            if (!textContainer) {
                rect = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphRange.location effectiveRange:nil withoutAdditionalLayout:NO];
                usedRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphRange.location effectiveRange:nil withoutAdditionalLayout:NO];
                if (CGRectEqualToRect(rect, CGRectZero)) {
                    firstSublayer.frame = self.layer.mask.bounds;
                    return;
                }
            }
            lineIndex++;
            // it is the last line
            if (NSMaxRange(changedRange) == NSMaxRange(glyphRange)) {
                if (hasViewAttachment) {
                    CGRect maskRect = CGRectMake(0, 0, rect.size.width, CGRectGetMaxY(rect));
                    firstSublayer.frame = maskRect;
                    return;
                }
                
                // the front part of the last line is transparent
                CGRect maskRect = CGRectMake(0, 0, rect.size.width, CGRectGetMinY(rect));
                firstSublayer.frame = maskRect;
                
                CALayer *layerInSameLine = nil;
                
                NSMutableArray* lineSubLayer = [NSMutableArray array];
                
                NSArray *sublayers = [mask.sublayers copy];
                for (CALayer *l in sublayers) {
                    CGRect lineRect = CGRectMake(floor(rect.origin.x), floor(rect.origin.y), ceil(rect.size.width), ceil(rect.size.height+1));
                    lineRect.size.width = ceil(CGRectGetMaxX(usedRect)) - CGRectGetMinX(lineRect);
                    if ([l isKindOfClass:[AMGradientLayer class]]) {
                        if (CGRectContainsRect(lineRect, l.frame)) {
                            [lineSubLayer addObject:l];
                            if (!layerInSameLine) {
                                layerInSameLine = l;
                            } else if (CGRectGetMaxX(l.frame) > CGRectGetMaxX(layerInSameLine.frame)) {
                                layerInSameLine = l;
                            }
                        } else {
                            [l removeFromSuperlayer];
                        }
                    }
                }
                
                // make gradient from the begining of the lase line
                CGFloat x = rect.origin.x;
                // if there is a gradient layer already, then make gradient from the right of the layer
                if (layerInSameLine) {
                    x = CGRectGetMaxX(layerInSameLine.frame);
                }
                
                
                CGRect newLayerFrame = CGRectMake(x, rect.origin.y,
                                                  CGRectGetMaxX(usedRect) - x,
                                                  rect.size.height);
                
                BOOL hasSameFadeLayer = NO;
                // if there is a same layer, then drop it
                for (CALayer *l in lineSubLayer) {
                        if ([l isKindOfClass:[AMGradientLayer class]]) {
                            if(CGRectEqualToRect(CGRectIntegral(l.frame), CGRectIntegral(newLayerFrame)))
                            {
                                hasSameFadeLayer = YES;
                                break;
                            }
                        }
                }

                NSLog(@"=fade= hasSameFadeLayer = %d, lineHasLayerCount = %ld",hasSameFadeLayer,[lineSubLayer count]);
                
                if(!hasSameFadeLayer
                   && newLayerFrame.size.width > 0.001
                   && newLayerFrame.size.height > 0.001)
                {
                    AMGradientLayer *layer = [AMGradientLayer layer];
                    layer.lineIndex = lineIndex;
                    layer.startPoint = CGPointMake(0, 0.5);
                    layer.endPoint = CGPointMake(1, 0.5);
                    layer.frame = newLayerFrame;
                    layer.colors = @[(id)[UIColor blueColor].CGColor, (id)[UIColor blueColor].CGColor];
                    @weakify(layer);
                    [layer addAnimation:({
                        CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
                        anim.values = @[
                            @[(id)[UIColor clearColor].CGColor, (id)[UIColor clearColor].CGColor],
                            @[(id)[UIColor blueColor].CGColor, (id)[UIColor clearColor].CGColor],
                            @[(id)[UIColor blueColor].CGColor, (id)[UIColor blueColor].CGColor]];
                        anim.calculationMode = kCAAnimationLinear;
                        anim.fillMode = kCAFillModeBoth;
                        anim.duration = 0.15;
                        anim.removedOnCompletion = YES;
                        anim.delegate = [_AMAnimationDelegate delegateWithEnd:^(CAAnimation *anim, BOOL flag) {
                            @strongify(layer);
                            layer.isFadeComplete = YES;
                            if (flag) {
                                // [layer removeFromSuperlayer];
                            }
                        }];
                        anim;
                    }) forKey:@"fadeIn"];
                    [mask addSublayer:layer];
                    NSLog(@"=fade= addSublayer = %@, lineIndex = %ld, chRange = %@, text = %@",NSStringFromCGRect(newLayerFrame),lineIndex,NSStringFromRange(changedRange),[[attributedText attributedSubstringFromRange:changedRange] string]);
                }
            }
        }];
    } else {
        self.layer.mask = nil;
    }
}

- (void)setAttributedText_ant_mark:(NSAttributedString *)attributedText {
    
    [self.attributedText enumerateAttribute:NSAttachmentAttributeName
                                    inRange:NSMakeRange(0, self.attributedText.length)
                                    options:0
                                 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
            id<AMViewAttachment> attach = (id<AMViewAttachment>)value;
            UIView<AMViewAttachment> *view = [attach view];
            if (view.superview == self) {
                if ([view respondsToSelector:@selector(setAttachment:)]) {
                    view.attachment = nil;
                }
                [view removeFromSuperview];
            }
        }
    }];

    self.layer.mask = nil;
    
    [self setAttributedText:attributedText];
    
    [attributedText enumerateAttribute:NSAttachmentAttributeName
                               inRange:NSMakeRange(0, attributedText.length)
                               options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired
                            usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        if ([value conformsToProtocol:@protocol(AMViewAttachment)]) {
            id<AMViewAttachment> attach = (id<AMViewAttachment>)value;
            UIView<AMViewAttachment> *view = [attach view];
            if (view) {
                if ([view respondsToSelector:@selector(setAttachment:)]) {
                    view.attachment = attach;
                }
                view.hidden = YES;
                if (view.superview != self) {
                    [self addSubview:view];
                }
            }
        }
    }];
}

- (void)setMarkdownText_ant_mark:(NSString *)text {
    [self setMarkdownText_ant_mark:text styles:[AMTextStyles defaultStyles]];
}

- (void)setMarkdownText_ant_mark:(NSString *)text styles:(AMTextStyles *)styles {
    [self setAttributedText_ant_mark:[text markdownToAttributedStringWithStyles_ant_mark:styles]];
}

- (void)setMarkdownTextPartialUpdate_ant_mark:(NSString *)text styles:(AMTextStyles *)styles
{
    [self setMarkdownTextPartialUpdate_ant_mark:text styles:styles animated:NO];
}

- (void)setMarkdownTextPartialUpdate_ant_mark:(NSString *)text styles:(AMTextStyles *)styles animated:(BOOL)animated
{
    [self setAttributedTextPartialUpdate_ant_mark:[text markdownToAttributedStringWithStyles_ant_mark:styles] animated:animated];
}

@end
