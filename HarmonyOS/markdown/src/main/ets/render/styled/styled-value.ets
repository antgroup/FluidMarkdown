// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { LengthMetrics } from "@kit.ArkUI";
import { MDLength } from '../../util';
import type { StyledObject } from './styled-object';
import Sys from '@ohos.deviceInfo';

export enum EStyledValue {
  Text = 'text',
  Decoration = 'decoration',
  BaselineOffset = 'baselineOffset',
  LetterSpacing = 'letterSpacing',
  TextShadow = 'textShadow',
  Gesture = 'gesture',
  ImageAttachment = 'imageAttachment',
  Paragraph = 'paragraph',
  LineHeight = 'lineHeight',
  CustomSpan = 'customSpan',
  BackgroundColor = 'backgroundColor',

  UserBridge = 'userBridge',
}
export abstract class StyledValue {
  abstract readonly type: EStyledValue;
  abstract readonly key: StyledStringKey;
  abstract readonly value: StyledStringValue;
  abstract cascade(value: StyledValue): void;
  abstract copy(): StyledValue;
  abstract get empty(): boolean;
}
export interface IStyledTextValue extends TextStyleInterface {}
export class StyledTextValue extends StyledValue {
  readonly type = EStyledValue.Text;
  readonly key = StyledStringKey.FONT;
  private _option: IStyledTextValue;
  constructor(option: IStyledTextValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new TextStyle(this._option);
  }
  cascade(value: StyledTextValue) {
    if (!(value instanceof StyledTextValue)) {
      return;
    }
    this._option.fontColor = value._option.fontColor ?? this._option.fontColor;
    this._option.fontSize = value._option.fontSize ?? this._option.fontSize;
    this._option.fontWeight = value._option.fontWeight ?? this._option.fontWeight;
    this._option.fontFamily = value._option.fontFamily ?? this._option.fontFamily;
    this._option.fontStyle = value._option.fontStyle ?? this._option.fontStyle;
  }
  copy(): StyledValue {
    return new StyledTextValue({
      fontColor: this._option.fontColor,
      fontSize: this._option.fontSize,
      fontWeight: this._option.fontWeight,
      fontFamily: this._option.fontFamily,
      fontStyle: this._option.fontStyle,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledDecorationValue {
  type?: TextDecorationType;
  color?: ResourceColor;
  style?: TextDecorationStyle;
}
export class StyledDecorationValue extends StyledValue {
  readonly type = EStyledValue.Decoration;
  readonly key = StyledStringKey.DECORATION;
  private _option: IStyledDecorationValue;
  constructor(option: IStyledDecorationValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new DecorationStyle({
      style: this._option.style,
      type: this._option.type ?? TextDecorationType.None,
      color: this._option.color,
    });
  }
  cascade(value: StyledDecorationValue) {
    if (!(value instanceof StyledDecorationValue)) {
      return;
    }
    this._option.type = value._option.type ?? this._option.type;
    this._option.color = value._option.color ?? this._option.color;
    this._option.style = value._option.style ?? this._option.style;
  }
  copy(): StyledValue {
    return new StyledDecorationValue({
      type: this._option.type,
      color: this._option.color,
      style: this._option.style,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledBaselineOffsetValue {
  offset?: LengthMetrics;
}
export class StyledBaselineOffsetValue extends StyledValue {
  readonly type = EStyledValue.BaselineOffset;
  readonly key = StyledStringKey.BASELINE_OFFSET;
  private _option: IStyledBaselineOffsetValue;
  constructor(option: IStyledBaselineOffsetValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new BaselineOffsetStyle(this._option.offset ?? LengthMetrics.vp(0));
  }
  cascade(value: StyledBaselineOffsetValue) {
    if (!(value instanceof StyledBaselineOffsetValue)) {
      return;
    }
    this._option.offset = value._option.offset ?? this._option.offset;
  }
  copy(): StyledValue {
    return new StyledBaselineOffsetValue({
      offset: this._option.offset,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledLetterSpacingValue {
  spacing?: LengthMetrics;
}
export class StyledLetterSpacingValue extends StyledValue {
  readonly type = EStyledValue.LetterSpacing;
  readonly key = StyledStringKey.LETTER_SPACING;
  private _option: IStyledLetterSpacingValue;
  constructor(option: IStyledLetterSpacingValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new LetterSpacingStyle(this._option.spacing ?? LengthMetrics.vp(0));
  }
  cascade(value: StyledLetterSpacingValue) {
    if (!(value instanceof StyledLetterSpacingValue)) {
      return;
    }
    this._option.spacing = value._option.spacing ?? this._option.spacing;
  }
  copy(): StyledValue {
    return new StyledLetterSpacingValue({
      spacing: this._option.spacing,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledTextShadowValue {
  radius?: number | Resource;
  type?: ShadowType;
  color?: Color | string | Resource | ColoringStrategy;
  offsetX?: number | Resource;
  offsetY?: number | Resource;
  fill?: boolean;
}
export class StyledTextShadowValue extends StyledValue {
  readonly type = EStyledValue.TextShadow;
  readonly key = StyledStringKey.TEXT_SHADOW;
  private _option: IStyledTextShadowValue;
  constructor(option: IStyledTextShadowValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new TextShadowStyle({
      radius: this._option.radius ?? 0,
      type: this._option.type,
      color: this._option.color,
      offsetX: this._option.offsetX,
      offsetY: this._option.offsetY,
      fill: this._option.fill,
    });
  }
  cascade(value: StyledTextShadowValue) {
    if (!(value instanceof StyledTextShadowValue)) {
      return;
    }
    this._option.radius = value._option.radius ?? this._option.radius;
    this._option.type = value._option.type ?? this._option.type;
    this._option.color = value._option.color ?? this._option.color;
    this._option.offsetX = value._option.offsetX ?? this._option.offsetX;
    this._option.offsetY = value._option.offsetY ?? this._option.offsetY;
    this._option.fill = value._option.fill ?? this._option.fill;
  }
  copy(): StyledValue {
    return new StyledTextShadowValue({
      radius: this._option.radius,
      type: this._option.type,
      color: this._option.color,
      offsetX: this._option.offsetX,
      offsetY: this._option.offsetY,
      fill: this._option.fill,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledGestureValue extends GestureStyleInterface {}
export class StyledGestureValue extends StyledValue {
  readonly type = EStyledValue.Gesture;
  readonly key = StyledStringKey.GESTURE;
  private _option: IStyledGestureValue;
  constructor(option: IStyledGestureValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new GestureStyle(this._option);
  }
  cascade(value: StyledGestureValue) {
    if (!(value instanceof StyledGestureValue)) {
      return;
    }
    this._option.onClick = value._option.onClick ?? this._option.onClick;
    this._option.onLongPress = value._option.onLongPress ?? this._option.onLongPress;
  }
  copy(): StyledValue {
    return new StyledGestureValue({
      onClick: this._option.onClick,
      onLongPress: this._option.onLongPress,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledImageAttachmentValue {
  value?: PixelMap;
  size?: SizeOptions;
  verticalAlign?: ImageSpanAlignment;
  objectFit?: ImageFit;
  layoutStyle?: ImageAttachmentLayoutStyle;
}
export class StyledImageAttachmentValue extends StyledValue {
  readonly type = EStyledValue.ImageAttachment;
  readonly key = StyledStringKey.IMAGE;
  private _option: IStyledImageAttachmentValue;
  constructor(option: IStyledImageAttachmentValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new ImageAttachment(this._option.value ? {
      value: this._option.value,
      size: this._option.size,
      verticalAlign: this._option.verticalAlign,
      objectFit: this._option.objectFit,
      layoutStyle: this._option.layoutStyle,
    } : undefined);
  }
  cascade(value: StyledImageAttachmentValue) {
    if (!(value instanceof StyledImageAttachmentValue)) {
      return;
    }
    this._option.value = value._option.value ?? this._option.value;
    this._option.size = value._option.size ?? this._option.size;
    this._option.verticalAlign = value._option.verticalAlign ?? this._option.verticalAlign;
    this._option.objectFit = value._option.objectFit ?? this._option.objectFit;
    this._option.layoutStyle = value._option.layoutStyle ?? this._option.layoutStyle;
  }
  copy(): StyledValue {
    return new StyledImageAttachmentValue({
      value: this._option.value,
      size: this._option.size,
      verticalAlign: this._option.verticalAlign,
      objectFit: this._option.objectFit,
      layoutStyle: this._option.layoutStyle,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledParagraphValue extends ParagraphStyleInterface {}
export class StyledParagraphValue extends StyledValue {
  readonly type = EStyledValue.Paragraph;
  readonly key = StyledStringKey.PARAGRAPH_STYLE;
  private _option: IStyledParagraphValue;
  constructor(option: IStyledParagraphValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new ParagraphStyle(this._option);
  }
  cascade(value: StyledParagraphValue) {
    if (!(value instanceof StyledParagraphValue)) {
      return;
    }
    this._option.textAlign = value._option.textAlign ?? this._option.textAlign;
    this._option.textIndent = value._option.textIndent ?? this._option.textIndent;
    this._option.maxLines = value._option.maxLines ?? this._option.maxLines;
    this._option.overflow = value._option.overflow ?? this._option.overflow;
    this._option.wordBreak = value._option.wordBreak ?? this._option.wordBreak;
    if (value._option.leadingMargin && value._option.leadingMargin instanceof LengthMetrics) {
      if (this._option.leadingMargin && this._option.leadingMargin instanceof LengthMetrics) {
        this._option.leadingMargin = MDLength.vp(this._option.leadingMargin.value + value._option.leadingMargin.value);
      } else {
        this._option.leadingMargin = value._option.leadingMargin;
      }
    }
  }
  copy(): StyledValue {
    return new StyledParagraphValue({
      textAlign: this._option.textAlign,
      textIndent: this._option.textIndent,
      maxLines: this._option.maxLines,
      overflow: this._option.overflow,
      wordBreak: this._option.wordBreak,
      leadingMargin: this._option.leadingMargin,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledLineHeightValue {
  height?: LengthMetrics;
}
export class StyledLineHeightValue extends StyledValue {
  readonly type = EStyledValue.LineHeight;
  readonly key = StyledStringKey.LINE_HEIGHT;
  private _option: IStyledLineHeightValue;
  constructor(option: IStyledLineHeightValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return new LineHeightStyle(this._option.height ?? LengthMetrics.vp(0));
  }
  cascade(value: StyledLineHeightValue) {
    if (!(value instanceof StyledLineHeightValue)) {
      return;
    }
    this._option.height = value._option.height ?? this._option.height;
  }
  copy(): StyledValue {
    return new StyledLineHeightValue({
      height: this._option.height,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledCustomSpanValue {
  span: CustomSpan;
}
export class StyledCustomSpanValue extends StyledValue {
  readonly type = EStyledValue.CustomSpan;
  readonly key = StyledStringKey.CUSTOM_SPAN;
  private _option: IStyledCustomSpanValue;
  constructor(option: IStyledCustomSpanValue) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    return this._option.span;
  }
  cascade(value: StyledCustomSpanValue) {
    if (!(value instanceof StyledCustomSpanValue)) {
      return;
    }
    this._option.span = value._option.span ?? this._option.span;
  }
  copy(): StyledValue {
    return new StyledCustomSpanValue({
      span: this._option.span,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export interface IStyledBackgroundRadiuses {
  topLeft?: LengthMetrics;
  topRight?: LengthMetrics;
  bottomLeft?: LengthMetrics;
  bottomRight?: LengthMetrics;
}
export interface IStyledBackgroundValue {
  color?: ResourceColor;
  radius?: LengthMetrics;
  radiuses?: IStyledBackgroundRadiuses;
}
export class StyledBackgroundColorValue extends StyledValue {
  readonly type = EStyledValue.BackgroundColor;
  readonly key = Sys.sdkApiVersion >= 14 ? StyledStringKey.BACKGROUND_COLOR : StyledStringKey.USER_DATA;
  private _option: IStyledBackgroundValue;
  constructor(option: IStyledBackgroundValue = {}) {
    super();
    this._option = option;
  }
  get option() {
    return this._option;
  }
  get value() {
    if (Sys.sdkApiVersion >= 14) {
      if (this._option.radius) {
        return new BackgroundColorStyle({
          color: this._option.color,
          radius: this._option.radius?.value,
        });
      }
      if (this._option.radiuses) {
        return new BackgroundColorStyle({
          color: this._option.color,
          radius: {
            topLeft: this._option.radiuses.topLeft?.value,
            topRight: this._option.radiuses.topRight?.value,
            bottomLeft: this._option.radiuses.bottomLeft?.value,
            bottomRight: this._option.radiuses.bottomRight?.value,
          },
        });
      }
      return new BackgroundColorStyle({
        color: this._option.color,
      });
    } else {
      return new StyledInvalidValue();
    }
  }
  cascade(value: StyledBackgroundColorValue) {
    if (!(value instanceof StyledBackgroundColorValue)) {
      return;
    }
    this._option.color = value._option.color ?? this._option.color;
    this._option.radius = value._option.radius ?? this._option.radius;
    this._option.radiuses = value._option.radiuses ?? this._option.radiuses;
  }
  copy(): StyledValue {
    return new StyledBackgroundColorValue({
      color: this._option.color,
      radius: this._option.radius,
      radiuses: this._option.radiuses,
    });
  }
  get empty() {
    return Object.keys(this._option).length > 0 ? false : true;
  }
}
export abstract class StyledDataSpan extends UserDataSpan {
  abstract readonly type: EStyledValue;
  readonly key: StyledStringKey = StyledStringKey.USER_DATA;
}
export class StyledUserBridgeValue extends StyledDataSpan {
  readonly type: EStyledValue = EStyledValue.UserBridge;
  readonly object: WeakRef<StyledObject>;
  constructor(object: StyledObject) {
    super();
    this.object = new WeakRef(object);
  }
}
class StyledInvalidValue extends UserDataSpan {
  private message: string = 'invalid-styled-value';
}