// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Token } from '../markdown-it';
import * as M from './models';
import { ENodeEvent, NodePlugin, BuildIn } from './plugin';
import type { Engine } from '../../../engine';

interface IProgram {
  engine: () => WeakRef<Engine> | undefined;
}
export class Program {
  nodes: M.Node[] = [];
  private stacks: M.Node[] = [];
  private option: IProgram;
  readonly document: M.Document;
  private nodePlugins: NodePlugin[] = BuildIn.plugins();

  constructor(tokens: Token[], option: IProgram) {
    this.option = option;
    this.nodePlugins.forEach(ele => {
      ele.engine = () => {
        return this.option.engine();
      };
    });

    M.Node.resetID();
    this.document = new M.Document(tokens);

    this.push(this.document);
    const meet = (token: Token) => {
      const node = this.create(token);
      if (node) {

        this.nodes.push(node);
        node.on<M.Node>('did-remove-node', _node => {
          if (_node) {
            this.nodes = this.nodes.filter(ele => ele !== _node);
          }
        });

        if (token.nesting === 1) {  //  open
          this.append(node);
          this.push(node);
        } else if (token.nesting === -1) {  //  close
          this.pop();
        } else if (node.state === M.EState.Open) {
          this.append(node);
          this.push(node);
        } else if (node.state === M.EState.Close) {
          this.pop();
        } else {
          this.append(node);
        }

        if (token.children) {
          this.push(node);
          token.children?.forEach(ele => {
            meet(ele);
          });
          this.pop();
        }
      }
    };
    tokens.forEach(ele => {
      meet(ele);
    });
    this.pop();
  }
  private append(node: M.Node) {
    this.current.append(node);
    this.nodePlugins.forEach(ele => {
      ele.emit({ event: ENodeEvent.DidAppend, node }, { program: this });
    });
  }
  private push(node: M.Node) {
    this.nodePlugins.forEach(ele => {
      ele.emit({ event: ENodeEvent.WillFill, node }, { program: this });
    });
    this.stacks.push(node);
  }
  private pop() {
    const node = this.stacks.pop();
    this.nodePlugins.forEach(ele => {
      ele.emit({ event: ENodeEvent.DidFill, node }, { program: this });
    });
  }
  get current(): M.Node {
    return this.stacks[this.stacks.length - 1];
  }
  private create(token: Token): M.Node | undefined {
    const fatToken = NodePlugin.fatToken(token);
    let node: M.Node | undefined = undefined;
    for (const ele of this.nodePlugins) {
      const _node = ele.emit({
        event: ENodeEvent.Create,
        token: fatToken,
      }, {
        program: this,
      })?.node;
      if (_node) {
        node = _node;
        break;
      }
    }
    if (node) {
      node.token = token;
    }
    return node;
  }
}