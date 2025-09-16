// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMMarkDownTableViewBlowUpControllerViewController.h"
#import "AMUtils.h"
#import "AMGradientView.h"
#import "AMMarkdownTableLayout.h"
#import "UITextView+AntMarkdown.h"

const CGFloat AMTableCellMinimumLineLandScapeSpacing = 1;
const CGFloat AMTableMinimumLandScapeRowHeight = 35;
const UIEdgeInsets AMTableLandScapeCellInset = {10, 40, 8, 40};

@interface AMMarkdownTableRowBackgroundLandScapeView : UICollectionReusableView

@end

@implementation AMMarkdownTableRowBackgroundLandScapeView
@end

@interface AMMarkdownLandScapeTableCell : UICollectionViewCell <AMMarkdownTableCell>
@property (nonatomic) UITextView *textview;
@property (nonatomic) UIEdgeInsets contentInsets;
@property (nonatomic) BOOL partialUpdate;

+ (CGSize)sizeForCell:(CMTableCell *)cell;

@end

@implementation AMMarkdownLandScapeTableCell
@synthesize cellData = _cellData;

+ (CGSize)sizeForCell:(CMTableCell *)cell
{
    return [self sizeForCell:cell constrainedWidth:CGFLOAT_MAX];
}

+ (CGSize)sizeForCell:(CMTableCell *)cell constrainedWidth:(CGFloat)width
{
    const CGFloat paddingHorizontal = AMTableLandScapeCellInset.left + AMTableLandScapeCellInset.right;
    const CGFloat paddingVertical = AMTableLandScapeCellInset.top + AMTableLandScapeCellInset.bottom;
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
        
        self.contentInsets = AMTableLandScapeCellInset;
        
        
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
    if (_cellData != cellData) {
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


@interface AMMarkDownTableViewBlowUpControllerViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic) AMMarkdownTableLayout *layout;

@property (nonatomic) UICollectionView * collectionView;

@property (nonatomic) CGFloat maximumColumnWidth;

@property (nonatomic) UIColor *borderColor;

@property (nonatomic) CGFloat borderWidth;

@property (nonatomic) AMGradientView *rightGradientView, *leftGradientView;

@property (nonatomic)UIScrollView *scrollView;

@property (nonatomic)NSLayoutConstraint* collectionNSLayoutConstraint;
@property (nonatomic)NSLayoutConstraint* scrollViewNSLayoutConstraint;


@end

@implementation AMMarkDownTableViewBlowUpControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.borderColor = self.styles.tableTitleAttributes.stringAttributes[NSBackgroundColorAttributeName]? : [UIColor colorWithHex_ant_mark:0x1f3b6329];
    self.borderWidth = self.styles.tableAttributes.stringAttributes[@"borderWidth"] ? [self.styles.tableAttributes.stringAttributes[@"borderWidth"] floatValue] : 0;
    [self setupUI];
}

- (void)setupUI {
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [backButton setImage:[UIImage imageNamed_ant_mark:@"icon_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
    backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backButton];
    [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:backButton
                                     attribute:NSLayoutAttributeLeft
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeLeft
                                    multiplier:1
                                      constant:20],
        [NSLayoutConstraint constraintWithItem:backButton
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:20],
        [NSLayoutConstraint constraintWithItem:backButton
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:70],
        [NSLayoutConstraint constraintWithItem:backButton
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:30],
    ]];
    
    CGFloat maxHeight = self.view.bounds.size.width - 80;
    CGFloat width = self.view.bounds.size.height - 100;
    CGFloat height = self.collectionSize.height > maxHeight ? maxHeight : self.collectionSize.height;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    [self.view addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    _scrollViewNSLayoutConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1
                                                                  constant:height];
    [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:backButton
                                     attribute:NSLayoutAttributeBottom
                                    multiplier:1
                                      constant:14],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeCenterX
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:self.view
                                     attribute:NSLayoutAttributeCenterX
                                    multiplier:1
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:_scrollView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:width],
        _scrollViewNSLayoutConstraint,
    ]];
    
    
    self.layout = [[AMMarkdownTableLayout alloc] init];
    self.layout.minimumLineSpacing = AMTableCellMinimumLineLandScapeSpacing;
    self.layout.minimumInteritemSpacing = 1;
    self.layout.minimumRowHeight = AMTableMinimumLandScapeRowHeight;
    self.layout.itemSize = CGSizeMake(105, 35);
    
    self.maximumColumnWidth = 300;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height)
                                             collectionViewLayout:self.layout];
    [self.collectionView registerClass:[AMMarkdownLandScapeTableCell class]
            forCellWithReuseIdentifier:CLSSTR(AMMarkdownLandScapeTableCell)];
    [self.collectionView registerClass:[AMMarkdownTableRowBackgroundLandScapeView class]
            forSupplementaryViewOfKind:@"Background"
                   withReuseIdentifier:CLSSTR(AMMarkdownTableRowBackgroundLandScapeView)];
    self.collectionView.bounces = NO;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(1, 0, 0, 0);
    self.collectionView.backgroundColor = self.borderColor;
    self.collectionView.alwaysBounceHorizontal = NO;
    self.collectionView.alwaysBounceVertical = NO;
