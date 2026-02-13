/**
 * 投递漂流瓶页面 - 符合设计数
 */

import { router } from '@kit.ArkUI';

@Entry
@Component
struct DriftBottlePage {
  @State content: string = '';
  @State isTaskBottle: boolean = false;
  @State isPublishing: boolean = false;

  build() {
    Column() {
      Row() {
        // 关闭按钮
        Column() {
          Text('←')
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

        Blank()

        // TraQuick 标签
        Text('TRAQUICK')
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#38BDF8')
          .letterSpacing(2)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
          .backgroundColor('rgba(255,255,255,0.9)')
          .borderRadius(16)

        Blank()

        Column().width(44)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 52 })
      .position({ x: 0, y: 0 })
      .zIndex(10)

      // 海洋背景图片区域
      Stack() {
        // 渐变背景模拟海洋
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['#87CEEB', 0],
              ['#3BA3C8', 0.6],
              ['#2A8CB6', 1]
            ]
          })

        // 漂流瓶图片占位
        Column() {
          Text('🍾')
            .fontSize(120)
        }
        .position({ x: '50%', y: '40%' })
        .translate({ x: '-50%', y: '-50%' })
      }
      .width('100%')
      .height('45%')
      .borderRadius({ bottomLeft: 32, bottomRight: 32 })
      .clip(true)

      // 标题区域
      Column() {
        Text('投递漂流瓶')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        Text('将你的思绪放入大海，等待回应')
          .fontSize(14)
          .fontColor('#64748B')
          .margin({ top: 8 })
      }
      .margin({ top: 24 })

      // 内容输入区域
      Column() {
        TextArea({ placeholder: '写下你的愿望或心情...\n就像对着大海诉说一样', text: this.content })
          .width('100%')
          .height(120)
          .fontSize(15)
          .fontColor('#1E293B')
          .placeholderColor('#94A3B8')
          .backgroundColor('transparent')
          .caretColor('#38BDF8')
          .onChange((value: string) => {
            this.content = value;
          })

        Row() {
          Row() {
            Text('😊')
              .fontSize(16)
            Text('MOOD')
              .fontSize(11)
              .fontColor('#94A3B8')
              .margin({ left: 6 })
          }

          Blank()

          Text(`${this.content.length}/500`)
            .fontSize(12)
            .fontColor('#CBD5E1')
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(20)
      .margin({ left: 20, right: 20, top: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius(20)
      .border({ width: 1, color: '#F1F5F9' })

      // 任务型漂流瓶选项
      Row() {
        Column() {
          Text('📷')
            .fontSize(20)
        }
        .width(44)
        .height(44)
        .backgroundColor('#E0F2FE')
        .borderRadius(22)
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('任务型漂流瓶')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1E293B')
          Text('请求拾瓶者拍摄一张当地照片')
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        .layoutWeight(1)

        Toggle({ type: ToggleType.Switch, isOn: this.isTaskBottle })
          .selectedColor('#38BDF8')
          .onChange((isOn: boolean) => {
            this.isTaskBottle = isOn;
          })
      }
      .width('100%')
      .padding(16)
      .margin({ left: 20, right: 20, top: 16 })
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .border({ width: 1, color: '#F1F5F9' })

      Blank()

      // 投递按钮
      Button() {
        Row() {
          Text('投递')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text('→')
            .fontSize(16)
            .fontColor('#FFFFFF')
            .margin({ left: 8 })
        }
      }
      .width('90%')
      .height(52)
      .backgroundColor('#38BDF8')
      .borderRadius(26)
      .shadow({ radius: 16, color: 'rgba(14, 165, 233, 0.35)', offsetY: 6 })
      .margin({ bottom: 16 })
      .onClick(() => {
        this.handlePublish();
      })

      // 社区公约
      Text('TraQuick 社区公约：请友善交流，传递温暖')
        .fontSize(11)
        .fontColor('#94A3B8')
        .margin({ bottom: 32 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  handlePublish() {
    if (!this.content) {
      return;
    }
    this.isPublishing = true;
    setTimeout(() => {
      this.isPublishing = false;
      router.back();
    }, 1500);
  }
}
