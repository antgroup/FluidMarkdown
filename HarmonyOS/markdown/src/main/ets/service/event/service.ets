// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { EService, Service } from '../../engine/service';
import { Plugin } from '../../engine/plugin';
import type { Node } from '../ast';
import type {
  ITextComponentEvent,
  ITextComponentSelectionChangeEvent,
  ITextComponentSelectionOption,
  ITableComponentEvent,
  ITableComponentActionClickEvent,
  IContentBoxBar,
  ICodeComponentEvent,
  ICodeComponentActionClickEvent,
} from '../../render';

interface IClickEvent {
  node: Node;
  event: ClickEvent;
}
interface ILongPressEvent {
  node: Node;
  event: GestureEvent;
}
export class EventService extends Service {
  readonly type: EService = EService.Event;
  onClick?: Callback<IClickEvent>;
  onLongPress?: Callback<ILongPressEvent>;
  onTextComponentSelectionChange?: Callback<ITextComponentSelectionChangeEvent>;
  onTextComponentSelectionOption?: Callback<ITextComponentEvent, ITextComponentSelectionOption>;
  onTableComponentActionClick?: Callback<ITableComponentActionClickEvent>;
  onTableComponentBarOption?: Callback<ITableComponentEvent, IContentBoxBar | undefined>;
  onCodeComponentActionClick?: Callback<ICodeComponentActionClickEvent>;
  onCodeComponentBarOption?: Callback<ICodeComponentEvent, IContentBoxBar | undefined>;
  add<T extends Plugin>(plugin: T): void {}

  invokeClickGesture(node: Node, event: ClickEvent) {
    this.onClick?.({ node, event });
  }
  invokeLongPressGesture(node: Node, event: GestureEvent) {
    this.onLongPress?.({ node, event });
  }
  invokeTextSelectionChange(event: ITextComponentSelectionChangeEvent) {
    this.onTextComponentSelectionChange?.(event);
  }
  invokeTextSelectionOption(event: ITextComponentEvent): ITextComponentSelectionOption {
    return this.onTextComponentSelectionOption?.(event) ?? {};
  }
  invokeTableActionClick(event: ITableComponentActionClickEvent) {
    this.onTableComponentActionClick?.(event);
  }
  invokeTableBarOption(event: ITableComponentEvent): IContentBoxBar | undefined {
    return this.onTableComponentBarOption?.(event);
  }
  invokeCodeActionClick(event: ICodeComponentActionClickEvent) {
    this.onCodeComponentActionClick?.(event);
  }
  invokeCodeBarOption(event: ICodeComponentEvent): IContentBoxBar | undefined {
    return this.onCodeComponentBarOption?.(event);
  }
}