// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CMBlockTextAttachment.h"
#import "CMImageTextAttachment.h"

@implementation CMBlockTextAttachment
{
    __weak NSTextContainer *_textContainer;
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    _textContainer = textContainer;
    
    textContainer.widthTracksTextView = YES;
    const CGFloat width = textContainer.size.width - textContainer.lineFragmentPadding * 2;
    CGRect rect = [super attachmentBoundsForTextContainer:textContainer
                                     proposedLineFragment:lineFrag
                                            glyphPosition:position
                                           characterIndex:charIndex];
    rect.size.width = width;
    return rect;
}

- (void)setNeedsUpdate {
    [_textContainer.layoutManager setNeedsLayoutForAttachment:self];
}

- (BOOL)isEqual:(nullable id)object {
    if ([super isEqual:object]) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToAttachment:(CMBlockTextAttachment *)object];
}

- (BOOL)isEqualToAttachment:(CMBlockTextAttachment *)attach
{
    return [self.text isEqualToString:attach.text];
}

- (NSAttributedString *)attributedString
{
    return [NSAttributedString attributedStringWithAttachment:self];
}

@end
