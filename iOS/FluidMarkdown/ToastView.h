// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ToastView : NSObject
+ (void)showToastInView:(UIView *)view withText:(NSString *)text duration:(NSTimeInterval)duration;
@end

NS_ASSUME_NONNULL_END
