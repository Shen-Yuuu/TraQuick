/**
 * 漂流瓶结果页 - 沉浸式海洋风格
 */

import { router } from '@kit.ArkUI';

@Entry
@Component
struct BottleResultPage {
  @State senderName: string = '小美';
  @State senderCity: string = '成都';
  @State senderLevel: number = 5;
  @State sendTime: string = '2小时前';
  @State distance: string = '2,300';
  @State wishContent: string = '希望能看到拉萨布达拉宫的日落 🌅';
  @State bottleFloat: number = 0;

  aboutToAppear(): void {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.EaseInOut }, () => {
        this.bottleFloat = this.bottleFloat === 0 ? -10 : 0;
      });
    }, 2000);
  }

  build() {
    Stack() {
      // 海洋渐变背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#E0F2FE', 0],
            ['#BAE6FD', 0.25],
            ['#7DD3FC', 0.5],
            ['#38BDF8', 0.75],
            ['#0EA5E9', 1]
          ]
        })

      // 装饰光效
      Column()
        .width(300)
        .height(300)
        .borderRadius(150)
        .backgroundColor('#FFFFFF')
        .opacity(0.08)
        .blur(80)
        .position({ x: '60%', y: '5%' })

      Column()
        .width(200)
        .height(200)
        .borderRadius(100)
        .backgroundColor('#7DD3FC')
        .opacity(0.1)
        .blur(60)
        .position({ x: '-10%', y: '30%' })

      // 主内容
      Column() {
        // 顶部栏
        Row() {
          Column() {
            Text('←')
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1E293B')
          }
          .width(38)
          .height(38)
          .borderRadius(19)
          .backgroundColor('rgba(255,255,255,0.8)')
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => { router.back(); })

          Blank()

          Row() {
            Text('🍾')
              .fontSize(13)
            Text('漂流瓶')
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0369A1')
              .margin({ left: 4 })
          }
          .padding({ left: 14, right: 14, top: 8, bottom: 8 })
          .backgroundColor('rgba(255,255,255,0.8)')
          .borderRadius(16)

          Blank()

          Column().width(38).height(38)
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 44 })

        Blank()

        // 漂流瓶图标
        Column() {
          Text('🍾')
            .fontSize(80)
            .translate({ y: this.bottleFloat })

          Text('你捡到了一个漂流瓶')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.7)')
            .margin({ top: 16 })
        }
        .alignItems(HorizontalAlign.Center)

        // 内容卡片
        Column() {
          // 愿望内容
          Column() {
            Row() {
              Text('🌟')
                .fontSize(13)
              Text('许愿')
                .fontSize(12)
                .fontColor('#64748B')
                .margin({ left: 4 })
            }
            .padding({ left: 10, right: 10, top: 5, bottom: 5 })
            .backgroundColor('#FEF3C7')
            .borderRadius(10)
            .alignSelf(ItemAlign.Start)

            Text(`"${this.wishContent}"`)
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1E293B')
              .lineHeight(28)
              .margin({ top: 16 })
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius({ topLeft: 20, topRight: 20 })

          // 发送者信息
          Row() {
            Column() {
              Text('👩')
                .fontSize(22)
            }
            .width(44)
            .height(44)
            .backgroundColor('#EFF6FF')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Row() {
                Text(this.senderName)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1E293B')
                Text(`LV.${this.senderLevel}`)
                  .fontSize(10)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                  .backgroundColor('#38BDF8')
                  .borderRadius(8)
                  .margin({ left: 8 })
              }

              Row() {
                Text(`📍 ${this.senderCity}`)
                  .fontSize(12)
                  .fontColor('#94A3B8')
                Text(` · ${this.sendTime}`)
                  .fontSize(12)
                  .fontColor('#94A3B8')
                Text(` · ${this.distance}km`)
                  .fontSize(12)
                  .fontColor('#38BDF8')
              }
              .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 20 })
          .backgroundColor('#FAFBFC')
          .borderRadius({ bottomLeft: 20, bottomRight: 20 })
        }
        .width('100%')
        .padding({ left: 20, right: 20 })
        .margin({ top: 24 })
        .shadow({ radius: 20, color: 'rgba(0,0,0,0.08)', offsetY: 4 })

        Blank()

        // 操作按钮
        Column({ space: 12 }) {
          // 帮他实现
          Row() {
            Text('📷')
              .fontSize(16)
            Text('帮他实现')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ left: 8 })
          }
          .width('85%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: [['#0EA5E9', 0], ['#38BDF8', 1]]
          })
          .borderRadius(26)
          .shadow({ radius: 16, color: 'rgba(14,165,233,0.3)', offsetY: 4 })

          // 放回大海
          Row() {
            Text('🌊')
              .fontSize(15)
            Text('放回大海')
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.8)')
              .margin({ left: 6 })
          }
          .height(44)
          .justifyContent(FlexAlign.Center)
          .onClick(() => { router.back(); })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 50 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}