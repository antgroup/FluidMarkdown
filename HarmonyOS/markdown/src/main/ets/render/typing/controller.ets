// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { TypingTimer, ETypingTimerState } from './timer';
import type { ContextService } from '../../service';
import type { Node } from '../../service/ast';

export enum ETypingMode {
  Begin = 'begin',
  Append = 'append',
  End = 'end',
  Update = 'update',
}
export interface ITyping {
  /**
   * @note units: ms
   * @default 100
   */
  speed?: number;
  /**
   * @default 1
   */
  step?: number;
  rootController?: WeakRef<Typing>;
  more?: string;
}
export class Typing {
  private listener: Record<string, ITypingEventCallback[]> = {};
  readonly typingTimer: TypingTimer = new TypingTimer();

  get speed(): number {
    return this.ctx()?.typing()?.speed ?? 25;
  }
  get step(): number {
    return this.ctx()?.typing()?.step ?? 1;
  }
  get more(): string | undefined {
    return this.ctx()?.typing()?.more;
  }

  ctx: () => ContextService | undefined = () => (undefined);
  should: () => boolean = () => (true);
  mode: () => ETypingMode = () => (ETypingMode.Begin);
  update: <T = string | Node>(content: T, mode: ETypingMode, hasMore?: boolean) => void = () => {};
  completed: () => boolean = () => false;
  processing: () => boolean = () => {
    return this.typingTimer.processing;
  };
  timerState: () => ETypingTimerState = () => (this.typingTimer.state);
  pause: () => void = () => {
    if (this.should()) {
      this.typingTimer.pause();
      this.emit<ITypingPauseEvent>(ETypingEvent.Pause, {});
    }
  };
  resume: () => void = () => {
    if (this.should()) {
      this.typingTimer.resume();
      this.emit<ITypingResumeEvent>(ETypingEvent.Resume, {});
    }
  };
  stop: () => void = () => {
    if (this.should()) {
      this.typingTimer.stop();
      this.emit<ITypingStopEvent>(ETypingEvent.Stop, {});
    }
  }

  on<T, V = void>(name: string, callback: Callback<T, V>) {
    if (!this.listener[name]) {
      this.listener[name] = [];
    }
    this.listener[name].push({ type: ETypingEventCallback.On, callback });
    return this;
  }
  once<T, V = void>(name: string, callback: Callback<T, V>) {
    if (!this.listener[name]) {
      this.listener[name] = [];
    }
    this.listener[name].push({ type: ETypingEventCallback.Once, callback });
    return this;
  }
  emit<T, V = void>(name: string, event: T): V {
    let result: V = undefined as V;
    this.listener[name]?.forEach(ele => {
      result = (ele.callback as Callback<T, V>)(event);
      if (ele.type === ETypingEventCallback.Once) {
        this.off(name, (ele.callback as Callback<T, V>));
      }
    });
    return result;
  }
  off<T, V = void>(name: string, callback?: Callback<T, V>) {
    if (callback) {
      this.listener[name] = this.listener[name].filter(ele => ele.callback !== callback);
    } else {
      this.listener[name] = [];
    }
    return this;
  }
}
enum ETypingEventCallback {
  On = 'on',
  Once = 'once',
}
interface ITypingEventCallback {
  type: ETypingEventCallback;
  callback: Function;
}
export enum ETypingEvent {
  Pause = 'pause',
  Resume = 'resume',
  Stop = 'stop',
  Finish = 'finish',
}
export interface ITypingUpdateData<T = string | Node> {
  content: T;
  mode: ETypingMode;
  hasMore?: boolean;
}
export interface ITypingPauseEvent {}
export interface ITypingResumeEvent {}
export interface ITypingStopEvent {}
export interface ITypingFinishEvent {}