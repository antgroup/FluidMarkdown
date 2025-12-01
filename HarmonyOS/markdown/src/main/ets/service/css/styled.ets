// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { parse, walk, generate } from './csstree';
import { StyledValue, StyledTextValue } from '../../render';
import { MDLength } from '../../util';

export abstract class StyledUtil {
  static toStyled(css: string): StyledValue[] {
    try {
      const store = new StyledStore();
      const ast = parse(css, { context: 'declarationList' });
      walk(ast, node => {
        if (node.type === 'Declaration') {
          store.fill(node.property, generate(node.value));
        }
      });
      return store.values;
    } catch (e) {
      return [];
    }
  }
}
class StyledStore {
  private _text?: StyledTextValue;
  private funcs: Record<string, Callback<string, void>> = {
    'color': (value: string) => {
      this.text.option.fontColor = value;
    },
    'font-size': (value: string) => {
      const num = Number(value);
      if (num === 0 || !!num) {
        this.text.option.fontSize = MDLength.vp(num);
      } else {
        this.text.option.fontSize = MDLength.length2vp(value);
      }
    },
    'font-weight': (value: string) => {
      this.text.option.fontWeight = value;
    },
    'font-style': (value: string) => {
      if (value === 'italic') {
        this.text.option.fontStyle = FontStyle.Italic;
      }
    },
  };
  get values(): StyledValue[] {
    const values: StyledValue[] = [];
    if (this._text) {
      values.push(this._text);
    }
    return values;
  }
  get text(): StyledTextValue {
    if (!this._text) {
      this._text = new StyledTextValue();
    }
    return this._text;
  }
  fill(property: string, value: string) {
    this.funcs[property]?.(value);
  }
}