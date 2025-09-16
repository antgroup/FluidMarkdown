// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <AntMarkdown/AMTableViewAttachment.h>

@class CMTableCell;

NS_ASSUME_NONNULL_BEGIN

@protocol AMMarkdownTableCell <NSObject>
@property (nonatomic, nullable) CMTableCell *cellData;

+ (CGSize)sizeForCell:(CMTableCell *)cell
     constrainedWidth:(CGFloat)width;

@end

@interface AMMarkdownLabelTableCell : UICollectionViewCell <AMMarkdownTableCell>
@property (nonatomic) UILabel * label;
@property (nonatomic) UIEdgeInsets contentInsets;

+ (CGSize)sizeForCell:(CMTableCell *)cell;

@end

@interface AMMarkdownTableCell : UICollectionViewCell <AMMarkdownTableCell>
@property (nonatomic) UITextView *textview;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) BOOL partialUpdate;

+ (CGSize)sizeForCell:(CMTableCell *)cell;

@end

@interface AMMarkdownTableView : UIView <AMTableView, AMAttachedView>
@property (nonatomic) CGFloat maximumColumnWidth;
@property (nonatomic, readonly) UICollectionView *collectionView;
@property (nonatomic, copy) NSArray<UIView *> *tableOperationViews;
@property (nonatomic) BOOL partialUpdate;

@property (nonatomic) UIColor *borderColor;

- (instancetype)initWithStyles:(AMTextStyles *)styles NS_DESIGNATED_INITIALIZER;

- (void)didSelectTableCell:(UICollectionView<AMMarkdownTableCell> *)cell content:(CMTableCell *)content;

/**
 * Default is \c AMMarkdownLabelTableCell
 */
+ (Class<AMMarkdownTableCell>)cellClass;

@end

NS_ASSUME_NONNULL_END
