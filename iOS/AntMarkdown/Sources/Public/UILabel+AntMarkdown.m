// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "UILabel+AntMarkdown.h"
#import "NSString+AntMarkdown.h"
#import "CocoaMarkdown.h"
#import "AMTextStyles.h"
#import "AMAttributedStringRenderer.h"
#import "AMHTMLTransformer.h"
#import "AMViewAttachment.h"

@implementation UILabel (AntMarkdown)

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

@end
