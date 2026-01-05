// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Node } from '../../service/ast/node';
import { newLog, K_COMPONENT, IMDArea, MDArea } from '../../util';
import {
  Styled, StyledObject, StyledEmbed, EStyledObject, type StyledValue,
  EStyledObjectEvent, IStyledObjectAppendEvent, type IStyledObjectReplaceStyleEvent,
  StyledTextValue, EStyledEmbedBuilder,
} from '../styled';
import type { ITheme } from '../../theme';
import { Engine, BaseEngine } from '../../engine';
import { buildComponent } from './builder';
import { TextComponent, TextComponentController } from './text';
import {
  ETypingMode, ETypingEvent, Typing,
  type ITypingPauseEvent, type ITypingResumeEvent, type ITypingFinishEvent
} from '../typing';

const log = newLog('EmbedComponent');

@ComponentV2
export struct EmbedComponent {
  static _gid: number = 0;
  static gid() {
    return EmbedComponent._gid++;
  }
  private gid: number = EmbedComponent.gid();
  get ID() {
    return this.gid;
  }

  @Param node?: Node = undefined;
  @Require @Param @Once area: IMDArea = {};
  @Param @Once styles?: StyledValue[] = undefined;
  @Param @Once controller?: EmbedComponentController = undefined;

  private textComponentController = new TextComponentController({});
  @Local content: StyledObject = StyledObject.empty();
  @Local layers: StyledEmbed[] = [];

  @Event onEmbedComponentBeforeAboutToAppear: Callback<IEmbedComponentEvent>;
  @Event onEmbedComponentAfterAboutToAppear: Callback<IEmbedComponentEvent>;
  @Event onEmbedComponentBeforeAboutToDisappear: Callback<IEmbedComponentEvent>;
  @Event onEmbedComponentAfterAboutToDisappear: Callback<IEmbedComponentEvent>;

