// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

/**
 * highlight.js
 * @home   : https://github.com/highlightjs/highlight.js
 * @branch : master
 * @commit : 5697ae5187746c24732e62cd625f3f83004a44ce
 */

import type { HL } from './src/types';
import { hljs } from './src/highlight';

const hl: HL = hljs;
export { hl };
export * from './src/types';
