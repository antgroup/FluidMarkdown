// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { newLog, IMDArea, K_COMPONENT, MDArea } from '../../util';
import { Engine, BaseEngine } from '../../engine';
import { ITheme } from '../../theme';
import { EmbedComponent, EmbedComponentController } from './embed';
import { Typing, ITypingUpdateData, ITypingFinishEvent, ETypingMode, ETypingEvent } from '../typing';
import { Node } from '../../service/ast';

const log = newLog('FragmentComponent');

@ComponentV2
export struct FragmentComponent {
  private static gid: number = 0;
  private static getGid() {
    return FragmentComponent.gid++;
  }
  readonly ID: number = FragmentComponent.getGid();

  @Param node?: Node = undefined;
  @Param @Once controller: FragmentComponentController = new FragmentComponentController({});
  @Require @Param area: IMDArea = {};

  @Consumer(K_COMPONENT.THEME) theme: ITheme = {};
  @Consumer(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = new BaseEngine();

  @Local fragments: Fragment[] = [];

  @Event onFragmentComponentBeforeAboutToAppear: Callback<IFragmentComponentEvent>;
  @Event onFragmentComponentAfterAboutToAppear: Callback<IFragmentComponentEvent>;
  @Event onFragmentComponentBeforeAboutToDisappear: Callback<IFragmentComponentEvent>;
  @Event onFragmentComponentAfterAboutToDisappear: Callback<IFragmentComponentEvent>;
  @Event onFragmentComponentTypingFinish: Callback<IFragmentComponentEvent>;

  private dirtyTypingUpdateData?: IFragmentUpdateData;

  @Monitor('node') onNodeChange(monitor: IMonitor) {
    const node = monitor.value<Node>()?.now;
    if (node) {
      const fragments: Fragment[] = [];
      if (!!this.sharedEngine.ctx?.fragmentEnable) {
        node.children.forEach((ele, index) => {
          fragments.push(this.dequeueFragment(index, ele));
        });
      } else {
        fragments.push(this.dequeueFragment(0, node));
      }
      this.fragments = fragments;
    } else {
      this.fragments = [];
    }
  }
  private dequeueFragment(index: number, node?: Node) {
    let fragment = this.fragments.slice(index, index + 1).pop();
    if (fragment) {
      fragment.option.node = node;
    } else {
      fragment = new Fragment({ likelyKey: Fragment.likelyKey(index, node), node });
      fragment.embedController.typing.on<ITypingFinishEvent>(ETypingEvent.Finish, e => {
        this.onEmbedControllerTypingFinish(e);
      });
      this.fragments.push(fragment);
    }
    return fragment;
  }
  private get fragment() {
    return this.fragments.slice().pop();
  }

  aboutToAppear(): void {
    this.onFragmentComponentBeforeAboutToAppear?.({});
    this.bindController();
    this.onFragmentComponentAfterAboutToAppear?.({});
  }
  aboutToDisappear(): void {
    this.onFragmentComponentBeforeAboutToDisappear?.({});
    this.onFragmentComponentAfterAboutToDisappear?.({});
  }
  private bindController() {
    this.controller.typing.processing = () => {
      if (this.dirtyTypingUpdateData) {
        return true;
      }
      return !!this.fragment?.embedController.typing.processing();
    }
    this.controller.typing.completed = () => {
      if (this.dirtyTypingUpdateData) {
        return false;
      }
      const fragment = this.fragment;
      return fragment ? !!fragment.embedController.typing.completed() : true;
    }
    this.controller.typing.pause = () => {
      return this.fragment?.embedController.typing.pause();
    }
    this.controller.typing.resume = () => {
      return this.fragment?.embedController.typing.resume();
    }
    this.controller.typing.stop = () => {
      return this.fragment?.embedController.typing.stop();
    }
    this.controller.typing.update = (node, mode, hasMore) => {
      if (node instanceof Node) {
        log.i(`${this.ID} update typing mode: ${mode}, hasMore: ${hasMore}, node: ${node.hash}`);
        this.dirtyTypingUpdateData = { content: node, mode, hasMore, nodes: node.children };
        if (mode === ETypingMode.Begin) {
          this.fragments = [];
        }
        this.update();
      } else {
        log.w(`${this.ID} can not update content, node(${typeof node}) is not instance of Node`);
      }
    }
  }
  private update() {
    if (!!this.fragment?.embedController.typing.processing()) {
      log.i(`${this.ID} fragment ${this.fragment?.ID} typing processing, will retry after finish`);
      return;
    }
    if (!this.dirtyTypingUpdateData) {
      log.w(`${this.ID} no dirty typing update data`);
      return;
    }
    if (!!this.sharedEngine.ctx?.fragmentEnable) {
      const targets = this.dirtyTypingUpdateData.content.children;
      if (targets.length > 0 && this.fragments.length === 0) {
        this.dequeueFragment(0);
        log.i(`${this.ID} first fragment, will dequeue: ${this.fragments.length}`);
      }
      const count = Math.min(targets.length, this.fragments.length);
      log.i(`${this.ID} update fragments: ${this.fragments.length}, targets: ${targets.length}, min count: ${count}`);
      const isLast = (index: number) => (index === count - 1);
      for (let index = 0; index < count; index++) {
        const fragment = this.fragments[index];
        const target = targets[index];
        if (fragment.updateData?.content.hash === target.hash) {
          log.i(`${this.ID} fragment ${fragment.ID} no change, skip update`);
          continue;
        }
        if (isLast(index)) {
          fragment.update(target, this.dirtyTypingUpdateData.mode, this.dirtyTypingUpdateData.hasMore);
        } else {
          fragment.update(target, ETypingMode.Update, this.dirtyTypingUpdateData.hasMore);
        }
      }
      this.fragments = this.fragments.slice(0, count);
      log.i(`${this.ID} after update fragments: ${this.fragments.length} targets: ${targets.length}`)
    } else {
      const fragment = this.dequeueFragment(0);
      fragment.update(this.dirtyTypingUpdateData.content, this.dirtyTypingUpdateData.mode, this.dirtyTypingUpdateData.hasMore);
      if (this.fragments.length > 1) {
        this.fragments = [fragment];
      }
    }
  }
  private onEmbedControllerTypingFinish = (_e: ITypingFinishEvent) => {
    log.i(`${this.ID} receive embed typing finish event`);
    if (this.dirtyTypingUpdateData) {
      const targets = this.dirtyTypingUpdateData.content.children;
      if (this.fragments.length === targets.length) {
        let allDone = true;
        this.fragments.forEach((fragment, index) => {
          const target = targets[index];
          if (fragment.updateData?.content.hash !== target.hash) {
            allDone = false;
          }
        });
        if (allDone) {
          log.i(`${this.ID} all fragments typing finish. emit onFragmentComponentTypingFinish`);
          this.dirtyTypingUpdateData = undefined;
          this.onFragmentComponentTypingFinish?.({});
          return;
        } else {
          log.i(`${this.ID} some fragments changed, need update`);
          this.update();
        }
      } else {
        log.i(`${this.ID} typing next fragment. fragments: ${this.fragments.length}, targets: ${targets.length}`);
        this.dequeueFragment(this.fragments.length);
        this.update();
      }
    } else {
      log.w(`${this.ID} no dirty typing update data, ignore finish event`);
    }
  }

  build() {
    Column() {
      ForEach(this.fragments, (fragment: Fragment) => {
        EmbedComponent({
          node: fragment.node, controller: fragment.embedController, area: this.area,
          onEmbedComponentAfterAboutToAppear: () => {
            log.i(`${this.ID} fragment ${fragment.ID} typing ready`);
            fragment.typingReady = true;
          },
          onEmbedComponentBeforeAboutToDisappear: () => {
            fragment.typingReady = false;
          },
        })
          .width('100%')
      }, (fragment: Fragment) => fragment.likelyKey)
    }
  }
}

const log2 = newLog('Fragment');

interface IFragment {
  likelyKey: string;
  node?: Node;
}
class Fragment {
  private static gid: number = 0;
  private static getGid() {
    return Fragment.gid++;
  }
  readonly ID: number = Fragment.getGid();
  readonly embedController: EmbedComponentController = new EmbedComponentController();
  readonly option: IFragment;
  updateData?: ITypingUpdateData<Node>;

