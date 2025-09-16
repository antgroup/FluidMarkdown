// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CMInlineTextAttachment.h"
#import "CMImageTextAttachment.h"

@implementation CMInlineTextAttachment
{
    __weak NSTextContainer *_textContainer;
}

- (instancetype)initWithData:(NSData *)contentData ofType:(NSString *)uti {
    self = [super initWithData:contentData ofType:uti];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithText:(NSString *)text size:(CGSize)size {
    self = [self initWithData:nil ofType:nil];
    if (self) {
        self.text = text;
        self.bounds = CGRectMake(0, -size.height / 2, size.width, size.height);
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)size {
    return [self initWithText:nil size:size];
}

- (void)setNeedsUpdate {
    [_textContainer.layoutManager setNeedsLayoutForAttachment:self];
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
    
    return [self isEqualToAttachment:(CMInlineTextAttachment *)object];
}

- (BOOL)isEqualToAttachment:(CMInlineTextAttachment *)attach
{
    return [self.text isEqual:attach.text];
}

- (CGRect)attachmentBoundsForTextContainer:(NSTextContainer *)textContainer
                      proposedLineFragment:(CGRect)lineFrag
                             glyphPosition:(CGPoint)position
                            characterIndex:(NSUInteger)charIndex {
    _textContainer = textContainer;
    return [super attachmentBoundsForTextContainer:textContainer
                              proposedLineFragment:lineFrag
                                     glyphPosition:position
                                    characterIndex:charIndex];
}

@end
