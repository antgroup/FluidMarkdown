// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { ENodeEvent, INodePayload, INodeResult, NodePlugin, INodeContext } from './plugin';
import { Code,
  EAlignment,
  ELayout,
  ELineBreak,
  EList, EListItem,
  Emoji,
  ENode,
  EState,
  ETableItem,
  FootnoteDef,
  FootnoteRef,
  Heading,
  HtmlTag,
  Image,
  LineBreak,
  Math,
  Link, List, ListItem, Node,
  TableItem } from '../models';

class QuotePlugin extends NodePlugin {
  readonly name = 'quote';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'blockquote') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.Quote, layout: ELayout.Block }) };
    }
    return undefined;
  }
}
class HeadingPlugin extends NodePlugin {
  readonly name = 'heading';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'heading') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new Heading();
      const level = parseInt(payload?.token?.token?.tag?.substring(1) || '');
      if (!isNaN(level)) {
        node.level = level;
      }
      return { node };
    }
    return undefined;
  }
}
class ParagraphPlugin extends NodePlugin {
  readonly name = 'paragraph';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'paragraph') {
      return true;
    }
    if (payload?.event === ENodeEvent.DidFill && payload?.node?.type === ENode.Paragraph) {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.Paragraph, layout: ELayout.Block, hidden: payload?.token?.token?.hidden }) };
    }
    return undefined;
  }
}
class CodePlugin extends NodePlugin {
  readonly name = 'code';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create) {
      if (payload?.token?.type === 'code_block' ||
          payload?.token?.type === 'fence' ||
          payload?.token?.type === 'code_inline') {
        return true;
      }
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new Code({
        layout: payload?.token?.type === 'code_inline' ? ELayout.Inline : ELayout.Block,
        content: payload?.token?.token.content,
      });
      node.language = payload?.token?.token.info;
      return { node }
    }
    return undefined;
  }
}
class ThematicBreakPlugin extends NodePlugin {
  readonly name = 'thematic_break';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'hr') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.ThematicBreak, layout: ELayout.Block }) };
    }
    return undefined;
  }
}
class ListPlugin extends NodePlugin {
  readonly name = 'list';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create) {
      if (payload?.token?.type === 'bullet_list' ||
          payload?.token?.type === 'ordered_list') {
        return true;
      }
    }
    if (payload?.event === ENodeEvent.DidFill) {
      if (payload?.node?.type === ENode.List) {
        return true;
      }
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new List();
      if (payload?.token?.type === 'ordered_list') {
        node.listType = EList.Ordered;
      } else if (payload?.token?.type === 'bullet_list') {
        const task = payload?.token?.token.attrs?.filter(ele => {
          if (ele.length > 1) {
            if (ele[0] === 'class' && /contains-task-list/.test(ele[1])) {
              return true;
            }
          }
          return false;
        });
        if (task && task.length > 0) {
          node.listType = EList.Task;
        } else {
          node.listType = EList.Bullet;
        }
      }
      return { node }
    }
    if (payload?.event === ENodeEvent.DidFill) {
      if (payload?.node?.type === ENode.List) {
        const listType = (payload?.node as List).listType;
        (payload.node as List).children.filter(ele => {
          return ele.type === ENode.ListItem;
        }).forEach((ele, index) => {
          (ele as ListItem).index = index;
          if ((ele as ListItem).itemType === EListItem.Unknown) {
            if (listType === EList.Bullet) {
              (ele as ListItem).itemType = EListItem.Bullet;
            } else if (listType === EList.Ordered) {
              (ele as ListItem).itemType = EListItem.Ordered;
            }
          }
        });
      }
    }
    return undefined;
  }
}
class ListItemPlugin extends NodePlugin {
  readonly name = 'list_item';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'list_item') {
      return true;
    }
    if (payload?.event === ENodeEvent.DidFill && payload?.node?.type === ENode.ListItem) {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new ListItem();
      node.info = payload?.token?.token.info;
      const checkbox = payload?.token?.token.attrs?.filter(ele => {
        if (ele.length > 1) {
          if (ele[0] === 'class' && /task-list-item([\s\S]*)enabled/.test(ele[1])) {
            return true;
          }
        }
        return false;
      });
      if (checkbox && checkbox.length > 0) {
        node.itemType = EListItem.CheckBox;
      }
      return { node };
    }
    if (payload?.event === ENodeEvent.DidFill && (payload?.node as ListItem)?.itemType === EListItem.CheckBox) {
      if (payload?.node?.first?.deref()?.first?.deref()?.type === ENode.Inline) {
        const inline = payload?.node?.first?.deref()?.first?.deref();
        if (ListItem.isCheckNode(inline?.first?.deref())) {
          (payload?.node as ListItem).checked = /checked=""/.test(inline?.first?.deref()?.content || '');
        }
      }
    }
    return undefined;
  }
}
class TablePlugin extends NodePlugin {
  readonly name = 'table';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'table') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.Table, layout: ELayout.Block }) };
    }
    return undefined;
  }
}
class TableItemPlugin extends NodePlugin {
  readonly name = 'table_item';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create) {
      if (payload?.token?.type === 'thead' ||
          payload?.token?.type === 'tbody' ||
          payload?.token?.type === 'tr' ||
          payload?.token?.type === 'td' ||
          payload?.token?.type === 'th') {
        return true;
      }
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new TableItem();
      if (payload?.token?.type === 'thead') {
        node.itemType = ETableItem.Head;
      } else if (payload?.token?.type === 'tbody') {
        node.itemType = ETableItem.Body;
      } else if (payload?.token?.type === 'tr') {
        node.itemType = ETableItem.TR;
      } else if (payload?.token?.type === 'td') {
        node.itemType = ETableItem.TD;
      } else if (payload?.token?.type === 'th') {
        node.itemType = ETableItem.TH;
      }
      if (payload?.token?.type === 'td' ||
          payload?.token?.type === 'th') {
        payload?.token?.token.attrs?.forEach(ele => {
          const name = ele.length > 0 ? ele[0] : undefined;
          const value = ele.length > 1 ? ele[1] : undefined;
          if (name === 'style') {
            if (/text-align( *):( *)left/.test(value || '')) {
              node.align = EAlignment.Left;
            } else if (/text-align( *):( *)center/.test(value || '')) {
              node.align = EAlignment.Center;
            } else if (/text-align( *):( *)right/.test(value || '')) {
              node.align = EAlignment.Right;
            }
          }
        })
      }
      return { node }
    }
    return undefined;
  }
}
class ImagePlugin extends NodePlugin {
  readonly name = 'image';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'image') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new Image();
      payload?.token?.token.attrs?.forEach(attr => {
        const name = attr.length > 0 ? attr[0] : undefined;
        const value = attr.length > 1 ? attr[1] : undefined;
        if (name === 'src') {
          node.src = value;
        } else if (name === 'alt') {
          node.alt = value;
        }
      });
      return { node };
    }
    return undefined;
  }
}
class LinkPlugin extends NodePlugin {
  readonly name = 'link';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'link') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new Link();
      payload?.token?.token.attrs?.forEach(attr => {
        const name = attr.length > 0 ? attr[0] : undefined;
        const value = attr.length > 1 ? attr[1] : undefined;
        if (name === 'href') {
          node.href = value;
        }
      });
      return { node };
    }
    return undefined;
  }
}
class StrongPlugin extends NodePlugin {
  readonly name = 'strong';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'strong') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.Strong, layout: ELayout.Inline }) };
    }
    return undefined;
  }
}
class EmphasisPlugin extends NodePlugin {
  readonly name = 'emphasis';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'em') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.Emphasis, layout: ELayout.Inline }) };
    }
    return undefined;
  }
}
class StrikeThroughPlugin extends NodePlugin {
  readonly name = 'strike_through';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 's') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.StrikeThrough, layout: ELayout.Inline }) };
    }
    return undefined;
  }
}
class ScriptPlugin extends NodePlugin {
  readonly name = 'script';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create) {
      if (payload?.token?.type === 'sub' ||
          payload?.token?.type === 'sup') {
        return true;
      }
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({
        layout: ELayout.Inline,
        type: payload?.token?.type === 'sub' ? ENode.Subscript : ENode.Superscript
      }) };
    }
    return undefined;
  }
}
class TextPlugin extends NodePlugin {
  readonly name = 'text';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'text') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({
        type: ENode.Text, layout: ELayout.Inline, content: payload?.token?.token.content
      }) };
    }
    return undefined;
  }
}
class BreakPlugin extends NodePlugin {
  readonly name = 'break';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create) {
      if (payload?.token?.type === 'softbreak' ||
          payload?.token?.type === 'hardbreak') {
        return true;
      }
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new LineBreak();
      node.lineBreakType = payload?.token?.type === 'softbreak' ? ELineBreak.Soft : ELineBreak.Hard;
      return { node };
    }
    return undefined;
  }
}
class FootnotePlugin extends NodePlugin {
  readonly name = 'footnote';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create) {
      //  footnote_block footnote_anchor 类型均忽略，仅通过 footnote_ref、footnote 创建REF、DEF
      if (payload?.token?.type === 'footnote_ref') {
        return true;
      }
      if (payload?.token?.type === 'footnote') {
        return true;
      }
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      if (payload?.token?.type === 'footnote_ref') {
        const node = new FootnoteRef();
        node.footnoteId = (payload?.token?.token.meta as IAnyTokenMeta)?.id;
        node.label = (payload?.token?.token.meta as IAnyTokenMeta)?.label;
        return { node };
      }
      if (payload?.token?.type === 'footnote') {
        const node = new FootnoteDef();
        node.footnoteId = (payload?.token?.token.meta as IAnyTokenMeta)?.id;
        node.label = (payload?.token?.token.meta as IAnyTokenMeta)?.label;
        return { node };
      }
    }
    return undefined;
  }
}
class EmojiPlugin extends NodePlugin {
  readonly name = 'emoji';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'emoji') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new Emoji({ content: payload?.token?.token.content });
      node.markup = payload?.token?.token.markup;
      return { node };
    }
    return undefined;
  }
}
class HtmlTagPlugin extends NodePlugin {
  readonly name = 'html-tag';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'html_inline') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      const node = new HtmlTag({ content: payload?.token?.token.content });
      if (/<\//.test(node.content || '')) {
        node.state = EState.Close;
      } else if (/<([\s\S]*)\/>/.test(node.content || '')) {
        node.state = EState.SelfClose;
      } else if (HtmlTagPlugin.isVoidElement(node.content || '')) {
        node.state = EState.SelfClose;
      } else if (/<([\s\S]*)>/.test(node.content || '')) {
        node.state = EState.Open;
      }
      if (node.state !== EState.Close) {
        const html = this.engine()?.deref()?.html;
        const doc = html?.parse(payload?.token?.token.content ?? '');
        if (doc) {
          const element = html?.toElement(doc.firstChild);
          if (element) {
            node.tagName = element.tagName;
            element.attributes.forEach(ele => node.attributes.push({
              name: ele.name,
              value: ele.value,
            }));
          }
        }
      }
      return { node };
    }
    return undefined;
  }
  static isVoidElement(content: string) {
    const names: string[] = [
      'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input',
      'link', 'meta', 'param', 'source', 'track', 'wbr', 'icon',
    ];
    return RegExp(`<(${names.join('|')})([\\s\\S]*)/?>$`).test(content);
  }
}
class MathPlugin extends NodePlugin {
  readonly name = 'math';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create &&
      (payload?.token?.type === 'math_inline' ||
        payload?.token?.type === 'math_block'))
    {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return {
        node: new Math({
          layout: payload.token?.token.block ? ELayout.Block : ELayout.Inline,
          content: payload?.token?.token.content,
        }),
      }
    }
    return undefined;
  }
}
class InlinePlugin extends NodePlugin {
  readonly name = 'inline';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.Create && payload?.token?.type === 'inline') {
      return true;
    }
    return false;
  }
  on(payload?: INodePayload, _?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.Create) {
      return { node: new Node({ type: ENode.Inline, layout: ELayout.Block }) };
    }
    return undefined;
  }
}
class DocumentPlugin extends NodePlugin {
  readonly name = 'document';
  should(payload?: INodePayload, _?: INodeContext) {
    if (payload?.event === ENodeEvent.DidFill ||
        payload?.event === ENodeEvent.DidAppend) {
      if (payload?.node?.type === ENode.FootnoteRef ||
          payload?.node?.type === ENode.FootnoteDef) {
        return true;
      }
    }
    return false;
  }
  on(payload?: INodePayload, context?: INodeContext): INodeResult | undefined {
    if (payload?.event === ENodeEvent.DidAppend && context?.program?.document) {
      if (payload?.node?.type === ENode.FootnoteRef) {
        const ref = payload?.node as FootnoteRef;
        context?.program?.document.footnoteRefs.push(new WeakRef(ref));
      }
      if (payload?.node?.type === ENode.FootnoteDef) {
        const def = payload?.node as FootnoteDef;
        context?.program?.document.footnoteDefs.push(new WeakRef(def));
      }
      return undefined;
    }
    if (payload?.event === ENodeEvent.DidFill && context?.program?.document) {
      if (payload?.node?.type === ENode.FootnoteRef) {
        const ref = payload?.node as FootnoteRef;
        for (const def of context?.program?.document.footnoteDefs || []) {
          if (def.deref()?.footnoteId === ref.footnoteId) {
            ref.def = new WeakRef(def.deref() as FootnoteDef);
            break;  // ref 只关联一个 def
          }
        }
      }
      if (payload?.node?.type === ENode.FootnoteDef) {
        const def = payload?.node as FootnoteDef;
        for (const ref of context?.program?.document.footnoteRefs || []) {
          if (ref.deref()?.footnoteId === def.footnoteId) {
            (ref.deref() as FootnoteRef).def = new WeakRef(def);
            // break; def 可能关联多个 ref
          }
        }
      }
      return undefined;
    }
    return undefined;
  }
}

export const plugins = (): NodePlugin[] => {
  return [
    new DocumentPlugin(),
    new QuotePlugin(),
    new HeadingPlugin(),
    new ParagraphPlugin(),
    new CodePlugin(),
    new ThematicBreakPlugin(),
    new ListPlugin(),
    new ListItemPlugin(),
    new TablePlugin(),
    new TableItemPlugin(),
    new ImagePlugin(),
    new LinkPlugin(),
    new StrongPlugin(),
    new EmphasisPlugin(),
    new StrikeThroughPlugin(),
    new ScriptPlugin(),
    new TextPlugin(),
    new BreakPlugin(),
    new FootnotePlugin(),
    new EmojiPlugin(),
    new HtmlTagPlugin(),
    new InlinePlugin(),
    new MathPlugin(),
  ];
}

interface IAnyTokenMeta {
  id?: number,
  label?: string,
}