// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <AntMarkdown/AMViewAttachment.h>

@class CMTable;
@class AMTextStyles;

NS_ASSUME_NONNULL_BEGIN

@protocol AMTableView <NSObject>
@property (nonatomic) CMTable *table;

@optional
- (instancetype)initWithStyles:(AMTextStyles *)styles;

+ (CGSize)sizeThatFits:(CGSize)size table:(CMTable *)table styles:(AMTextStyles *)styles;

@end

@interface AMTableViewAttachment : AMViewAttachment
@property (nonatomic, readonly, nullable) UIView<AMTableView> *view;
@property (nonatomic) BOOL partialUpdate;
@property (nonatomic) CMTable *table;
@property (nonatomic, readonly, nullable) AMTextStyles *styles;

+ (Class<AMTableView>)tableViewClass;    // Default is AMMarkdownTableView

- (instancetype)initWithTable:(CMTable *)table styles:(AMTextStyles *)styles;

@end

NS_ASSUME_NONNULL_END
