// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { newLog, K_COMPONENT, MDArea } from '../../util';
import { Engine, BaseEngine } from '../../engine';
import { StyledController, type StyledObject } from '../styled';

const log = newLog('TextComponent');

@ComponentV2
export struct TextComponent {
  private static gid: number = 0;
  private static getGID(): number {
    return TextComponent.gid++;
  }
  private ID: number = TextComponent.getGID();

  private styledController: TextController = new StyledController();
  @Local selectionStart: number = -1;
  @Local selectionEnd: number = -1;

  private selectionOption: ITextComponentSelectionOption = {};
  private selectionGesture: Map<ETextSelectionGesture, GestureEvent> = new Map();
  private uiArea?: Area;

  @Event onTextComponentBeforeAboutToAppear: Callback<ITextComponentEvent>;
  @Event onTextComponentAfterAboutToAppear: Callback<ITextComponentEvent>;

  @Param componentController: TextComponentController = new TextComponentController({});
  @Require @Param content: StyledObject;
  @Consumer(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = new BaseEngine();
  @Monitor('content') onContentChange(monitor: IMonitor) {
    const value = monitor.value<StyledString>();
    if (value) {
      this.styledController.setStyledString(value.now);
    }
  }

  private onCtxContentControllerClearSelection = (): void => {
    this.componentController.select(-1, -1);
  }
  private onCtxContentControllerShouldSelectGesture = (e: ITextComponentControllerShouldSelectGestureEvent)
    : ITextComponentControllerShouldSelectGestureResult | undefined => {
    if (this.selectionGesture.get(e.type)) {
      if (MDArea.isAreaContainFinger(this.uiArea, e.event.fingerList.slice().pop())) {
        return {
          componentController: this.componentController,
          ID: this.ID,
        };
      }
    }
    return undefined;
  }

  aboutToAppear(): void {
    this.componentController.select = (start, end) => {
      this.selectionStart = start;
      this.selectionEnd = end;
    };
    this.componentController.selectGesture = type => {
      const event = this.selectionGesture.get(type);
      if (event) {
        const finger = event.fingerList.slice(0, 1).pop();
        if (finger) {
          const offset = this.styledController.getLayoutManager().getGlyphPositionAtCoordinate(finger.localX, finger.localY).position;
          const range = this.content.nearbyParagraph(offset);
          if (range && range.start !== undefined && range.end !== undefined) {
            this.componentController.select(range.start, range.end);
          } else {
            log.w('selection with gesture. but range not found');
          }
        } else {
          log.w('selection with gesture. but finger not found');
        }
      } else {
        log.w('selection with gesture. but event not found');
      }
    };
    this.componentController.refresh = () => {
      this.styledController.setStyledString(this.content);
    };
    this.sharedEngine.ctx!.textContentController()?.on<undefined>(ETextComponentControllerEvent.ClearSelection, this.onCtxContentControllerClearSelection);
    this.sharedEngine.ctx!.textContentController()?.on(ETextComponentControllerEvent.ShouldSelectGesture, this.onCtxContentControllerShouldSelectGesture);
    this.onTextComponentBeforeAboutToAppear({});
    this.selectionOption = this.sharedEngine.event!.invokeTextSelectionOption({});
    this.styledController.setStyledString(this.content);
    this.onTextComponentAfterAboutToAppear({});
  }
  aboutToDisappear(): void {
    this.sharedEngine.ctx!.textContentController()?.off<undefined>(ETextComponentControllerEvent.ClearSelection, this.onCtxContentControllerClearSelection);
    this.sharedEngine.ctx!.textContentController()?.off(ETextComponentControllerEvent.ShouldSelectGesture, this.onCtxContentControllerShouldSelectGesture);
  }
  @Builder TextContent() {
    Text(undefined, { controller: this.styledController })
      .wordBreak(WordBreak.BREAK_ALL)
      .draggable(false)
      .selection(this.selectionStart, this.selectionEnd)
      .copyOption(this.selectionOption.enableSelection ? CopyOptions.InApp : CopyOptions.None)
      .bindSelectionMenu(
        TextSpanType.MIXED,
        this.selectionOption.bindSelectionMenuBuilder,
        TextResponseType.SELECT,
        this.selectionOption.bindSelectionMenuOptions,
      )
      .editMenuOptions(this.selectionOption.editSelectionMenuOptions)
      .onTextSelectionChange((start, end) => {
        this.selectionStart = start;
        this.selectionEnd = end;
        this.sharedEngine.event!.invokeTextSelectionChange({
          start, end,
          content: (() => {
            try {
              return this.content.getString().substring(start, end);
            } catch (e) {
              return undefined;
            }
          })(),
        });
      })
      .onAreaChange((_oldValue, newValue) => {
        this.uiArea = newValue;
      })
  }
  build() {
    if (this.selectionOption.ignoreInternal) {
      Row() {
        this.TextContent()
      }
      .parallelGesture(
        GestureGroup(
          GestureMode.Parallel,
          TapGesture({ count: 1 }).onAction(_e => {
            //  ignore internal tap gesture
          }),
          TapGesture({ count: 2 }).onAction(e => {
            this.selectionGesture.set(ETextSelectionGesture.DoubleTap, e);
          }),
          LongPressGesture().onAction(e => {
            this.selectionGesture.set(ETextSelectionGesture.LongPress, e)
          }),
        ),
        GestureMask.IgnoreInternal,
      )
    } else {
      this.TextContent()
    }
  }
}

export enum ETextSelectionGesture {
  DoubleTap = 'double_tap',
  LongPress = 'long_press',
}
interface ITextComponentController {}
export class TextComponentController {
  private option: ITextComponentController;
  constructor(option: ITextComponentController) {
    this.option = option;
  }
  select: (start: number, end: number) => void = () => {};
  selectGesture: (type: ETextSelectionGesture, event?: GestureEvent) => void = () => {};
  refresh: () => void = () => {};
}
export interface ITextComponentEvent {
}
export interface ITextComponentSelectionChangeEvent extends ITextComponentEvent {
  start: number,
  end: number,
  content?: string;
}
export interface ITextComponentSelectionOption {
  enableSelection?: boolean,
  bindSelectionMenuBuilder?: CustomBuilder,
  bindSelectionMenuOptions?: SelectionMenuOptions,
  editSelectionMenuOptions?: EditMenuOptions,
  ignoreInternal?: boolean,
}
export class TextContentController {
  private listener: Record<string, Function[]> = {};
  on<T, V = void>(name: string, callback: Callback<T, V>) {
    if (!this.listener[name]) {
      this.listener[name] = [];
    }
    this.listener[name].push(callback);
    return this;
  }
  emit<T, V = void>(name: string, event: T): V[] {
    let results: V[] = [];
    this.listener[name]?.forEach(ele => {
      results.push((ele as Callback<T, V>)(event));
    });
    return results;
  }
  off<T, V = void>(name: string, callback?: Callback<T, V>) {
    if (callback) {
      this.listener[name] = this.listener[name].filter(ele => ele !== callback);
    } else {
      this.listener[name] = [];
    }
    return this;
  }
  clearSelection() {
    this.emit(ETextComponentControllerEvent.ClearSelection, undefined);
  }
  selectGesture(type: ETextSelectionGesture, event: GestureEvent) {
    const result = this.emit<ITextComponentControllerShouldSelectGestureEvent, ITextComponentControllerShouldSelectGestureResult | undefined>(
      ETextComponentControllerEvent.ShouldSelectGesture,
      { type, event },
    );
    const textComponent = (result.filter(ele => ele !== undefined) as ITextComponentControllerShouldSelectGestureResult[])
      .slice().sort((a, b) => a.ID - b.ID)
      .pop();
    if (textComponent) {
      textComponent.componentController.selectGesture(type, event);
    }
  }
  isHit: (type: ETextSelectionGesture, event: GestureEvent) => boolean = () => false;
}
enum ETextComponentControllerEvent {
  ClearSelection = 'clear_selection',
  ShouldSelectGesture = 'should_select_gesture',
}
interface ITextComponentControllerShouldSelectGestureEvent {
  type: ETextSelectionGesture,
  event: GestureEvent,
}
interface ITextComponentControllerShouldSelectGestureResult {
  componentController: TextComponentController,
  ID: number;
}
