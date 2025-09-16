// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

#import "AMXMarkdownTimer.h"

@interface AMXMarkdownTimer ()
{
    dispatch_source_t _timer;
}
@property(nonatomic,assign)BOOL isRun;
@property(nonatomic,assign)NSInteger intervalTime; //microsecond
@property(nonatomic, strong) dispatch_queue_t queue;
@end

@implementation AMXMarkdownTimer

- (instancetype)initWithConfig:(NSInteger)intervalTime queue:(dispatch_queue_t)queue
{
    self = [super init];
    if (self) {
        self.queue = queue;
        self.intervalTime = intervalTime;
    }
    return self;
}

- (void)startTimer
{
    if(self.isRun)
        return;

    if(_timer)
    {
        return;
    }
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.intervalTime * NSEC_PER_MSEC));
    uint64_t intervalTime = (uint64_t)(self.intervalTime * NSEC_PER_MSEC);
    dispatch_source_set_timer(_timer, start, intervalTime, 0);
    
    __weak AMXMarkdownTimer* weakSelf = self;
    dispatch_source_set_event_handler(_timer, ^{
        if (weakSelf.isRun) {
            [weakSelf onTimer];
        }
    });
    
    dispatch_resume(_timer);

    self.isRun = YES;
}

- (void)stopTimer
{

    self.isRun = NO;
}

- (void)onTimer
{
    [self.delegate onTimer];
}

- (BOOL)isRuning
{
    return self.isRun;
}

@end
