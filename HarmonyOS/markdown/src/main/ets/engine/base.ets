// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { IEngine, Engine, EEngine } from './engine';
import {
  AstService, CodeService, ContextService,
  HtmlService, ImageService,
  EventService, CssService, MathService,
} from '../service';
import { ThemeService } from '../theme';
import { RenderService } from '../render';

interface IBaseEngine extends IEngine {}
export class BaseEngine extends Engine<IBaseEngine> {
  readonly type: EEngine = EEngine.Base;
  constructor(option?: IBaseEngine) {
    super(option);
    [
      new AstService(this),
      new CodeService(this),
      new ContextService(this),
      new HtmlService(this),
      new ImageService(this),
      new ThemeService(this),
      new RenderService(this),
      new EventService(this),
      new CssService(this),
      new MathService(this),
    ].forEach(ele => this.services.set(ele.type, ele));
  }
}