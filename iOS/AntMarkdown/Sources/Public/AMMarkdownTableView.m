// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMMarkdownTableView.h"
#import "AMUtils.h"
#import "CocoaMarkdown.h"
#import "AMGradientView.h"
#import "AMMarkdownTableLayout.h"
#import "AMTextStyles.h"
#import "UILabel+AntMarkdown.h"
#import "UITextView+AntMarkdown.h"
#import "AMMarkDownTableViewBlowUpControllerViewController.h"

const CGFloat AMTableHeaderHeight = 39;
const CGFloat AMTableMaximumColumnWidth = 300;
CGFloat AMTableCellMinimumLineSpacing = 0.5;
CGFloat AMTableCellMinimumInteritemSpacing = 0.5;
const CGFloat AMTableMinimumRowHeight = 35;
UIEdgeInsets AMTableCellInset = {10, 12, 8, 12};

@interface AMTableCellStyles : NSObject
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) CGFloat borderWidth;
@end

@interface AMMarkdownTableDatasource : NSObject <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic) CMTable *table;
@property (nonatomic) AMTextStyles *styles;
@property (nonatomic) BOOL partialUpdate;
@end

@interface AMMarkdownTableRowBackgroundView : UICollectionReusableView

@end

@interface AMMarkdownTableView() <UICollectionViewDelegate>
@property (nonatomic) AMMarkdownTableDatasource *dataSource;
@property (nonatomic) UIView *headerView;
@property (nonatomic) UIStackView *operationView;
@property (nonatomic) UILabel *titleView;
@property (nonatomic) UICollectionView *collectionView;
@property (nonatomic) AMGradientView *rightGradientView, *leftGradientView;
@property (nonatomic) AMMarkdownTableLayout *layout;
@property (nonatomic) AMTextStyles *styles;
@end

@implementation AMMarkdownTableView
@synthesize table = _table;
@synthesize attachment = _attachment;

