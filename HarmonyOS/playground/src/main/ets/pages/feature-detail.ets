import { Markdown, EMarkdownMode, MarkdownController } from 'fluid-markdown';
import { NAV, PAGE_BGCOLOR, IFeature } from './shared';

@ComponentV2
export struct FeatureDetailComponent {
  @Consumer(NAV.STACK) stack: NavPathStack = new NavPathStack();
  @Local feature?: IFeature = undefined;
  markdownController: MarkdownController = new MarkdownController({});

  aboutToAppear(): void {}

  build() {
    NavDestination() {
      Column() {
        TextArea({ text: this.feature?.content })
          .backgroundColor(Color.White)
          .margin(12)
          .layoutWeight(1)
          .borderRadius(14)
          .focusable(false)
          .fontColor(0xa6000000)

        Divider()
          .color(0x91d5ff)

        Scroll() {
          Markdown({
            content: this.feature?.content ?? ' ',
            controller: this.markdownController,
            mode: EMarkdownMode.Normal,
            onMarkdownAreaChange: () => {},
            onMarkdownNodeClick: data => {},
            onMarkdownTextComponentSelectionOption: data => {
              return {
                enableSelection: true,
                bindSelectionMenuBuilder: () => {},
                bindSelectionMenuOptions: {},
                editSelectionMenuOptions: {
                  onCreateMenu: menuItems => [],
                  onMenuItemClick: (menuItem, range) => false,
                },
              }
            },
            onMarkdownTextComponentSelectionChange: data => {},
            onMarkdownTableComponentActionClick: data => {},
            onMarkdownTableComponentContentBoxBar: data => {
              return undefined;
            },
          })
            .margin(12)
        }
        .scrollable(ScrollDirection.Vertical)
        .margin(12)
        .layoutWeight(2)
        .align(Alignment.TopStart)
        .backgroundColor(Color.White)
        .borderRadius(14)
      }
    }
    .title(this.feature?.name)
    .width('100%')
    .height('100%')
    .backgroundColor(PAGE_BGCOLOR)
    .onReady((ctx: NavDestinationContext) => {
      if (ctx.pathInfo.param) {
        this.feature = ctx.pathInfo.param as IFeature;
      }
    })
  }
}