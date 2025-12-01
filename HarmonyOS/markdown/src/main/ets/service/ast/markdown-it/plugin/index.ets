// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import plugin_footnote from './markdown-it-footnote';
import plugin_emoji from './markdown-it-emoji';
import plugin_sub from './markdown-it-sub';
import plugin_sup from './markdown-it-sup';
import plugin_taskList from './markdown-it-task-lists';
import plugin_katex from './vscode-markdown-it-katex';

export const plugins = [
  plugin_footnote, plugin_emoji, plugin_sub, plugin_sup, plugin_taskList, plugin_katex
]
export { plugin_footnote, plugin_emoji, plugin_sub, plugin_sup, plugin_taskList, plugin_katex }

export * from './vscode-markdown-it-katex';
export * from './markdown-it-task-lists';