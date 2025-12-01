// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

/**
 * 默认所有 Length 单位均为 vp
 */

import * as S from './styling';

export interface ITheme {
  document?: S.DocumentStyling;
  paragraph?: S.ParagraphStyling;
  thematicBreak?: S.ThematicBreakStyling;
  heading?: S.HeadingStyling;
  quote?: S.QuoteStyling;
  code?: S.CodeStyling;
  inlineCode?: S.InlineCodeStyling;
  table?: S.TableStyling;
  list?: S.ListStyling;
  listItem?: S.ListItemStyling;
  htmlTag?: S.HtmlTagStyling;
  math?: S.MathStyling;
  text?: S.TextStyling;
  lineBreak?: S.LineBreakStyling;
  emoji?: S.EmojiStyling;
  strong?: S.StrongStyling;
  emphasis?: S.EmphasisStyling;
  strikeThrough?: S.StrikeThroughStyling;
  underline?: S.UnderlineStyling;
  image?: S.ImageStyling;
  link?: S.LinkStyling;
  icon?: S.IconStyling;
  footnoteRef?: S.FootnoteRefStyling;
  footnoteDef?: S.FootnoteDefStyling;
  superscript?: S.SuperscriptStyling;
  subscript?: S.SubscriptStyling;
  inline?: S.InlineStyling;
  contentBox?: S.ContentBoxStyling;
}