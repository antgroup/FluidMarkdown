// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Event, MDCrypto } from '../../../util';

export enum ENode {
  Unknown = 'unknown',

  Document = 'document',

  Paragraph = 'paragraph',
  ThematicBreak = 'thematic-break',
  Heading = 'heading',
  Quote = 'quote',
  Code = 'code',
  Table = 'table',
  TableItem = 'table-item',
  List = 'list',
  ListItem = 'list-item',
  HtmlTag = 'html-tag',
  Math = 'math',

  Text = 'text',
  LineBreak = 'line-break',
  Emoji = 'emoji',
  Strong = 'strong',
  Emphasis = 'emphasis',
  StrikeThrough = 'strike-through',
  Image = 'image',
  Link = 'link',
  FootnoteRef = 'footnote-ref',
  FootnoteDef = 'footnote-def',
  Superscript = 'sup',
  Subscript = 'sub',

  Inline = 'inline',

  StyledContent = 'styled-content',
}

export enum ELayout {
  Unknown = 'unknown',
  Inline = 'inline',
  Block = 'block',
}
export enum ELineBreak {
  Unknown = 'unknown',
  Soft = 'soft',
  Hard = 'hard',
}
export enum EList {
  Unknown = 'unknown',
  Bullet = 'bullet',
  Ordered = 'ordered',
  Task = 'task',
}
export enum EListItem {
  Unknown = 'unknown',
  Ordered = 'ordered',
  Bullet = 'bullet',
  CheckBox = 'check-box',
}
export enum ETableItem {
  Unknown = 'unknown',
  Head = 'head',
  Body = 'body',
  TR = 'tr', //  table row
  TD = 'td', //  table body cell
  TH = 'th', //  table head cell
}
export enum EAlignment {
  Unknown = 'unknown',
  Left = 'left',
  Center = 'center',
  Right = 'right',
}
export enum EState {
  Unknown = 'unknown',
  Open = 'open',
  Close = 'close',
  SelfClose = 'self-close',
}

export interface ILocation {
  readonly lineBegin: number,
  readonly lineEnd: number,
}
const EmptyLocation: ILocation = { lineBegin: -1, lineEnd: -1 };
export interface IAttribute {
  readonly name: string,
  readonly value?: string | number | boolean,
}
export interface IVisitor {
  on: (node: Node) => boolean,
  filter?: (node: Node) => boolean,
}
interface IVisitorAsync {
  on: (node: Node) => Promise<boolean>,
  filter?: (node: Node) => Promise<boolean>,
}

interface INode {
  type?: ENode,
  layout?: ELayout,
  content?: string,
  hidden?: boolean,
}
interface INodeSummary {
  id?: number,
  type?: ENode,
  layout?: ELayout,
  content?: string,
  attributes?: IAttribute[],
  children?: INodeSummary[],
  hidden?: boolean,
  hash?: string,
}
export class Node extends Event {
  readonly id: number = Node.getID();
  type: ENode = ENode.Unknown;
  layout: ELayout = ELayout.Unknown;
  location: ILocation = EmptyLocation;
  attributes: IAttribute[] = [];
  content?: string;
  state: EState = EState.Unknown;
  hidden: boolean = false;

  parent?: WeakRef<Node>;
  first?: WeakRef<Node>;
  last?: WeakRef<Node>;
  prev?: WeakRef<Node>;
  next?: WeakRef<Node>;

