/**
 * 登录页面 - 符合设计数 */
import { Colors, FontSizes, Spacing, Radius, Sizes } from '../../utils/Constants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State isPasswordVisible: boolean = false;
  @State isLoading: boolean = false;

  build() {
    Column() {
      // 渐变背景
      Column()
        .width('100%')
        .height('40%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#E0F2FE', 0], ['#F0F9FF', 0.5], ['#FFFFFF', 1]]
        })
        .position({ x: 0, y: 0 })

      // 主内容
      Column() {
        // Logo区域
        Column() {
          // 轨道动画Logo
          Stack() {
            // 外圈轨道
            Column()
              .width(100)
              .height(100)
              .borderRadius(50)
              .border({ width: 2, color: 'rgba(14, 165, 233, 0.2)' })

            // 中圈轨道
            Column()
              .width(80)
              .height(80)
              .borderRadius(40)
              .border({ width: 1.5, color: 'rgba(14, 165, 233, 0.3)' })

            // 内圈填充
            Column()
              .width(60)
              .height(60)
              .borderRadius(30)
              .backgroundColor('rgba(14, 165, 233, 0.1)')

            // 地球图标
            Text('🌐')
              .fontSize(32)
          }

          Text('TraQuick')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ top: 20 })

          Text('探索无限可能')
            .fontSize(14)
            .fontColor('#94A3B8')
            .letterSpacing(4)
            .margin({ top: 8 })
        }
        .margin({ top: 80, bottom: 48 })
        .alignItems(HorizontalAlign.Center)

        // 表单区域
        Column() {
          // 账号输入
          Column() {
            Text('账号')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#64748B')
              .margin({ bottom: 10, left: 4 })

            Row() {
              Text('👤')
                .fontSize(18)
                .margin({ right: 12 })

              TextInput({ placeholder: '请输入手机号/邮箱', text: this.account })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(15)
                .fontColor('#1E293B')
                .placeholderColor('#CBD5E1')
                .caretColor('#38BDF8')
                .onChange((value: string) => {
                  this.account = value;
                })
            }
            .width('100%')
            .height(52)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F8FAFC')
            .borderRadius(14)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)

          // 密码输入
          Column() {
            Text('密码')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#64748B')
              .margin({ bottom: 10, left: 4 })

            Row() {
              Text('🔒')
                .fontSize(18)
                .margin({ right: 12 })

              TextInput({ placeholder: '请输入密码', text: this.password })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(15)
                .fontColor('#1E293B')
                .placeholderColor('#CBD5E1')
                .caretColor('#38BDF8')
                .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                })

              Text(this.isPasswordVisible ? '👁️' : '🙈')
                .fontSize(18)
                .opacity(0.6)
                .onClick(() => {
                  this.isPasswordVisible = !this.isPasswordVisible;
                })
            }
            .width('100%')
            .height(52)
            .padding({ left: 16, right: 16 })
            .backgroundColor('#F8FAFC')
            .borderRadius(14)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 20 })

          // 忘记密码
          Row() {
            Blank()
            Text('忘记密码?')
              .fontSize(13)
              .fontColor('#94A3B8')
          }
          .width('100%')
          .margin({ top: 12 })

          // 登录按钮
          Button() {
            Row() {
              if (this.isLoading) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color('#FFFFFF')
              } else {
                Text('登录')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('→')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .margin({ left: 8 })
              }
            }
          }
          .width('100%')
          .height(52)
          .backgroundColor('#38BDF8')
          .borderRadius(26)
          .shadow({ radius: 16, color: 'rgba(14, 165, 233, 0.35)', offsetY: 6 })
          .margin({ top: 32 })
          .onClick(() => {
            this.handleLogin();
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

        // 底部区域
        Column() {
          // 分割线
          Row() {
            Divider().layoutWeight(1).color('#E2E8F0')
            Text('或者使用以下方式登录')
              .fontSize(12)
              .fontColor('#CBD5E1')
              .margin({ left: 16, right: 16 })
            Divider().layoutWeight(1).color('#E2E8F0')
          }
          .width('100%')
          .margin({ bottom: 28 })

          // 第三方登录
          Row() {
            this.ThirdPartyIcon('💬')
            this.ThirdPartyIcon('👁️')
            this.ThirdPartyIcon('🌐')
          }
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 36 })

          // 注册入口
          Row() {
            Text('还没有账号？')
              .fontSize(14)
              .fontColor('#94A3B8')
            Text('立即注册')
              .fontSize(14)
              .fontColor('#38BDF8')
              .fontWeight(FontWeight.Bold)
              .margin({ left: 4 })
              .onClick(() => {
                router.pushUrl({ url: 'pages/auth/RegisterPage' });
              })
          }
        }
        .margin({ top: 48 })
        .padding({ left: 24, right: 24 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  ThirdPartyIcon(icon: string) {
    Column() {
      Text(icon)
        .fontSize(22)
    }
    .width(52)
    .height(52)
    .backgroundColor('#F8FAFC')
    .borderRadius(26)
    .justifyContent(FlexAlign.Center)
    .border({ width: 1, color: '#E2E8F0' })
    .margin({ left: 16, right: 16 })
  }

  handleLogin() {
    if (!this.account || !this.password) {
      return;
    }

    this.isLoading = true;
    setTimeout(() => {
      this.isLoading = false;
      router.replaceUrl({ url: 'pages/Index' });
    }, 1500);
  }
}
