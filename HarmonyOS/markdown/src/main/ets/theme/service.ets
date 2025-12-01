// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Service, EService, Plugin } from '../engine';
import { MDLength } from '../util';
import type { ITheme } from './theme';

export class ThemeService extends Service {
  readonly type: EService = EService.Theme;
  static _default?: ITheme;
  add<T extends Plugin>(_plugin: T): void {}
  get theme(): ITheme {
    if (!ThemeService._default) {
      ThemeService._default = ThemeService.default();
    }
    return ThemeService._default;
  }
  static default(): ITheme {
    return {
      document: {
        letterSpacing: { spacing: MDLength.vp(0.5) },
        lineHeight: { height: MDLength.vp(24) },
        font: {
          fontColor: 0x333333,
          fontSize: MDLength.vp(15),
        },
        blockSpace: MDLength.vp(12),
        more: {
          fontColor: 0x999999,
          fontSize: MDLength.vp(12),
          fontWeight: FontWeight.Normal,
        },
      },
      paragraph: {
      },
      thematicBreak: {
        lineHeight: { height: MDLength.vp(2) },
        lineColor: 0xe2e5f3,
      },
      heading: {
        h1: {
          font: { fontWeight: FontWeight.Bold },
        },
        h2: {
          font: { fontWeight: FontWeight.Bold },
        },
        h3: {
          font: { fontWeight: FontWeight.Bold },
        },
        h4: {
          font: { fontWeight: FontWeight.Bold },
        },
        h5: {
          font: { fontWeight: FontWeight.Bold },
        },
        h6: {
          font: { fontWeight: FontWeight.Bold },
        },
      },
      quote: {
        contentParagraph: {
          leadingMargin: MDLength.vp(18),
        },
        font: { fontColor: 0x7d88ac },
        edgeWidth: MDLength.vp(1),
        edgeColor: 0x7d88ac,
      },
      image: {
        size: { height: MDLength.vp(180) },
        content: {
          verticalAlign: ImageSpanAlignment.CENTER,
          objectFit: ImageFit.Contain,
          layoutStyle: { borderRadius: MDLength.vp(12) }
        },
        border: {
          width: MDLength.vp(0.5),
          color: 0x979797,
          radius: MDLength.vp(12),
        },
        background: {
          color: 0xd8d8d8,
          radius: MDLength.vp(12),
        },
        textFont: { fontColor: Color.White },
        maxHeight: MDLength.vp(1000),
      },
      underline: {
        markHeight: MDLength.vp(6),
        markColor: 0x801677ff,
      },
      strong: {
        font: { fontWeight: FontWeight.Bold },
      },
      emphasis: {
        font: { fontStyle: FontStyle.Italic },
      },
      strikeThrough: {
        decoration: { type: TextDecorationType.LineThrough },
      },
      subscript: {
        font: { fontSize: MDLength.vp(9) },
      },
      superscript: {
        font: { fontSize: MDLength.vp(9) },
      },
      link: {
        font: { fontColor: 0x4745ca },
        iconSize: { width: MDLength.vp(12), height: MDLength.vp(12) },
        iconSpace: { width: MDLength.vp(1) },
      },
      icon: {
        size: { width: MDLength.vp(13), height: MDLength.vp(13) },
        content: {
          verticalAlign: ImageSpanAlignment.CENTER,
          objectFit: ImageFit.Contain,
        },
      },
      footnoteRef: {
        font: {
          fontColor: 0x999999,
          fontSize: MDLength.vp(10),
        },
        background: {
          color: 0xD8DEE4,
          radius: MDLength.vp(9),
        },
        minSize: { width: MDLength.vp(14), height: MDLength.vp(14) },
      },
      inlineCode: {
        background: {
          color: 0xD8DEE4,
          radius: MDLength.vp(4),
        },
        contentPadding: { left: MDLength.vp(4).value, right: MDLength.vp(4).value },
      },
      listItem: {
        contentParagraph: { leadingMargin: MDLength.vp(15) },
        contentTopParagraph: { leadingMargin: MDLength.vp(20) },
        contentTopBoxWidth: MDLength.vp(14),
        contentTopBoxFont: { fontSize: MDLength.vp(10), fontColor: Color.White },
        contentTopBoxRadius: MDLength.vp(3),
        contentTopBoxBackgroundColor: 0x0e51ce,
        contentTopBadgeWidth: MDLength.vp(8),
        contentTopBadgeBackgroundColor: 0x0e51ce,
        contentBadgeWidth: MDLength.vp(4),
        contentBadgeBackgroundColor: 0x0d1f38,
        taskFlagWidth: MDLength.vp(12),
        taskFlagColor: 0x0e51ce,
      },
      table: {
        headerFont: {
          fontSize: MDLength.vp(13),
          fontColor: 0x999999,
          fontWeight: FontWeight.Bold,
        },
        headerBackgroundColor: 0x0a1f3b63,
        contentFont: {
          fontSize: MDLength.vp(13),
          fontColor: 0x333333,
        },
        cellMaxWidth: MDLength.vp(210),
        cellMaxWidth4First: MDLength.vp(90),
        cellLineHeight: { height: MDLength.vp(20) },
      },
      contentBox: {
        barMargin: {
          left: MDLength.vp(12), right: MDLength.vp(12),
          top: MDLength.vp(8), bottom: MDLength.vp(8),
        },
        barFont: {
          fontSize: MDLength.vp(13),
          fontColor: 0x999999,
          fontWeight: FontWeight.Bold,
        },
        barBackgroundColor: 0x141f3b63,
        barActionIconWidth: MDLength.vp(20),
        barActionIconHeight: MDLength.vp(20),
        headerFont: {
          fontSize: MDLength.vp(13),
          fontColor: 0x999999,
          fontWeight: FontWeight.Bold,
        },
        headerBackgroundColor: 0x0a1f3b63,
        border: {
          width: MDLength.vp(1),
          color: 0x28333333,
          radius: MDLength.vp(12),
        }
      },
      math: {
        cssFontSize: `${MDLength.vp2px(15).value}px`,
        cssColor: '#333333',
      },
    };
  }
}