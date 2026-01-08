import { Markdown, newLog, EMarkdownMode, MarkdownController, ETypingMode } from 'fluid-markdown';
import { NAV, PAGE_BGCOLOR } from './shared';

const log = newLog('Playground');

export enum EShowMode {
  Normal = 'normal',
  Typing = 'typing',
  Stream = 'stream',
}

@ComponentV2
export struct BoardComponent {
  @Consumer(NAV.STACK) stack: NavPathStack = new NavPathStack();
  @Param content?: string = undefined;
  @Param @Require mode: EShowMode;
  private scroller: Scroller = new Scroller();

  markdownController: MarkdownController = new MarkdownController({
    typingMore: '\n(已终止回答)'
  });

  aboutToAppear(): void {}

  build() {
    NavDestination() {
      Scroll(this.scroller) {
        Markdown({
          content: this.content,
          controller: this.markdownController,
          mode: (this.mode === EShowMode.Normal ? EMarkdownMode.Normal : EMarkdownMode.Typing),
          onMarkdownTypingReady: () => {
            if (this.mode === EShowMode.Stream) {
              const message = this.content ?? '';
              let offset = 0;
              const step = 10000;
              const timer = setInterval(() => {
                let mode = ETypingMode.Append;
                if (offset === 0) {
                  mode = ETypingMode.Begin;
                } else if (offset >= message.length) {
                  mode = ETypingMode.End;
                }
                offset += step;
                this.markdownController.typing.update(message.substring(0, offset), mode);
                if (mode === ETypingMode.End) {
                  clearInterval(timer);
                }
              }, 100);
            } else if (this.mode === EShowMode.Typing) {
              this.markdownController.typing.update(this.content, ETypingMode.Begin);
            }
          },
          onMarkdownAreaChange: () => {
            // if (this.mode !== EShowMode.Normal) {
            //   this.scroller.scrollEdge(Edge.Bottom);
            // }
          },
          onMarkdownNodeClick: data => {
            log.i('click node: %{public}s event: %{public}s', JSON.stringify(data.node.summary), JSON.stringify(data.event));
          },
          onMarkdownTextComponentSelectionOption: data => {
            return {
              enableSelection: true,
              bindSelectionMenuBuilder: () => {},
              bindSelectionMenuOptions: {},
              editSelectionMenuOptions: {
                onCreateMenu: menuItems => [],
                onMenuItemClick: (menuItem, range) => false,
              },
              // if true, will ignore any ohos build-in selection gesture. you need use MarkdownController.TextContentController.selectGesture to invoke selection.
              // ignoreInternal: true,
            }
          },
          onMarkdownTextComponentSelectionChange: data => {
            log.i('text selection change: %{public}d %{public}d', data.textEvent.start, data.textEvent.end);
          },
          onMarkdownTableComponentActionClick: data => {
            log.i('click table action: %{public}s event: %{public}s', JSON.stringify(data.tableEvent.action.tag), JSON.stringify(data.tableEvent.event));
          },
          onMarkdownTableComponentContentBoxBar: data => {
            log.i('table using default action bar');
            return undefined;
          },
        })
          .margin(12)
      }
      .scrollable(ScrollDirection.Vertical)
      .margin(12)
      .backgroundColor(Color.White)
      .borderRadius(14)
    }
    .title('Board')
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BGCOLOR)
    .onReady(() => {})
  }
}