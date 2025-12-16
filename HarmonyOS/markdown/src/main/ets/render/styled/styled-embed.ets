// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { StyledObject, IStyledObject, EStyledObject } from './styled-object';
import { StyledValue } from './styled-value';
import { StyledSpan } from './styled';
import { MDLength, IMDArea, newLog, MDArea } from '../../util';
import { ITheme } from '../../theme';

const log = newLog('StyledEmbed');

export interface IStyledEmbed {
  initMetrics: CustomSpanMetrics;
  builderType: EStyledEmbedBuilder;
  embedController: StyledEmbedController;
  theme: ITheme;
}
@ObservedV2
export class StyledEmbed extends StyledObject {
  readonly type: EStyledObject = EStyledObject.Embed;
  readonly embedOption: IStyledEmbed;
  readonly initMetrics: CustomSpanMetrics;
  @Trace position?: Position;

  constructor(option: IStyledObject, embedOption: IStyledEmbed, styles?: StyledValue[]) {
    const metrics = embedOption.initMetrics;
    super(
      option,
      new StyledSpan({
        onMeasure: (_span, _measureInfo) => {
          return metrics;
        },
        onDraw: (_span, _context, drawInfo) => {
          this.position = {
            x: MDLength.metrics2length(MDLength.px2vp(drawInfo.x)),
            y: MDLength.metrics2length(MDLength.px2vp(drawInfo.lineTop - MDLength.vp2px(embedOption.theme.document?.blockSpace?.value ?? 0).value)),
          };
          this._area = {
            width: MDLength.vp(metrics.width),
            height: metrics.height !== undefined ? MDLength.vp(metrics.height) : undefined,
          };
        },
      }),
      styles,
    );
    this.embedOption = embedOption;
    this.initMetrics = metrics;
  }
  set area(area: IMDArea | undefined) {
    this._area = area;
    if (this.attached) {
      this.root?.deref()?.replaceStyle({
        start: this.offset, length: this.length,
        styledKey: StyledStringKey.CUSTOM_SPAN,
        styledValue: new StyledSpan({
          onMeasure: (_span, _measureInfo) => {
            if (MDArea.isEmpty(this._area)) {
              return this.embedOption.initMetrics;
            } else {
              return MDArea.area2metrics(this._area ?? {});
            }
          },
          onDraw: (_span, _context, drawInfo) => {
            this.position = {
              x: MDLength.metrics2length(MDLength.px2vp(drawInfo.x)),
              y: MDLength.metrics2length(MDLength.px2vp(drawInfo.lineTop - (MDLength.vp2px(this.embedOption.theme.document?.blockSpace?.value ?? 0).value))),
            };
          },
        }),
      });
    }
  }
  get embedController() {
    return this.embedOption.embedController;
  }
  fork(): StyledEmbed {
    const embed = new StyledEmbed(this.option, {
      initMetrics: MDArea.isEmpty(this.area) ? this.initMetrics : MDArea.area2metrics(this.area!),
      builderType: this.embedOption.builderType,
      embedController: this.embedController,
      theme: this.embedOption.theme,
    }, this.styleValues);
    return embed;
  }
  reuse(embed: StyledEmbed) {
    this.position = embed.position;
    this.embedOption.embedController = embed.embedOption.embedController;
    this.area = embed.embedOption.embedController.currentArea();
  }
  componentAreaChange(_oldValue: Area, newValue: Area) {
    if (!this.attached) {
      log.w('StyledEmbed not attached');
      return;
    }
    this.area = MDArea.area(newValue);
  }
  get likelyKey(): string {
    return `${this.embedOption.builderType}_${this.option.styled.node?.id}`;
  }
}
export enum EStyledEmbedBuilder {
  Table = 'table',
  Code = 'code',
  ImageGallery = 'image-gallery',
}
export class StyledEmbedController {
  readonly ID: number = StyledEmbedController.getGID();
  private static gid: number = 0;
  private static getGID() {
    return StyledEmbedController.gid++;
  }
  updateEmbed: (embed: StyledEmbed) => void = () => {};
  currentArea: () => IMDArea | undefined = () => undefined;
}