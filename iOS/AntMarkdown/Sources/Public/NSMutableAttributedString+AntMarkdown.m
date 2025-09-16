// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "NSMutableAttributedString+AntMarkdown.h"
#import "AMLayoutManager.h"
#import "AMViewAttachment.h"
#import "AMUtils.h"

@implementation NSMutableAttributedString (AntMarkdown)

- (void)setAttributedStringPartialUpdate_ant_mark:(NSAttributedString *)attributedText {    
    __block NSUInteger location = 0;
    // find the diffrent location,from ending to beginning
    [self enumerateAttributesInRange:NSMakeRange(0, MIN(self.length, attributedText.length))
                             options:NSAttributedStringEnumerationReverse
                          usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        if ([[attributedText attributedSubstringFromRange:range] isEqualToAttributedString:[self attributedSubstringFromRange:range]]) {
            location = NSMaxRange(range);
            *stop = YES;
        }
    }];
    
    // update at the diffrent point
    [self beginEditing];
    if (attributedText.length > location) {
        [attributedText enumerateAttributesInRange:NSMakeRange(location, attributedText.length - location)
                                           options:0
                                        usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            NSRange currentRange = range;
            // the length of the string is long enough, replace it
            if (self.length > range.location) {
                NSDictionary<NSAttributedStringKey,id> * currentAttrs = [self attributesAtIndex:range.location
                                                                          longestEffectiveRange:&currentRange
                                                                                        inRange:NSMakeRange(range.location, MIN(range.length, self.length - range.location))];
                NSTextAttachment *oldAttach = currentAttrs[NSAttachmentAttributeName];
                NSTextAttachment *newAttach = attrs[NSAttachmentAttributeName];
                
                if ((range.location < currentRange.location || NSMaxRange(range) > NSMaxRange(currentRange)) || ![currentAttrs includesDictionary_ant_mark:attrs]) {
                    BOOL shouldReplace = YES;
                    if ([oldAttach conformsToProtocol:@protocol(AMAttachmentUpdatable)]) {
                        id<AMAttachmentUpdatable> attach = (id<AMAttachmentUpdatable>)oldAttach;
                        if ([attach respondsToSelector:@selector(updateAttachmentFromAttachment:)] && [newAttach isKindOfClass:attach.class]) {
                            shouldReplace = currentRange.length != range.length;
                            [attach updateAttachmentFromAttachment:newAttach];
                        }
                    }
                    
                    if (shouldReplace) {
                        
                        [self replaceCharactersInRange:NSMakeRange(range.location, self.length - range.location)
                                  withAttributedString:[attributedText attributedSubstringFromRange:range]];
                    }
                }
            } else {    // the length of the string is not long enough, append it
                [self appendAttributedString:[attributedText attributedSubstringFromRange:range]];
            }
        }];
    }
    if (attributedText.length < self.length) {
        NSRange rangeToDelete = NSMakeRange(attributedText.length, self.length - attributedText.length);
        [self deleteCharactersInRange:rangeToDelete];
    }
    [self endEditing];
}

@end
