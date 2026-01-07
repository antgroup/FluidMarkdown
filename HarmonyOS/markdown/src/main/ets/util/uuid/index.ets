// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

/**
 * uuid
 * @home   : https://github.com/uuidjs/uuid
 * @branch : master
 * @commit : 0423d49df2dc8efc300c804731d25f4d7e0fccc4
 */

import * as UUID from './src';

export abstract class MDUuid {
  static md5(content: string): string {
    return UUID.v5(content, UUID.NIL);
  }
}

export * from './src';