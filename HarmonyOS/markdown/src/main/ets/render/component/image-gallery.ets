// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { K_COMPONENT } from '../../util';
import { Engine, BaseEngine } from '../../engine';
import { ITheme } from '../../theme';
import { StyledEmbed } from '../styled';

@ComponentV2
export struct ImageGalleryComponent {
  @Require @Param styledEmbed: StyledEmbed;

  @Consumer(K_COMPONENT.THEME) theme: ITheme = {};
  @Consumer(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = new BaseEngine();

  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
    }

    .position(this.styledEmbed?.position)

    .scrollable(ScrollDirection.Horizontal)
    .border({ width: '2px', color: 0x28333333, style: BorderStyle.Solid, radius: '24px' })
    .clipContent(ContentClipMode.CONTENT_ONLY)
    .onAreaChange((oldValue, newValue) => {
      this.styledEmbed?.componentAreaChange(oldValue, newValue);
    })
  }
}