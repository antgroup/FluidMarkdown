// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMLayoutManager.h"

@protocol AMDrawable;
NS_ASSUME_NONNULL_BEGIN

@interface AMQuoteLayoutContext : NSObject

@property (nonatomic, assign) CGFloat originX;
@property (nonatomic, assign) CGFloat originY;
@property (nonatomic, assign) NSInteger level;

@end

@interface AMLayoutManager (Quote)

- (BOOL)handleQuoteDraw:(CGContextRef)context
           quoteContext:(AMQuoteLayoutContext *)quoteContext
               drawable:(id<AMDrawable>)drawable
                  range:(NSRange)range;

@end

NS_ASSUME_NONNULL_END
