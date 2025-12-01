// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

type EncodeTrieNode = string | {
    v?: string;
    n: number | Map<number, EncodeTrieNode>;
    o?: string;
};
export declare const htmlTrie: Map<number, EncodeTrieNode>;
export {};
//# sourceMappingURL=encode-html.d.ts.map