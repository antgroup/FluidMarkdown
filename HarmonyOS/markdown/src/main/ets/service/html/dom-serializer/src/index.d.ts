// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import type { AnyNode } from "../../domhandler/src";
export interface DomSerializerOptions {
    /**
     * Print an empty attribute's value.
     *
     * @default xmlMode
     * @example With <code>emptyAttrs: false</code>: <code>&lt;input checked&gt;</code>
     * @example With <code>emptyAttrs: true</code>: <code>&lt;input checked=""&gt;</code>
     */
    emptyAttrs?: boolean;
    /**
     * Print self-closing tags for tags without contents. If `xmlMode` is set, this will apply to all tags.
     * Otherwise, only tags that are defined as self-closing in the HTML specification will be printed as such.
     *
     * @default xmlMode
     * @example With <code>selfClosingTags: false</code>: <code>&lt;foo&gt;&lt;/foo&gt;&lt;br&gt;&lt;/br&gt;</code>
     * @example With <code>xmlMode: true</code> and <code>selfClosingTags: true</code>: <code>&lt;foo/&gt;&lt;br/&gt;</code>
     * @example With <code>xmlMode: false</code> and <code>selfClosingTags: true</code>: <code>&lt;foo&gt;&lt;/foo&gt;&lt;br /&gt;</code>
     */
    selfClosingTags?: boolean;
    /**
     * Treat the input as an XML document; enables the `emptyAttrs` and `selfClosingTags` options.
     *
     * If the value is `"foreign"`, it will try to correct mixed-case attribute names.
     *
     * @default false
     */
    xmlMode?: boolean | "foreign";
    /**
     * Encode characters that are either reserved in HTML or XML.
     *
     * If `xmlMode` is `true` or the value not `'utf8'`, characters outside of the utf8 range will be encoded as well.
     *
     * @default `decodeEntities`
     */
    encodeEntities?: boolean | "utf8";
    /**
     * Option inherited from parsing; will be used as the default value for `encodeEntities`.
     *
     * @default true
     */
    decodeEntities?: boolean;
}
/**
 * Renders a DOM node or an array of DOM nodes to a string.
 *
 * Can be thought of as the equivalent of the `outerHTML` of the passed node(s).
 *
 * @param node Node to be rendered.
 * @param options Changes serialization behavior
 */
export declare function render(node: AnyNode | ArrayLike<AnyNode>, options?: DomSerializerOptions): string;
export default render;
//# sourceMappingURL=index.d.ts.map