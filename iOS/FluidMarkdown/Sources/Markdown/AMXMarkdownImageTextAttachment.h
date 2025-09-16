// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <AntMarkdown/AntMarkdown.h>
#import <AntMarkdown/AMImageTextAttachment.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AMXMarkDownImageAttachmentProtocol <NSObject>

- (UIImage *)getImageFromCacheIfExist:(NSString *)url;

- (void)onImageLoadFinish:(UIImage *)image url:(NSString *)url;

@end

@interface AMXMarkdownImageTextAttachment : AMImageTextAttachment<AMImageAttachmentBuilder>

@property (nonatomic, weak) id<AMXMarkDownImageAttachmentProtocol> imgDelegate;

- (void)refreshImageIfNeed;

@end

NS_ASSUME_NONNULL_END
