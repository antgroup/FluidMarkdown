// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { IStyled, StyledSpan } from './styled';
import { log, IMDArea, MDLength } from '../../util';
import {
  StyledValue, EStyledValue, StyledParagraphValue,
  StyledUserBridgeValue,
} from './styled-value';
import Sys from '@ohos.deviceInfo';

log.tag('StyledObject', true);

export interface IStyledObject {
  styled: IStyled;
  mark?: EStyledObjectMark;
}
export enum EStyledObjectMark {
  Unknown = 'unknown',
  BlockBegin = 'block-begin',
  BlockEnd = 'block-end',
  BuildBegin = 'build-begin',
  BuildEnd = 'build-end',
  Group = 'group',
  Break = 'break',
  Root = 'root',
  Empty = 'empty',
  Anchor = 'anchor',
  More = 'more',
  Text = 'text',
}
type EStyledObjectBeginMark = EStyledObjectMark.BlockBegin | EStyledObjectMark.BuildBegin;
type EStyledObjectEndMark = EStyledObjectMark.BlockEnd | EStyledObjectMark.BuildEnd;
export enum EStyledObject {
  Normal = 'normal',
  Embed = 'embed',
}
type StyledObjectContent = string | ImageAttachment | StyledSpan;
export class StyledObject extends MutableStyledString {
  private _id: number = StyledObject._getID();
  private static _gid: number = 0;
  private static _getID() {
    return StyledObject._gid++;
  }
  get id() {
    return this._id;
  }
  readonly type: EStyledObject = EStyledObject.Normal;
  root?: WeakRef<StyledObject>;
  private owner?: WeakRef<StyledObject>;
  protected styleValues: StyledValue[] = [];
  private _offset: number = 0;
  private _attached: boolean = false;
  private value: StyledObjectContent;
  readonly option: IStyledObject;
  private _controller?: WeakRef<TextController>;
  private _listener: Record<string, Function[]> = {};
  protected _area?: IMDArea;

