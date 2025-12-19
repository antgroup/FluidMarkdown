// Copyright 2025 The FluidMarkdown Authors. All rights reserved.
// Use of this source code is governed by a Apache 2.0 license that can be
// found in the LICENSE file.

import { K_COMPONENT, newLog, IMDArea, MDArea, MDMargin } from '../../util';
import { Engine, BaseEngine } from '../../engine';
import { ITheme } from '../../theme';
import { StyledEmbed } from '../styled';
import { ENode, Code } from '../../service/ast/node';
import { EmbedComponent } from './embed';
import { ContentBoxComponent, ContentBoxBar, type IContentBoxAction, IContentBoxBar } from './content-box';

const log = newLog('CodeComponent');

@ComponentV2
export struct CodeComponent {
  private _gid: number = CodeComponent.getGID();
  private static gid: number = 0;
  private static getGID() {
    return CodeComponent.gid++;
  }
  get ID() {
    return this._gid;
  }

  @Require @Param @Once styledEmbed: StyledEmbed;

  @Consumer(K_COMPONENT.THEME) theme: ITheme = {};
  @Consumer(K_COMPONENT.SHARED_ENGINE) sharedEngine: Engine = new BaseEngine();

  private bridge: CodeComponentBridge = new CodeComponentBridge({
    styledEmbed: () => this.styledEmbed,
    codeContent: () => this.node?.content,
  });

  private barOption?: IContentBoxBar;
  private currentArea?: IMDArea;

  private get node() {
    const node = this.styledEmbed.node;
    if (!node || !node.is(ENode.Code)) {
      log.e(`current embed node is not table: ${node?.type}`);
      return undefined;
    }
    return node as Code;
  }

  aboutToAppear(): void {
    this.styledEmbed.embedController.updateEmbed = embed => {
      if (embed?.option.styled.node?.hash !== this.styledEmbed?.option.styled.node?.hash) {
        this.styledEmbed = embed;
      }
    };
    this.styledEmbed.embedController.currentArea = () => {
      return this.currentArea;
    };
    this.barOption = this.sharedEngine.event!.invokeCodeBarOption({ bridge: this.bridge });
  }

  build() {
    ContentBoxComponent({
      content: () => { this.CodeContent() },
      bar: {
        title: this.node?.language || '',
        actions: this.barOption?.actions ?? [
          ContentBoxBar.copyAction(undefined, this.sharedEngine),
          // ContentBoxBar.openAction(undefined, this.sharedEngine),
        ],
      },
      onActionClick: (action, event) => {
        this.sharedEngine.event!.invokeCodeActionClick({ bridge: this.bridge, action, event });
      },
    })
      .position(this.styledEmbed?.position)
      .onAreaChange((oldValue, newValue) => {
        this.currentArea = MDArea.area(newValue);
        if (!MDArea.mdAreaEqual(MDArea.area(oldValue), MDArea.area(newValue))) {
          this.styledEmbed?.componentAreaChange(oldValue, newValue);
        }
      })
      .visibility(this.styledEmbed?.position !== undefined ? Visibility.Visible : Visibility.Hidden)
      .width(this.styledEmbed?.initMetrics.width)
  }
  @Builder
  CodeContent() {
    Row() {
      EmbedComponent({
        node: this.node?.styledContent,
        area: {},
      })
        .constraintSize({ minWidth: '100%' })
    }
    .padding(this.theme.contentBox?.barMargin ? MDMargin.lengthMargin(this.theme.contentBox?.barMargin) : undefined)
  }
}

interface ICodeComponentBridge {
  styledEmbed: () => StyledEmbed,
  codeContent: () => string | undefined;
}
export class CodeComponentBridge {
  private option: ICodeComponentBridge;
  constructor(option: ICodeComponentBridge) {
    this.option = option;
  }
  get styledEmbed() {
    return this.option.styledEmbed();
  }
  get codeContent() {
    return this.option.codeContent();
  }
}
export interface ICodeComponentEvent {
  bridge: CodeComponentBridge;
}
export interface ICodeComponentActionClickEvent extends ICodeComponentEvent {
  action: IContentBoxAction,
  event: ClickEvent,
}