  private _typingReady: boolean = false;

  constructor(option: IFragment) {
    this.option = option;
  }
  get typingReady() {
    return this._typingReady;
  }
  set typingReady(value: boolean) {
    this._typingReady = value;
    if (value && this.updateData) {
      log2.i(`${this.ID} typing ready, retry update node: ${this.updateData.content.hash}, mode: ${this.updateData.mode}, hasMore: ${this}`);
      this.embedController.typing.update(this.updateData.content, this.updateData.mode, this.updateData.hasMore);
    }
  }
  update(node: Node, mode: ETypingMode, hasMore?: boolean) {
    log2.i(`${this.ID} will update node: ${node.hash}, mode: ${mode}, hasMore: ${hasMore}`)
    this.updateData = { content: node, mode, hasMore };
    if (this.typingReady) {
      this.embedController.typing.update(node, mode, hasMore);
    } else {
      log2.i(`${this.ID} typing not ready, will update after ready`);
    }
  }
  get node() {
    return this.option.node;
  }
  get likelyKey() {
    return this.option.likelyKey;
  }
  static likelyKey(index: number, node?: Node) {
    return `fragment-${index}-${node?.hash}`;
  }
}

interface IFragmentUpdateData extends ITypingUpdateData<Node> {
  nodes: Node[];
}

interface IFragmentComponentController {}
export class FragmentComponentController {
  readonly option: IFragmentComponentController;
  readonly typing: Typing = new Typing();
  constructor(option: IFragmentComponentController) {
    this.option = option;
  }
}
export interface IFragmentComponentEvent {}