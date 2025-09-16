// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMXMarkdownCustomRenderEventModel : NSObject
@property (nonatomic, copy)NSString* contentUrl;
@property (nonatomic, copy)NSString* contentType;
@property (nonatomic, copy)NSString* contentName;
@property (nonatomic, assign)NSInteger exposurePercent;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, strong)NSDictionary* extParam;

@end

NS_ASSUME_NONNULL_END
