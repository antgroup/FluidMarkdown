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

interface ILogInfo {
  domain: number,
  tag: string,
  format: string,
  args: Any[],
  isHilog: boolean,
}
export enum ELog {
  Debug = 'debug',
  Info = 'info',
  Warn = 'warn',
  Error = 'error',
}
export class Log implements ILog {
  private _tag_default: string = TAG;
  private _domain_default: number = DOMAIN;
  private _tag: string = TAG;
  private _domain: number = DOMAIN;
  private reset() {
    this._tag = this._tag_default;
    this._domain = this._domain_default;
  }
  private static __on?: (level: ELog, message: string, info: ILogInfo) => boolean | void;
  private static _on(isHilog: boolean, level: ELog, domain: number, tag: string, format: string, ...args: Any[]): boolean {
    if (Log.__on) {
      let message = `[fluid-markdown|${tag}] ${format}`;
      args.forEach(ele => {
        message += ` ${ele}`;
      });
      const should = Log.__on(level, message, { domain, tag, format, args, isHilog });
      if (typeof should === 'boolean') {
        return should;
      }
    }
    return true;
  }
  /**
   * handle log
   * @param handler return true to enable fluid-markdown output message, false to disable. default is true.
   */
  static set on(handler: (level: ELog, message: string, info: ILogInfo) => boolean | void) {
    if (!Log.__on) {
      Log.__on = handler;
    }
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
    if (Log._on(true, ELog.Debug, this._domain, this._tag, format, ...args)) {
      hilog.debug(this._domain, this._tag, format, ...args);
    }
    this.reset();
  }
  i(format: string, ...args: Any[]) {
    if (Log._on(true, ELog.Info, this._domain, this._tag, format, ...args)) {
      hilog.info(this._domain, this._tag, format, ...args);
    }
    this.reset();
  }
  w(format: string, ...args: Any[]) {
    if (Log._on(true, ELog.Warn, this._domain, this._tag, format, ...args)) {
      hilog.warn(this._domain, this._tag, format, ...args);
    }
    this.reset();
  }
  e(format: string, ...args: Any[]) {
    if (Log._on(true, ELog.Error, this._domain, this._tag, format, ...args)) {
      hilog.error(this._domain, this._tag, format, ...args);
    }
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