+ (Class<AMMarkdownTableCell>)cellClass
{
    return [AMMarkdownTableCell class];
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self initWithStyles:[AMTextStyles defaultStyles]];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithStyles:(AMTextStyles *)styles
{
    self = [super initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 80)];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.styles = styles;
        if (self.styles.tableCellAttributes.stringAttributes[@"cellPadding"]) {
            AMTableCellInset.top = [self.styles.tableCellAttributes.stringAttributes[@"cellPadding"] UIEdgeInsetsValue].top;
            AMTableCellInset.bottom = [self.styles.tableCellAttributes.stringAttributes[@"cellPadding"] UIEdgeInsetsValue].bottom;
            AMTableCellInset.left = [self.styles.tableCellAttributes.stringAttributes[@"cellPadding"] UIEdgeInsetsValue].left;
            AMTableCellInset.right = [self.styles.tableCellAttributes.stringAttributes[@"cellPadding"] UIEdgeInsetsValue].right;
        }
        if (self.styles.tableAttributes.stringAttributes[@"rowSpacing"]) {
            AMTableCellMinimumLineSpacing = [self.styles.tableAttributes.stringAttributes[@"rowSpacing"] floatValue];
        }
        if (self.styles.tableAttributes.stringAttributes[@"columnSpacing"]) {
            AMTableCellMinimumInteritemSpacing = [self.styles.tableAttributes.stringAttributes[@"columnSpacing"] floatValue];
        }
    
        self.borderColor = self.styles.tableTitleAttributes.stringAttributes[NSBackgroundColorAttributeName] ? : [UIColor colorWithHex_ant_mark:0x1f3b6329];
        self.layer.borderColor = self.borderColor.CGColor;
        self.layer.borderWidth = self.styles.tableAttributes.stringAttributes[@"borderWidth"] ? [self.styles.tableAttributes.stringAttributes[@"borderWidth"] floatValue] : 0;
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        
        self.dataSource = [[AMMarkdownTableDatasource alloc] init];
        self.dataSource.styles = self.styles;
        self.dataSource.partialUpdate = self.partialUpdate;
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, AMTableHeaderHeight)];
        self.headerView.backgroundColor = self.styles.tableTitleAttributes.stringAttributes[NSBackgroundColorAttributeName] ? : [UIColor whiteColor];
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:39]];
        [self addSubview:self.headerView];
        [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.headerView
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.headerView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.headerView
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:0],
        ]];
        
        self.titleView = [UILabel new];
        self.titleView.text = @"表格";
        CGFloat titleSize = self.styles.tableTitleAttributes.fontAttributes[UIFontDescriptorSizeAttribute] ? [self.styles.tableTitleAttributes.fontAttributes[UIFontDescriptorSizeAttribute] floatValue]: 13;
        self.titleView.font = [UIFont boldSystemFontOfSize:titleSize];
        self.titleView.textColor = self.styles.baseTextAttributes.stringAttributes[NSForegroundColorAttributeName] ?: self.styles.paragraphAttributes.stringAttributes[NSForegroundColorAttributeName];
        if (self.styles.tableTitleAttributes.stringAttributes[NSForegroundColorAttributeName]) {
            self.titleView.textColor = self.styles.tableTitleAttributes.stringAttributes[NSForegroundColorAttributeName];
        }
        self.titleView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerView addSubview:self.titleView];
        
        self.operationView = [[UIStackView alloc] initWithArrangedSubviews:@[]];
        self.operationView.alignment = UIStackViewAlignmentCenter;
        self.operationView.axis = UILayoutConstraintAxisHorizontal;
        self.operationView.distribution = UIStackViewDistributionFillEqually;
        self.operationView.spacing = 12;
        self.operationView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerView addSubview:self.operationView];
        
        [self.headerView addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.headerView
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.titleView
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:-12],
            [NSLayoutConstraint constraintWithItem:self.headerView
                                         attribute:NSLayoutAttributeCenterY
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.titleView
                                         attribute:NSLayoutAttributeCenterY
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.titleView
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                            toItem:self.operationView
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:10],
            [NSLayoutConstraint constraintWithItem:self.operationView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.headerView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.operationView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.headerView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.operationView
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.headerView
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:-12],
        ]];
        
        UIButton *blowUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        blowUpButton.titleLabel.font = [UIFont systemFontOfSize:12];
        if (self.styles.tableAttributes.stringAttributes[@"operationIcon"]) {
            NSString* iconPath = self.styles.tableAttributes.stringAttributes[@"operationIcon"];
            NSRange iOSRange = [iconPath rangeOfString:@"/"];
            if (iOSRange.location != NSNotFound) {
                NSString *bundlePart = [iconPath substringToIndex:iOSRange.location];
                NSString *imagePart = [iconPath substringFromIndex:iOSRange.location + 1];
                [blowUpButton setImage:[UIImage imageNamed_ant_bundle:bundlePart name:imagePart] forState:UIControlStateNormal];
            }
        } else {
            [blowUpButton setImage:[UIImage imageNamed_ant_mark:@"blow_up_old"] forState:UIControlStateNormal];
        }
        [blowUpButton addTarget:self action:@selector(_onBlowUp:) forControlEvents:UIControlEventTouchUpInside];
        blowUpButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self setTableOperationViews:@[blowUpButton]];
        
        self.layout = [[AMMarkdownTableLayout alloc] init];
        self.layout.minimumLineSpacing = AMTableCellMinimumLineSpacing;
        self.layout.minimumInteritemSpacing = AMTableCellMinimumInteritemSpacing;
        self.layout.minimumRowHeight = AMTableMinimumRowHeight;
        self.layout.itemSize = CGSizeMake(80, 35);
        
        self.maximumColumnWidth = 300;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds
                                                 collectionViewLayout:self.layout];
        [self.collectionView registerClass:[self.class cellClass]
                forCellWithReuseIdentifier:CLSSTR(AMMarkdownTableCell)];
        [self.collectionView registerClass:[AMMarkdownTableRowBackgroundView class]
                forSupplementaryViewOfKind:@"Background"
                       withReuseIdentifier:CLSSTR(AMMarkdownTableRowBackgroundView)];
        self.collectionView.bounces = NO;
        self.collectionView.scrollsToTop = NO;
        self.collectionView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
        self.collectionView.backgroundColor = self.borderColor;
        self.collectionView.alwaysBounceHorizontal = NO;
        self.collectionView.alwaysBounceVertical = NO;
#if __IPHONE_17_4 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_17_4
        if (@available(iOS 17.4, *)) {
            self.collectionView.bouncesHorizontally = NO;
            self.collectionView.bouncesVertically = NO;
        } else {
            // Fallback on earlier versions
        }
