// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMGradientView.h"
#import "AMUtils.h"

@interface AMGradientView ()
@property(nonatomic, readonly, strong) CAGradientLayer *layer;
@end

@implementation AMGradientView
@dynamic layer;

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.startPoint = CGPointMake(0, 0.5);
        self.endPoint = CGPointMake(1, 0.5);
    }
    return self;
}

- (void)setStartPoint:(CGPoint)startPoint
{
    _startPoint = startPoint;
    self.layer.startPoint = startPoint;
}

- (void)setEndPoint:(CGPoint)endPoint
{
    _endPoint = endPoint;
    self.layer.endPoint = endPoint;
}

- (void)setColors:(NSArray<UIColor *> *)colors
{
    _colors = colors;
    self.layer.colors = [colors mapWithBlock_ant_mark:^id _Nonnull(UIColor * _Nonnull obj) {
        return (id)obj.CGColor;
    }];
}

- (void)setLocations:(NSArray<NSNumber *> *)locations
{
    _locations = locations;
    self.layer.locations = locations;
}

@end
