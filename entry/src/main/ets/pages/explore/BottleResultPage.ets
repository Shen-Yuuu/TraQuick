/**
 * 漂流瓶结果页面- 捡到漂流瓶后的展
 */

import { router } from '@kit.ArkUI';

@Entry
@Component
struct BottleResultPage {
  @State senderAvatar: string = '👩';
  @State senderName: string = '小美';
  @State senderCity: string = '成都';
  @State senderLevel: number = 5;
  @State sendTime: string = '2小时前';
  @State distance: string = '2,300 km';
  @State wishContent: string = '"希望能看到拉萨布达拉宫的日落"';

  build() {
    Stack() {
      // 渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#E0F2FE', 0],
            ['#BAE6FD', 0.3],
            ['#7DD3FC', 0.6],
            ['#38BDF8', 1]
          ]
        })

      // 顶部栏
      Row() {
        // TraQuick 标签
        Row() {
          Text('🌍')
            .fontSize(14)
          Text('TRAQUICK')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#64748B')
            .letterSpacing(1)
            .margin({ left: 6 })
        }
        .padding({ left: 14, right: 14, top: 8, bottom: 8 })
        .backgroundColor('rgba(255,255,255,0.9)')
        .borderRadius(20)

        Blank()

        // 关闭按钮
        Column() {
          Text('✕')
            .fontSize(18)
            .fontColor('#64748B')
        }
        .width(44)
        .height(44)
        .backgroundColor('#FFFFFF')
        .borderRadius(22)
        .justifyContent(FlexAlign.Center)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.08)', offsetY: 2 })
        .onClick(() => {
          router.back();
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 52 })
      .position({ x: 0, y: 0 })
      .zIndex(10)

      // 主内容区域
      Column() {
        // New Discovery 标签
        Row() {
          Text('✨')
            .fontSize(14)
            .fontColor('#38BDF8')
          Text('New Discovery')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#38BDF8')
            .margin({ left: 6 })
        }
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .backgroundColor('rgba(255,255,255,0.9)')
        .borderRadius(20)
        .margin({ top: 100 })

        // 标题
        Text('你在海边捡到一个漂流瓶')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
          .margin({ top: 16 })

        // 漂流瓶图片区域
        Stack() {
          Column()
            .width('85%')
            .height(280)
            .backgroundColor('#F1F5F9')
            .borderRadius(24)
            .linearGradient({
              direction: GradientDirection.Bottom,
              colors: [['#E2E8F0', 0], ['#CBD5E1', 1]]
            })

          // 漂流瓶图片
          Text('🍾')
            .fontSize(100)
        }
        .width('100%')
        .height(280)
        .margin({ top: 16 })

        // 发送者信息卡片
        Column() {
          Row() {
            // 头像
            Stack() {
              Column() {
                Text(this.senderAvatar)
                  .fontSize(28)
              }
              .width(52)
              .height(52)
              .backgroundColor('#F1F5F9')
              .borderRadius(26)
              .justifyContent(FlexAlign.Center)

              // 等级标签
              Text(`LV.${this.senderLevel}`)
                .fontSize(9)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .backgroundColor('#38BDF8')
                .borderRadius(8)
                .position({ x: 30, y: 42 })
            }

            // 用户信息
            Column() {
              Row() {
                Text(`来自 ${this.senderCity} 的`)
                  .fontSize(14)
                  .fontColor('#64748B')
                Text(this.senderName)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1E293B')
              }

              Row() {
                Text('🕐')
                  .fontSize(12)
                Text(this.sendTime)
                  .fontSize(12)
                  .fontColor('#94A3B8')
                  .margin({ left: 4 })

                Text('·')
                  .fontSize(12)
                  .fontColor('#CBD5E1')
                  .margin({ left: 8, right: 8 })

                Text('📍')
                  .fontSize(12)
                Text(this.distance)
                  .fontSize(12)
                  .fontColor('#38BDF8')
                  .margin({ left: 4 })
              }
              .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })

            Blank()

            Text('···')
              .fontSize(20)
              .fontColor('#CBD5E1')
          }
          .width('100%')

          // 愿望内容
          Text(this.wishContent)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .lineHeight(28)
            .margin({ top: 16 })
        }
        .width('90%')
        .padding(20)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .shadow({ radius: 16, color: 'rgba(0,0,0,0.08)', offsetY: 4 })
        .margin({ top: -40 })

        Blank()

        // 帮他实现按钮
        Button() {
          Row() {
            Text('📷')
              .fontSize(18)
            Text('帮他实现')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ left: 8 })
          }
        }
        .width('90%')
        .height(52)
        .backgroundColor('#38BDF8')
        .borderRadius(26)
        .shadow({ radius: 16, color: 'rgba(14, 165, 233, 0.35)', offsetY: 6 })
        .onClick(() => {
          // TODO: 跳转到帮助实现页面
        })

        // 放回大海按钮
        Row() {
          Text('🌊')
            .fontSize(16)
          Text('放回大海')
            .fontSize(14)
            .fontColor('#64748B')
            .margin({ left: 6 })
        }
        .margin({ top: 20, bottom: 40 })
        .onClick(() => {
          router.back();
        })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}
