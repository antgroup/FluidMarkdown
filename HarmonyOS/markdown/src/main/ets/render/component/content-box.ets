// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { K_COMPONENT, MDLength, MDMargin } from '../../util';
import { Engine } from '../../engine';
import { ITheme } from '../../theme';
import { image } from '@kit.ImageKit';

@ComponentV2
export struct ContentBoxComponent {
  @Consumer(K_COMPONENT.THEME) theme: ITheme = {};
  @BuilderParam content: () => void;
  @Require @Param bar: IContentBoxBar;
  @Event onActionClick?: (action: IContentBoxAction, event: ClickEvent) => void = undefined;

  private scroller: Scroller = new Scroller();

  aboutToAppear(): void {
  }

  build() {
    Column() {
      //  bar
      Row() {
        Text(this.bar.title)
          .fontColor(this.theme.contentBox?.barFont?.fontColor)
          .fontSize(this.theme.contentBox?.barFont?.fontSize?.value)
          .fontWeight(this.theme.contentBox?.barFont?.fontWeight)
          .margin(this.theme.contentBox?.barMargin ? MDMargin.lengthMargin(this.theme.contentBox?.barMargin) : undefined)
        Row() {
          ForEach(this.bar.actions ?? [], (action: IContentBoxAction) => {
            Image(action.icon)
              .width(MDLength.metrics2length(this.theme.contentBox?.barActionIconWidth ?? MDLength.vp(0)))
              .height(MDLength.metrics2length(this.theme.contentBox?.barActionIconHeight ?? MDLength.vp(0)))
              .margin({ left: 10 })
              .onClick(event => this.onActionClick?.(action, event))
          })
        }
        .margin(this.theme.contentBox?.barMargin ? MDMargin.lengthMargin(this.theme.contentBox?.barMargin) : undefined)
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .backgroundColor(this.theme.contentBox?.barBackgroundColor)
      .border({
        radius: {
          topLeft: this.theme.contentBox?.border?.radius?.value ? this.theme.contentBox?.border?.radius?.value - 1 : undefined,
          topRight: this.theme.contentBox?.border?.radius?.value ? this.theme.contentBox?.border?.radius?.value - 1 : undefined,
        },
      })
      .clip(true)

      //  content
      Scroll(this.scroller) {
        this.content()
      }
      .scrollable(ScrollDirection.Horizontal)
    }
    .border({
      width: MDLength.metrics2length(this.theme.contentBox?.border?.width ?? MDLength.vp(0)),
      color: this.theme.contentBox?.border?.color,
      radius: MDLength.metrics2length(this.theme.contentBox?.border?.radius ?? MDLength.vp(0)),
      style: BorderStyle.Solid,
    })
    .clip(true)
  }
}
export interface IContentBoxBar {
  title?: string;
  actions?: IContentBoxAction[];
}
export interface IContentBoxAction {
  icon?: image.PixelMap;
  tag?: string | EContentBoxAction;
}
export enum EContentBoxAction {
  Open = 'open',
  Copy = 'copy',
}
export abstract class ContentBoxBar {
  static openAction(option?: IContentBoxAction, engine?: Engine): IContentBoxAction {
    return {
      icon: option?.icon ?? engine?.image?.load('icon_open.png')?.createPixelMapSync(),
      tag: option?.tag ?? EContentBoxAction.Open,
    };
  }
  static copyAction(option?: IContentBoxAction, engine?: Engine): IContentBoxAction {
    return {
      icon: option?.icon ?? engine?.image?.load('icon_copy.png')?.createPixelMapSync(),
      tag: option?.tag ?? EContentBoxAction.Copy,
    };
  }
}