// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <AntMarkdown/CMPlatformDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A text attachment for displaying horizontal rules in Markdown.
 */
@interface CMHorizontalRuleAttachment : NSTextAttachment

/**
 *  Initializes a horizontal rule attachment with default settings.
 *
 *  @return An initialized instance of the receiver.
 */
- (instancetype)init;

/**
 *  The color of the horizontal rule.
 *  Defaults to light gray.
 */
@property (nonatomic, strong) CMColor *lineColor;

/**
 *  The thickness of the horizontal rule line.
 *  Defaults to 1.0.
 */
@property (nonatomic, assign) CGFloat lineThickness;

/**
 *  The inset from the left and right edges.
 *  Defaults to 0.0.
 */
@property (nonatomic, assign) CGFloat horizontalInset;

/**
 *  The vertical padding  below the line.
 *  Defaults to 6.0.
 */
@property (nonatomic, assign) CGFloat verticalPadding;
/**
 *  The vertical padding above the line.
 *  Defaults to 6.0.
 */
@property (nonatomic, assign) CGFloat verticalPaddingBefore;

@end

NS_ASSUME_NONNULL_END 
