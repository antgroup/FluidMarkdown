// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

@protocol AMXMarkdownTimerDelegate <NSObject>

@required
- (void)onTimer;

@end

NS_ASSUME_NONNULL_BEGIN

@interface AMXMarkdownTimer : NSObject
- (instancetype)initWithConfig:(NSInteger)intervalTime queue:(dispatch_queue_t)queue;

- (void)startTimer;

- (void)stopTimer;

- (BOOL)isRuning;

@property(nonatomic,weak)id<AMXMarkdownTimerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
