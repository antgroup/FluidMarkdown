// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

/**
 * vscode-markdown-it-katex
 * @home   : https://github.com/microsoft/vscode-markdown-it-katex
 * @branch : master
 * @commit : efd01d8e61b4aca4d8b1489d15dd29f641663119
 */

import plugin from './vscode-markdown-it-katex';
export default plugin;

export interface IPluginKatexOption {
  throwOnError?: boolean;
}