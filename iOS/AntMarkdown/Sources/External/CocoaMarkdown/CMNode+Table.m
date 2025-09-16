// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "CMNode+Table.h"
#import "CMNode_Private.h"

@implementation CMTable
{
    NSMutableArray<CMTableRow *> * _rows;
    CMNode * _node;
}

+ (instancetype)tableWithNumberOfColumns:(NSUInteger)numberOfColumns
{
    CMTable *table = [self new];
    table->_numberOfColumns = numberOfColumns;
    return table;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rows = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithNode:(CMNode *)node {
    self = [self init];
    if (self) {
        _node = node;
    }
    return self;
}

- (NSArray<CMTableRow *> *)rows
{
    return [_rows copy];
}

- (void)push:(nonnull CMTableRow *)row {
    [_rows addObject:row];
}

- (nonnull CMTableRow *)peekRow {
    return _rows.lastObject;
}

- (NSInteger)numberOfRows
{
    return _rows.count;
}

- (CMTableCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rows[indexPath.section].cells[indexPath.item];
}

- (BOOL)isHeaderAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rows[indexPath.section].isHeader;
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToTable:(CMTable *)object];
}

- (BOOL)isEqualToTable:(CMTable *)table
{
    return self.numberOfRows == table.numberOfRows
    && self.numberOfColumns == table.numberOfColumns
    && [self.rows isEqualToArray:table.rows];
}

@end

@implementation CMTableRow
{
    NSMutableArray<CMTableCell *> * _cells;
    CMNode * _node;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _cells = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithNode:(CMNode *)node {
    self = [self init];
    if (self) {
        _node = node;
    }
    return self;
}


+ (nonnull instancetype)rowWithHeader:(BOOL)isHeader {
    CMTableRow *row = [self new];
    row->_isHeader = isHeader;
    return row;
}

+ (nonnull instancetype)row {
    return [self rowWithHeader:NO];
}

- (void)push:(nonnull CMTableCell *)cell {
    [_cells addObject:cell];
}

- (NSInteger)numberOfColumns
{
    return _cells.count;
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToRow:(CMTableRow *)object];
}

- (BOOL)isEqualToRow:(CMTableRow *)row
{
    return self.isHeader == row.isHeader
    && [self.cells isEqualToArray:row.cells];
}

@end

@implementation CMTableCell
{
    CMNode * _node;
}

- (instancetype)initWithNode:(CMNode *)node {
    self = [super init];
    if (self) {
        _node = node;
    }
    return self;
}

- (BOOL)isEqual:(nullable id)object {
    if (object == nil) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    return [self isEqualToCell:(CMTableCell *)object];
}

- (BOOL)isEqualToCell:(CMTableCell *)cell
{
    return self.alignment == cell.alignment
    && [self.content isEqualToAttributedString:cell.content];
}

+ (nonnull instancetype)cellWithContent:(nonnull NSAttributedString *)content
                              alignment:(NSTextAlignment)alignment {
    CMTableCell *cell = [self new];
    cell->_content = [content copy];
    cell->_alignment = alignment;
    return cell;
}

+ (nonnull instancetype)cellWithContent:(nonnull NSAttributedString *)content {
    return [self cellWithContent:content alignment:NSTextAlignmentNatural];
}

@end

@implementation CMNode (Table)

- (CMTable *)table {
    if (self.type != CMNodeTypeTable) {
        return nil;
    }
    return [[CMTable alloc] initWithNode:self];
}

- (BOOL)rowIsHeader {
    return cmark_gfm_extensions_get_table_row_is_header(self.node);
}

- (NSInteger)numberOfColumns {
    return cmark_gfm_extensions_get_table_columns(self.node);
}

- (NSTextAlignment)cellAlignment {
    uint8_t align = cmark_gfm_extensions_get_table_cell_alignment(self.node);
    switch (align) {
        case 'l':
            return NSTextAlignmentLeft;
            break;
        case 'r':
            return NSTextAlignmentRight;
            break;
        case 'c':
            return NSTextAlignmentCenter;
            break;
        default:
            return NSTextAlignmentNatural;
            break;
    }
}

@end
