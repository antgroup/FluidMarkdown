// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { newLog } from '../../util';

const log = newLog('TypingTimer');

export class TypingTimer {
  private static gid: number = 0;
  private static createGid() {
    return ++TypingTimer.gid;
  }
  readonly ID = TypingTimer.createGid();
  private timer?: number;
  private handler?: Callback<void>;
  private interval?: number;
  state: ETypingTimerState = ETypingTimerState.Unknown;
  onDidPause?: Callback<void>;
  onDidStop?: Callback<void>;
  onWillResume?: Callback<void>;

  start(handler: Callback<void>, interval: number) {
    if (this.state === ETypingTimerState.Paused || this.state === ETypingTimerState.Stopped) {
      log.i(`${this.ID} skip start as state is ${this.state}`);
      return;
    }
    log.i(`${this.ID} invoke start`);
    if (this.timer !== undefined) {
      clearInterval(this.timer);
    }
    this.handler = handler;
    this.interval = interval;
    this.timer = setInterval(handler, interval);
  }
  pause() {
    if (this.state === ETypingTimerState.Stopped) {
      log.i(`${this.ID} skip pause as state is ${this.state}`);
      return;
    }
    log.i(`${this.ID} invoke pause`);
    if (this.timer !== undefined) {
      this.state = ETypingTimerState.Paused;
      clearInterval(this.timer);
      this.timer = undefined;
      this.onDidPause?.();
    }
  }
  resume() {
    if (this.state === ETypingTimerState.Stopped) {
      log.i(`${this.ID} skip resume as state is ${this.state}`);
      return;
    }
    if (this.timer !== undefined) {
      log.i(`${this.ID} skip resume as timer is not undefined`);
      return;
    }
    log.i(`${this.ID} invoke resume`);
    this.state = ETypingTimerState.Resumed;
    this.onWillResume?.();
    if (this.handler && this.interval !== undefined) {
      this.timer = setInterval(this.handler, this.interval);
    }
  }
  stop() {
    log.i(`${this.ID} invoke stop`);
    this.state = ETypingTimerState.Stopped;
    if (this.timer !== undefined) {
      clearInterval(this.timer);
      this.timer = undefined;
    }
    this.handler = undefined;
    this.interval = undefined;
    this.onDidStop?.();
  }
  reset() {
    log.i(`${this.ID} invoke reset`);
    // this.state = ETypingTimerState.Unknown;  //  keep state
    if (this.timer !== undefined) {
      clearInterval(this.timer);
      this.timer = undefined;
    }
    this.handler = undefined;
    this.interval = undefined;
  }
  get processing(): boolean {
    return this.timer !== undefined;
  }
}

export enum ETypingTimerState {
  Unknown = 0,
  Paused = 1 << 0,
  Resumed = 1 << 1,
  Stopped = 1 << 2,
}