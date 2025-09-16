// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownCodeView.h"

@implementation AMXMarkdownCodeView

- (void)didCopyCode:(NSString *)code {
    if ([code length] > 0) {
        if ([self copyToPasteboard:code]) {
            // copy success
        }
    }
}

- (BOOL)copyToPasteboard:(NSString *)copyText {
    // Need to implement copy logic
    return NO;
}

@end
