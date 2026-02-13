/**
 * 发布图文动态页面- 符合设计数
 */

import { Colors, FontSizes, Spacing, Radius, Sizes } from '../../utils/Constants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct PublishPostPage {
  @State content: string = '';
  @State selectedImages: string[] = [];
  @State location: string = '北京';
  @State locationDetail: string = '朝阳区 · 三里屯';
  @State selectedTopic: string = '#旅行日记';
  @State postVisibility: string = '公开';
  @State isPublishing: boolean = false;
  @State coordinates: string = '39.9042° N, 116.4074° E';

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('取消')
          .fontSize(15)
          .fontColor('#64748B')
          .onClick(() => {
            router.back();
          })

        Blank()

        Button() {
          Row() {
            Text('发布')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
                  Text('✕')
              .fontSize(15)
              .fontColor('#FFFFFF')
              .margin({ left: 4 })
          }
        }
        .height(36)
        .padding({ left: 20, right: 20 })
        .backgroundColor(this.content || this.selectedImages.length > 0 ? '#38BDF8' : '#CBD5E1')
        .borderRadius(18)
        .onClick(() => {
          this.handlePublish();
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 52, bottom: 12 })
      .backgroundColor('#FFFFFF')

      Divider().color('#F1F5F9')

      Scroll() {
        Column() {
          // 内容输入区
          Column() {
            Text('此刻，你想记录些什么...')
              .fontSize(18)
              .fontColor(this.content ? '#1E293B' : '#94A3B8')
              .width('100%')

            Text('Share your journey...')
              .fontSize(15)
              .fontColor('#CBD5E1')
              .fontStyle(FontStyle.Italic)
              .width('100%')
              .margin({ top: 4 })
              .visibility(this.content ? Visibility.None : Visibility.Visible)

            TextArea({ placeholder: '', text: this.content })
              .width('100%')
              .height(120)
              .fontSize(16)
              .fontColor('#1E293B')
              .placeholderColor('#CBD5E1')
              .backgroundColor('transparent')
              .caretColor('#38BDF8')
              .margin({ top: 16 })
              .onChange((value: string) => {
                this.content = value;
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 24 })
          .alignItems(HorizontalAlign.Start)

          // 图片选择器 - 微信朋友圈风格网格布局
          Flex({ wrap: FlexWrap.Wrap }) {
            // 已选择的图片
            ForEach(this.selectedImages, (image: string, index: number) => {
              Stack() {
                Column()
                  .width('100%')
                  .height('100%')
                  .backgroundColor('#E2E8F0')
                  .borderRadius(8)
                  .linearGradient({
                    direction: GradientDirection.Bottom,
                    colors: [['#94A3B8', 0], ['#64748B', 1]]
                  })

                // 删除按钮
                Column() {
                  Text('✕')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                }
                .width(18)
                .height(18)
                .backgroundColor('rgba(0,0,0,0.5)')
                .borderRadius(9)
                .justifyContent(FlexAlign.Center)
                .position({ x: '100%', y: 0 })
                .translate({ x: -22, y: 4 })
                .onClick(() => {
                  this.selectedImages.splice(index, 1);
                  this.selectedImages = [...this.selectedImages];
                })
              }
              .width(((100 - 6) / 3).toString() + '%')
              .aspectRatio(1)
              .margin({ right: index % 3 === 2 ? 0 : '3%', bottom: 8 })
            })

            // 添加图片按钮
            if (this.selectedImages.length < 9) {
              Column() {
                Text('+')
                  .fontSize(36)
                  .fontColor('#94A3B8')
              }
              .width(((100 - 6) / 3).toString() + '%')
              .aspectRatio(1)
              .backgroundColor('#F8FAFC')
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Dashed })
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.selectImage();
              })
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16 })

          // 已选照片计数
          if (this.selectedImages.length > 0) {
            Text(`${this.selectedImages.length}/9 已选`)
              .fontSize(12)
              .fontColor('#94A3B8')
              .width('100%')
              .textAlign(TextAlign.End)
              .padding({ right: 20, top: 8 })
          }

          Divider().color('#F1F5F9').margin({ top: 24 })

          // 位置选择
          Row() {
            Column() {
              Text('📍')
                .fontSize(18)
            }
            .width(40)
            .height(40)
            .backgroundColor('#E0F2FE')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Column() {
              Row() {
                Text('我在')
                  .fontSize(15)
                  .fontColor('#64748B')
                Text(this.location)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#38BDF8')
              }
              Text(this.locationDetail)
                .fontSize(12)
                .fontColor('#94A3B8')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            .layoutWeight(1)

            Text('›')
              .fontSize(20)
              .fontColor('#CBD5E1')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })

          Divider().color('#F1F5F9')

          // 话题标签
          Row() {
            Column() {
              Text('#')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#38BDF8')
            }
            .width(40)
            .height(40)
            .backgroundColor('#E0F2FE')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Text('添加话题')
              .fontSize(15)
              .fontColor('#64748B')
              .margin({ left: 12 })
              .layoutWeight(1)

            Text(this.selectedTopic)
              .fontSize(13)
              .fontColor('#38BDF8')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#E0F2FE')
              .borderRadius(12)
              .margin({ right: 12 })

            Text('›')
              .fontSize(20)
              .fontColor('#CBD5E1')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })

          Divider().color('#F1F5F9')

          // 可见范围
          Row() {
            Column() {
                Text('👁️')
                .fontSize(18)
            }
            .width(40)
            .height(40)
            .backgroundColor('#E0F2FE')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Text('谁可以看')
              .fontSize(15)
              .fontColor('#64748B')
              .margin({ left: 12 })
              .layoutWeight(1)

            Text(this.postVisibility)
              .fontSize(13)
              .fontColor('#64748B')
              .margin({ right: 12 })

            Text('›')
              .fontSize(20)
              .fontColor('#CBD5E1')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })

          Divider().color('#F1F5F9')

          // 地图预览
          Column() {
            Stack() {
              Column()
                .width('100%')
                .height(120)
                .backgroundColor('#E0F2FE')
                .borderRadius(12)

              // 地图网格模拟
              Column()
                .width('100%')
                .height('100%')
                .borderRadius(12)
                .linearGradient({
                  direction: GradientDirection.Bottom,
                  colors: [['rgba(14, 165, 233, 0.1)', 0], ['rgba(14, 165, 233, 0.05)', 1]]
                })

              // 坐标显示
              Text(this.coordinates)
                .fontSize(11)
                .fontColor('#64748B')
                .fontFamily('monospace')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('rgba(255,255,255,0.9)')
                .borderRadius(8)
                .position({ x: 12, y: 88 })
            }
            .width('100%')
            .height(120)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 48 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  selectImage() {
    // 模拟添加图片
    if (this.selectedImages.length < 9) {
      this.selectedImages.push('mock_image_' + this.selectedImages.length);
    }
  }

  handlePublish() {
    if (!this.content && this.selectedImages.length === 0) {
      return;
    }

    this.isPublishing = true;
    setTimeout(() => {
      this.isPublishing = false;
      router.back();
    }, 1500);
  }
}
