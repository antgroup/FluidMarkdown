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
  likelyKey: string;
  @Trace position?: Position;

  constructor(option: IStyledObject, embedOption: IStyledEmbed, styles?: StyledValue[]) {
    const metrics = embedOption.initMetrics;
    super(
      option,
      new StyledSpan({
        onMeasure: (_span, _measureInfo) => {
          return metrics;
        },
        onDraw: (span, _context, drawInfo) => {
          const position: Position = {
            x: MDLength.metrics2length(MDLength.px2vp(drawInfo.x)),
            y: MDLength.metrics2length(MDLength.px2vp(drawInfo.lineTop - MDLength.vp2px(embedOption.theme.document?.blockSpace?.value ?? 0).value)),
          };
          const _area: IMDArea = {
            width: MDLength.vp(metrics.width),
            height: metrics.height !== undefined ? MDLength.vp(metrics.height) : undefined,
          };
          log.i(`${this.id} init position(${this.position?.x}, ${this.position?.y}) area(${span.metrics.width}, ${span.metrics.height})`);
          this.position = position;
          this.area = _area;
        },
      }),
      styles,
    );
    this.embedOption = embedOption;
    this.initMetrics = metrics;
    this.likelyKey = `${this.embedOption.builderType}_${this.option.styled.node?.id}`;
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
          onDraw: (span, _context, drawInfo) => {
            const position: Position = {
              x: MDLength.metrics2length(MDLength.px2vp(drawInfo.x)),
              y: MDLength.metrics2length(MDLength.px2vp(drawInfo.lineTop - (MDLength.vp2px(this.embedOption.theme.document?.blockSpace?.value ?? 0).value))),
            };
            log.i(`${this.id} update position(${this.position?.x}, ${this.position?.y}) area(${span.metrics.width}, ${span.metrics.height})`);
            this.position = position;
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
    const position = embed.position;
    const area = embed.embedOption.embedController.currentArea();
    log.i(`${this.id} reuse position(${this.position?.x}, ${this.position?.y}) area(${this.area?.width?.value}, ${this.area?.height?.value}`);
    this.position = position;
    this.embedOption.embedController = embed.embedOption.embedController;
    this.area = area;
  }
  componentAreaChange(_oldValue: Area, newValue: Area) {
    if (!this.attached) {
      log.w('StyledEmbed not attached');
      return;
    }
    this.area = MDArea.area(newValue);
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