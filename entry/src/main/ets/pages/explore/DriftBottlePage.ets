/**
 * 漂流瓶页面- 愿望互动
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { router } from '@kit.ArkUI';

interface DriftBottle {
  id: string;
  content: string;
  senderNickname: string;
  senderCity: string;
  createdAt: string;
  type: 'wish' | 'story' | 'question';
}

interface DriftBottleTypeOption {
  key: 'wish' | 'story' | 'question';
  label: string;
  icon: string;
}

@Entry
@Component
struct DriftBottlePage {
  @State currentTab: number = 0;  // 0: 捡瓶子, 1: 投瓶子, 2: 我的瓶子
  @State pickedBottle: DriftBottle | null = null;
  @State myContent: string = '';
  @State selectedType: 'wish' | 'story' | 'question' = 'wish';
  @State isPicking: boolean = false;
  @State myBottles: DriftBottle[] = [];

  private tabs: string[] = ['捡瓶', '投瓶', '我的瓶子'];
  private typeOptions: DriftBottleTypeOption[] = [
    { key: 'wish', label: '许愿', icon: '🌟' },
    { key: 'story', label: '故事', icon: '📖' },
    { key: 'question', label: '提问', icon: '❓' },
  ];

  aboutToAppear(): void {
    this.loadMyBottles();
  }

  // 加载我的漂流瓶
  private loadMyBottles(): void {
    this.myBottles = [
      {
        id: 'bottle_001',
        content: '希望今年能去一次日本看樱花 🌸',
        senderNickname: '小安',
        senderCity: '北京',
        createdAt: new Date(Date.now() - 86400000).toISOString(),
        type: 'wish',
      },
      {
        id: 'bottle_002',
        content: '在成都吃到了超级好吃的火锅，分享给有缘人',
        senderNickname: '小鹿',
        senderCity: '成都',
        createdAt: new Date(Date.now() - 172800000).toISOString(),
        type: 'story',
      },
    ];
  }

  // 捡瓶
  private pickBottle(): void {
    if (this.isPicking) return;

    this.isPicking = true;
    this.pickedBottle = null;

    // 模拟捡瓶子过程
    setTimeout(() => {
      this.isPicking = false;
      this.pickedBottle = {
        id: `bottle_${Date.now()}`,
        content: '希望每个看到这条消息的人都能开心每一天！遇见美好，遇见幸福。',
        senderNickname: '漂流者',
        senderCity: '上海',
        createdAt: new Date(Date.now() - 3600000 * 5).toISOString(),
        type: 'wish',
      };
    }, 2000);
  }

  // 投瓶
  private throwBottle(): void {
    if (!this.myContent.trim()) return;

    const newBottle: DriftBottle = {
      id: `bottle_${Date.now()}`,
      content: this.myContent,
      senderNickname: '旅行者',
      senderCity: '北京',
      createdAt: new Date().toISOString(),
      type: this.selectedType,
    };
    this.myBottles = [newBottle, ...this.myBottles];
    this.myContent = '';

    // TODO: 显示成功提示
  }

  // 返回
  private goBack(): void {
    router.back();
  }

  // 格式化时间
  private formatTime(isoString: string): string {
    const date = new Date(isoString);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (hours < 1) return '刚刚';
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  build() {
    Column() {
      // 导航栏
      this.NavigationBar()

      // Tab栏
      this.TabBar()

      // 内容区域
      if (this.currentTab === 0) {
        this.PickContent()
      } else if (this.currentTab === 1) {
        this.ThrowContent()
      } else {
        this.MyBottlesContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgSecondary)
  }

  @Builder
  NavigationBar() {
    Row() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor(Colors.textPrimary)
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.goBack())

      Blank()

      Text('漂流瓶')
        .fontSize(FontSizes.body)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textPrimary)

      Blank()

      Row().width(44).height(44)
    }
    .width('100%')
    .height(56)
    .padding({ left: 4, right: 4, top: 48 })
    .backgroundColor(Colors.bgPrimary)
  }

  @Builder
  TabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(FontSizes.body)
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentTab === index ? Colors.primary : Colors.textTertiary)
            .onClick(() => {
              this.currentTab = index;
            })

          if (this.currentTab === index) {
            Row()
              .width(24)
              .height(3)
              .backgroundColor(Colors.primary)
              .borderRadius(2)
              .margin({ top: 8 })
          } else {
            Row().height(11)
          }
        }
      })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Colors.bgPrimary)
  }

  @Builder
  PickContent() {
    Column() {
      Blank()

      // 海浪动画区域
      Column() {
        if (this.isPicking) {
          // 捡瓶子动画
          Column() {
            Text('🍾')
              .fontSize(80)
            Text('正在海上寻找漂流瓶...')
              .fontSize(FontSizes.body)
              .fontColor(Colors.textSecondary)
              .margin({ top: 20 })
            LoadingProgress()
              .width(32)
              .height(32)
              .margin({ top: 16 })
          }
        } else if (this.pickedBottle) {
          // 展示捡到的瓶子
          Column() {
            Text('🎉')
              .fontSize(48)
              .margin({ bottom: 16 })
            Text('你捡到了一个漂流瓶')
              .fontSize(FontSizes.h4)
              .fontWeight(FontWeight.Bold)
              .fontColor(Colors.textPrimary)

            Column() {
              Text(this.pickedBottle.content)
                .fontSize(FontSizes.body)
                .fontColor(Colors.textPrimary)
                .lineHeight(24)
                .textAlign(TextAlign.Center)

              Row() {
                Text(`来自 ${this.pickedBottle.senderCity}`)
                  .fontSize(FontSizes.small)
                  .fontColor(Colors.textTertiary)
                Text(' · ')
                  .fontSize(FontSizes.small)
                  .fontColor(Colors.textQuaternary)
                Text(this.formatTime(this.pickedBottle.createdAt))
                  .fontSize(FontSizes.small)
                  .fontColor(Colors.textTertiary)
              }
              .margin({ top: 16 })
            }
            .width('100%')
            .padding(24)
            .margin({ top: 24 })
            .backgroundColor(Colors.bgPrimary)
            .borderRadius(Radius.card)

            Row() {
              Button('回复TA')
                .fontSize(FontSizes.body)
                .fontColor(Colors.primary)
                .backgroundColor(Colors.primaryLightest)
                .borderRadius(Radius.full)
                .height(44)
                .layoutWeight(1)

              Button('再捡一个')
                .fontSize(FontSizes.body)
                .fontColor(Colors.textWhite)
                .backgroundColor(Colors.primary)
                .borderRadius(Radius.full)
                .height(44)
                .layoutWeight(1)
                .margin({ left: 16 })
                .onClick(() => this.pickBottle())
            }
            .width('100%')
            .margin({ top: 24 })
          }
          .width('100%')
          .padding({ left: 24, right: 24 })
        } else {
          // 等待捡瓶子状态
          Column() {
            Text('🌊')
              .fontSize(80)
            Text('大海里有很多漂流瓶')
              .fontSize(FontSizes.body)
              .fontColor(Colors.textSecondary)
              .margin({ top: 20 })
            Text('点击下方按钮试试运气')
              .fontSize(FontSizes.small)
              .fontColor(Colors.textTertiary)
              .margin({ top: 8 })
          }
        }
      }

      Blank()

      // 捡瓶子按钮
      if (!this.pickedBottle) {
        Button('🍾 捡一个漂流瓶')
          .width('80%')
          .height(56)
          .fontSize(FontSizes.bodyLarge)
          .fontColor(Colors.textWhite)
          .backgroundColor(Colors.primary)
          .borderRadius(Radius.full)
          .shadow({ radius: 16, color: 'rgba(14, 165, 233, 0.4)', offsetY: 4 })
          .margin({ bottom: 60 })
          .onClick(() => this.pickBottle())
          .enabled(!this.isPicking)
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  ThrowContent() {
    Column() {
      // 类型选择
      Row() {
        ForEach(this.typeOptions, (option: DriftBottleTypeOption) => {
          Column() {
            Text(option.icon)
              .fontSize(28)
            Text(option.label)
              .fontSize(FontSizes.small)
              .fontColor(this.selectedType === option.key ? Colors.primary : Colors.textTertiary)
              .margin({ top: 6 })
          }
          .width(80)
          .height(80)
          .backgroundColor(this.selectedType === option.key ? Colors.primaryLightest : Colors.bgPrimary)
          .borderRadius(Radius.card)
          .border({ width: 2, color: this.selectedType === option.key ? Colors.primary : 'transparent' })
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.selectedType = option.key;
          })
        })
      }
      .width('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 24 })
      .justifyContent(FlexAlign.SpaceEvenly)

      // 内容输入
      Column() {
        TextArea({ placeholder: '写下你想说的话，让它漂向远方...', text: this.myContent })
          .width('100%')
          .height(200)
          .fontSize(FontSizes.body)
          .backgroundColor(Colors.bgPrimary)
          .borderRadius(Radius.card)
          .padding(16)
          .onChange((value: string) => {
            this.myContent = value;
          })

        Text(`${this.myContent.length}/200`)
          .fontSize(FontSizes.small)
          .fontColor(Colors.textTertiary)
          .margin({ top: 8 })
          .alignSelf(ItemAlign.End)
      }
      .width('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 24 })

      Blank()

      // 投瓶子按钮
      Button('🍾 扔进大海')
        .width('80%')
        .height(56)
        .fontSize(FontSizes.bodyLarge)
        .fontColor(Colors.textWhite)
        .backgroundColor(this.myContent ? Colors.primary : Colors.bgTertiary)
        .borderRadius(Radius.full)
        .margin({ bottom: 60 })
        .enabled(!!this.myContent)
        .onClick(() => this.throwBottle())
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  MyBottlesContent() {
    if (this.myBottles.length > 0) {
      List() {
        ForEach(this.myBottles, (bottle: DriftBottle) => {
          ListItem() {
            Column() {
              Row() {
                Text(this.typeOptions.find(t => t.key === bottle.type)?.icon || '🍾')
                  .fontSize(20)
                Text(this.typeOptions.find(t => t.key === bottle.type)?.label || '')
                  .fontSize(FontSizes.small)
                  .fontColor(Colors.textTertiary)
                  .margin({ left: 8 })
                Blank()
                Text(this.formatTime(bottle.createdAt))
                  .fontSize(FontSizes.small)
                  .fontColor(Colors.textQuaternary)
              }
              .width('100%')
              .margin({ bottom: 12 })

              Text(bottle.content)
                .fontSize(FontSizes.body)
                .fontColor(Colors.textPrimary)
                .lineHeight(22)
                .width('100%')

              Row() {
                Text(`发自 ${bottle.senderCity}`)
                  .fontSize(FontSizes.mini)
                  .fontColor(Colors.textTertiary)
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding(Spacing.cardPadding)
            .backgroundColor(Colors.bgPrimary)
            .borderRadius(Radius.card)
          }
          .margin({ bottom: Spacing.cardMargin })
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 16, bottom: 16 })
      .scrollBar(BarState.Off)
    } else {
      Column() {
        Text('🍾')
          .fontSize(60)
          .opacity(0.5)
        Text('还没有投过漂流瓶')
          .fontSize(FontSizes.body)
          .fontColor(Colors.textTertiary)
          .margin({ top: 16 })
        Button('去投一个')
          .fontSize(FontSizes.bodySmall)
          .fontColor(Colors.primary)
          .backgroundColor(Colors.primaryLightest)
          .borderRadius(Radius.full)
          .height(36)
          .padding({ left: 24, right: 24 })
          .margin({ top: 16 })
          .onClick(() => {
            this.currentTab = 1;
          })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
  }
}
