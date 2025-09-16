// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/CMBlockTextAttachment.h>
#import <AntMarkdown/AMInlineMathAttachment.h>

NS_ASSUME_NONNULL_BEGIN
@class MTMathListDisplay;
@class MTMathList;

@interface AMBlockMathAttachment : CMBlockTextAttachment

@property (nonatomic, nullable, strong) NSError *error;

- (instancetype)initWithText:(nullable NSString *)text
                       style:(nullable AMMathStyle *)style NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithDisplayList:(nullable MTMathListDisplay *)displayList style:(nullable AMMathStyle *)style NS_DESIGNATED_INITIALIZER;

+ (NSArray<AMBlockMathAttachment *> *)constructorBlockMathAttachmentWithText:(NSString *)text style:(AMMathStyle *)style;

@end

NS_ASSUME_NONNULL_END
