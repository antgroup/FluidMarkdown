// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { type Service, EService } from './service';
import type {
  AstService, CodeService, ContextService,
  HtmlService, ImageService,
  EventService, CssService, MathService,
} from '../service';
import type { ThemeService } from '../theme';
import type { RenderService } from '../render';

export enum EEngine {
  Unknown = 'unknown',
  Base = 'base',
  Global = 'global',
}
export interface IEngine {}
export abstract class Engine <
  Option extends IEngine = IEngine
> {
  readonly type: EEngine = EEngine.Unknown;
  readonly option?: Option;
  protected services: Map<EService, Service> = new Map();
  constructor(option?: Option) {
    this.option = option;
  }
  service<T extends Service = Service>(type: EService): T | undefined {
    return this.services.get(type) as T;
  }

  get ast() {
    return this.service<AstService>(EService.AST);
  }
  get code() {
    return this.service<CodeService>(EService.Code);
  }
  get ctx() {
    return this.service<ContextService>(EService.CTX);
  }
  get html() {
    return this.service<HtmlService>(EService.HTML);
  }
  get image() {
    return this.service<ImageService>(EService.Image);
  }
  get theme() {
    return this.service<ThemeService>(EService.Theme);
  }
  get render() {
    return this.service<RenderService>(EService.Render);
  }
  get event() {
    return this.service<EventService>(EService.Event);
  }
  get css() {
    return this.service<CssService>(EService.CSS);
  }
  get math() {
    return this.service<MathService>(EService.Math);
  }
}