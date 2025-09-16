// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "CMNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMTableCell : NSObject
@property (nonatomic, readonly) NSTextAlignment alignment;
@property (nonatomic, readonly) NSAttributedString *content;

+ (instancetype)cellWithContent:(NSAttributedString *)content;
+ (instancetype)cellWithContent:(NSAttributedString *)content
                      alignment:(NSTextAlignment)alignment;

- (BOOL)isEqualToCell:(CMTableCell *)cell;

@end

@interface CMTableRow : NSObject
@property (nonatomic, readonly) NSArray <CMTableCell *> *cells;
@property (nonatomic, readonly) NSInteger numberOfColumns;
@property (nonatomic, readonly) BOOL isHeader;

+ (instancetype)row;
+ (instancetype)rowWithHeader:(BOOL)isHeader;

- (void)push:(CMTableCell *)cell;

- (BOOL)isEqualToRow:(CMTableRow *)row;

@end

@interface CMTable : NSObject
@property (nonatomic, readonly) NSArray <CMTableRow *> *rows;
@property (nonatomic, readonly) NSInteger numberOfColumns;
@property (nonatomic, readonly) NSInteger numberOfRows;

+ (instancetype)tableWithNumberOfColumns:(NSUInteger)numberOfColumns;

- (void)push:(CMTableRow *)row;
- (CMTableRow *)peekRow;


- (CMTableCell *)cellAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isHeaderAtIndexPath:(NSIndexPath *)indexPath;

- (BOOL)isEqualToTable:(CMTable *)table;

@end

@interface CMNode (Table)

@property (readonly, nullable) CMTable *table;
@property (nonatomic, readonly) NSInteger numberOfColumns;
@property (readonly) BOOL rowIsHeader;
@property (readonly) NSTextAlignment cellAlignment;

@end

NS_ASSUME_NONNULL_END
