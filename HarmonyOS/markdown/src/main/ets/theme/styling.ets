// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

/**
 * 默认所有 Length 单位均为 vp
 */

import type { LengthMetrics } from '@kit.ArkUI';
import type { 
  IStyledTextValue, IStyledLetterSpacingValue, IStyledBaselineOffsetValue,
  IStyledLineHeightValue, IStyledDecorationValue,
  IStyledParagraphValue,
  IStyledImageAttachmentValue,
  IStyledBackgroundValue,
} from '../render/styled/styled-value';
import type { IMDMargin } from '../util';

export interface IBorderStyling {
  color?: ResourceColor;
  width?: LengthMetrics;
  radius?: LengthMetrics;
}
export interface ISizeStyling {
  height?: LengthMetrics;
  width?: LengthMetrics;
}
export interface ISpaceStyling extends ISizeStyling {}
export interface IStyling {}
export interface DocumentStyling extends IStyling {
  width?: LengthMetrics;
  letterSpacing?: IStyledLetterSpacingValue;
  baselineOffset?: IStyledBaselineOffsetValue;
  lineHeight?: IStyledLineHeightValue;
  font?: IStyledTextValue;
  blockSpace?: LengthMetrics;
  more?: IStyledTextValue;
}

export interface ParagraphStyling extends IStyling {
}
export interface ThematicBreakStyling extends IStyling {
  lineHeight?: IStyledLineHeightValue;
  lineColor?: ResourceColor;
}
export interface HeadingLevelStyling {
  font?: IStyledTextValue;
  lineHeight?: IStyledLineHeightValue;
}
export interface HeadingStyling extends IStyling {
  h1?: HeadingLevelStyling;
  h2?: HeadingLevelStyling;
  h3?: HeadingLevelStyling;
  h4?: HeadingLevelStyling;
  h5?: HeadingLevelStyling;
  h6?: HeadingLevelStyling;
}
export interface QuoteStyling extends IStyling {
  contentParagraph?: IStyledParagraphValue;
  font?: IStyledTextValue;
  edgeWidth?: LengthMetrics;
  edgeColor?: ResourceColor;
}
export interface CodeStyling extends IStyling {}
export interface TableStyling extends IStyling {
  headerFont?: IStyledTextValue;
  headerBackgroundColor?: ResourceColor;
  contentFont?: IStyledTextValue;
  cellMaxWidth?: LengthMetrics;
  cellMaxWidth4First?: LengthMetrics;
  cellLineHeight?: IStyledLineHeightValue;
}
export interface ListStyling extends IStyling {}
export interface ListItemStyling extends IStyling {
  contentParagraph?: IStyledParagraphValue;
  contentTopParagraph?: IStyledParagraphValue;
  contentTopBoxWidth?: LengthMetrics;
  contentTopBoxFont?: IStyledTextValue;
  contentTopBoxRadius?: LengthMetrics;
  contentTopBoxBackgroundColor?: ResourceColor;
  contentTopBadgeWidth?: LengthMetrics;
  contentTopBadgeBackgroundColor?: ResourceColor;
  contentBadgeWidth?: LengthMetrics;
  contentBadgeBackgroundColor?: ResourceColor;
  taskFlagWidth?: LengthMetrics;
  taskFlagColor?: ResourceColor;
}
export interface HtmlTagStyling extends IStyling {}
export interface MathStyling extends IStyling {
  cssFontSize?: string;
  cssColor?: string;
  cssMaxWidth?: string;
  cssMaxHeight?: string;
}

export interface TextStyling extends IStyling {}
export interface LineBreakStyling extends IStyling {}
export interface EmojiStyling extends IStyling {}
export interface StrongStyling extends IStyling {
  font?: IStyledTextValue;
}
export interface EmphasisStyling extends IStyling {
  font?: IStyledTextValue;
}
export interface StrikeThroughStyling extends IStyling {
  decoration?: IStyledDecorationValue;
}
export interface UnderlineStyling extends IStyling {
  markHeight?: LengthMetrics;
  markColor?: ResourceColor;
}
export interface IconStyling extends IStyling {
  size?: ISizeStyling;
  content?: IStyledImageAttachmentValue;
}
export interface ImageStyling extends IStyling {
  size?: ISizeStyling;
  content?: IStyledImageAttachmentValue;
  border?: IBorderStyling;
  background?: IStyledBackgroundValue;
  textFont?: IStyledTextValue;
  textBlock?: IStyledParagraphValue;
  maxHeight?: LengthMetrics;
}
export interface LinkStyling extends IStyling {
  font?: IStyledTextValue;
  iconSize?: ISizeStyling;
  iconSpace?: ISpaceStyling;
}
export interface FootnoteRefStyling extends IStyling {
  font?: IStyledTextValue;
  background?: IStyledBackgroundValue;
  minSize?: ISizeStyling;
}
export interface FootnoteDefStyling extends IStyling {}
export interface SuperscriptStyling extends IStyling {
  font?: IStyledTextValue;
}
export interface SubscriptStyling extends IStyling {
  font?: IStyledTextValue;
}
export interface InlineCodeStyling extends IStyling {
  font?: IStyledTextValue;
  background?: IStyledBackgroundValue;
  contentPadding?: Padding;
}
export interface ContentBoxStyling extends IStyling {
  barMargin?: IMDMargin;
  barFont?: IStyledTextValue;
  barBackgroundColor?: ResourceColor;
  barActionIconWidth?: LengthMetrics;
  barActionIconHeight?: LengthMetrics;
  headerFont?: IStyledTextValue;
  headerBackgroundColor?: ResourceColor;
  border?: IBorderStyling;
}

export interface InlineStyling extends IStyling {}