#endif
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self.dataSource;
        [self addSubview:self.collectionView];
        self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.rightGradientView = [[AMGradientView alloc] init];
        self.rightGradientView.colors = @[
            [UIColor colorWithHex_ant_mark:0x201f3b63].transparentColor_ant_mark,
            [UIColor colorWithHex_ant_mark:0x201f3b63],
        ];
        self.rightGradientView.layer.actions = @{
            KEYPATH(CALayer *, opacity): [NSNull null],
            KEYPATH(CALayer *, hidden): [NSNull null],
        };
        self.rightGradientView.hidden = YES;
        self.rightGradientView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.rightGradientView];
        
        self.leftGradientView = [[AMGradientView alloc] init];
        self.leftGradientView.colors = @[
            [UIColor colorWithHex_ant_mark:0x201f3b63],
            [UIColor colorWithHex_ant_mark:0x201f3b63].transparentColor_ant_mark,
        ];
        self.leftGradientView.layer.actions = @{
            KEYPATH(CALayer *, opacity): [NSNull null],
            KEYPATH(CALayer *, hidden): [NSNull null],
        };
        self.leftGradientView.hidden = YES;
        self.leftGradientView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.leftGradientView];
        
        [self addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.collectionView
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.collectionView.superview
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.collectionView
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.collectionView.superview
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.collectionView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.headerView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.collectionView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.collectionView.superview
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.collectionView
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.rightGradientView
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.rightGradientView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.collectionView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.rightGradientView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.collectionView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.rightGradientView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:18],
            [NSLayoutConstraint constraintWithItem:self.collectionView
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.leftGradientView
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.leftGradientView
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.collectionView
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.leftGradientView
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.collectionView
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.leftGradientView
                                         attribute:NSLayoutAttributeWidth
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:nil
                                         attribute:NSLayoutAttributeNotAnAttribute
                                        multiplier:1
                                          constant:18],
        ]];
        
        [self.collectionView addObserver:self
                              forKeyPath:KEYPATH(self.collectionView, contentSize)
                                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                 context:nil];
        [self scrollViewDidScroll:self.collectionView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithStyles:[AMTextStyles defaultStyles]];
}

- (void)_onBlowUp:(id)sender {
    UIResponder *responder = self;
    UIViewController *vc = nil;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            vc = (UIViewController *)responder;
            break;
        }
        responder = [responder nextResponder];
    }
    if (vc) {
        AMMarkDownTableViewBlowUpControllerViewController *tableVC = [[AMMarkDownTableViewBlowUpControllerViewController alloc] init];
        tableVC.styles = self.styles;
        tableVC.table = self.table;
        tableVC.partialUpdate = self.partialUpdate;
        tableVC.collectionSize = self.collectionView.bounds.size;
        tableVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [vc presentViewController:tableVC animated:NO completion:nil];
    }
}

- (void)dealloc
{
    [self.collectionView removeObserver:self
                             forKeyPath:KEYPATH(self.collectionView, contentSize)];
}

- (void)setPartialUpdate:(BOOL)partialUpdate
{
    _partialUpdate = partialUpdate;
    self.dataSource.partialUpdate = partialUpdate;
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    if (object == self.collectionView) {
        CGSize oldSize = [change[NSKeyValueChangeOldKey] CGSizeValue];
        CGSize newSize = [change[NSKeyValueChangeNewKey] CGSizeValue];
        
        self.rightGradientView.hidden = self.leftGradientView.hidden = newSize.width < self.collectionView.bounds.size.width + 1;
        if (!self.rightGradientView.isHidden) {
            [self scrollViewDidScroll:self.collectionView];
        }
        
        if (!CGSizeEqualToSize(oldSize, newSize)) {
            if ([self.attachment respondsToSelector:@selector(setNeedsLayout)]) {
                [self.attachment setNeedsLayout];
            }
        }
    }
}

- (void)setTableOperationViews:(NSArray<UIView *> *)tableOperationViews
{
    if (![_tableOperationViews isEqualToArray:tableOperationViews]) {
        _tableOperationViews = tableOperationViews;
        [self.operationView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [tableOperationViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.operationView addArrangedSubview:obj];
        }];
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.collectionView.backgroundColor = borderColor;
}

- (void)setTable:(CMTable *)table
{
    if (![_table isEqualToTable:table]) {
        _table = table;
        self.dataSource.table = table;
        [self invalidateIntrinsicContentSize];
        [self setNeedsLayout];
        [self.collectionView reloadData];
    }
}

