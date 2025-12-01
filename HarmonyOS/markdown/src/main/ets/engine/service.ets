// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import type { Plugin } from './plugin';
import type { Engine } from './engine';

export enum EService {
  AST = 'ast',
  Code = 'code',
  CTX = 'ctx',
  HTML = 'html',
  Image = 'image',
  Latex = 'latex',
  Theme = 'theme',
  File = 'file',
  Render = 'render',
  Event = 'event',
  Typing = 'typing',
  CSS = 'css',
  Math = 'math',
}
export abstract class Service {
  readonly engine?: WeakRef<Engine>;
  constructor(engine?: Engine) {
    this.engine = engine ? new WeakRef(engine) : undefined;
  }
  abstract readonly type: EService;
  abstract add<T extends Plugin>(plugin: T): void;
}