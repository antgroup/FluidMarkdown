// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

/**
 * markdown-it
 * @home   : https://github.com/markdown-it/markdown-it
 * @branch : master
 * @commit : 0fe7ccb4b7f30236fb05f623be6924961d296d3d
 */
import markdown, { config } from './src/markdown-it';

export * from './src/types';
export { markdown, config };
export * from './plugin';