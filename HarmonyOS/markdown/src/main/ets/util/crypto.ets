// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';

export abstract class MDCrypto {
  static async md5(content?: string): Promise<string | undefined> {
    if (content) {
      try {
        const hash = cryptoFramework.createMd('MD5');
        await hash.update({
          data: new Uint8Array(buffer.from(content, 'utf-8').buffer)
        });
        return Array.from( (await hash.digest()).data )
          .map(ele => ele.toString(16).padStart(2, '0'))
          .join('');
      } catch (e) {
        return undefined;
      }
    }
    return undefined;
  }
}