- (void)setMaximumColumnWidth:(CGFloat)maximumColumnWidth
{
    _maximumColumnWidth = maximumColumnWidth;
    self.layout.maximumColumnWidth = maximumColumnWidth;
}

- (void)didSelectTableCell:(UICollectionView<AMMarkdownTableCell> *)cell content:(CMTableCell *)content
{
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    [self.collectionView layoutIfNeeded];
    CGSize contentSize = self.layout.collectionViewContentSize;
    size.width = MIN(size.width, contentSize.width + self.collectionView.contentInset.left + self.collectionView.contentInset.right);
    size.height = contentSize.height + self.headerView.bounds.size.height + self.collectionView.contentInset.top + self.collectionView.contentInset.bottom;
    return size;
}

+ (CGSize)sizeThatFits:(CGSize)size table:(CMTable *)table styles:(AMTextStyles *)styles
{
    size.height = AMTableHeaderHeight;
    for (int row = 0; row < table.numberOfRows; row ++) {
        CGFloat height = AMTableMinimumRowHeight;
        for (int col = 0; col < table.numberOfColumns; col ++) {
            CMTableCell *cell = [table cellAtIndexPath:[NSIndexPath indexPathForItem:col inSection:row]];
            CGFloat constraintWidth = AMTableMaximumColumnWidth;
            if (col == 0) {
                if ([styles.tableCellAttributes.stringAttributes objectForKey:@"firstMaxWidth"]) {
                    constraintWidth = [styles.tableCellAttributes.stringAttributes[@"firstMaxWidth"] floatValue];
                }
            } else {
                if ([styles.tableCellAttributes.stringAttributes objectForKey:@"defaultMaxWidth"]) {
                    constraintWidth = [styles.tableCellAttributes.stringAttributes[@"defaultMaxWidth"] floatValue];
                }
            }
            CGSize cellSize = [AMMarkdownTableCell sizeForCell:cell constrainedWidth:constraintWidth];
            height = MAX(height, cellSize.height);
        }
        size.height += height;
    }
    size.height += AMTableCellMinimumLineSpacing * (table.numberOfRows - 1);
    return size;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x + scrollView.bounds.size.width >= scrollView.contentSize.width - 1) {
        if (![self.rightGradientView.layer animationForKey:@"Fadeout"]) {
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:KEYPATH(self.rightGradientView.layer, opacity)];
            anim.duration = 0.15;
            anim.toValue = @0;
            anim.fillMode = kCAFillModeBoth;
            anim.removedOnCompletion = NO;
            [self.rightGradientView.layer addAnimation:anim forKey:@"Fadeout"];
        }
        self.rightGradientView.alpha = 0;
    } else {
        if ([self.rightGradientView.layer animationForKey:@"Fadeout"]) {
            [self.rightGradientView.layer removeAnimationForKey:@"Fadeout"];
            if (scrollView.isDragging) {
                CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:KEYPATH(self.rightGradientView.layer, opacity)];
                anim.duration = 0.15;
                anim.fromValue = @0;
                anim.removedOnCompletion = YES;
                [self.rightGradientView.layer addAnimation:anim forKey:@"Fadein"];
            }
        }
        self.rightGradientView.alpha = 1;
    }
    
    if (scrollView.contentOffset.x < 1) {
        if (![self.leftGradientView.layer animationForKey:@"Fadeout"]) {
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:KEYPATH(self.leftGradientView.layer, opacity)];
            anim.duration = 0.15;
            anim.toValue = @0;
            anim.fillMode = kCAFillModeBoth;
            anim.removedOnCompletion = NO;
            [self.leftGradientView.layer addAnimation:anim forKey:@"Fadeout"];
        }
        self.leftGradientView.alpha = 0;
    } else {
        if ([self.leftGradientView.layer animationForKey:@"Fadeout"]) {
            [self.leftGradientView.layer removeAnimationForKey:@"Fadeout"];
            if (scrollView.isDragging) {
                CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:KEYPATH(self.leftGradientView.layer, opacity)];
                anim.duration = 0.15;
                anim.fromValue = @0;
                anim.removedOnCompletion = YES;
                [self.leftGradientView.layer addAnimation:anim forKey:@"Fadein"];
            }
        }
        self.leftGradientView.alpha = 1;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMTableCell *cellData = [self.table cellAtIndexPath:indexPath];
    CGFloat constraintWidth = self.maximumColumnWidth;
    if (indexPath.row == 0) {
        if ([self.styles.tableCellAttributes.stringAttributes objectForKey:@"firstMaxWidth"]) {
            constraintWidth = [self.styles.tableCellAttributes.stringAttributes[@"firstMaxWidth"] floatValue];
        }
    } else {
        if ([self.styles.tableCellAttributes.stringAttributes objectForKey:@"defaultMaxWidth"]) {
            constraintWidth = [self.styles.tableCellAttributes.stringAttributes[@"defaultMaxWidth"] floatValue];
        }
    }
    return [[self.class cellClass] sizeForCell:cellData constrainedWidth:constraintWidth];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    CMTableCell *cellData = [self.table cellAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self didSelectTableCell:(UICollectionView<AMMarkdownTableCell> *)cell
                     content:cellData];
}

