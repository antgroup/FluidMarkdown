// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownCodeViewAttachment.h"
#import "AMXMarkdownCodeView.h"

@interface AMXMarkdownCodeViewAttachment ()

@end

@implementation AMXMarkdownCodeViewAttachment

+ (Class<AMCodeView>)codeViewClass {
    return [AMXMarkdownCodeView class];
}

#pragma mark AMCodeAttachmentBuilder

- (NSTextAttachment<AMViewAttachment> *)buildWithCode:(NSString *)code
                                             language:(nullable NSString *)language
                                               styles:(AMTextStyles *)styles {
    return [AMXMarkdownCodeViewAttachment attachmentWithCode:code
                                                    language:language
                                                      styles:styles];
}

@end
