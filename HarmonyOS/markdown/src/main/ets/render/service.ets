// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Service, EService, Plugin } from '../engine';
import type { Styled, IStyledBuild } from './styled';
import { newLog } from '../util';

const log = newLog('RenderService');

export class RenderService extends Service {
  readonly type: EService = EService.Render;
  private plugins: RenderServicePlugin[] = [];
  add<T extends Plugin = RenderServicePlugin>(plugin: T): void {
    if (plugin instanceof RenderServicePlugin) {
      this.plugins.push(plugin);
    } else {
      log.e(`add plugin error, not RenderServicePlugin`);
    }
  }
  styledBuildingPlugin(styled: Styled, buildOption: IStyledBuild): RenderServicePlugin<IRenderPluginStyledBuilding> | undefined {
    for (const ele of this.plugins) {
      if (ele.type === ERenderPlugin.StyledBuilding) {
        const plugin = ele as RenderServicePlugin<IRenderPluginStyledBuilding>;
        if (plugin.handler.should(styled, buildOption)) {
          return plugin;
        }
      }
    }
    return undefined;
  }
}

export enum ERenderPlugin {
  Unknown = 'unknown',
  StyledBuilding = 'styled_building',
}
export interface IRenderPlugin {}
export interface IRenderPluginStyledBuilding extends IRenderPlugin {
  should: (styled: Styled, buildOption: IStyledBuild) => boolean;
  building: (styled: Styled, buildOption: IStyledBuild) => void;
}
export abstract class RenderServicePlugin <
  T extends IRenderPlugin = IRenderPlugin
> extends Plugin {
  abstract readonly type: ERenderPlugin;
  abstract readonly handler: T;
}