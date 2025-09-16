// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMMarkdownTableLayout.h"


@interface AMSizeConstraint : NSObject
@property (nonatomic) CGSize minSize;
@property (nonatomic) CGSize maxSize;
@end

@implementation AMSizeConstraint

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.minSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
        self.maxSize = CGSizeZero;
    }
    return self;
}

- (void)updateSize:(CGSize)size
{
    CGSize s = self.minSize;
    s.width = MIN(self.minSize.width, size.width);
    s.height = MIN(self.minSize.height, size.height);
    self.minSize = s;
    
    s = self.maxSize;
    s.width = MAX(self.maxSize.width, size.width);
    s.height = MAX(self.maxSize.height, size.height);
    self.maxSize = s;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"min: %@, max: %@", NSStringFromCGSize(self.minSize), NSStringFromCGSize(self.maxSize)];
}

@end


@implementation AMMarkdownTableLayout
{
    NSMutableArray <AMSizeConstraint *> * _columnConstraint;
    NSMutableArray <AMSizeConstraint *> * _rowConstraint;
    NSMutableDictionary <NSIndexPath *, NSValue *> * _sizeCache;
    NSMutableArray <NSArray <UICollectionViewLayoutAttributes *> *> * _allAttributes;
    CGSize  _contentSize;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _columnConstraint = [NSMutableArray array];
        _rowConstraint = [NSMutableArray array];
        _sizeCache = [NSMutableDictionary dictionary];
        _allAttributes = [NSMutableArray array];
        
        _minimumLineSpacing = 1;
        _minimumInteritemSpacing = 1;
        _minimumRowHeight = 35;
        _maximumColumnWidth = 360;
        _fillWidth = YES;
    }
    return self;
}

- (void)setMaximumColumnWidth:(CGFloat)maximumColumnWidth
{
    if (_maximumColumnWidth != maximumColumnWidth) {
        _maximumColumnWidth = maximumColumnWidth;
        [self invalidateLayout];
    }
}

- (void)setMinimumRowHeight:(CGFloat)minimumRowHeight
{
    if (_minimumRowHeight != _minimumRowHeight) {
        _minimumRowHeight = minimumRowHeight;
        [self invalidateLayout];
    }
}

- (void)setFillWidth:(BOOL)fillWidth
{
    if (_fillWidth != fillWidth) {
        _fillWidth = fillWidth;
        [self invalidateLayout];
    }
}

- (void)setMinimumLineSpacing:(CGFloat)minimumLineSpacing
{
    if (_minimumLineSpacing != minimumLineSpacing) {
        _minimumLineSpacing = minimumLineSpacing;
        [self invalidateLayout];
    }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing
{
    if (_minimumInteritemSpacing != minimumInteritemSpacing) {
        _minimumInteritemSpacing = minimumInteritemSpacing;
        [self invalidateLayout];
    }
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    [_columnConstraint removeAllObjects];
    [_rowConstraint removeAllObjects];
    [_sizeCache removeAllObjects];
    [_allAttributes removeAllObjects];
    
    CGSize contentSize = CGSizeZero;
    
    NSInteger sections = self.collectionView.numberOfSections;
    NSInteger columns = 0;
    for (int s = 0; s < sections; s ++) {
        NSInteger col = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:s];
        
        for (int c = 0; c < col; c ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            CGSize size = [(id<UICollectionViewDelegateFlowLayout>)self.collectionView.delegate collectionView:self.collectionView
                                                                                                        layout:self
                                                                                        sizeForItemAtIndexPath:indexPath];
            _sizeCache[indexPath] = [NSValue valueWithCGSize:size];
        }
        
        if (columns < col) {
            columns = col;
        }
    }
    
    CGFloat totalWidth = 0;
    for (int c = 0; c < columns; c ++) {
        AMSizeConstraint *constraint = [[AMSizeConstraint alloc] init];
        for (int s = 0; s < sections; s ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            CGSize size = _sizeCache[indexPath].CGSizeValue;
            [constraint updateSize:size];
        }
        totalWidth += constraint.maxSize.width + self.minimumInteritemSpacing;
        [_columnConstraint addObject:constraint];
    }
    totalWidth -= self.minimumInteritemSpacing;
    
    for (int s = 0; s < sections; s ++) {
        AMSizeConstraint *constraint = [[AMSizeConstraint alloc] init];
        for (int c = 0; c < columns; c ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            CGSize size = _sizeCache[indexPath].CGSizeValue;
            [constraint updateSize:size];
        }
        [_rowConstraint addObject:constraint];
    }
    
    const CGFloat fullWidth = UIEdgeInsetsInsetRect(self.collectionView.bounds, self.collectionView.contentInset).size.width;
    BOOL ignoreMaxWidth = NO;

    if (totalWidth < fullWidth && self.fillWidth) {
        ignoreMaxWidth = YES;
        const CGFloat spacing = self.minimumInteritemSpacing * (columns - 1);
        for (int c = 0; c < columns; c ++) {
            AMSizeConstraint *constraint = _columnConstraint[c];
            CGSize size = constraint.maxSize;
            size.width = size.width / (totalWidth - spacing) * (fullWidth - spacing);
            [constraint updateSize:size];
        }
    }
    
    const CGPoint initialOffset = CGPointZero;
    CGPoint offset = initialOffset;
    for (int s = 0; s < sections; s ++) {
        NSInteger col = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:s];
        AMSizeConstraint *rowConstraint = _rowConstraint[s];
        const CGFloat height = MAX(rowConstraint.maxSize.height, self.minimumRowHeight);
        
        NSMutableArray<UICollectionViewLayoutAttributes *> *arr = [NSMutableArray arrayWithCapacity:columns];
        for (int c = 0; c < col; c ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:c inSection:s];
            AMSizeConstraint *colConstraint = _columnConstraint[c];
            const CGFloat width = MIN(colConstraint.maxSize.width, ignoreMaxWidth ? CGFLOAT_MAX : self.maximumColumnWidth);
            UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            attr.frame = CGRectMake(offset.x, offset.y, width, height);
            [arr addObject:attr];
            
            offset.x += width + self.minimumInteritemSpacing;
        }
        contentSize.width = MAX(contentSize.width, offset.x - self.minimumInteritemSpacing);
        
        offset.x = initialOffset.x;
        offset.y += height + self.minimumLineSpacing;
        [_allAttributes addObject:arr.copy];
    }
    contentSize.height = offset.y - self.minimumLineSpacing;
    
    _contentSize = contentSize;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray <UICollectionViewLayoutAttributes *> * result = [NSMutableArray array];
    [_allAttributes enumerateObjectsUsingBlock:^(NSArray<UICollectionViewLayoutAttributes *> * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        [section enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectIntersectsRect(rect, item.frame)) {
                [result addObject:item];
            }
        }];
    }];
    return [result copy];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _allAttributes[indexPath.section][indexPath.item];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    if (CGSizeEqualToSize(newBounds.size, self.collectionView.bounds.size)) {
        return NO;
    }
    return self.fillWidth;
}

- (CGSize)collectionViewContentSize
{
    CGSize size = _contentSize;
    return size;
}

@end
