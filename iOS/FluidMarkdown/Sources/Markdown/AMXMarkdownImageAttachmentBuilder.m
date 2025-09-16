// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownImageAttachmentBuilder.h"
#import "AMXMarkdownImageTextAttachment.h"

@implementation AMXMarkdownImageAttachmentBuilder

- (NSTextAttachment *)buildWithURL:(NSURL *)url
                             title:(nullable NSString *)title
                            styles:(AMTextStyles *)styles {
    AMXMarkdownImageTextAttachment *textAttachment = [[AMXMarkdownImageTextAttachment alloc] initWithImageURL:url];
    return textAttachment;
}

@end
