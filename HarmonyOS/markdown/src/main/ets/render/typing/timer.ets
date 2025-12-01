// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

export class TypingTimer {
  private timer?: number;
  private handler?: Callback<void>;
  private interval?: number;
  onDidPause?: Callback<void>;
  onDidStop?: Callback<void>;
  onWillResume?: Callback<void>;

  start(handler: Callback<void>, interval: number) {
    if (this.timer !== undefined) {
      clearInterval(this.timer);
    }
    this.handler = handler;
    this.interval = interval;
    this.timer = setInterval(handler, interval);
  }
  pause() {
    if (this.timer !== undefined) {
      clearInterval(this.timer);
      this.timer = undefined;
      this.onDidPause?.();
    }
  }
  resume() {
    if (this.timer !== undefined) {
      return;
    }
    this.onWillResume?.();
    if (this.handler && this.interval !== undefined) {
      this.timer = setInterval(this.handler, this.interval);
    }
  }
  stop() {
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