// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

export class TypingTimer {
  private timer?: number;
  private handler?: Callback<void>;
  private interval?: number;
  private state: ETypingTimerState = ETypingTimerState.Unknown;
  onDidPause?: Callback<void>;
  onDidStop?: Callback<void>;
  onWillResume?: Callback<void>;

  start(handler: Callback<void>, interval: number) {
    if (this.state === ETypingTimerState.Paused) {
      return;
    }
    if (this.timer !== undefined) {
      clearInterval(this.timer);
    }
    this.handler = handler;
    this.interval = interval;
    this.timer = setInterval(handler, interval);
  }
  pause() {
    if (this.timer !== undefined) {
      this.state = ETypingTimerState.Paused;
      clearInterval(this.timer);
      this.timer = undefined;
      this.onDidPause?.();
    }
  }
  resume() {
    if (this.timer !== undefined) {
      return;
    }
    this.state = ETypingTimerState.Resumed;
    this.onWillResume?.();
    if (this.handler && this.interval !== undefined) {
      this.timer = setInterval(this.handler, this.interval);
    }
  }
  stop() {
    this.state = ETypingTimerState.Stopped;
    if (this.timer !== undefined) {
      clearInterval(this.timer);
      this.timer = undefined;
    }
    this.handler = undefined;
    this.interval = undefined;
    this.onDidStop?.();
  }
  get processing(): boolean {
    return this.timer !== undefined;
  }
}

enum ETypingTimerState {
  Unknown = 0,
  Paused = 1 << 0,
  Resumed = 1 << 1,
  Stopped = 1 << 2,
}