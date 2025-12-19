// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { Engine, BaseEngine } from './engine';
import { newLog, K_COMPONENT, IMDArea, MDArea, EMarkdownMode } from './util';
import { Program, type Node } from './service/ast/node';
import {
  EmbedComponent, EmbedComponentController,
  type ITextComponentSelectionChangeEvent,
  type ITextComponentEvent, type ITextComponentSelectionOption,
  type ITableComponentActionClickEvent, type IContentBoxBar,
  type ITableComponentEvent,
  type ICodeComponentEvent, type ICodeComponentActionClickEvent,
  Typing, ETypingEvent, ITypingFinishEvent, ETypingMode,
  TextContentController,
} from './render';
import { type ITheme, ThemeService } from './theme';

const log = newLog('Markdown');

@ComponentV2
export struct Markdown {
  private static gid: number = 0;
  private static createGid(): number {
    return Markdown.gid++;
  }
  readonly ID: number = Markdown.createGid();

  @Param content: string = '';
  @Param @Once controller: MarkdownController = new MarkdownController({});
  @Param @Once engine: Engine = new BaseEngine();
  @Param @Once mode: EMarkdownMode = EMarkdownMode.Normal;
  @Param @Once area: IMDArea = {};

  @Event onMarkdownBeforeAboutToAppear: Callback<IMarkdownEvent>;
  @Event onMarkdownAfterAboutToAppear: Callback<IMarkdownEvent>;
  @Event onMarkdownBeforeAboutToDisappear: Callback<IMarkdownEvent>;
  @Event onMarkdownAfterAboutToDisappear: Callback<IMarkdownEvent>;
  @Event onMarkdownBeforeAboutToReuse: Callback<IMarkdownEvent>;
  @Event onMarkdownAfterAboutToReuse: Callback<IMarkdownEvent>;
  @Event onMarkdownBeforeAboutToRecycle: Callback<IMarkdownEvent>;
  @Event onMarkdownAfterAboutToRecycle: Callback<IMarkdownEvent>;
  @Event onMarkdownAreaChange: Callback<IMarkdownAreaChangeEvent>;
  @Event onMarkdownNodeClick: Callback<IMarkdownNodeClickEvent>;
  @Event onMarkdownTextComponentSelectionOption: Callback<IMarkdownTextComponentSelectionOptionEvent, ITextComponentSelectionOption>;
  @Event onMarkdownTextComponentSelectionChange: Callback<IMarkdownTextComponentSelectionChangeEvent>;
  @Event onMarkdownTableComponentActionClick: Callback<IMarkdownTableComponentActionClickEvent>;
  @Event onMarkdownTableComponentContentBoxBar: Callback<IMarkdownTableComponentBarOptionEvent, IContentBoxBar | undefined>;
  @Event onMarkdownCodeComponentActionClick: Callback<IMarkdownCodeComponentActionClickEvent>;
  @Event onMarkdownCodeComponentContentBoxBar: Callback<IMarkdownCodeComponentBarOptionEvent, IContentBoxBar | undefined>;
  @Event onMarkdownTypingReady: Callback<IMarkdownEvent>;
  @Event onMarkdownTypingCompleted: Callback<IMarkdownEvent>;

