// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AMXMarkdownWidget.h"
@interface CustomButton : UIButton


- (instancetype)initWithFrame:(CGRect)frame
                   title:(NSString *)title
              titleColor:(UIColor *)titleColor
           gradientStart:(UIColor *)startColor
             gradientEnd:(UIColor *)endColor;


@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, strong) UIColor *shadowColor;

@end

@interface StreamPreviewViewController : UIViewController

@property (nonatomic, strong) CustomButton *actionStartButton;
@property (nonatomic, strong) CustomButton *actionPauseButton;
@property (nonatomic, strong) CustomButton *actionResumeButton;
@property (nonatomic, strong) CustomButton *actionStopButton;
@property (nonatomic, strong) CustomButton *actionAppendButton;
@property (nonatomic, strong) CustomButton *oneceButton;
@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, strong) AMXMarkdownTextView *contentTextView;
@property (nonatomic, strong) UIScrollView* containerView;

@end

