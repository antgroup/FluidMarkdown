// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Parser, type ParserOptions } from "./Parser";
export type { Handler, ParserOptions } from "./Parser";
export { Parser } from "./Parser";
import { type DomHandlerOptions, type ChildNode, type Element, type Document } from "../../domhandler/src";
export { DomHandler, DomHandler as DefaultHandler, type DomHandlerOptions, } from "../../domhandler/src";
export type Options = ParserOptions & DomHandlerOptions;
/**
 * Parses the data, returns the resulting document.
 *
 * @param data The data that should be parsed.
 * @param options Optional options for the parser and DOM handler.
 */
export declare function parseDocument(data: string, options?: Options): Document;
/**
 * Parses data, returns an array of the root nodes.
 *
 * Note that the root nodes still have a `Document` node as their parent.
 * Use `parseDocument` to get the `Document` node instead.
 *
 * @param data The data that should be parsed.
 * @param options Optional options for the parser and DOM handler.
 * @deprecated Use `parseDocument` instead.
 */
export declare function parseDOM(data: string, options?: Options): ChildNode[];
/**
 * Creates a parser instance, with an attached DOM handler.
 *
 * @param callback A callback that will be called once parsing has been completed, with the resulting document.
 * @param options Optional options for the parser and DOM handler.
 * @param elementCallback An optional callback that will be called every time a tag has been completed inside of the DOM.
 */
export declare function createDocumentStream(callback: (error: Error | null, document: Document) => void, options?: Options, elementCallback?: (element: Element) => void): Parser;
/**
 * Creates a parser instance, with an attached DOM handler.
 *
 * @param callback A callback that will be called once parsing has been completed, with an array of root nodes.
 * @param options Optional options for the parser and DOM handler.
 * @param elementCallback An optional callback that will be called every time a tag has been completed inside of the DOM.
 * @deprecated Use `createDocumentStream` instead.
 */
export declare function createDomStream(callback: (error: Error | null, dom: ChildNode[]) => void, options?: Options, elementCallback?: (element: Element) => void): Parser;
export { default as Tokenizer, type Callbacks as TokenizerCallbacks, QuoteType, } from "./Tokenizer.js";
export * as ElementType from "../../domelementtype/src";
import { type Feed } from "../../domutils/src";
export { getFeed, type Feed } from "../../domutils/src";
/**
 * Parse a feed.
 *
 * @param feed The feed that should be parsed, as a string.
 * @param options Optionally, options for parsing. When using this, you should set `xmlMode` to `true`.
 */
export declare function parseFeed(feed: string, options?: Options): Feed | null;
export * as DomUtils from "../../domutils/src";
//# sourceMappingURL=index.d.ts.map