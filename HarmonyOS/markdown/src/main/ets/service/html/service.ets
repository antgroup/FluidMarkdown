// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { parseDocument, ElementType } from './htmlparser2';
import { render } from './dom-serializer';
import type { AnyNode } from './domhandler';
import { Element, isTag, Node, NodeWithChildren } from './domhandler';
import { EService, Service } from '../../engine/service';
import { Plugin } from '../../engine/plugin';
import { StyledUtil } from './styled';

interface IVisitor {
  on: (node: AnyNode) => boolean,
  filter?: (node: AnyNode) => boolean,
}
export class HtmlService extends Service {
  readonly type: EService = EService.HTML;
  add<T extends Plugin>(_plugin: T): void {}
  parse(_content: string) {
    return parseDocument(_content);
  }
  toElement(node?: Node | null) {
    return isTag(node) ? node as Element : undefined;
  }
  toStyled(content: string) {
    return StyledUtil.toStyled(content, {
      engine: () => this.engine?.deref(),
    });
  }
  render(node: AnyNode) {
    return render(node, {
      decodeEntities: false, selfClosingTags: true,
    });
  }
  traverse(node?: AnyNode, visitor?: IVisitor) {
    if (!node || !visitor) {
      return;
    }
    let canNext = true;
    if (visitor.filter) {
      if (visitor.filter(node)) {
        canNext = visitor.on(node);
      }
    } else {
      canNext = visitor.on(node);
    }
    if (!canNext) {
      return;
    }
    //  children
    if (node instanceof NodeWithChildren)
    node.children.forEach(ele => {
      this.traverse(ele, visitor);
    });
  }
}
export { ElementType, Element, isTag };