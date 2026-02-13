/**
 * 埋下时空胶囊页面 - 符合设计数
 */

import { router } from '@kit.ArkUI';

interface TimeOption {
  label: string;
  sublabel: string;
  value: number;
}

@Entry
@Component
struct TimeCapsulePage {
  @State content: string = '';
  @State selectedImages: string[] = [];
  @State selectedTimeIndex: number = 1;  // 默认选中1年后
  @State locationName: string = '京都, 日本';
  @State coordinates: string = '35.0116° N, 135.7681° E';
  @State capsuleNumber: string = 'NO. 8291';
  @State isPublishing: boolean = false;

  private timeOptions: TimeOption[] = [
    { label: '6个月', sublabel: '2024\n年秋', value: 6 },
    { label: '1年后', sublabel: '2025\n年春', value: 12 },
    { label: '5年后', sublabel: '2029\n年冬', value: 60 },
    { label: '自定义', sublabel: '选择日期', value: -1 },
  ];

  build() {
    Column() {
      // 顶部深色区域
      Column() {
        // 导航栏
        Row() {
          Column() {
            Text('←')
              .fontSize(24)
              .fontColor('#FFFFFF')
          }
          .width(40)
          .height(40)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            router.back();
          })

          Text('埋下时空胶囊')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)

          Column().width(40)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 52 })

        // 时钟图标区域
        Column() {
          Stack() {
            // 时钟外圈发光
            Column()
              .width(180)
              .height(180)
              .borderRadius(90)
              .backgroundColor('#D4A574')
              .shadow({ radius: 30, color: 'rgba(212, 165, 116, 0.5)', offsetY: 0 })

            // 时钟内圈
            Column()
              .width(160)
              .height(160)
              .borderRadius(80)
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [['#C9956C', 0], ['#A67C52', 1]]
              })

            // 时钟表盘
            Text('🕐')
              .fontSize(100)
          }
        }
        .margin({ top: 24, bottom: 24 })

        // 胶囊编号
        Text(`TIME CAPSULE · ${this.capsuleNumber}`)
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.6)')
          .letterSpacing(2)
          .margin({ bottom: 24 })
      }
      .width('100%')
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: [['#1E293B', 0], ['#334155', 1]]
      })
      .alignItems(HorizontalAlign.Center)

      // 底部白色内容区域
      Column() {
        // 拖拽指示条
        Column()
          .width(40)
          .height(4)
          .backgroundColor('#E2E8F0')
          .borderRadius(2)
          .margin({ top: 12, bottom: 20 })

        Scroll() {
          Column() {
            // 内容输入区
            Column() {
              Text('写下给未来的自己...')
                .fontSize(16)
                .fontColor(this.content ? '#1E293B' : '#94A3B8')
                .width('100%')

              Text('此刻的心情，或是对未来的期许')
                .fontSize(14)
                .fontColor('#CBD5E1')
                .width('100%')
                .margin({ top: 4 })

              TextArea({ placeholder: '', text: this.content })
                .width('100%')
                .height(80)
                .fontSize(15)
                .fontColor('#1E293B')
                .backgroundColor('transparent')
                .caretColor('#2563EB')
                .margin({ top: 16 })
                .onChange((value: string) => {
                  this.content = value;
                })
            }
            .width('100%')
            .padding(20)
            .alignItems(HorizontalAlign.Start)

            // 照片选择器
            Row() {
              // 添加照片按钮
              Column() {
                Text('📷+')
                  .fontSize(24)
                  .fontColor('#94A3B8')
                Text('添加照片')
                  .fontSize(10)
                  .fontColor('#94A3B8')
                  .margin({ top: 4 })
              }
              .width(72)
              .height(72)
              .backgroundColor('#F8FAFC')
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Dashed })
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                if (this.selectedImages.length < 9) {
                  this.selectedImages.push('image_' + this.selectedImages.length);
                }
              })

              // 已选图片
              ForEach(this.selectedImages, (img: string, index: number) => {
                Column()
                  .width(72)
                  .height(72)
                  .backgroundColor('#E2E8F0')
                  .borderRadius(12)
                  .linearGradient({
                    direction: GradientDirection.Bottom,
                    colors: [['#94A3B8', 0], ['#64748B', 1]]
                  })
                  .margin({ left: 8 })
              })
            }
            .width('100%')
            .padding({ left: 20, right: 20 })

            // 开启时间选择
            Column() {
              Row() {
                Text('⏰')
                  .fontSize(16)
                Text('开启时间')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1E293B')
                  .margin({ left: 8 })
              }
              .width('100%')
              .margin({ bottom: 16 })

              Row() {
                ForEach(this.timeOptions, (option: TimeOption, index: number) => {
                  Column() {
                    Text(option.label)
                      .fontSize(14)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.selectedTimeIndex === index ? '#FFFFFF' : '#64748B')

                    Text(option.sublabel)
                      .fontSize(10)
                      .fontColor(this.selectedTimeIndex === index ? 'rgba(255,255,255,0.8)' : '#94A3B8')
                      .margin({ top: 4 })
                      .textAlign(TextAlign.Center)
                  }
                  .width(75)
                  .height(75)
                  .backgroundColor(this.selectedTimeIndex === index ? '#2563EB' : '#F8FAFC')
                  .borderRadius(12)
                  .border({
                    width: this.selectedTimeIndex === index ? 0 : 1,
                    color: '#E2E8F0'
                  })
                  .justifyContent(FlexAlign.Center)
                  .shadow(this.selectedTimeIndex === index ?
                    { radius: 8, color: 'rgba(14, 165, 233, 0.3)', offsetY: 4 } :
                    { radius: 0, color: 'transparent' })
                  .onClick(() => {
                    this.selectedTimeIndex = index;
                  })
                })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 24 })

            // 埋藏地点
            Column() {
              Row() {
                Text('📍')
                  .fontSize(16)
                Text('埋藏地点')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1E293B')
                  .margin({ left: 8 })

                Blank()

                Text('更换')
                  .fontSize(13)
                  .fontColor('#2563EB')
                Text('›')
                  .fontSize(13)
                  .fontColor('#2563EB')
                  .margin({ left: 2 })
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 地图预览
              Stack() {
                Column()
                  .width('100%')
                  .height(100)
                  .backgroundColor('#E0F2FE')
                  .borderRadius(12)

                Column() {
                  Text(this.locationName)
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1E293B')
                  Text(this.coordinates)
                    .fontSize(11)
                    .fontColor('#64748B')
                    .fontFamily('monospace')
                    .margin({ top: 4 })
                }
                .alignItems(HorizontalAlign.Start)
                .position({ x: 12, y: 65 })
              }
              .width('100%')
              .height(100)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 24, bottom: 24 })
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)

        // 确认埋下按钮
        Button() {
          Row() {
            Text('确认埋下')
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
        .backgroundColor('#2563EB')
        .borderRadius(26)
        .shadow({ radius: 16, color: 'rgba(14, 165, 233, 0.35)', offsetY: 6 })
        .margin({ bottom: 32 })
        .onClick(() => {
          this.handlePublish();
        })
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 24, topRight: 24 })
      .margin({ top: -24 })
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1E293B')
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
