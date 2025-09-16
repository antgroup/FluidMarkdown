// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <AntMarkdown/AMDrawable.h>
#import <AntMarkdown/AMUnderline.h>

NS_ASSUME_NONNULL_BEGIN

@interface AMGradient : NSObject <AMDrawable, AMUnderlineDrawable>
@property (nonatomic) NSArray <UIColor *> *colors;
@property (nonatomic, nullable) NSArray <NSNumber *> *locations;
@property (nonatomic) CGPoint startPoint, endPoint;
@property (nonatomic, nullable) NSNumber *degree;  // angle，0 is from top to bottom，clockwise
@property (nonatomic, readonly) CGGradientRef CGGradient;

+ (instancetype)gradientWithColors:(NSArray <UIColor *> *)colors;
+ (instancetype)gradientWithColors:(NSArray <UIColor *> *)colors 
                        startPoint:(CGPoint)start
                          endPoint:(CGPoint)end;
+ (instancetype)gradientWithColors:(NSArray <UIColor *> *)colors
                         locations:(NSArray<NSNumber *> * _Nullable)locations
                        startPoint:(CGPoint)start
                          endPoint:(CGPoint)end;
+ (instancetype)gradientWithColors:(NSArray <UIColor *> *)colors
                         locations:(NSArray<NSNumber *> * _Nullable)locations
                           degree:(CGFloat)degree;

- (BOOL)isEqualToGradient:(AMGradient *)gradient;

@end

NS_ASSUME_NONNULL_END
