// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import type { Node } from '../../service/ast/node';
import type { StyledObject } from './styled-object';
import type { ITheme } from '../../theme';
import type { Engine } from '../../engine';
import Image from '@ohos.multimedia.image';
import type { IImageServiceRequest, IMathServiceRequest } from '../../service';
import { newLog } from '../../util';

const log = newLog('Styled');

export interface IStyled {
  readonly option: IStyledOption;
  readonly node?: Node;
}
export interface IStyledOption {
  node?: Node;
}
export interface IStyledBuild {
  readonly theme: ITheme;
  readonly engine: Engine;
  didCreateStyled: (styled: StyledObject) => void;
  willBuild?: (anchor: StyledObject) => void;
  didBuild?: (anchor: StyledObject) => void;
}

export interface IStyledSpan<T = StyledSpan> {
  onMeasure?: (
    span: T,
    measureInfo: CustomSpanMeasureInfo
  ) => CustomSpanMetrics;
  onDraw?: (
    span: T,
    context: DrawContext,
    drawInfo: CustomSpanDrawInfo
  ) => void;
}
export class StyledSpan extends CustomSpan {
  protected option: IStyledSpan;
  protected _metrics: CustomSpanMetrics = { width: 0, height: 0 };
  constructor(option: IStyledSpan) {
    super();
    this.option = option;
  }
  get metrics() {
    return this._metrics;
  }
  onMeasure(measureInfo: CustomSpanMeasureInfo): CustomSpanMetrics {
    if (this.option.onMeasure) {
      this._metrics = this.option.onMeasure(this, measureInfo);
    }
    return this.metrics;
  }
  onDraw(context: DrawContext, drawInfo: CustomSpanDrawInfo): void {
    if (this.option.onDraw) {
      this.option.onDraw(this, context, drawInfo);
    }
  }
}
export interface IStyledImageSpan<T = StyledImageSpan> extends IStyledSpan<T> {
  buildOption: IStyledBuild;
  request: IImageServiceRequest;
  onImageSourceRequested: (span: T) => void;
}
export class StyledImageSpan extends StyledSpan {
  imageSource?: Image.ImageSource;
  constructor(option: IStyledImageSpan) {
    super(option);
    const request = option.request;
    this.imageSource = option.buildOption.engine.image?.cache(request)?.imageSource;
    if (!this.imageSource) {
      option.buildOption.engine.image?.post(request).then(resp => {
        if (resp.imageSource) {
          this.imageSource = resp.imageSource;
          option.onImageSourceRequested(this);
        } else {
          log.w('image span response invalid. url: %s', request.url);
        }
      }).catch((e: Error) => {
        log.w('image span request error: %s url: %s', e.message, request.url);
      });
    }
  }
}
export interface IStyledMathSpan extends IStyledSpan<StyledMathSpan> {
  buildOption: IStyledBuild;
  request: IMathServiceRequest;
  onResourceLoaded: (span: StyledMathSpan) => void;
}
export class StyledMathSpan extends StyledSpan {
  imageSource?: Image.ImageSource;
  constructor(option: IStyledMathSpan) {
    super(option);
    this.imageSource = option.buildOption.engine.math?.cache(option.request);
    if (!this.imageSource) {
      option.buildOption.engine.math?.generate(option.request).then(v => {
        if (v.image) {
          this.imageSource = v.image;
          option.onResourceLoaded(this);
        } else {
          log.w('math span generate invalid image source. content: %s, errorMessage: %s', option.request.content, v.errorMessage);
        }
      }).catch((e: Error) => {
        log.w('math span generate error: %s content: %s', e.message, option.request.content);
      });
    }
  }
}