  @Consumer(K_COMPONENT.THEME) theme: ITheme = {};
  @Consumer(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = new BaseEngine();

  private bindController() {
    if (this.controller) {
      this.controller.typing.ctx = () => this.sharedEngine.ctx;
      this.controller.typing.update = (content, mode) => {
        if (!(content instanceof Node)) {
          return;
        }
        this.controller!.typing.mode = () => mode;
        if (mode === ETypingMode.Update) {
          this.attach4update(mode, content);
        } else {
          this.attach4typing(mode, content);
        }
      };
    }
  }

  @Monitor('node') onNodeChange(monitor: IMonitor) {
    const node = monitor.value<Node>();
    if (node) {
      if (node.now?.hash !== node.before?.hash) {
        this.attach4normal(node.now);
      }
    } else {
      this.layers = [];
      this.content = StyledObject.empty();
    }
  }
  private attach4normal(node?: Node) {
    if (!node) {
      return;
    }
    this.layers = [];
    const content = StyledObject.root(this.area, this.styles)
      .on<IStyledObjectAppendEvent>(EStyledObjectEvent.DidAppend, event => {
        if (event.target.type === EStyledObject.Embed) {
          const embed = event.target as StyledEmbed;
          this.layers.push(embed);
        }
      })
      .on<IStyledObjectReplaceStyleEvent>(EStyledObjectEvent.DidReplaceStyle, () => {
        this.textComponentController.refresh();
      });

    Styled.create({
      node,
    })?.build({
      theme: this.theme,
      engine: this.sharedEngine,
      didCreateStyled: (styled) => {
        content.attach(styled);
      },
    });
    this.content = content;
  }
  private attach4update(mode: ETypingMode, node?: Node) {
    if (!node) {
      this.layers = [];
      this.content = StyledObject.empty();
      return;
    }
    const currentLayers: Record<string, StyledEmbed> = {};
    const content = StyledObject.root(this.area, this.styles)
      .on<IStyledObjectAppendEvent>(EStyledObjectEvent.DidAppend, event => {
        if (event.target.type === EStyledObject.Embed) {
          const embed = event.target as StyledEmbed;
          let existedIndex: number | undefined = undefined;
          let existed: StyledEmbed | undefined = undefined;
          this.layers.forEach((ele, index) => {
            if (ele.likelyKey === embed.likelyKey) {
              existedIndex = index;
              existed = ele;
            }
          });
          if (existed !== undefined && existedIndex !== undefined) {
            embed.reuse(existed);
            (existed as StyledEmbed).embedController.updateEmbed(embed);
          } else {
            this.layers.push(embed);
          }
          currentLayers[embed.likelyKey] = embed;
        }
      })
      .on<IStyledObjectReplaceStyleEvent>(EStyledObjectEvent.DidReplaceStyle, () => {
        this.textComponentController.refresh();
      });
    const likelyUtil = new EmbedComponentLikelyUtil();
    Styled.create({
      node,
    })?.build({
      theme: this.theme,
      engine: this.sharedEngine,
      didCreateStyled: (styled) => {
        if (styled.type === EStyledObject.Embed) {
          const embed = styled as StyledEmbed;
          embed.likelyKey = `${embed.embedOption.builderType}_${likelyUtil.index(embed.embedOption.builderType)}`;
        }
        content.attach(styled);
      },
    });
    this.content = content;
    do {
      //  clear unused layers
      let index = 0;
      while (index < this.layers.length) {
        const embed = this.layers[index];
        const current = currentLayers[embed.likelyKey];
        if (current) {
          this.layers.splice(index, 1, current);
        } else {
          this.layers.splice(index, 1);
        }
        index++;
      }
    } while (0);
  }
  private attach4typing(mode: ETypingMode, node?: Node) {
    if (!this.controller) {
      return;
    }
    const targetContent = StyledObject.root(this.area, this.styles)
      .on<IStyledObjectReplaceStyleEvent>(EStyledObjectEvent.DidReplaceStyle, (event) => {
        if (!event.spanStyle) {
          //  empty style event only posted from image-span image source changed
          this.textComponentController.refresh();
        }
      });
    Styled.create({
      node,
    })?.build({
      theme: this.theme,
      engine: this.sharedEngine,
      didCreateStyled: (styled) => {
        targetContent.attach(styled);
      },
    });

    let offset: number = 0;
    if (mode === ETypingMode.Begin) {
      this.layers = [];
    } else {
      offset = Math.min(this.content.length, targetContent.length);
    }
    const step = this.controller.typing.step;
    const currentLayers: Record<string, StyledEmbed> = {};

    const hasMore = (): boolean => {
      return !!(this.controller?.typing.more) && !(offset >= targetContent.length);
    };
    this.controller!.typing.typingTimer.onDidStop = () => {
      if (hasMore()) {
        this.content.attach(StyledObject.more(
          this.controller?.typing.more || '',
          [new StyledTextValue(this.theme.document?.more)],
        ));
        this.textComponentController.refresh();
      }
    }
    this.controller!.typing.typingTimer.onWillResume = () => {};
    this.controller!.typing.typingTimer.onDidStop = () => {};
    this.controller!.typing.completed = () => offset >= targetContent.length;

    log.i(`${this.ID} attach for typing, mode: ${mode} offset: ${offset} targetLength: ${targetContent.length}`);

    this.controller?.typing.typingTimer.start(() => {
      
      offset = Math.min(offset + step, targetContent.length);

      log.i(`${this.ID} typing onStep, offset: ${offset}`);

      const currentContent = StyledObject.root(this.area, this.styles)
        .on<IStyledObjectAppendEvent>(EStyledObjectEvent.DidAppend, event => {
          if (event.target.type === EStyledObject.Embed) {
            const embed = event.target as StyledEmbed;
            let existedIndex: number | undefined = undefined;
            let existed: StyledEmbed | undefined = undefined;
            this.layers.forEach((ele, index) => {
              if (ele.likelyKey === embed.likelyKey) {
                existedIndex = index;
                existed = ele;
              }
            });
            if (existed !== undefined && existedIndex !== undefined) {
              embed.reuse(existed);
              (existed as StyledEmbed).embedController.updateEmbed(embed);
            } else {
              this.layers.push(embed);
            }
            currentLayers[embed.likelyKey] = embed;
          }
        })
        .on<IStyledObjectReplaceStyleEvent>(EStyledObjectEvent.DidReplaceStyle, () => {
          this.textComponentController.refresh();
        });

      if (offset > 0) {
        const likelyUtil = new EmbedComponentLikelyUtil();
        targetContent.subStyledObjects(0, offset).forEach(ele => {
          if (ele.object instanceof StyledObject) {
            if (ele.object.type === EStyledObject.Embed) {
              const embed = ele.object as StyledEmbed;
              embed.likelyKey = `${embed.embedOption.builderType}_${likelyUtil.index(embed.embedOption.builderType)}`;
            }
          }
          currentContent.attach(ele.object);
        });
        this.content = currentContent;
      }
      do {
        //  clear unused layers
        let index = 0;
        while (index < this.layers.length) {
          const embed = this.layers[index];
          const current = currentLayers[embed.likelyKey];
          if (current) {
            this.layers.splice(index, 1, current);
          } else {
            this.layers.splice(index, 1);
          }
          index++;
        }
      } while (0);

      if (offset >= targetContent.length) {
        log.i(`${this.ID} typing onFinish, offset: ${offset}`);
        this.controller?.typing.typingTimer.reset();
        //  notify finish
        this.controller?.typing.emit<ITypingFinishEvent>(ETypingEvent.Finish, {});
      }
    }, this.controller.typing.speed);
  }
  private onRootTypingPause = (_e: ITypingPauseEvent) => {
    this.controller?.typing.pause();
  }
  private onRootTypingResume = (_e: ITypingResumeEvent) => {
    this.controller?.typing.resume();
  }
  aboutToAppear(): void {
    log.i(`aboutToAppear node: ${JSON.stringify(this.node?.summary)}`);
    this.onEmbedComponentBeforeAboutToAppear({ controller: this.controller });
    this.sharedEngine.ctx!.typing().rootController?.deref()?.on<ITypingPauseEvent>(ETypingEvent.Pause, this.onRootTypingPause);
    this.sharedEngine.ctx!.typing().rootController?.deref()?.on<ITypingResumeEvent>(ETypingEvent.Resume, this.onRootTypingResume);
    this.bindController();
    this.attach4normal(this.node);
    this.onEmbedComponentAfterAboutToAppear({ controller: this.controller });
  }
  aboutToDisappear(): void {
    log.i(`aboutToDisappear node: ${JSON.stringify(this.node?.summary)}`);
    this.onEmbedComponentBeforeAboutToDisappear({ controller: this.controller });
    this.sharedEngine.ctx!.typing().rootController?.deref()?.off(ETypingEvent.Pause, this.onRootTypingPause);
    this.sharedEngine.ctx!.typing().rootController?.deref()?.off(ETypingEvent.Resume, this.onRootTypingResume);
    this.onEmbedComponentAfterAboutToDisappear({ controller: this.controller });
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      //  text content
      TextComponent({
        content: this.content, componentController: this.textComponentController,
      })
      //  overlay span
      ForEach(this.layers, (layer: StyledEmbed) => {
        buildComponent(layer);
      }, (layer: StyledEmbed) => layer.likelyKey)
    }
  }
}

export class EmbedComponentController {
  readonly typing: Typing = new Typing();
}
export interface IEmbedComponentEvent {
  controller?: EmbedComponentController;
}

class EmbedComponentLikelyUtil {
  private indexStore: Map<EStyledEmbedBuilder, number> = new Map();
  index(builderType: EStyledEmbedBuilder): number {
    let index = this.indexStore.get(builderType);
    if (index === undefined) {
      index = 0;
      this.indexStore.set(builderType, index);
    } else {
      index++;
      this.indexStore.set(builderType, index);
    }
    return index;
  }
}