  @Local program?: Program;
  @Provider(K_COMPONENT.THEME) theme: ITheme = this.engine.theme!.theme;
  @Provider(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = this.engine;

  private embedController: EmbedComponentController = new EmbedComponentController();
  private dirtyContent?: IMarkdownDirtyContent;
  private uiArea?: Area;
  private lastParseContent?: string;
  private embedComponentTypingReady: boolean = false;

  @Monitor('area') _onMarkdownAreaChange(monitor: IMonitor) {
    const value = monitor.value<IMDArea>();
    if (MDArea.isEmpty(value?.before) && this.mode === EMarkdownMode.Normal) {
      this.parse(this.content, program => {
        this.program = program;
      });
    }
  }
  @Monitor('content') onContentChange(monitor: IMonitor) {
    const value = monitor.value<string>();
    log.i(`${this.ID} onContentChange now: ${value?.now} before: ${value?.before}`);
    if (this.mode === EMarkdownMode.Normal) {
      this.parse(value?.now, program => {
        this.program = program;
      });
    }
  }
  private parse(content: string = '', callback: Callback<Program>) {
    log.i(`${this.ID} parse content: ${content}`);
    if (this.lastParseContent === content) {
      log.w(`${this.ID} parse content is same as last, skip`);
      return;
    }
    this.lastParseContent = content;
    this.sharedEngine.ast?.parse(content).then(v => {
      log.i(`${this.ID} parse content success: ${JSON.stringify(v.program.document.summary)}`);
      callback(v.program);
    }).catch((e: Error) => {
      log.e(`${this.ID} parse content failed: ${e.message} ${e.name}`)
    });
  }
  private bindController() {
    this.sharedEngine.ctx!.typing = () => ({
      speed: this.controller.typingSpeed,
      step: this.controller.typingStep,
      rootController: new WeakRef(this.controller.typing),
      more: this.controller.typingMore,
    });
    this.sharedEngine.ctx!.textContentController = () => {
      return this.controller.textContentController;
    }
    this.controller.textContentController.isHit = (_type, event) => {
      return MDArea.isAreaContainFinger(this.uiArea, event.fingerList.slice().pop());
    };
    this.controller.typing.should = () => {
      return this.mode === EMarkdownMode.Typing;
    };
    this.controller.typing.processing = () => {
      return this.embedController.typing.processing();
    };
    this.controller.typing.update = (content, mode) => {
      if (this.mode !== EMarkdownMode.Typing) {
        log.w(`${this.ID} current mode(${this.mode}) is not typing, can not update typing content`);
        return;
      }
      if (!this.embedComponentTypingReady) {
        log.w(`${this.ID} embed component typing not ready, skip update typing content: ${content}`);
      }
      if (typeof content === 'string') {
        this.parse(content, program => {
          log.i(`${this.ID} will update typing content. node: ${program.document.hash}, mode: ${mode}, content: ${content}`);
          if (this.embedController.typing.processing()) {
            log.i(`${this.ID} catch typing content. node: ${program.document.hash}, mode: ${mode}, content: ${content}`);
            this.dirtyContent = { mode, program, content };
          } else {
            this.embedController.typing.update(program.document, mode);
          }
        });
      }
    };
  }
  private onEmbedControllerTypingFinish = (_e: ITypingFinishEvent) => {
    if (this.dirtyContent) {
      const program = this.dirtyContent.program;
      const mode = this.dirtyContent.mode;
      const content = this.dirtyContent.content;
      log.i(`${this.ID} retry update typing content. node: ${program.document.hash}, mode: ${mode}, content: ${content}`);
      this.embedController.typing.update(program.document, mode);
      this.dirtyContent = undefined;
    } else {
      log.i(`${this.ID} emit typing finish event`);
      // this.controller.typing.emit<ITypingFinishEvent>(ETypingEvent.Finish, {});
      this.onMarkdownTypingCompleted({});
    }
  }

  aboutToAppear(): void {
    log.i(`${this.ID} before aboutToAppear`);
    this.onMarkdownBeforeAboutToAppear({});
    this.engine.ctx!.ctx = this.getUIContext();
    this.engine.ctx!.markdownMode = () => this.mode;
    this.embedController.typing.on<ITypingFinishEvent>(ETypingEvent.Finish, this.onEmbedControllerTypingFinish);
    this.bindController();

    this.engine.event!.onClick = data => {
      this.onMarkdownNodeClick({ node: data.node, event: data.event });
    };
    this.engine.event!.onTextComponentSelectionChange = event => {
      this.onMarkdownTextComponentSelectionChange({ textEvent: event });
    };
    this.engine.event!.onTextComponentSelectionOption = event => {
      return this.onMarkdownTextComponentSelectionOption({ textEvent: event }) ?? {};
    };
    this.engine.event!.onTableComponentActionClick = event => {
      this.onMarkdownTableComponentActionClick({ tableEvent: event });
    };
    this.engine.event!.onTableComponentBarOption = event => {
      return this.onMarkdownTableComponentContentBoxBar({ tableEvent: event });
    };
    this.engine.event!.onCodeComponentActionClick = event => {
      this.onMarkdownCodeComponentActionClick({ codeEvent: event });
    };
    this.engine.event!.onCodeComponentBarOption = event => {
      return this.onMarkdownCodeComponentContentBoxBar({ codeEvent: event });
    };
    if (!MDArea.isEmpty(this.area)) {
      this.parse(this.content, program => {
        this.program = program;
      });
    }
    this.onMarkdownAfterAboutToAppear({});

    log.i(`${this.ID} after aboutToAppear`);
  }
  aboutToDisappear(): void {
    log.i(`${this.ID} before aboutToDisappear`);
    this.onMarkdownBeforeAboutToDisappear({});
    this.embedController.typing.off(ETypingEvent.Finish, this.onEmbedControllerTypingFinish);
    this.onMarkdownAfterAboutToDisappear({});
    log.i(`${this.ID} after aboutToDisappear`);
  }
  aboutToReuse(): void {
    log.i(`${this.ID} before aboutToReuse`);
    this.onMarkdownBeforeAboutToReuse({});
    this.onMarkdownAfterAboutToReuse({});
    log.i(`${this.ID} after aboutToReuse`);
  }
  aboutToRecycle(): void {
    log.i(`${this.ID} before aboutToRecycle`);
    this.onMarkdownBeforeAboutToRecycle({});
    this.onMarkdownAfterAboutToRecycle({});
    log.i(`${this.ID} after aboutToRecycle`);
  }

  build() {
    if (MDArea.isEmpty(this.area)) {
      Row()
        .width('100%')
        .onAreaChange((oldValue, newValue) => {
          log.i(`${this.ID} onAreaChange ${JSON.stringify(oldValue)} ${JSON.stringify(newValue)}`);
          this.uiArea = newValue;
          this.area = MDArea.area(newValue);
          this.onMarkdownAreaChange({ oldValue, newValue });
        })
    } else {
      Stack({ alignContent: Alignment.TopStart }) {
        EmbedComponent({
          node: this.program?.document, area: this.area, controller: this.embedController,
          onEmbedComponentAfterAboutToAppear: () => {
            this.embedComponentTypingReady = true;
            log.i(`${this.ID} on typing will ready`);
            this.onMarkdownTypingReady({});
            log.i(`${this.ID} on typing did ready`);
          },
          onEmbedComponentBeforeAboutToDisappear: () => {
            this.embedComponentTypingReady = false;
          },
        })
          .position({ x: 0, y: 0 })
          .zIndex(0)
          .width('100%')
          .onAreaChange((oldValue, newValue) => {
            // log.i(`onAreaChange ${JSON.stringify(oldValue)} ${JSON.stringify(newValue)}`);
            this.uiArea = newValue;
            this.area = MDArea.area(newValue);
            this.onMarkdownAreaChange({ oldValue, newValue });
          })
      }
    }
  }
}

interface IMarkdownController {
  /**
   * @note units: ms
   * @default 25
   */
  typingSpeed?: number;
  /**
   * @default 1
   */
  typingStep?: number;
  /**
   * tail message while stop typing, eg ...
   */
  typingMore?: string;
}
export class MarkdownController {
  private option: IMarkdownController;
  private listener: Record<string, IMarkdownEventCallback[]> = {};
  readonly typing: Typing = new Typing();
  readonly textContentController: TextContentController = new TextContentController();
  constructor(option: IMarkdownController) {
    this.option = option;
  }
  set typingSpeed(value: number | undefined) {
    this.option.typingSpeed = value;
  }
  get typingSpeed(): number | undefined {
    return this.option.typingSpeed;
  }
  get typingStep(): number | undefined {
    return this.option.typingStep;
  }
  get typingMore(): string | undefined {
    return this.option.typingMore;
  }
  on<T, V = void>(name: string, callback: Callback<T, V>) {
    if (!this.listener[name]) {
      this.listener[name] = [];
    }
    this.listener[name].push({ type: EMarkdownEventCallback.On, callback });
    return this;
  }
  once<T, V = void>(name: string, callback: Callback<T, V>) {
    if (!this.listener[name]) {
      this.listener[name] = [];
    }
    this.listener[name].push({ type: EMarkdownEventCallback.Once, callback });
    return this;
  }
  emit<T, V = void>(name: string, event: T): V {
    let result: V = undefined as V;
    this.listener[name]?.forEach(ele => {
      result = (ele.callback as Callback<T, V>)(event);
      if (ele.type === EMarkdownEventCallback.Once) {
        this.off(name, (ele.callback as Callback<T, V>));
      }
    });
    return result;
  }
  off<T, V = void>(name: string, callback?: Callback<T, V>) {
    if (callback) {
      this.listener[name] = this.listener[name].filter(ele => ele.callback !== callback);
    } else {
      this.listener[name] = [];
    }
    return this;
  }
}
enum EMarkdownEventCallback {
  On = 'on',
  Once = 'once',
}
interface IMarkdownEventCallback {
  type: EMarkdownEventCallback;
  callback: Function;
}

interface IMarkdownDirtyContent {
  mode: ETypingMode;
  program: Program;
  content: string;
}

export interface IMarkdownEvent {
}
export interface IMarkdownAreaChangeEvent extends IMarkdownEvent {
  oldValue: Area;
  newValue: Area;
}
export interface IMarkdownNodeClickEvent extends IMarkdownEvent {
  node: Node;
  event: ClickEvent;
}
export interface IMarkdownTextComponentSelectionOptionEvent extends IMarkdownEvent {
  textEvent: ITextComponentEvent;
}
export interface IMarkdownTextComponentSelectionChangeEvent extends IMarkdownEvent {
  textEvent: ITextComponentSelectionChangeEvent;
}
export interface IMarkdownTableComponentActionClickEvent extends IMarkdownEvent {
  tableEvent: ITableComponentActionClickEvent;
}
export interface IMarkdownTableComponentBarOptionEvent extends IMarkdownEvent {
  tableEvent: ITableComponentEvent;
}
export interface IMarkdownCodeComponentActionClickEvent extends IMarkdownEvent {
  codeEvent: ICodeComponentActionClickEvent;
}
export interface IMarkdownCodeComponentBarOptionEvent extends IMarkdownEvent {
  codeEvent: ICodeComponentEvent;
}