#if __IPHONE_11_0 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
#endif
    
    
#if __IPHONE_17_4 && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_17_4
    if (@available(iOS 17.4, *)) {
        self.collectionView.bouncesHorizontally = NO;
        self.collectionView.bouncesVertically = NO;
    } else {
        // Fallback on earlier versions
    }
#endif
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.layer.borderWidth = self.borderWidth;
    self.collectionView.layer.borderColor = self.borderColor.CGColor;
    self.collectionView.layer.cornerRadius = 12;
    [_scrollView addSubview:self.collectionView];
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
    [_scrollView addSubview:self.rightGradientView];
    
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
    [_scrollView addSubview:self.leftGradientView];
    _collectionNSLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:height];
    [_scrollView addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.collectionView
                                     attribute:NSLayoutAttributeWidth
                                     relatedBy:NSLayoutRelationGreaterThanOrEqual
                                        toItem:nil
                                     attribute:NSLayoutAttributeNotAnAttribute
                                    multiplier:1
                                      constant:width],
        _collectionNSLayoutConstraint,
        [NSLayoutConstraint constraintWithItem:self.rightGradientView
                                     attribute:NSLayoutAttributeTop
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
                                     attribute:NSLayoutAttributeTop
                                    multiplier:1
                                      constant:0],
        [NSLayoutConstraint constraintWithItem:self.rightGradientView
                                     attribute:NSLayoutAttributeBottom
                                     relatedBy:NSLayoutRelationEqual
                                        toItem:_scrollView
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
                                        toItem:_scrollView
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
            // layout
            CGFloat maxHeight = self.view.bounds.size.height - 100;
            CGFloat height = newSize.height > maxHeight ? maxHeight : newSize.height;
            CGRect oldFrame = [_scrollView frame];
            [_scrollView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, height)];
            [_collectionView setFrame:CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, height)];
            [_scrollView removeConstraint:_collectionNSLayoutConstraint];
            [self.view removeConstraint:_scrollViewNSLayoutConstraint];
            NSLayoutConstraint* newNSLayoutConstraint = [NSLayoutConstraint constraintWithItem:self.collectionView
                                                                                            attribute:NSLayoutAttributeHeight
                                                                                            relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                                               toItem:nil
                                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                                           multiplier:1
                                                                                             constant:height];
            NSLayoutConstraint* newscrollNSLayoutConstraint = [NSLayoutConstraint constraintWithItem:_scrollView
                                                                                           attribute:NSLayoutAttributeHeight
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:nil
                                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                                          multiplier:1
                                                                                            constant:height];
            [_scrollView addConstraint:newNSLayoutConstraint];
            [self.view addConstraint:newscrollNSLayoutConstraint];
        }
    }
}

- (void)dealloc
{
    [self.collectionView removeObserver:self
                             forKeyPath:KEYPATH(self.collectionView, contentSize)];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self forceLandscapeOrientation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self forceOrientationPortrait];
}

- (void)forceOrientationPortrait {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)forceLandscapeOrientation {
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}


- (void)onBack:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

# pragma UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CMTableCell *cellData = [self.table cellAtIndexPath:indexPath];
    return [[AMMarkdownLandScapeTableCell class] sizeForCell:cellData constrainedWidth:self.maximumColumnWidth];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}


# pragma UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.table.numberOfColumns;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AMMarkdownLandScapeTableCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CLSSTR(AMMarkdownLandScapeTableCell)
                                                                                                forIndexPath:indexPath];
    CMTableCell *cellData = [self.table cellAtIndexPath:indexPath];
    cell.cellData = cellData;
    if ([cell isKindOfClass:[AMMarkdownLandScapeTableCell class]]) {
        ((AMMarkdownLandScapeTableCell *)cell).partialUpdate = self.partialUpdate;
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    if ([self.table isHeaderAtIndexPath:indexPath]) {
        UIColor *color = self.styles.tableHeaderAttributes.stringAttributes[@"contentBgColor"] ?: [UIColor colorWithHex_ant_mark:0x141f3b63];
        if ([color isKindOfClass:[UIColor class]]) {
            cell.contentView.backgroundColor = color;
        }
    }
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.table.numberOfRows;
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:@"Background"]) {
        AMMarkdownTableRowBackgroundLandScapeView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                    withReuseIdentifier:CLSSTR(AMMarkdownTableRowBackgroundLandScapeView)
                                                                                           forIndexPath:indexPath];
        return view;
    }
    return nil;
}




@end
