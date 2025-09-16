// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMMarkdownTableLayout : UICollectionViewLayout
@property (nonatomic) CGFloat minimumLineSpacing;   // Default 1
@property (nonatomic) CGFloat minimumInteritemSpacing;  // Default 1
@property (nonatomic) CGSize itemSize;

@property (nonatomic) BOOL fillWidth;               // Default YES
@property (nonatomic) CGFloat minimumRowHeight;     // Default 35
@property (nonatomic) CGFloat maximumColumnWidth;   // Default 360
@end

NS_ASSUME_NONNULL_END
