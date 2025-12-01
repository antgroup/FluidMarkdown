// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { EService, Service } from '../../engine/service';
import { Plugin } from '../../engine/plugin';
import {
  parse as cssParse, CssNode,
  type EnterOrLeaveFn, type WalkOptions, type FindFn,
  walk as cssWalk, find as cssFind, findAll as cssFindAll, generate as cssGenerate,
} from './csstree';
import { MDError, IMDResult } from '../../util';
import { StyledUtil } from './styled';

export class CssService extends Service {
  readonly type: EService = EService.CSS;
  add<T extends Plugin>(_plugin: T): void {}
  parse(content: string): IMDResult<CssNode> {
    try {
      const node = cssParse(content);
      return { data: node };
    } catch (e) {
      return { error: new MDError(e) };
    }
  }
  toStyled(style: string) {
    return StyledUtil.toStyled(style);
  }
  static walk(ast: CssNode, options: EnterOrLeaveFn | WalkOptions) {
    cssWalk(ast, options);
  }
  static find<T = CssNode>(ast: CssNode, fn: FindFn): T | undefined {
    return cssFind(ast, fn) as T ?? undefined;
  }
  static findAll<T = CssNode>(ast: CssNode, fn: FindFn): T[] {
    return cssFindAll(ast, fn) as T[];
  }
  static generate(ast: CssNode): string {
    return cssGenerate(ast);
  }
}

export { CssNode };