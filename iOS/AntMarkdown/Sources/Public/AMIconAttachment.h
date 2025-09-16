// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#import "CocoaMarkdown.h"
#import "AMViewAttachment.h"

NS_ASSUME_NONNULL_BEGIN

@interface AMIconAttachment : NSTextAttachment
@property (nonatomic, nullable) NSString *path;
@property (nonatomic, nullable) NSString *text;
@property (nonatomic) UIFont *baseFont;
@property (nonatomic) UIColor *textColor;
@property (nonatomic, assign) NSInteger textSize;
@property (nonatomic, assign)NSTextAlignment textAlignment;
@property (nonatomic) CGSize attachmentSize;
@property (nonatomic) CGFloat marginLeft;
@property (nonatomic) CGFloat marginRight;
@property (nonatomic) BOOL boldText;

- (instancetype)init;
- (void)setNeedsUpdate;

- (BOOL)isEqualToAttachment:(AMIconAttachment *)attach;

@end

NS_ASSUME_NONNULL_END
