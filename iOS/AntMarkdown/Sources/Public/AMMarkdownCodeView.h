// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <AntMarkdown/AMCodeViewAttachment.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMMarkdownCodeView : UIView <AMCodeView, AMAttachedView>
@property (nonatomic) UILabel *languageLabel;
@property (nonatomic) UIButton *codeCopyButton;
@property (nonatomic) BOOL partialUpdate;

@property (nonatomic) CGFloat maximumHeight;    // Default is Screen Height / 2

- (instancetype)initWithStyles:(AMTextStyles *)styles;

- (void)didCopyCode:(NSString *)code;

@end

NS_ASSUME_NONNULL_END
