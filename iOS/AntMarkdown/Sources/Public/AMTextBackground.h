// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <AntMarkdown/AMDrawable.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMBorder : NSObject
@property (nonatomic) CGFloat borderWidth;
@property (nonatomic) UIColor * borderColor;
@property (nonatomic) CGLineCap lineCap;

- (BOOL)isEqualToBorder:(AMBorder *)border;

@end

@interface AMTextBackground : NSObject <AMDrawable>
@property (nonatomic) BOOL isInline;
@property (nonatomic, nullable) UIColor *backgroundColor;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) UIEdgeInsets contentInset;
@property (nonatomic, nullable) AMBorder *leftBorder, *rightBorder, *topBorder, *bottomBorder;
@property (nonatomic, assign) BOOL isQuote;

- (BOOL)isEqualToBackground:(AMTextBackground *)background;

+ (instancetype)leftBorderColor:(UIColor *)color width:(CGFloat)width;
+ (instancetype)topBorderColor:(UIColor *)color width:(CGFloat)width;
+ (instancetype)rightBorderColor:(UIColor *)color width:(CGFloat)width;
+ (instancetype)bottomBorderColor:(UIColor *)color width:(CGFloat)width;

+ (instancetype)leftColor:(UIColor * _Nullable)leftColor leftWidth:(CGFloat)leftWidth
                 topColor:(UIColor * _Nullable)topColor topWidth:(CGFloat)topWidth
               rightColor:(UIColor * _Nullable)rightColor rightWidth:(CGFloat)rightWidth
              bottomColor:(UIColor * _Nullable)bottomColor bottomWidth:(CGFloat)bottomWidth;

+ (instancetype)backgroundWithColor:(UIColor *)color radius:(CGFloat)radius;
+ (instancetype)backgroundWithColor:(UIColor *)color radius:(CGFloat)radius insets:(UIEdgeInsets)insets;

@end

NS_ASSUME_NONNULL_END
