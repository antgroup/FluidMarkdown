// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import "CMPlatformDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface CMTaskCheckAttachment : NSTextAttachment

@property (nonatomic, assign) BOOL checked;
//
/**
*  border color of uncheckedbox
*  Defaults to lightGrayColor
*/
@property (nonatomic, strong) CMColor *borderColor;

/**
*  The border width of the uncheckedbox
*  Defaults to 3.0.
*/
@property (nonatomic, assign) CGFloat borderWidth;

/**
*  background of checkedbox
*  Defaults to system green
*/
@property (nonatomic, strong) CMColor *backgroundColor;

/**
*  The inset from the left and right edges.
*  Defaults to 0.0.
*/
@property (nonatomic, assign) CGFloat horizontalPadding;

/**
*  The vertical padding above and below the checkbox.
*  Defaults to 6.0.
*/
@property (nonatomic, assign) CGFloat verticalPadding;

@end

NS_ASSUME_NONNULL_END