@end

@implementation AMMarkdownLabelTableCell
@synthesize cellData = _cellData;

+ (CGSize)sizeForCell:(CMTableCell *)cell
{
    return [self sizeForCell:cell constrainedWidth:CGFLOAT_MAX];
}

+ (CGSize)sizeForCell:(CMTableCell *)cell constrainedWidth:(CGFloat)width
{
    static dispatch_once_t onceToken;
    static AMMarkdownLabelTableCell *view = nil;
    dispatch_once(&onceToken, ^{
        view = [[AMMarkdownLabelTableCell alloc] initWithFrame:CGRectZero];
    });
    view.label.preferredMaxLayoutWidth = width;
    [view.label setAttributedText_ant_mark:cell.content];
    return [view systemLayoutSizeFittingSize:CGSizeMake(width, CGFLOAT_MAX)
               withHorizontalFittingPriority:UILayoutPriorityFittingSizeLevel
                     verticalFittingPriority:UILayoutPriorityFittingSizeLevel];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentInsets = UIEdgeInsetsMake(4, 12, 4, 12);
        
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        self.label.font = [UIFont systemFontOfSize:14];
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
        
        self.label.translatesAutoresizingMaskIntoConstraints = NO;
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (void)setCellData:(CMTableCell *)cellData
{
    if (_cellData != cellData) {
        _cellData = cellData;
        
        self.label.textAlignment = cellData.alignment;
        [self.label setAttributedText_ant_mark:cellData.content];
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateConstraints
{
    [self.contentView removeConstraints:[self.contentView constraints]];
    [self.contentView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.label
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.label.superview
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1
                                      constant:self.contentInsets.left],
        [NSLayoutConstraint constraintWithItem:self.label
                                     attribute:NSLayoutAttributeRight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.label.superview
                                     attribute:NSLayoutAttributeRight
                                    multiplier:1
                                      constant:-self.contentInsets.right],
        [NSLayoutConstraint constraintWithItem:self.label
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.label.superview
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:self.contentInsets.top],
        [NSLayoutConstraint constraintWithItem:self.label
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.label.superview
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:-self.contentInsets.bottom],
    ]];
    
    [super updateConstraints];
}

@end


@implementation AMMarkdownTableCell
@synthesize cellData = _cellData;

+ (CGSize)sizeForCell:(CMTableCell *)cell
{
    return [self sizeForCell:cell constrainedWidth:CGFLOAT_MAX];
}

+ (CGSize)sizeForCell:(CMTableCell *)cell constrainedWidth:(CGFloat)width
{
    const CGFloat paddingHorizontal = AMTableCellInset.left + AMTableCellInset.right;
    const CGFloat paddingVertical = AMTableCellInset.top + AMTableCellInset.bottom;
    CGSize size = CGRectIntegral([cell.content boundingRectWithSize:CGSizeMake(width - paddingHorizontal, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                            context:nil]).size;
    
    CGSize size2 = CGRectIntegral([cell.content boundingRectWithSize:CGSizeMake(width - paddingHorizontal, CGFLOAT_MAX)
                                                            options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesDeviceMetrics
                                                            context:nil]).size;

    return CGSizeMake(MIN(width, size.width + paddingHorizontal), MAX(size.height, size2.height) + paddingVertical);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textview = [[UITextView alloc] initWithFrame_ant_mark:UIEdgeInsetsInsetRect(self.bounds, self.contentInsets)];
        self.textview.font = [UIFont systemFontOfSize:14];
        self.textview.scrollEnabled = YES;
        self.textview.selectable = NO;
        self.textview.editable = NO;
        self.textview.backgroundColor = [UIColor clearColor];
        self.textview.textContainerInset = UIEdgeInsetsZero;
        self.textview.textContainer.lineFragmentPadding = 0;
        [self.contentView addSubview:self.textview];
        
        self.textview.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addConstraints:@[
            [NSLayoutConstraint constraintWithItem:self.textview
                                         attribute:NSLayoutAttributeLeft
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textview.superview
                                         attribute:NSLayoutAttributeLeft
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.textview
                                         attribute:NSLayoutAttributeRight
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textview.superview
                                         attribute:NSLayoutAttributeRight
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.textview
                                         attribute:NSLayoutAttributeTop
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textview.superview
                                         attribute:NSLayoutAttributeTop
                                        multiplier:1
                                          constant:0],
            [NSLayoutConstraint constraintWithItem:self.textview
                                         attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual
                                            toItem:self.textview.superview
                                         attribute:NSLayoutAttributeBottom
                                        multiplier:1
                                          constant:0],
        ]];
        
        self.contentInsets = AMTableCellInset;
        
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onSizeUpdate:)
                                                   name:AMTextAttachmentSizeDidUpdateNotification
                                                 object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)onSizeUpdate:(NSNotification *)noti
{
    if ([noti.object isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *attri = (NSAttributedString *)noti.object;
        if ([attri.string isEqual:self.cellData.content.string]) {
            UICollectionView *collectionView = (UICollectionView *)self.superview;
            while (![collectionView isKindOfClass:[UICollectionView class]]) {
                collectionView = (UICollectionView *)collectionView.superview;
            }
            if ([collectionView isKindOfClass:[UICollectionView class]]) {
                NSIndexPath *indexPath = [collectionView indexPathForCell:self];
                UICollectionViewLayoutInvalidationContext *context = [[UICollectionViewLayoutInvalidationContext alloc] init];
                if (indexPath) {
                    [context invalidateItemsAtIndexPaths:@[indexPath]];
                } else {
                    
                }
                
                [collectionView.collectionViewLayout invalidateLayout];
            }
        }
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.textview.attributedText = nil;
}

- (void)setCellData:(CMTableCell *)cellData
{
    if (_cellData != cellData || (!self.textview.attributedText || [self.textview.attributedText length] <= 0)) {
        _cellData = cellData;
        
        self.textview.textAlignment = cellData.alignment;
        if (self.partialUpdate) {
            [self.textview setAttributedTextPartialUpdate_ant_mark:cellData.content];
        } else {
            [self.textview setAttributedText_ant_mark:cellData.content];
        }
    }
}

- (void)setContentInsets:(UIEdgeInsets)contentInsets {
    if (!UIEdgeInsetsEqualToEdgeInsets(_contentInsets, contentInsets)) {
        _contentInsets = contentInsets;
        self.textview.textContainerInset = contentInsets;
    }
}

@end

@implementation AMMarkdownTableDatasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.table.numberOfColumns;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell<AMMarkdownTableCell> *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CLSSTR(AMMarkdownTableCell)
                                                                                                forIndexPath:indexPath];
    CMTableCell *cellData = [self.table cellAtIndexPath:indexPath];
    cell.cellData = cellData;
    if ([cell isKindOfClass:[AMMarkdownTableCell class]]) {
        ((AMMarkdownTableCell *)cell).partialUpdate = self.partialUpdate;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    if ([self.table isHeaderAtIndexPath:indexPath]) {
        UIColor *color = self.styles.tableHeaderAttributes.stringAttributes[@"contentBgColor"] ?: [UIColor colorWithHex_ant_mark:0x141f3b63];
        if ([color isKindOfClass:[UIColor class]]) {
            cell.contentView.backgroundColor = color;
        }
    } else {
        UIColor *color = self.styles.tableCellAttributes.stringAttributes[@"contentBgColor"];
        if ([color isKindOfClass:[UIColor class]]) {
            cell.contentView.backgroundColor = color;
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.table.numberOfRows;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView 
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:@"Background"]) {
        AMMarkdownTableRowBackgroundView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                    withReuseIdentifier:CLSSTR(AMMarkdownTableRowBackgroundView)
                                                                                           forIndexPath:indexPath];
        return view;
    }
    return nil;
}

@end

@implementation AMMarkdownTableRowBackgroundView


@end
