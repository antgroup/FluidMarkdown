// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMXMarkdownLogModel : NSObject
/// The id of the log
@property (nonatomic, copy) NSString *spm;

/// Extra parameters
@property (nonatomic, strong) NSDictionary *extraParams;

/// The unique style id
@property (nonatomic, copy) NSString *styleId;


@end

NS_ASSUME_NONNULL_END
