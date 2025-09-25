// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "ToastView.h"

@implementation ToastView

+ (void)showToastInView:(UIView *)view withText:(NSString *)text duration:(NSTimeInterval)duration {

    UIView *toastView = [[UIView alloc] init];
    toastView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    toastView.layer.cornerRadius = 10;
    toastView.alpha = 0;
 
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    [label sizeToFit];
    
    CGFloat padding = 16;
    CGRect labelFrame = label.frame;
    toastView.frame = CGRectMake(0, 0, labelFrame.size.width + padding*2, labelFrame.size.height + padding*2);
    label.center = CGPointMake(toastView.frame.size.width/2, toastView.frame.size.height/2);
    
    [toastView addSubview:label];
    toastView.center = CGPointMake(view.frame.size.width/2, view.frame.size.height*0.8);
    [view addSubview:toastView];
    
    [UIView animateWithDuration:0.3 animations:^{
        toastView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:duration options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toastView.alpha = 0;
        } completion:^(BOOL finished) {
            [toastView removeFromSuperview];
        }];
    }];
}

@end
