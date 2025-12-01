// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Service, EService, Plugin } from '../engine';

export class RenderService extends Service {
  readonly type: EService = EService.Render;
  add<T extends Plugin>(plugin: T): void {}
}