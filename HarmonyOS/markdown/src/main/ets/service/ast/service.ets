// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import {
  type MarkdownIt, markdown,
  plugin_footnote, plugin_emoji, plugin_sub, plugin_sup, plugin_taskList, plugin_katex,
  type IPluginKatexOption, type IPluginTaskListOption,
} from './markdown-it';
import { Program, Node, ENode, ELayout, Code, StyledContent } from './node';
import { EService, Service } from '../../engine/service';
import { Plugin } from '../../engine/plugin';
import { CssService } from '../css';
import type { Declaration, Rule } from '../css/csstree';

interface IResult {
  program: Program;
}

export class AstService extends Service {
  readonly type: EService = EService.AST;
  add<T extends Plugin>(_plugin: T): void {

  }
  async parse(content: string): Promise<IResult> {
    const markdown_it = markdown() as MarkdownIt;
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
    await program.document.createHash();
    await this.prepareCodeBlock(program);
    return { program }
  }
  private async prepareCodeBlock(program: Program) {
    await Node.traverseAsync(program.document, {
      on: async (node) => {
        const code = node as Code;
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
                await styled.createHash();
                styled.styled = await this.engine?.deref()?.code?.styledFromHtml(adapted);
                program.nodes.push(styled);
                code.append(styled);
              }
            }
          }
        }
        return true;
      },
      filter: async (node) => {
        return node.type === ENode.Code && node.layout === ELayout.Block;
      }
    })
  }
}

// export { Program, Node };