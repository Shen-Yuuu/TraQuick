/**
 * 发布选择弹窗组件 - 全屏毛玻璃 + 底部关闭按钮
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';

interface PublishOption {
  icon: string;
  iconBg: string[];   // 渐变色
  title: string;
  desc: string;
  type: 'post' | 'capsule' | 'bottle';
}

@Component
export struct PublishSelectDialog {
  @Link isShow: boolean;
  onSelect: (type: string) => void = () => {};

  // 入场动画
  @State cardScale: number = 0.92;
  @State cardOpacity: number = 0;

  private options: PublishOption[] = [
    {
      icon: '📷',
      iconBg: ['#38BDF8', '#0EA5E9'],
      title: '发布图文/视频',
      desc: '分享当下的精彩瞬间',
      type: 'post'
    },
    {
      icon: '🕰️',
      iconBg: ['#A78BFA', '#7C3AED'],
      title: '埋下时空胶囊',
      desc: '给未来的自己留一段言',
      type: 'capsule'
    },
    {
      icon: '🍾',
      iconBg: ['#34D399', '#059669'],
      title: '投递漂流瓶',
      desc: '遇见未知的旅途伙伴',
      type: 'bottle'
    },
  ];

  private doClose(): void {
    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.cardScale = 0.92;
      this.cardOpacity = 0;
    });
    setTimeout(() => {
      this.isShow = false;
    }, 210);
  }

  build() {
    if (this.isShow) {
      Stack() {
        // ===== 毛玻璃全屏遮罩 =====
        Column()
          .width('100%')
          .height('100%')
          .backgroundBlurStyle(BlurStyle.Regular)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              ['rgba(186, 230, 253, 0.88)', 0],
              ['rgba(224, 242, 254, 0.92)', 0.45],
              ['rgba(255, 255, 255, 0.96)', 1]
            ]
          })
          .onClick(() => {
            this.doClose();
          })

        // ===== 内容主体 =====
        Column() {
          // -- 标题 --
          Column() {
            Text('开始你的旅程')
              .fontSize(26)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0F172A')

            Text('选择一种方式记录此刻的奇遇')
              .fontSize(14)
              .fontColor('#64748B')
              .margin({ top: 8 })
          }
          .margin({ bottom: 36 })

          // -- 选项卡片 --
          ForEach(this.options, (option: PublishOption) => {
            Row() {
              // 渐变图标
              Column() {
                Text(option.icon)
                  .fontSize(28)
              }
              .width(54)
              .height(54)
              .linearGradient({
                direction: GradientDirection.RightBottom,
                colors: [[option.iconBg[0], 0], [option.iconBg[1], 1]]
              })
              .borderRadius(18)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .shadow({ radius: 12, color: `${option.iconBg[1]}35`, offsetY: 4 })

              // 文字
              Column() {
                Text(option.title)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1E293B')

                Text(option.desc)
                  .fontSize(13)
                  .fontColor('#64748B')
                  .margin({ top: 3 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 16 })
              .layoutWeight(1)

              // 箭头
              Text('›')
                .fontSize(22)
                .fontColor('#CBD5E1')
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 18, bottom: 18 })
            .backgroundColor('rgba(255, 255, 255, 0.82)')
            .borderRadius(20)
            .shadow({ radius: 10, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
            .border({ width: 0.5, color: 'rgba(255,255,255,0.9)' })
            .margin({ bottom: 14 })
            .onClick(() => {
              this.onSelect(option.type);
              this.isShow = false;
              // 重置动画状态以备下次
              this.cardScale = 0.92;
              this.cardOpacity = 0;
            })
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 100 })
        .alignItems(HorizontalAlign.Center)
        .scale({ x: this.cardScale, y: this.cardScale })
        .opacity(this.cardOpacity)

        // 底部遮罩（覆盖 TabBar 残影）
        Column()
          .width('100%')
          .height(90)
          .backgroundColor('rgba(255, 255, 255, 0.98)')
          .position({ x: 0, y: '100%' })
          .translate({ y: -90 })

        // ===== 底部关闭按钮（与 Tab 栏 + 号对应） =====
        Column() {
          Column() {
            Text('✕')
              .fontSize(22)
              .fontWeight(FontWeight.Medium)
              .fontColor('#FFFFFF')
          }
          .width(52)
          .height(52)
          .linearGradient({
            direction: GradientDirection.RightBottom,
            colors: [['#94A3B8', 0], ['#64748B', 1]]
          })
          .borderRadius(26)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .shadow({ radius: 16, color: 'rgba(0, 0, 0, 0.15)', offsetY: 4 })
          .onClick(() => {
            this.doClose();
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: '100%' })
        .translate({ y: -45 })
      }
      .width('100%')
      .height('100%')
      .onAppear(() => {
        animateTo({
          duration: 280,
          curve: Curve.EaseOut,
        }, () => {
          this.cardScale = 1;
          this.cardOpacity = 1;
        });
      })
    }
  }
}
