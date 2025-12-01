// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Plugin } from '../../engine/plugin';
import { EService, Service } from '../../engine/service';
import { FileService } from '../file';
import Http from '@ohos.net.http';
import Image from '@ohos.multimedia.image';

export class ImageServiceError extends Error {
  code?: number;
  domain?: string;
  constructor(message: string, code?: number, domain?: string) {
    super(message);
    this.code = code;
    this.domain = domain;
  }
}
export interface IImageServiceRequest {
  url: string;
}
export interface IImageServiceResponse {
  imageSource?: Image.ImageSource;
}
export class ImageService extends Service {
  readonly type: EService = EService.Image;
  private store: Map<string, IImageServiceResponse> = new Map();
  add<T extends Plugin>(_plugin: T): void {}
  private storeKey(request: IImageServiceRequest): string {
    return request.url;
  }
  cache(request: IImageServiceRequest): IImageServiceResponse | undefined {
    return this.store.get(this.storeKey(request));
  }
  async post(request: IImageServiceRequest): Promise<IImageServiceResponse> {
    const client = Http.createHttp();
    try {
      const resp = await client.request(request.url, { method: Http.RequestMethod.GET });
      if (resp.responseCode !== 200) {
        throw new ImageServiceError(
          resp.resultType === Http.HttpDataType.STRING ? resp.result as string : 'http request failed',
          resp.responseCode
        );
      }
      if (resp.resultType !== Http.HttpDataType.ARRAY_BUFFER) {
        throw new ImageServiceError(
          'response type is not array buffer',
          -1
        )
      }
      const response: IImageServiceResponse = { imageSource: Image.createImageSource(resp.result as ArrayBuffer) };
      this.store.set(this.storeKey(request), response);
      return response;
    } catch (e) {
      throw new ImageServiceError(e.message, e.code, e.domain);
    } finally {
      client.destroy();
    }
  }
  load(fileName: string): Image.ImageSource | undefined {
    const content = this.engine?.deref()?.ctx?.resourceManager?.
                    getRawFileContentSync(`markdown/${fileName}`);
    if (content) {
      return Image.createImageSource(content.buffer);
    }
    return undefined;
  }
  private get fileService() {
    return this.engine?.deref()?.service<FileService>(EService.File);
  }
}