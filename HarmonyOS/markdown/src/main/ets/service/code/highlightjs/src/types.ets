// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

export interface HL {
  highlightAuto(code: string): HighlightResult
  highlight(code: string, options: HighlightOptions): HighlightResult
  getLanguage(language: string): Language | undefined
  addPlugin: (plugin: HLJSPlugin) => void
  removePlugin: (plugin: HLJSPlugin) => void
}
export interface Language {}
export interface HighlightOptions {
  language: string
  ignoreIllegals?: boolean
}
export interface HighlightResult {
  code?: string
  relevance : number
  value : string
  language? : string
  illegal : boolean
  errorRaised? : Error
}
export interface BeforeHighlightContext {
  code: string,
  language: string,
  result?: HighlightResult
}
export interface HLJSPlugin {
  'after:highlight'?: (result: HighlightResult) => void,
  'before:highlight'?: (context: BeforeHighlightContext) => void,
}