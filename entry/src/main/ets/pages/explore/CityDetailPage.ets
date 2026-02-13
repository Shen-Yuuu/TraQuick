/**
 * 城市详情- 从探索页点击城市跳转
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { router } from '@kit.ArkUI';

interface CityTabItem {
  title: string;
}

@Entry
@Component
struct CityDetailPage {
  @State cityName: string = '巴黎';
  @State currentTab: number = 0;

  private tabs: CityTabItem[] = [
    { title: '社区' },
    { title: '驴友' },
    { title: '攻略' },
  ];

  build() {
    Column() {
      // 沉浸式头部
      Stack() {
        // 背景图
        Column()
          .width('100%')
          .height(280)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#1E3A5F', 0], ['#38BDF8', 0.5], ['#FFFFFF', 1]]
          })

        // 顶部导航
        Row() {
          Text('←')
            .fontSize(24)
            .fontColor(Colors.textWhite)
            .onClick(() => {
              router.back();
            })

          Blank()

          Text('⋯')
            .fontSize(24)
            .fontColor(Colors.textWhite)
        }
        .width('100%')
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 48 })
        .position({ x: 0, y: 0 })

        // 城市信息
        Column() {
          // 城市图标
          Text('🗼')
            .fontSize(60)

          Text(this.cityName)
            .fontSize(FontSizes.h1)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textWhite)
            .margin({ top: 8 })

          Text('法国 · 法兰西岛')
            .fontSize(FontSizes.bodySmall)
            .fontColor('rgba(255,255,255,0.8)')
            .margin({ top: 4 })

          // 信息标签
          Row() {
            this.InfoTag('🌡️', '12°C')
            this.InfoTag('📍', '9,823km')
            this.InfoTag('👥', '128人来过')
          }
          .margin({ top: 16 })
        }
        .position({ x: '50%', y: '45%' })
        .translate({ x: '-50%', y: '-50%' })
      }
      .width('100%')
      .height(280)

      // Tab栏
      Row() {
        ForEach(this.tabs, (tab: CityTabItem, index: number) => {
          Column() {
            Text(tab.title)
              .fontSize(FontSizes.body)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.currentTab === index ? Colors.textPrimary : Colors.textTertiary)
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
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        })
      }
      .width('100%')
      .height(52)
      .backgroundColor(Colors.bgPrimary)
      .border({ width: { bottom: 1 }, color: Colors.borderLight })

      // 内容区域
      Scroll() {
        Column() {
          if (this.currentTab === 0) {
            this.CommunityContent()
          } else if (this.currentTab === 1) {
            this.TravelersContent()
          } else {
            this.GuideContent()
          }
        }
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: Spacing.md, bottom: 24 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgSecondary)
  }

  @Builder
  InfoTag(icon: string, text: string) {
    Row() {
      Text(icon)
        .fontSize(FontSizes.small)
      Text(text)
        .fontSize(FontSizes.small)
        .fontColor(Colors.textWhite)
        .margin({ left: 4 })
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('rgba(255,255,255,0.2)')
    .borderRadius(Radius.full)
    .margin({ left: 6, right: 6 })
  }

  @Builder
  CommunityContent() {
    Column() {
      // 模拟动态卡片
      ForEach([1, 2, 3], (item: number) => {
        Column() {
          Row() {
            Image($r('app.media.layered_image'))
              .width(36)
              .height(36)
              .borderRadius(18)

            Column() {
              Text('巴黎旅行者')
                .fontSize(FontSizes.bodySmall)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.textPrimary)
              Text('2小时前')
                .fontSize(FontSizes.mini)
                .fontColor(Colors.textQuaternary)
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Text('埃菲尔铁塔的夜景真的太美了！灯光闪烁的时刻让人永生难忘！#巴黎')
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)
            .lineHeight(22)
            .margin({ bottom: 12 })

          Row() {
            Column()
              .width('100%')
              .aspectRatio(1.5)
              .backgroundColor(Colors.bgTertiary)
              .borderRadius(Radius.md)
          }
          .width('100%')
        }
        .width('100%')
        .padding(Spacing.cardPadding)
        .backgroundColor(Colors.bgPrimary)
        .borderRadius(Radius.card)
        .margin({ bottom: Spacing.cardMargin })
      })
    }
  }

  @Builder
  TravelersContent() {
    Column() {
      // 在此处
      Column() {
        Row() {
          Text('🟢')
            .fontSize(12)
          Text('在此处')
            .fontSize(FontSizes.body)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
            .margin({ left: 8 })
          Text('(3人)')
            .fontSize(FontSizes.bodySmall)
            .fontColor(Colors.textTertiary)
            .margin({ left: 4 })
        }
        .width('100%')
        .margin({ bottom: 16 })

        ForEach([1, 2, 3], (item: number) => {
          Row() {
            Image($r('app.media.layered_image'))
              .width(44)
              .height(44)
              .borderRadius(22)

            Column() {
              Text('旅行者 ' + item)
                .fontSize(FontSizes.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.textPrimary)
              Text('正在探索埃菲尔铁塔附近')
                .fontSize(FontSizes.small)
                .fontColor(Colors.textTertiary)
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            .layoutWeight(1)

            Button('打招呼')
              .fontSize(FontSizes.small)
              .fontColor(Colors.primary)
              .backgroundColor(Colors.primaryLightest)
              .borderRadius(Radius.full)
              .height(32)
          }
          .width('100%')
          .padding(12)
          .backgroundColor(Colors.bgSecondary)
          .borderRadius(Radius.md)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding(Spacing.cardPadding)
      .backgroundColor(Colors.bgPrimary)
      .borderRadius(Radius.card)
      .margin({ bottom: Spacing.cardMargin })

      // 计划中
      Column() {
        Row() {
          Text('📅')
            .fontSize(12)
          Text('计划中')
            .fontSize(FontSizes.body)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
            .margin({ left: 8 })
          Text('(12人)')
            .fontSize(FontSizes.bodySmall)
            .fontColor(Colors.textTertiary)
            .margin({ left: 4 })
        }
        .width('100%')

        Text('查看计划来巴黎的驴友 →')
          .fontSize(FontSizes.bodySmall)
          .fontColor(Colors.primary)
          .margin({ top: 16 })
      }
      .width('100%')
      .padding(Spacing.cardPadding)
      .backgroundColor(Colors.bgPrimary)
      .borderRadius(Radius.card)
    }
  }

  @Builder
  GuideContent() {
    Column() {
      Text('📝')
        .fontSize(48)
        .margin({ bottom: 16 })
      Text('攻略功能开发中')
        .fontSize(FontSizes.body)
        .fontColor(Colors.textTertiary)
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(Colors.bgPrimary)
    .borderRadius(Radius.card)
  }
}
