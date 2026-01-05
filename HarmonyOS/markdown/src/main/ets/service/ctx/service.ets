// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import type { MeasureOptions, UIContext } from '@kit.ArkUI';
import { EService, Service } from '../../engine/service';
import { Plugin } from '../../engine/plugin';
import { EMarkdownMode } from '../../util';
import { type ITyping, type TextContentController } from '../../render';
import type { IFragment } from '../ast';

export class ContextService extends Service {
  readonly type: EService = EService.CTX;
  ctx?: UIContext;

  markdownMode: () => EMarkdownMode = () => EMarkdownMode.Normal;
  typing: () => ITyping = () => ({});
  textContentController: () => TextContentController | undefined = () => undefined;

  fragment: () => IFragment | undefined = () => undefined;
  get fragmentEnable(): boolean {
    return this.fragment()?.enable ?? true;
  }
  get fragmentBlockMax(): number {
    return Number(this.fragment()?.blockMax) || 10;
  }

  add<T extends Plugin>(_plugin: T): void {
  }
  get resourceManager() {
    return this.ctx?.getHostContext()?.resourceManager;
  }
  measureTextWidth(option: IContextServiceMeasureText) {
    return this.ctx?.getMeasureUtils()?.measureText({
      textContent: option.textContent,
      fontSize: option.fontSize ?? (option.textStyle?.fontSize !== undefined ? `${option.textStyle?.fontSize}vp` : undefined),
      fontWeight: option.fontWeight ?? option.textStyle?.fontWeight,
      fontStyle: option.fontStyle ?? option.textStyle?.fontStyle,
      fontFamily: option.fontFamily ?? option.textStyle?.fontFamily,
      letterSpacing: option.letterSpacing ?? (option.letterSpacingStyle?.letterSpacing !== undefined ? `${option.letterSpacingStyle?.letterSpacing}vp` : undefined),
      lineHeight: option.lineHeight ?? (option.lineHeightStyle?.lineHeight !== undefined ? `${option.lineHeightStyle?.lineHeight}vp` : undefined),
      maxLines: option.maxLines,
      textAlign: option.textAlign,
      constraintWidth: option.constraintWidth,
      overflow: option.overflow,
      baselineOffset: option.baselineOffset,
      textCase: option.textCase,
      textIndent: option.textIndent,
      wordBreak: option.wordBreak,
    });
  }
  measureTextSize(option: IContextServiceMeasureText) {
    return this.ctx?.getMeasureUtils()?.measureTextSize({
      textContent: option.textContent,
      fontSize: option.fontSize ?? (option.textStyle?.fontSize !== undefined ? `${option.textStyle?.fontSize}vp` : undefined),
      fontWeight: option.fontWeight ?? option.textStyle?.fontWeight,
      fontStyle: option.fontStyle ?? option.textStyle?.fontStyle,
      fontFamily: option.fontFamily ?? option.textStyle?.fontFamily,
      letterSpacing: option.letterSpacing ?? (option.letterSpacingStyle?.letterSpacing !== undefined ? `${option.letterSpacingStyle?.letterSpacing}vp` : undefined),
      lineHeight: option.lineHeight ?? (option.lineHeightStyle?.lineHeight !== undefined ? `${option.lineHeightStyle?.lineHeight}vp` : undefined),
      maxLines: option.maxLines,
      textAlign: option.textAlign,
      constraintWidth: option.constraintWidth,
      overflow: option.overflow,
      baselineOffset: option.baselineOffset,
      textCase: option.textCase,
      textIndent: option.textIndent,
      wordBreak: option.wordBreak,
    });
  }
}
export interface IContextServiceMeasureText extends MeasureOptions {
  textStyle?: TextStyle,
  letterSpacingStyle?: LetterSpacingStyle,
  lineHeightStyle?: LineHeightStyle,
}