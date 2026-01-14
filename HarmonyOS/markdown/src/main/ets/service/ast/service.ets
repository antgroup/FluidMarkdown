// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import {
  type MarkdownIt, markdown,
  plugin_footnote, plugin_emoji, plugin_sub, plugin_sup, plugin_taskList, plugin_katex,
  type IPluginKatexOption, type IPluginTaskListOption,
} from './markdown-it';
import { Program, Node, ENode, ELayout, Code, StyledContent, Fragment } from './node';
import { EService, Service } from '../../engine/service';
import { Plugin } from '../../engine/plugin';
import { CssService } from '../css';
import type { Declaration, Rule } from '../css/csstree';
import { newLog } from '../../util';

const log = newLog('AstService');

interface IResult {
  program: Program;
  content?: string;
}

export class AstService extends Service {
  private static gid: number = 0;
  readonly ID: number = AstService.gid++;
  readonly type: EService = EService.AST;
  private tail: Promise<IResult | void> = Promise.resolve();
  private count: number = 0;
  private plugins: AstServicePlugin[] = [];
  add<T extends Plugin = AstServicePlugin>(plugin: T): void {
    if (plugin instanceof AstServicePlugin) {
      this.plugins.push(plugin);
    } else {
      log.e(`${this.ID} add plugin error, not AstServicePlugin`);
    }
  }
  private get parsePlugin(): AstServicePlugin<IAstPluginParse> | undefined {
    return this.plugins.filter(ele => ele.type === EAstPlugin.Parse).pop();
  }
  parse(content: string): Promise<IResult> {
    this.count++;
    const tail = this.tail.then(async () => {
      this.parsePlugin?.handler?.willParse?.(content);

      const markdown_it = new markdown() as MarkdownIt;
      markdown_it.set({ html: true });
      markdown_it.disable(['html_block']);  // only support inline html

      const plugins = [
        plugin_footnote,
        plugin_emoji,
        plugin_sub,
        plugin_sup,
      ];
      plugins.forEach(ele => markdown_it.use(ele));

      markdown_it.use<IPluginTaskListOption>(plugin_taskList, { enabled: true });
      markdown_it.use<IPluginKatexOption>(plugin_katex, { throwOnError: false });

      const tokens = markdown_it.parse(content, new Object());
      const program = new Program(tokens, {
        engine: () => this.engine,
      });
      this.prepareFragment(program);
      program.document.createHash();
      this.prepareCodeBlock(program);

      const result: IResult = { program, content };

      this.parsePlugin?.handler?.didParse?.(result);

      return result;
    }).finally(() => {
      this.count--;
    });
    this.tail = tail;
    return tail;
  }
  get processing(): boolean {
    return this.count > 0;
  }
  private prepareFragment(program: Program) {
    if (!this.engine?.deref()?.ctx?.fragmentEnable) {
      log.i(`${this.ID} ast fragment is disabled`);
      return;
    }
    const blockMax = Number(this.engine?.deref()?.ctx?.fragmentBlockMax) || 10;
    const ignoreNodes: ENode[] = [ ENode.FootnoteDef ];
    log.i(`${this.ID} will prepare ast fragment. blockMax: ${this.engine?.deref()?.ctx?.fragmentBlockMax}`);
    const fragments: Fragment[] = [];
    const dequeue = () => {
      let fragment = fragments.slice(-1).pop();
      if (!fragment) {
        fragment = new Fragment();
        fragments.push(fragment);
      } else {
        let blockCount: number = 0;
        let child = fragment.first?.deref();
        while (child) {
          if (child.layout === ELayout.Block && !ignoreNodes.includes(child.type)) {
            blockCount++;
          }
          child = child.next?.deref();
        }
        if (blockCount >= blockMax) {
          fragment = new Fragment();
          fragments.push(fragment);
        }
      }
      return fragment;
    };
    let node = program.document.first?.deref();
    while (node) {
      const fragment = dequeue();
      fragment.append(node);
      node = program.document.first?.deref();
    }
    fragments.forEach(ele => {
      program.document.append(ele);
    });
    log.i(`${this.ID} did prepare ast fragment. fragments: ${fragments.length}`);
  }
  private prepareCodeBlock(program: Program) {
    const codes: Code[] = [];
    Node.traverse(program.document, {
      on: node => {
        codes.push(node as Code);
        return true;
      },
      filter: node => {
        return node.type === ENode.Code && node.layout === ELayout.Block;
      },
    });
    for (const code of codes) {
      if (code.content) {
        const page = this.engine?.deref()?.code?.parse4page(code.content, { language: code.language || '' });
        if (page) {
          const html = this.engine?.deref()?.html?.parse(page);
          const css = this.engine?.deref()?.code?.css;
          if (html && css) {
            this.engine?.deref()?.html?.traverse(html, {
              on: htmlNode => {
                const element = this.engine?.deref()?.html?.toElement(htmlNode);
                if (element) {
                  const cls = element.attribs['class']?.split(' ').filter(ele => ele.length > 0) || [];
                  if (cls && cls.length > 0) {
                    let style = element.attribs['style'] ? `${element.attribs['style']};` : '';
                    CssService.findAll<Rule>(css, rule => {
                      return rule.type === 'Rule';
                    }).forEach(rule => {
                      const matched = CssService.find(rule.prelude, prelude => {
                        if (prelude.type === 'ClassSelector') {
                          return cls.indexOf(prelude.name) !== -1;
                        }
                        return false;
                      });
                      if (matched) {
                        CssService.findAll<Declaration>(rule.block, block => {
                          return block.type === 'Declaration';
                        }).forEach(declaration => {
                          style = `${style} ${declaration.property}: ${CssService.generate(declaration.value)};`;
                        });
                      }
                    });
                    if (style.length > 0) {
                      element.attribs['style'] = `${style} font-size: 13;`;
                    }
                  }
                }
                return true;
              },
            });
            const adapted = this.engine?.deref()?.html?.render(html);
            if (adapted && adapted.length > 0) {
              const styled = new StyledContent();
              styled.createHash();
              styled.styled = this.engine?.deref()?.code?.styledFromHtml(adapted);
              program.nodes.push(styled);
              code.append(styled);
            }
          }
        }
      }
    }
  }
}

export interface IFragment {
  enable?: boolean;
  blockMax?: number;
}

export enum EAstPlugin {
  Unknown = 'unknown',
  Parse = 'parse',
}
export interface IAstPlugin {}
export interface IAstPluginParse extends IAstPlugin {
  willParse?: (content: string) => void;
  didParse?: (result: IResult) => void;
}
export abstract class AstServicePlugin <
  T extends IAstPlugin = IAstPlugin,
> extends Plugin {
  abstract readonly type: EAstPlugin;
  abstract readonly handler: T;
}

// export { Program, Node };