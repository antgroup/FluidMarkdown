// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { hilog } from "@kit.PerformanceAnalysisKit";

const TAG = '[markdown]';
const DOMAIN = 0x0001;
type Any = string | number | null | undefined | boolean | object;

interface ILog {
  d: (format: string, ...args: Any[]) => void,
  i: (format: string, ...args: Any[]) => void,
  w: (format: string, ...args: Any[]) => void,
  e: (format: string, ...args: Any[]) => void,
  tag: (tag: string, freeze?: boolean) => ILog,
  domain: (domain: number, freeze?: boolean) => ILog,
}
class Log implements ILog {
  private _tag_default: string = TAG;
  private _domain_default: number = DOMAIN;
  private _tag: string = TAG;
  private _domain: number = DOMAIN;
  private reset() {
    this._tag = this._tag_default;
    this._domain = this._domain_default;
  }
  _d(...args: Any[]) {
    console.debug(this._tag, ...args);
    this.reset();
  }
  _i(...args: Any[]) {
    console.info(this._tag, ...args);
    this.reset();
  }
  _w(...args: Any[]) {
    console.warn(this._tag, ...args);
    this.reset();
  }
  _e(...args: Any[]) {
    console.error(this._tag, ...args);
    this.reset();
  }
  d(format: string, ...args: Any[]) {
    hilog.debug(this._domain, this._tag, format, ...args);
    this.reset();
  }
  i(format: string, ...args: Any[]) {
    hilog.info(this._domain, this._tag, format, ...args);
    this.reset();
  }
  w(format: string, ...args: Any[]) {
    hilog.warn(this._domain, this._tag, format, ...args);
    this.reset();
  }
  e(format: string, ...args: Any[]) {
    hilog.error(this._domain, this._tag, format, ...args);
    this.reset();
  }
  tag(tag: string, freeze: boolean = false) {
    this._tag = tag;
    if (freeze) {
      this._tag_default = tag;
    }
    return this;
  }
  domain(domain: number, freeze: boolean = false) {
    this._domain = domain;
    if (freeze) {
      this._domain_default = domain;
    }
    return this;
  }
}

export const log = new Log();
export const newLog = (tag?: string, domain?: number) => {
  const _log = new Log();
  if (tag) {
    _log.tag(tag, true);
  }
  if (domain !== undefined) {
    _log.domain(domain, true);
  }
  return _log;
}