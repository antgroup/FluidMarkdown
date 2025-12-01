import { NAV, PAGE_BGCOLOR, Feature, FeatureMeta, IFeature, EPage } from './shared';

const HEADER_BG_COLOR = 0xf0f0f0;
const HEADER_FONT_COLOR = 0xe0000000;
const BORDER_COLOR = 0xd9d9d9;
const ITEM_FONT_COLOR = 0xa6000000;

@ComponentV2
export struct FeatureListComponent {
  @Consumer(NAV.STACK) stack: NavPathStack = new NavPathStack();
  @Local meta: FeatureMeta = {};

  aboutToAppear(): void {
    this.meta = Feature.shared().meta(this.getUIContext()) ?? {};
  }

  @Builder
  FeatureGroupHeader(group: string) {
    Text(group)
      .width('100%')
      .padding({ left: 20, right: 20 })
      .height(30)
      .fontSize(16)
      .fontColor(HEADER_FONT_COLOR)
      .borderColor(BORDER_COLOR)
      .borderWidth({ bottom: 1 })
      .backgroundColor(HEADER_BG_COLOR)
  }
  @Builder
  FeatureGroup() {
    List() {
      ForEach(Object.keys(this.meta), (key: string) => {
        ListItemGroup({
          header: this.FeatureGroupHeader(key)
        }) {
          this.FeatureItem(key)
        }
      })
    }
  }

  @Builder
  FeatureItem(group: string) {
    List() {
      ForEach(this.meta[group], (item: IFeature) => {
        ListItem() {
          Text(item.name)
            .width('100%')
            .padding({ left: 20, right: 20 })
            .height(44)
            .fontSize(20)
            .fontColor(ITEM_FONT_COLOR)
            .borderColor(BORDER_COLOR)
            .borderWidth({ bottom: 1 })
            .onClick(() => {
              this.stack.pushPathByName(EPage.FeatureDetail, item);
            })
        }
      })
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        this.FeatureGroup()
      }
      .width('100%')
      .height('100%')
      // .margin(10)
      // .borderRadius(20)
      .backgroundColor(Color.White)
      .scrollable(ScrollDirection.Vertical)
    }
    .title('Feature List')
    .backgroundColor(PAGE_BGCOLOR)
    .onReady(() => {})
  }
}