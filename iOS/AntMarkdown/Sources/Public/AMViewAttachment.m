// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMViewAttachment.h"
#import "CMImageTextAttachment.h"
#import "AMUtils.h"

NSString *const AMTextAttachmentSizeDidUpdateNotification = @"AMTextAttachmentSizeDidUpdateNotification";

@interface AMViewAttachment ()
@property (nonatomic) CGRect cachedBounds;
@end

@implementation AMViewAttachment
{
    __weak NSTextContainer *_textContainer;
}
@dynamic view;

- (void)dealloc
{
    if([NSThread isMainThread])
    {
        [self.viewIfLoaded removeFromSuperview];
    }
    else
    {
        UIView* view = self.viewIfLoaded;
        dispatch_async(dispatch_get_main_queue(), ^{
            [view removeFromSuperview];
        });
    }
}

- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti {
    self = [super initWithData:nil ofType:nil];
    if (self) {
        self.fullWidth = YES;
    }
    return self;
}

- (__kindof UIView<AMAttachedView> *)view {
    return nil;
}

- (__kindof UIView<AMAttachedView> *)viewIfLoaded
{
    return nil;
}

- (void)setNeedsUpdate
{
    [self setNeedsLayout];
}

- (void)setForceNeedsLayout
{
    NSLayoutManager *mgr = _textContainer.layoutManager;
    if (mgr) {
        self.cachedBounds = CGRectNull;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [mgr setNeedsLayoutForAttachment:self];
            
            NSNotification *noti = [[NSNotification alloc] initWithName:AMTextAttachmentSizeDidUpdateNotification
                                                                 object:mgr.textStorage
                                                               userInfo:@{
                NSAttachmentAttributeName: self,
            }];
            [[NSNotificationQueue defaultQueue] enqueueNotification:noti
                                                       postingStyle:NSPostWhenIdle
                                                       coalesceMask:NSNotificationCoalescingOnSender
                                                           forModes:nil];
        });
    }
}

- (void)setNeedsLayout
{
    if (CGRectIsNull(self.cachedBounds)) {
        return;
    }
    [self setForceNeedsLayout];
}

- (void)setNeedsDisplay
{
    [_textContainer.layoutManager setNeedsDisplayForAttachment:self];
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
    
    return [self isEqualToAttachment:(AMViewAttachment *)object];
}

- (BOOL)isEqualToAttachment:(AMViewAttachment *)attach
{
    return self.fullWidth == attach.fullWidth && [self.view isEqual:attach.view];
}

- (void)updateAttachmentFromAttachment:(AMViewAttachment *)attach
{
    self.fullWidth = attach.fullWidth;
    self.cachedBounds = CGRectZero;
}

- (NSAttributedString *)attributedString
{
    NSMutableAttributedString *attr = [[NSAttributedString attributedStringWithAttachment:self] mutableCopy];
    if (self.fullWidth) {
        NSParagraphStyle *paragraph = ({
            NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            style.paragraphSpacing = 0;
            style.paragraphSpacingBefore = 10;
            style.lineSpacing = 0;
            style.lineHeightMultiple = 1;
            style.lineBreakStrategy = NSLineBreakStrategyPushOut;
            style.firstLineHeadIndent = 0;
            style;
        });

        [attr appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [attr addAttribute:NSParagraphStyleAttributeName value:paragraph range:NSMakeRange(0, attr.length)];
    }
    return [attr copy];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self.view sizeThatFits:size];
}

- (UIImage *)imageForBounds:(CGRect)imageBounds
              textContainer:(NSTextContainer *)textContainer
             characterIndex:(NSUInteger)charIndex {
    return nil;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    _textContainer = textContainer;
    
    const CGFloat width = textContainer.size.width - textContainer.lineFragmentPadding * 2;
    
    if (!CGRectIsEmpty(self.cachedBounds) && (!self.fullWidth || self.cachedBounds.size.width == width)) {
        return self.cachedBounds;
    }
    CGRect rect = [super attachmentBoundsForTextContainer:textContainer
                                     proposedLineFragment:lineFrag
                                            glyphPosition:position
                                           characterIndex:charIndex];
    rect.size = [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    if (self.fullWidth) {
        rect.size.width = width;
    }
    self.cachedBounds = rect;
    return rect;
}

@end

@interface AMButtonViewAttachment ()
@property (nonatomic, copy, nullable) ButtonAction buttonAction;
@end

@implementation AMButtonViewAttachment

- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti {
    return [self initWithTitle:@"" action:nil];
}

- (instancetype)initWithTitle:(NSString *)title action:(ButtonAction)action
{
    self = [super initWithData:nil ofType:nil];
    if (self) {
        self.fullWidth = NO;
        self.buttonAction = action;
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        self.button.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.button setTitle:title forState:UIControlStateNormal];
        [self.button setTitleColor:[UIColor colorWithHex_ant_mark:0x1F3B63]
                          forState:UIControlStateNormal];
        [self.button addTarget:self
                        action:@selector(onButton:)
              forControlEvents:UIControlEventTouchUpInside];
        [self.button sizeToFit];
    }
    return self;
}

- (__kindof UIView<AMAttachedView> *)view
{
    return self.button;
}

- (void)onButton:(id)sender
{
    !self.buttonAction ?: self.buttonAction();
}

@end
