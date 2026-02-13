/**
 * 转发分享弹窗 - 微博风格
 * 底部弹出用户头像列表 + 分享此刻想法
 */

import { Colors, Radius, Spacing, FontSizes } from '../../utils/Constants';
import { User } from '../../models/User';
import { mockCurrentUser, mockUsers } from '../../services/MockData';

@Component
export struct SharePanel {
  @Prop isShow: boolean = false;
  @State shareText: string = '';
  @State shareAnimProgress: number = 0;
  onClose: () => void = () => {};
  onShareToUser: (userId: string, text: string) => void = () => {};

  private shareUsers: User[] = [mockCurrentUser, ...mockUsers];

  aboutToAppear(): void {
    animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
      this.shareAnimProgress = 1;
    });
  }

  build() {
    if (this.isShow) {
      Stack() {
        // 遮罩
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.4)')
          .opacity(this.shareAnimProgress)
          .onClick(() => this.onClose())

        // 底部面板
        Column() {
          // 拖拽指示条
          Column()
            .width(40)
            .height(4)
            .borderRadius(2)
            .backgroundColor('#E2E8F0')
            .margin({ top: 12, bottom: 16 })

          // 标题
          Text('分享到')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ bottom: 16 })

          // 用户头像横滑列表
          Scroll() {
            Row({ space: 16 }) {
              ForEach(this.shareUsers, (user: User) => {
                Column() {
                  // 头像
                  Column() {
                    Text((user.nickname || 'U').charAt(0))
                      .fontSize(20)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#FFFFFF')
                  }
                  .width(56)
                  .height(56)
                  .borderRadius(28)
                  .backgroundColor('#38BDF8')
                  .justifyContent(FlexAlign.Center)

                  Text(user.nickname)
                    .fontSize(11)
                    .fontColor('#64748B')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 6 })
                    .width(60)
                    .textAlign(TextAlign.Center)
                }
                .alignItems(HorizontalAlign.Center)
                .onClick(() => {
                  this.onShareToUser(user.id, this.shareText);
                  this.onClose();
                })
              })
            }
            .padding({ left: 20, right: 20 })
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width('100%')

          // 分隔线
          Divider()
            .strokeWidth(0.5)
            .color('#F1F5F9')
            .margin({ top: 20, bottom: 16 })

          // 分享想法输入
          Column() {
            Text('分享此刻的想法')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#475569')
              .margin({ bottom: 10 })

            TextArea({ placeholder: '说点什么吧...', text: this.shareText })
              .width('100%')
              .height(80)
              .backgroundColor('#F8FAFC')
              .borderRadius(12)
              .padding(12)
              .fontSize(14)
              .onChange((value: string) => {
                this.shareText = value;
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .alignItems(HorizontalAlign.Start)

          // 其他分享方式
          Divider()
            .strokeWidth(0.5)
            .color('#F1F5F9')
            .margin({ top: 16, bottom: 16 })

          Row({ space: 28 }) {
            this.ShareMethod('🔗', '复制链接')
            this.ShareMethod('💬', '微信')
            this.ShareMethod('📱', '朋友圈')
            this.ShareMethod('🐦', '微博')
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)

          // 取消按钮
          Button('取消')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#64748B')
            .backgroundColor('#F1F5F9')
            .borderRadius(24)
            .height(44)
            .width('90%')
            .margin({ top: 20, bottom: 34 })
            .onClick(() => this.onClose())
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius({ topLeft: 20, topRight: 20 })
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: '100%' })
        .translate({ y: -this.shareAnimProgress * 520 })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  ShareMethod(icon: string, label: string) {
    Column() {
      Column() {
        Text(icon)
          .fontSize(24)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .backgroundColor('#F1F5F9')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Text(label)
        .fontSize(11)
        .fontColor('#64748B')
        .margin({ top: 6 })
    }
    .alignItems(HorizontalAlign.Center)
  }
}