  constructor(option: IStyledObject, value: StyledObjectContent, styles?: StyledValue[]) {
    super(value);
    this.value = value;
    this.option = option;
    this.styleValues = styles?.filter(ele => !ele.empty) ?? [];

    this.on<IStyledObjectAttachEvent>(EStyledObjectEvent.WillAttachTo, event => {
      if (event.current.value instanceof CustomSpan) {
        event.current.owner?.deref()?.attach(StyledObject.anchor());
      }
    });
  }
  fork(): StyledObject {
    return new StyledObject(this.option, this.value, this.styleValues);
  }
  on<T, V = void>(name: string, callback: Callback<T, V>) {
    if (!this._listener[name]) {
      this._listener[name] = [];
    }
    this._listener[name].push(callback);
    return this;
  }
  emit<T, V = void>(name: string, event: T): V {
    let result: V = undefined as V;
    this._listener[name]?.forEach(ele => {
      result = (ele as Callback<T, V>)(event);
    });
    return result;
  }
  set area(area: IMDArea | undefined) {
    this._area = area;
  }
  get area() {
    return this._area;
  }
  get node() {
    return this.option.styled.node;
  }
  get offset() {
    return this._offset;
  }
  private get canAttach() {
    if (this.option.mark === EStyledObjectMark.Root) {
      return true;
    }
    if (this.root?.deref()) {
      return true;
    }
    return false;
  }
  attach(other: StyledObject | StyledString) {
    const root = this.root ?? new WeakRef(this);
    if (other instanceof StyledObject) {
      if (!this.canAttach) {
        throw Error('current object should be attached first');
      }
      other.owner = new WeakRef(this);
      other.root = root;

      this.emit<IStyledObjectAttachEvent>(EStyledObjectEvent.WillAttach, { current: this, target: other });
      other.emit<IStyledObjectAttachEvent>(EStyledObjectEvent.WillAttachTo, { current: other, target: this });

      other._offset = this.root?.deref()?.length ?? this.length;
      root.deref()?.appendStyledString(other);

      other.accept();
      other._attached = true;

      other.emit<IStyledObjectAttachEvent>(EStyledObjectEvent.DidAttachTo, { current: other, target: this });
      this.emit<IStyledObjectAttachEvent>(EStyledObjectEvent.DidAttach, { current: this, target: other });

      root.deref()?.emit<IStyledObjectAppendEvent>(EStyledObjectEvent.DidAppend, { target: other });
    } else {
      root.deref()?.appendStyledString(other);
    }
  }
  get attached() {
    return this._attached;
  }
  private accept() {
    const owner = this.owner?.deref();
    if (!owner) {
      return;
    }
    const styles = owner.styleValues.map(ele => ele.copy());
    for (const style of this.styleValues) {
      const exists = styles.filter(ele => ele.type === style.type);
      if (exists.length > 0) {
        exists.forEach(ele => ele.cascade(style));
      } else {
        styles.push(style);
      }
    }
    this.styleValues = styles;

    if (this.length === 0) {
      return;
    }
    styles.forEach(ele => {
      this.root?.deref()?.setStyle({
        start: this._offset, length: this.length,
        styledKey: ele.key, styledValue: ele.value,
      });
    });

    do {
      const value = new StyledUserBridgeValue(this);
      this.root?.deref()?.setStyle({
        start: this._offset, length: this.length,
        styledKey: value.key, styledValue: value,
      });
    } while (0);
  }
  cascadedStyle<T = StyledStringValue>(key: StyledStringKey) {
    return this.root?.deref()?.getStyles(this._offset, this.length, key).slice().shift()?.styledValue as T | undefined;
  }
  get blockArea(): IMDArea | undefined {
    const area = this.area ?? this.root?.deref()?.area;
    if (area) {
      let leadingMargin: number = 0;
      this.styleValues.filter(ele => ele.type === EStyledValue.Paragraph).forEach(ele => {
        const paragraphValue = ele as StyledParagraphValue;
        const paragraph = paragraphValue.value;
        if (paragraph.leadingMargin) {
          if (paragraph.leadingMargin instanceof Number) {
            leadingMargin = paragraph.leadingMargin as number;
          } else {
            //  FIXME: need LeadingMarginPlaceholder ?
          }
        }
      });
      if (leadingMargin > 0) {
        //  NOTE: Length as number
        area.width = MDLength.vp((area.width?.value as number ?? 0) - leadingMargin);
      }
      return area;
    }
    return undefined;
  }
  get currentRoot() {
    return this.root?.deref();
  }
  bindTextController(controller: TextController) {
    this._controller = new WeakRef(controller);
  }
  get textController() {
    return this.root?.deref()?._controller?.deref() ?? this._controller?.deref();
  }
  get mark(): EStyledObjectMark {
    return this.option.mark || EStyledObjectMark.Unknown;
  }
  getRectsForRange(range: TextRange, widthStyle: RectWidthStyle, heightStyle: RectHeightStyle): Array<TextBox> {
    if (Sys.sdkApiVersion >= 14) {
      const layoutManager = this.textController?.getLayoutManager();
      if (layoutManager) {
        return layoutManager.getRectsForRange(range, widthStyle, heightStyle);
      }
    }
    return [];
  }
  nearbyParagraph(offset: number): TextRange | undefined {
    const length = this.length;
    if (length > 0 && offset < length) {
      const isBreaker = (str?: StyledString) => {
        if (str) {
          return ['\n', '\r', '\t'].indexOf(str.getString()) !== -1;
        }
        return true;
      }
      const picker = (cursor: number) => {
        try {
          return this.subStyledString(cursor, 1);
        } catch (e) {
          return undefined;
        }
      };
      let start: number = offset;
      do {
        let cursor = offset;
        do {
          cursor -= 1;
        } while (!isBreaker(picker(cursor)));
        start = cursor + 1;
      } while (0);
      let end: number = offset;
      do {
        let cursor = offset;
        do {
          cursor += 1;
        } while (!isBreaker(picker(cursor)));
        end = cursor - 1;
      } while (0);
      return { start, end }
    }
    return undefined;
  }
  subStyledObjects(start: number, length: number): IStyledSubObject[] {
    const bridgeStyles = this.getStyles(start, length, StyledStringKey.USER_DATA).filter(ele => {
      return ele.styledValue instanceof StyledUserBridgeValue;
    });
    return bridgeStyles.map<IStyledSubObject>(ele => {
      const object = (ele.styledValue as StyledUserBridgeValue).object.deref();
      if (object && object.type === EStyledObject.Embed) {
        return {
          object: object.fork(),
          real: object,
        };
      }
      return {
        object: this.subStyledString(ele.start, ele.length),
        real: object,
      };
    });
  }
  replaceStyle(spanStyle: SpanStyle): void {
    super.replaceStyle(spanStyle);
    this.emit<IStyledObjectReplaceStyleEvent>(
      EStyledObjectEvent.DidReplaceStyle,
      { current: this, spanStyle },
    );
  }

