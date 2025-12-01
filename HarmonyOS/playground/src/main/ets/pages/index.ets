import { NAV, PAGE_BGCOLOR, EPage } from 'ets/pages/shared';
import { EShowMode, BoardComponent } from './board';
import { FeatureListComponent } from './feature-list';
import { FeatureDetailComponent } from './feature-detail';

let markdown = `
<u>🌴 **三亚两日游攻略**</u>

### 📅 行程推荐
**方案一：经典海岛+文化组合**
**Day1：蜈支洲岛+亚龙湾**
- 上午：蜈支洲岛潜水/摩托艇（建议8:30前登船）[^4]
- 下午：亚龙湾沙滩漫步，体验玻璃海
- 傍晚：椰梦长廊拍摄落日剪影[^1]

**Day2：南山观音+天涯海角**
- 上午：南山文化旅游区祈福，观108米海上观音[^4]
- 下午：天涯海角打卡“天涯石”“海角石”[^2]
- 晚上：第一市场夜市品尝海鲜[^1]

---

### 🚗 交通贴士
> 1. **蜈支洲岛**需乘船20分钟，建议8:30前到达码头[^1]。
> 2. **亚龙湾至南山**车程约40分钟，可包车或跟团接送[^3]。

---

### ⚠️ 注意事项
- 防晒必备：SPF50+防晒霜+物理防晒装备[^5]。
- 海鲜消费：选择明码标价餐厅，称重前甩干水分[^5]。
- 水上安全：浮潜需穿救生衣，警惕低价潜水陷阱[^5]。

---

### 🦐 必吃美食推荐

| 小吃       | 招牌菜品        | 人均消费 | 位置参考      |
|-----------------|-----------------|----------|---------------|
| 炒冰       | 榴莲炒冰       | 36元     | 市区分店      |
| 清补凉茶     | 十料椰奶       | 15元     | 渔村路        |
| 香味海鲜   | 椒盐皮皮虾     | 120元    | 亚龙湾/海棠湾 |

---

查看更多[酒店机票](url)优惠套餐和[跟团旅游](url)推荐行程。

[^1]: ref1
[^2]: ref2
[^3]: ref3
[^4]: ref4
[^5]: ref5
`;

@Entry
@ComponentV2
export struct Index {
  @Provider(NAV.STACK) stack: NavPathStack = new NavPathStack();

  private content: string = markdown;
  private textAreaController: TextAreaController = new TextAreaController();

  private get actions(): IAction[] {
    return [
      { title: EShowMode.Normal, mode: EShowMode.Normal },
      { title: EShowMode.Typing, mode: EShowMode.Typing },
      { title: EShowMode.Stream, mode: EShowMode.Stream }
    ];
  }

  @Builder
  Action(title: string, mode: EShowMode) {
    Button(title)
      .backgroundColor(0x1890ff)
      .onClick(() => {
        this.stack.pushPath({ name: mode })
      })
  }
  @Builder
  Page(name: string) {
    if (name === EShowMode.Normal) {
      BoardComponent({ content: this.content, mode: EShowMode.Normal })
    } else if (name === EShowMode.Typing) {
      BoardComponent({ content: this.content, mode: EShowMode.Typing })
    } else if (name === EShowMode.Stream) {
      BoardComponent({ content: this.content, mode: EShowMode.Stream })
    } else if (name === EPage.FeatureList) {
      FeatureListComponent()
    } else if (name === EPage.FeatureDetail) {
      FeatureDetailComponent()
    }
  }

  build() {
    Navigation(this.stack) {
      Column() {
        Column() {
          Row() {
            TextArea({
              text: this.content,
              placeholder: 'input markdown content here',
              controller: this.textAreaController
            })
              .width('100%')
              .height('100%')
              .fontColor(Color.Black)
              .backgroundColor(Color.White)
              .onSubmit(() => { this.textAreaController.stopEditing() })
              .onChange(e => { this.content = e })
          }
          .width('100%')
          .layoutWeight(1)
          .padding(10)

          Row() {
            Blank()
            ForEach(this.actions, (item: IAction) => {
              Button(item.title)
                .backgroundColor(0x1890ff)
                .onClick(() => {
                  this.stack.pushPath({ name: item.mode });
                })
              Blank()
            })
          }
          .width('100%')
          .height(60)
        }
      }
      .height('100%')
    }
    .title('Fluid Markdown')
    .backgroundColor(PAGE_BGCOLOR)
    .mode(NavigationMode.Auto)
    .titleMode(NavigationTitleMode.Mini)
    .hideBackButton(true)
    .navDestination(this.Page)
    .menus([{
      value: '',
      icon:'resources/base/media/pl_icon_list_bullet.svg',
      action: () => this.stack.pushPath({ name: EPage.FeatureList }),
    }])
    .onClick(() => this.textAreaController.stopEditing())
  }
}

interface IAction {
  title: string;
  mode: EShowMode;
}