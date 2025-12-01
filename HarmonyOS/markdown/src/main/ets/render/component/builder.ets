// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { StyledEmbed, EStyledEmbedBuilder } from '../styled';
import { TableComponent } from './table';
import { CodeComponent } from './code';
import { ImageGalleryComponent } from './image-gallery';

@Builder
export function buildComponent(builder: StyledEmbed) {
  if (builder.embedOption.builderType === EStyledEmbedBuilder.Table) {
    TableComponent({
      styledEmbed: builder,
    })
  } else if (builder.embedOption.builderType === EStyledEmbedBuilder.Code) {
    CodeComponent({
      styledEmbed: builder,
    })
  } else if (builder.embedOption.builderType === EStyledEmbedBuilder.ImageGallery) {
    ImageGalleryComponent({
      styledEmbed: builder,
    })
  }
}