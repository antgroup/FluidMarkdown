// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import type { Node } from '../models';
import { Token } from '../../markdown-it';
import type { Program } from '../program';
import type { Engine } from '../../../../engine';

export enum EPlugin {
  Unknown = 'unknown',
  Node = 'node',
}
export abstract class Plugin <
P extends IPayload = IPayload,
R extends IResult = IResult,
C extends IContext = IContext,
> {
  readonly id: number = Plugin.gid();
  abstract readonly type: EPlugin;
  abstract readonly name: string;
  abstract should(payload?: P, context?: C): boolean;
  abstract on(payload?: P, context?: C): undefined | R;
  emit(payload?: P, context?: C) {
    if (!this.should(payload, context)) {
      return undefined;
    }
    return this.on(payload, context);
  }

  private static _gid: number = 0;
  private static gid() {
    return Plugin._gid++;
  }
}
export interface IPayload {}
export interface IContext {}
export interface IResult {}

export enum ENodeEvent {
  // @summary 节点创建
  Create = 'create',
  // @summary 节点添加到父节点完成
  DidAppend = 'did-append',
  // @summary 节点将要填充子节点
  WillFill = 'will-fill',
  // @summary 节点填充子节点完成
  DidFill = 'did-fill',
}
export interface INodeContext extends IContext {
  program: Program;
}
export interface INodePayload extends IPayload {
  event?: ENodeEvent;
  // @summary ENodeEvent.Create 时填充
  token?: FatToken;
  // @summary ENodeEvent.WillFill | ENodeEvent.DidFill 时填充
  node?: Node;
}
export interface INodeResult extends IResult {
  // @summary ENodeEvent.Create 时填充
  node?: Node;
}
export abstract class NodePlugin extends Plugin<INodePayload, INodeResult, INodeContext> {
  readonly type: EPlugin = EPlugin.Node;
  engine: () => WeakRef<Engine> | undefined = () => undefined;
  static fatToken(token: Token) {
    return new FatToken(token);
  }
}
class FatToken {
  readonly token: Token;
  readonly type: string;
  constructor(token: Token) {
    this.token = token;
    this.type = token.type.replace('_open', '').replace('_close', '');
  }
}