  static begin(option: IStyledObject, styles?: StyledValue[], mark: EStyledObjectBeginMark = EStyledObjectMark.BlockBegin): StyledObject {
    return new StyledObject({
      styled: option.styled, mark,
    }, '', styles);
  }
  static end(option: IStyledObject, styles?: StyledValue[], mark: EStyledObjectEndMark = EStyledObjectMark.BlockEnd): StyledObject {
    return new StyledObject({
      styled: option.styled, mark,
    }, '', styles);
  }
  static group(option: IStyledObject, styles?: StyledValue[]): StyledObject {
    return new StyledObject({
      styled: option.styled,
      mark: EStyledObjectMark.Group,
    }, '', styles);
  }
  static break(option: IStyledObject, styles?: StyledValue[]): StyledObject {
    return new StyledObject({
      styled: option.styled,
      mark: EStyledObjectMark.Break,
    }, '\n', styles);
  }
  static root(area?: IMDArea, styles?: StyledValue[]): StyledObject {
    const object = new StyledObject({
      styled: { option: {} },
      mark: EStyledObjectMark.Root,
    }, '', styles);
    object.area = area;
    return object;
  }
  static empty(styles?: StyledValue[]) {
    return new StyledObject({
      styled: { option: {} },
      mark: EStyledObjectMark.Empty,
    }, '\u200B', styles);
  }
  static anchor(styles?: StyledValue[]) {
    return new StyledObject({
      styled: { option: {} },
      mark: EStyledObjectMark.Anchor,
    }, '\u200B', styles);
  }
  static more(content: string, styles?: StyledValue[]) {
    return new StyledObject({
      styled: { option: {} },
      mark: EStyledObjectMark.More,
    }, content, styles);
  }
  static text(content: string, styles?: StyledValue[]) {
    return new StyledObject({
      styled: { option: {} },
      mark: EStyledObjectMark.Text,
    }, content, styles);
  }
}
export enum EStyledObjectEvent {
  WillAttach = 'will_attach',       //  CURRENT will attach TARGET    => CURRENT will bind TARGET
  DidAttach = 'did_attach',         //  CURRENT did attach TARGET     => CURRENT did bind TARGET
  WillAttachTo = 'will_attach_to',  //  CURRENT will attach to TARGET => TARGET will bind CURRENT
  DidAttachTo = 'did_attach_to',    //  CURRENT did attach to TARGET  => TARGET did bind CURRENT

  DidAppend = 'did_append',         //  CURRENT did append TARGET

  DidReplaceStyle = 'did_replace_style',

  GetArea = 'get_area',
}
export interface IStyledObjectAttachEvent {
  current: StyledObject;
  target: StyledObject;
}
export interface IStyledObjectAppendEvent {
  target: StyledObject;
}
export interface IStyledObjectReplaceStyleEvent {
  current?: StyledObject;
  spanStyle?: SpanStyle;
}
interface IStyledSubObject {
  object: StyledObject | StyledString,
  real?: StyledObject,
}