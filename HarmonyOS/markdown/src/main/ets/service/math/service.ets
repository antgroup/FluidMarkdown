// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Plugin } from '../../engine/plugin';
import { EService, Service } from '../../engine/service';
import Image from '@ohos.multimedia.image';

export class MathService extends Service {
  readonly type: EService = EService.Math;
  private store: Map<string, Image.ImageSource> = new Map();
  add<T extends Plugin>(_plugin: T): void {}
  private cacheKey(request: IMathServiceRequest): string {
    return `${request.hash}_${request.fontSize}_${request.fontColor}_${request.backgroundColor}`;
  }
  cache(request: IMathServiceRequest): Image.ImageSource | undefined {
    return this.store.get(this.cacheKey(request));
  }
  async generate(request: IMathServiceRequest): Promise<IMathServiceResponse> {
    return {
      success: false,
      errorMessage: 'unsupport',
    }
  }
}
export interface IMathServiceRequest {
  content: string;
  hash?: string;
  fontSize?: number;   //  px
  fontColor?: number;
  backgroundColor?: number;
}
export interface IMathServiceResponse {
  success: boolean;
  image?: Image.ImageSource;
  errorMessage?: string;
}