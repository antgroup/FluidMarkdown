// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@class AMTextStyles;

NS_ASSUME_NONNULL_BEGIN

@interface AMCodeHighlighter : NSObject

- (instancetype)initWithStyles:(AMTextStyles *)styles;

- (NSAttributedString *)highlightCodeString:(NSString *)code 
                                   language:(nullable NSString *)language;

- (nullable NSAttributedString *)cachedAttributedCodeForCode:(NSString *)code
                                                    language:(nullable NSString *)language;

@end

NS_ASSUME_NONNULL_END
