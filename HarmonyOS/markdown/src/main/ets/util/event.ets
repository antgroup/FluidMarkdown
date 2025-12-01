// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

type Any = string | number | boolean | object;
type Callback = <T>(param?: T) => void;

export class Event {
  private listeners: Record<string, Callback[]> = {};

  public on<T>(event: string, listener: (param?: T) => void) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(listener as Callback);
  }

  protected emit<T>(event: string, param?: T) {
    if (this.listeners[event]) {
      this.listeners[event].forEach((listener) => listener(param));
    }
  }
}