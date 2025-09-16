// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol CMAttributedStringRendererDelegate;
@interface AMLayoutManager : NSLayoutManager
@property (nonatomic, weak)id<CMAttributedStringRendererDelegate> delegate;
@property (nonatomic, strong)NSMutableArray* locArray;
@property (nonatomic, strong)NSMutableDictionary* attachmentDic;
@property (nonatomic, copy)NSString* styleId;
@end

NS_ASSUME_NONNULL_END
