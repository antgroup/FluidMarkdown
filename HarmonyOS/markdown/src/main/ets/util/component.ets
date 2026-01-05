// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

interface IComponentConstant {
  THEME: string,
  SHARED_ENGINE: string,
}
export const K_COMPONENT: IComponentConstant = {
  THEME: '__const.component.theme',
  SHARED_ENGINE: '__const.component.engine',
};
export enum EMarkdownMode {
  Normal = 'normal',
  Typing = 'typing',
}
export enum EMarkdownMainBotEvent {
  ScrollBegin = 'mainBotScrollBegin',
  ScrollEnd = 'mainBotScrollEnd',
  StopTyping = 'mainBotStopTyping',
}