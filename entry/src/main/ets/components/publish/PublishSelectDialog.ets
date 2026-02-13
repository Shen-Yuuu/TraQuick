/**
 * 发布选择弹窗组件 - 符合设计数
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';

interface PublishOption {
  icon: string;
  iconBg: string;
  title: string;
  desc: string;
  type: 'post' | 'capsule' | 'bottle';
}

@Component
export struct PublishSelectDialog {
  @Link isShow: boolean;
  onSelect: (type: string) => void = () => {};

  private options: PublishOption[] = [
    {
      icon: '📷',
      iconBg: '#38BDF8',
      title: '发布图文/视频',
      desc: '分享当下的精彩瞬间',
      type: 'post'
    },
    {
      icon: '🕰️',
      iconBg: '#8B5CF6',
      title: '埋下时空胶囊',
      desc: '给未来的自己留一段言',
      type: 'capsule'
    },
    {
      icon: '🍾',
      iconBg: '#38BDF8',
      title: '投递漂流瓶',
      desc: '遇见未知的旅途伙伴',
      type: 'bottle'
    },
  ];

  build() {
    if (this.isShow) {
      Stack() {
        // 毛玻璃遮罩层
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['rgba(186, 230, 253, 0.9)', 0], ['rgba(224, 242, 254, 0.95)', 0.5], ['rgba(255, 255, 255, 0.98)', 1]]
          })
          .onClick(() => {
            this.isShow = false;
          })

        // 弹窗内容
        Column() {
          // 标题区域
          Column() {
            Text('开始你的旅程')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E293B')

            Text('选择一种方式记录此刻的奇遇')
              .fontSize(14)
              .fontColor('#64748B')
              .margin({ top: 8 })
          }
          .margin({ bottom: 32 })

          // 选项列表
          ForEach(this.options, (option: PublishOption, index: number) => {
            Row() {
              // 图标容器
              Column() {
                Text(option.icon)
                  .fontSize(28)
              }
              .width(56)
              .height(56)
              .backgroundColor(option.iconBg)
              .borderRadius(28)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .shadow({ radius: 8, color: `${option.iconBg}40`, offsetY: 4 })

              // 文字内容
              Column() {
                Text(option.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1E293B')

                Text(option.desc)
                  .fontSize(13)
                  .fontColor('#64748B')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16 })
              .layoutWeight(1)

              // 箭头
              Column() {
                Text('›')
                  .fontSize(24)
                  .fontColor('#CBD5E1')
              }
              .width(32)
              .height(32)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }
            .width('100%')
            .padding(16)
            .backgroundColor('rgba(255, 255, 255, 0.8)')
            .borderRadius(16)
            .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
            .margin({ bottom: 12 })
            .onClick(() => {
              this.onSelect(option.type);
              this.isShow = false;
            })
          })


        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 80, bottom: 60 })
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
    }
  }
}