  private _hash?: string;
  get hash() {
    return this._hash;
  }
  async createHash(): Promise<string | undefined> {
    const hashList: string[] = [];
    //  this
    do {
      const hash = await this.createThisHash();
      if (hash) {
        hashList.push(hash);
      }
    } while (0);
    //  children
    do {
      const hash = await this.first?.deref()?.createHash();
      if (hash) {
        hashList.push(hash);
      }
    } while (0);
    //  brother
    do {
      const hash = await this.next?.deref()?.createHash();
      if (hash) {
        hashList.push(hash);
      }
    } while (0);
    this._hash = hashList.length > 0 ? await MDCrypto.md5(hashList.join('_')) : undefined;
    return this._hash;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      this.id
    }${
      this.type
    }${
      this.layout
    }${
      this.attributes.map(ele => ([ele.name, ele.value].join(''))).join('')
    }${
      this.content
    }${
      this.hidden
    }`;
    return await MDCrypto.md5(content);
  }

  constructor(option?: INode) {
    super();
    if (option?.type) {
      this.type = option.type;
    }
    if (option?.layout) {
      this.layout = option.layout;
    }
    if (option?.content) {
      this.content = option.content;
    }
  }

  is(type: ENode) {
    return this.type === type;
  }
  weak() {
    return new WeakRef(this);
  }
  stringify() {
    return JSON.stringify({
      id: this.id,
      type: this.type,
      level: this.layout,
      location: JSON.stringify(this.location),
      attributes: JSON.stringify(this.attributes),
    });
  }
  append(node: Node) {
    if (!this.canAppend(node)) {
      return;
    }
    this.emit('will-append-node', node);
    this.unbind(node);
    node.parent = this.weak();
    const last = this.last?.deref();
    if (last) {
      last.next = node.weak();
      node.prev = last.weak();
    } else {
      const first = this.first?.deref();
      if (first) {
        first.next = node.weak();
        node.prev = first.weak();
      } else {
        this.first = node.weak();
      }
    }
    this.last = node.weak();
    this.emit('did-append-node', node);
  }
  remove(node: Node) {
    if (!this.canRemove(node)) {
      return;
    }
    this.emit('will-remove-node', node);
    this.unbind(node);
    this.emit('did-remove-node', node);
  }
  insert(node: Node, anchor: Node, before: boolean = true) {
    if (!this.canInsert(node, anchor, before)) {
      return;
    }
    if (!before) {
      //  目前仅支持 before 插入
      return;
    }
    this.emit('will-insert-node', node);
    this.unbind(node);
    node.parent = this.weak();
    const prev = anchor.prev?.deref();
    if (prev) {
      prev.next = node.weak();
      node.prev = prev.weak();
      node.next = anchor.weak();
      anchor.prev = node.weak();
    } else {
      this.first = node.weak();
      node.next = anchor.weak();
      anchor.prev = node.weak();
    }
    this.emit('did-insert-node', node);
  }
  private canAppend(node: Node) {
    return node ? true : false;
  }
  private canRemove(node: Node) {
    if (!node) {
      return false;
    }
    if (node.parent?.deref() !== this) {
      return false;
    }
    return true;
  }
  private canInsert(node: Node, anchor: Node, before: boolean = true) {
    if (!node || !anchor) {
      return false;
    }
    if (!before) {
      return false;
    }
    if (anchor.parent?.deref() !== this) {
      return false;
    }
    return true;
  }
  private unbind(node?: Node) {
    if (!node) {
      return;
    }
    const prev = node?.prev?.deref();
    const next = node?.next?.deref();
    const parent = node?.parent?.deref();
    if (parent) {
      if (parent.first?.deref() === node) {
        parent.first = next?.weak();
      }
      if (parent.last?.deref() === node) {
        parent.last = prev?.weak();
      }
      node.parent = undefined;
    }
    if (prev) {
      prev.next = next?.weak();
      node.prev = undefined;
    }
    if (next) {
      next.prev = prev?.weak();
      node.next = undefined;
    }
  }
  get children(): Node[] {
    const nodes: Node[] = [];
    let node = this.first?.deref();
    if (node) {
      nodes.push(node);
    }
    do {
      node = node?.next?.deref();
      if (node) {
        nodes.push(node);
      }
    } while (node && this.last?.deref() && node !== this.last?.deref());
    return nodes;
  }
  get summary(): INodeSummary {
    return {
      id: this.id,
      type: this.type,
      layout: this.layout,
      content: this.content,
      attributes: this.attributes,
      hidden: this.hidden,
      hash: this.hash,
      children: this.children.map((node) => node.summary),
    };
  }
  private static gid: number = 0;
  private static getID() {
    return Node.gid++;
  }
  static resetID() {
    Node.gid = 0;
  }
  static traverseSelf(node?: Node, visitor?: IVisitor) {
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
    const first = node.first?.deref();
    if (first) {
      Node.traverse(first, visitor);
    }
  }
  static traverse(node?: Node, visitor?: IVisitor) {
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
    const first = node.first?.deref();
    if (first) {
      Node.traverse(first, visitor);
    }
    //  brother
    const next = node.next?.deref();
    if (next) {
      Node.traverse(next, visitor);
    }
  }
  static async traverseAsync(node?: Node, visitor?: IVisitorAsync) {
    if (!node || !visitor) {
      return;
    }
    let canNext = true;
    if (visitor.filter) {
      if (await visitor.filter(node)) {
        canNext = await visitor.on(node);
      }
    } else {
      canNext = await visitor.on(node);
    }
    if (!canNext) {
      return;
    }
    //  children
    const first = node.first?.deref();
    if (first) {
      await Node.traverseAsync(first, visitor);
    }
    //  brother
    const next = node.next?.deref();
    if (next) {
      await Node.traverseAsync(next, visitor);
    }
  }
}

interface IHeadingSummary extends INodeSummary {
  level?: number,
}
export class Heading extends Node {
  readonly type: ENode = ENode.Heading;
  readonly layout: ELayout = ELayout.Block;
  level: number = 0;
  get summary(): IHeadingSummary {
    const summary = super.summary as IHeadingSummary;
    summary.level = this.level;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.level
    }`;
    return await MDCrypto.md5(content);
  }
}
interface ICodeSummary extends INodeSummary {
  language?: string,
}
export class Code extends Node {
  readonly type: ENode = ENode.Code;
  language?: string;
  get summary(): ICodeSummary {
    const summary = super.summary as ICodeSummary;
    summary.language = this.language;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
     await super.createThisHash()
    }${
      this.language
    }`;
    return await MDCrypto.md5(content);
  }
  get styledContent() {
    const first = this.first?.deref();
    return first?.is(ENode.StyledContent) ? first as StyledContent : undefined;
  }
}
interface IListSummary extends INodeSummary {
  isTop?: boolean,
  listType?: EList,
}
export class List extends Node {
  readonly type: ENode = ENode.List;
  readonly layout: ELayout = ELayout.Block;
  listType: EList = EList.Unknown;
  get isTop() {
    return this.parent?.deref()?.is(ENode.ListItem) ? false : true;
  }
  get summary(): IListSummary {
    const summary = super.summary as IListSummary;
    summary.isTop = this.isTop;
    summary.listType = this.listType;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.listType
    }`;
    return await MDCrypto.md5(content);
  }
}
interface IListItemSummary extends INodeSummary {
  itemType?: EListItem,
  index?: number,
  checked?: boolean,
  info?: string,
}
export class ListItem extends Node {
  readonly type: ENode = ENode.ListItem;
  readonly layout: ELayout = ELayout.Block;
  itemType: EListItem = EListItem.Unknown;
  index: number = -1;
  checked: boolean = false;
  info?: string;
  get parentList() {
    if (this.parent?.deref()?.is(ENode.List)) {
      return this.parent?.deref() as List;
    }
    return undefined;
  }
  get summary(): IListItemSummary {
    const summary = super.summary as IListItemSummary;
    summary.itemType = this.itemType;
    summary.index = this.index;
    summary.checked = this.checked;
    summary.info = this.info;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.itemType
    }${
      this.index
    }${
      this.checked
    }`;
    return await MDCrypto.md5(content);
  }
  static isCheckNode(node?: Node) {
    if (node?.type === ENode.HtmlTag && node?.layout === ELayout.Inline) {
      return /<input([\s\S]*)type="checkbox"/.test(node.content || '');
    }
    return false;
  }
}
interface ITableItemSummary extends INodeSummary {
  itemType?: ETableItem,
  align?: EAlignment,
}
export class TableItem extends Node {
  readonly type: ENode = ENode.TableItem;
  readonly layout: ELayout = ELayout.Block;
  itemType: ETableItem = ETableItem.Unknown;
  align: EAlignment = EAlignment.Left;
  get summary(): ITableItemSummary {
    const summary = super.summary as ITableItemSummary;
    summary.itemType = this.itemType;
    summary.align = this.align;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.itemType
    }${
      this.align
    }`;
    return await MDCrypto.md5(content);
  }
}
interface IImageSummary extends INodeSummary {
  src?: string,
  alt?: string,
}
export class Image extends Node {
  readonly type: ENode = ENode.Image;
  readonly layout: ELayout = ELayout.Inline;
  src?: string;
  alt?: string;
  get summary(): IImageSummary {
    const summary = super.summary as IImageSummary;
    summary.src = this.src;
    summary.alt = this.alt;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.src
    }${
      this.alt
    }`;
    return await MDCrypto.md5(content);
  }
}
interface ILinkSummary extends INodeSummary {
  href?: string,
}
export class Link extends Node {
  readonly type: ENode = ENode.Link;
  readonly layout: ELayout = ELayout.Inline;
  href?: string;
  get summary(): ILinkSummary {
    const summary = super.summary as ILinkSummary;
    summary.href = this.href;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.href
    }`;
    return await MDCrypto.md5(content);
  }
}
interface IFootnoteRefSummary extends INodeSummary {
  footnoteId?: number,
  label?: string,
}
export class FootnoteRef extends Node {
  readonly type: ENode = ENode.FootnoteRef;
  readonly layout: ELayout = ELayout.Inline;
  footnoteId?: number;
  label?: string;
  def?: WeakRef<FootnoteDef>;
  get summary(): IFootnoteRefSummary {
    const summary = super.summary as IFootnoteRefSummary;
    summary.footnoteId = this.footnoteId;
    summary.label = this.label;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.footnoteId
    }${
      this.label
    }${
      this.def?.deref()?.id
    }`;
    return await MDCrypto.md5(content);
  }
}
interface IFootnoteDefSummary extends INodeSummary {
  footnoteId?: number,
  label?: string,
}
export class FootnoteDef extends Node {
  readonly type: ENode = ENode.FootnoteDef;
  readonly layout: ELayout = ELayout.Block;
  footnoteId?: number;
  label?: string;
  // refs?: WeakRef<FootnoteRef>[];
  get summary(): IFootnoteDefSummary {
    const summary = super.summary as IFootnoteDefSummary;
    summary.footnoteId = this.footnoteId;
    summary.label = this.label;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.footnoteId
    }${
      this.label
    }`;
    return await MDCrypto.md5(content);
  }
}
interface ILineBreakSummary extends INodeSummary {
  lineBreakType?: ELineBreak,
}
export class LineBreak extends Node {
  readonly type: ENode = ENode.LineBreak;
  readonly layout: ELayout = ELayout.Inline;
  lineBreakType: ELineBreak = ELineBreak.Unknown;
  get summary(): ILineBreakSummary {
    const summary = super.summary as ILineBreakSummary;
    summary.lineBreakType = this.lineBreakType;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.lineBreakType
    }`;
    return await MDCrypto.md5(content);
  }
}
interface IEmojiSummary extends INodeSummary {
  markup?: string,
}
export class Emoji extends Node {
  readonly type: ENode = ENode.Emoji;
  readonly layout: ELayout = ELayout.Inline;
  markup?: string;
  get summary(): IEmojiSummary {
    const summary = super.summary as IEmojiSummary;
    summary.markup = this.markup;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.markup
    }`;
    return await MDCrypto.md5(content);
  }
}
interface IHtmlTagSummary extends INodeSummary {
  tagName?: string,
}
export class HtmlTag extends Node {
  readonly type: ENode = ENode.HtmlTag;
  readonly layout: ELayout = ELayout.Inline;
  tagName?: string;
  //  TODO: 解析 tag-name、tag-attrs
  get summary(): IHtmlTagSummary {
    const summary = super.summary as IHtmlTagSummary;
    summary.tagName = this.tagName;
    return summary;
  }
}
interface IMathSummary extends INodeSummary {
  mathHash?: string,
}
export class Math extends Node {
  readonly type: ENode = ENode.Math;
  mathHash?: string;
  get summary(): IMathSummary {
    const summary = super.summary as IMathSummary;
    summary.mathHash = this.mathHash;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    this.mathHash = await MDCrypto.md5(this.content);
    return await super.createThisHash();
  }
}
interface IStyledContent extends INodeSummary {
}
export class StyledContent extends Node {
  readonly type: ENode = ENode.StyledContent;
  styled?: StyledString;
  get summary(): IStyledContent {
    const summary = super.summary as IStyledContent;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.styled?.getString()
    }`;
    return await MDCrypto.md5(content);
  }
}
interface IDocumentSummary extends INodeSummary {
}
export class Document extends Node {
  readonly type: ENode = ENode.Document;
  readonly layout: ELayout = ELayout.Block;
  readonly footnoteRefs: WeakRef<FootnoteRef>[] = [];
  readonly footnoteDefs: WeakRef<FootnoteDef>[] = [];
  get summary(): IDocumentSummary {
    const summary = super.summary as IDocumentSummary;
    return summary;
  }
  protected async createThisHash(): Promise<string | undefined> {
    const content = `${
      await super.createThisHash()
    }${
      this.footnoteRefs.map(ele => ele.deref()?.id).join('')
    }${
      this.footnoteDefs.map(ele => ele.deref()?.id).join('')
    }`;
    return await MDCrypto.md5(content);
  }
}