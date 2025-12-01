// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { StyledObject } from '../../render';
import { AnyNode, Element, Document, Text, isTag } from './domhandler';
import { parseDocument } from './htmlparser2';
import type { Engine } from '../../engine';

type StyledResult = StyledString | undefined;
interface IStyledUtil {
  engine: () => Engine | undefined;
}
interface IStyledUtilFrom extends IStyledUtil {
  didCreateStyled: (styled: StyledObject) => void;
}
export abstract class StyledUtil {
  static toStyled(content: string, option: IStyledUtil): StyledResult {
    try {
      const document = parseDocument(content);
      const root = StyledObject.root();
      fromNode(document, {
        engine: option.engine,
        didCreateStyled: (styled) => {
          root.attach(styled);
        },
      });
      return root.subStyledString(0);
    } catch (e) {
      return undefined;
    }
  }
}
const fromNode = (node: AnyNode, option: IStyledUtilFrom): void => {
  if (node instanceof Document) {
    fromDocument(node, option);
  } else if (node instanceof Text) {
    fromText(node, option);
  } else if (isTag(node)) {
    fromElement(node, option);
  }
}
const fromDocument = (document: Document, option: IStyledUtilFrom): void => {
  const styled = StyledObject.text('');
  option.didCreateStyled(styled);

  document.children.forEach(ele => fromNode(ele, {
    engine: option.engine,
    didCreateStyled: (_styled) => {
      styled.attach(_styled);
    },
  }));
}
const fromText = (text: Text, option: IStyledUtilFrom): void => {
  option.didCreateStyled(StyledObject.text(text.data));
}
const fromElement = (element: Element, option: IStyledUtilFrom): void => {
  const values = option.engine()?.css?.toStyled(element.attribs['style'] || '');
  const styled = StyledObject.text('', values);
  option.didCreateStyled(styled);

  element.children.forEach(ele => fromNode(ele, {
    engine: option.engine,
    didCreateStyled: (_styled) => {
      styled.attach(_styled);
    },
  }));
}