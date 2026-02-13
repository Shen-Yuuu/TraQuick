/**
 * 注册页面
 */

import { Colors, FontSizes, Spacing, Radius, Sizes } from '../../utils/Constants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct RegisterPage {
  @State nickname: string = '';
  @State account: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State verifyCode: string = '';
  @State isPasswordVisible: boolean = false;
  @State countdown: number = 0;
  @State isLoading: boolean = false;
  @State agreeTerms: boolean = false;

  build() {
    Column() {
      // 背景装饰
      Column()
        .width('100%')
        .height('25%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#E0F2FE', 0], ['#FFFFFF', 1]]
        })
        .position({ x: 0, y: 0 })

      // 顶部导航
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor(Colors.textPrimary)
          .onClick(() => {
            router.back();
          })

        Text('注册')
          .fontSize(FontSizes.h4)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)

        // 占位保持居中
        Text('')
          .width(24)
      }
      .width('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 56, bottom: 20 })

      // 表单区域
      Scroll() {
        Column() {
          // Logo
          Column() {
            Text('🌍')
              .fontSize(48)
            Text('加入 TraQuick')
              .fontSize(FontSizes.h4)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.textPrimary)
              .margin({ top: 12 })
            Text('开启你的探索之旅')
              .fontSize(FontSizes.bodySmall)
              .fontColor(Colors.textTertiary)
              .margin({ top: 4 })
          }
          .margin({ bottom: 32 })
          .alignItems(HorizontalAlign.Center)

          // 昵称输入
          this.InputField('昵称', '👤', '请输入昵称', this.nickname, (value: string) => {
            this.nickname = value;
          })

          // 账号输入
          this.InputField('手机/邮箱', '📱', '请输入手机号或邮箱', this.account, (value: string) => {
            this.account = value;
          })

          // 验证码输入
          Column() {
            Text('验证码')
              .fontSize(FontSizes.bodySmall)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.textSecondary)
              .margin({ bottom: 8, left: 4 })

            Row() {
              Text('✉️')
                .fontSize(18)
                .margin({ right: 12 })

              TextInput({ placeholder: '请输入验证码', text: this.verifyCode })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(FontSizes.body)
                .fontColor(Colors.textPrimary)
                .placeholderColor(Colors.textQuaternary)
                .caretColor(Colors.primary)
                .onChange((value: string) => {
                  this.verifyCode = value;
                })

              Button(this.countdown > 0 ? `${this.countdown}s` : '获取验证码')
                .fontSize(FontSizes.small)
                .fontColor(this.countdown > 0 ? Colors.textQuaternary : Colors.primary)
                .backgroundColor('transparent')
                .enabled(this.countdown === 0)
                .onClick(() => {
                  this.sendVerifyCode();
                })
            }
            .width('100%')
            .height(Sizes.inputHeight)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Colors.bgSecondary)
            .borderRadius(Radius.input)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 })

          // 密码输入
          Column() {
            Text('密码')
              .fontSize(FontSizes.bodySmall)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.textSecondary)
              .margin({ bottom: 8, left: 4 })

            Row() {
              Text('🔒')
                .fontSize(18)
                .margin({ right: 12 })

              TextInput({ placeholder: '请设置8-20位密码', text: this.password })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(FontSizes.body)
                .fontColor(Colors.textPrimary)
                .placeholderColor(Colors.textQuaternary)
                .caretColor(Colors.primary)
                .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                .onChange((value: string) => {
                  this.password = value;
                })

              Text(this.isPasswordVisible ? '👁️' : '🙈')
                .fontSize(18)
                .onClick(() => {
                  this.isPasswordVisible = !this.isPasswordVisible;
                })
            }
            .width('100%')
            .height(Sizes.inputHeight)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Colors.bgSecondary)
            .borderRadius(Radius.input)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 16 })

          // 确认密码
          Column() {
            Text('确认密码')
              .fontSize(FontSizes.bodySmall)
              .fontWeight(FontWeight.Medium)
              .fontColor(Colors.textSecondary)
              .margin({ bottom: 8, left: 4 })

            Row() {
              Text('🔒')
                .fontSize(18)
                .margin({ right: 12 })

              TextInput({ placeholder: '请再次输入密码', text: this.confirmPassword })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(FontSizes.body)
                .fontColor(Colors.textPrimary)
                .placeholderColor(Colors.textQuaternary)
                .caretColor(Colors.primary)
                .type(InputType.Password)
                .onChange((value: string) => {
                  this.confirmPassword = value;
                })
            }
            .width('100%')
            .height(Sizes.inputHeight)
            .padding({ left: 16, right: 16 })
            .backgroundColor(Colors.bgSecondary)
            .borderRadius(Radius.input)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 24 })

          // 用户协议
          Row() {
            Checkbox()
              .select(this.agreeTerms)
              .selectedColor(Colors.primary)
              .onChange((value: boolean) => {
                this.agreeTerms = value;
              })

            Text() {
              Span('我已阅读并同意')
                .fontSize(FontSizes.small)
                .fontColor(Colors.textTertiary)
              Span('《用户协议》')
                .fontSize(FontSizes.small)
                .fontColor(Colors.primary)
              Span('和')
                .fontSize(FontSizes.small)
                .fontColor(Colors.textTertiary)
              Span('《隐私政策》')
                .fontSize(FontSizes.small)
                .fontColor(Colors.primary)
            }
            .margin({ left: 8 })
          }
          .width('100%')

          // 注册按钮
          Button() {
            Row() {
              if (this.isLoading) {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color(Colors.textWhite)
              } else {
                Text('注册')
                  .fontSize(FontSizes.bodyLarge)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Colors.textWhite)
              }
            }
          }
          .width('100%')
          .height(Sizes.buttonLg)
          .backgroundColor(this.agreeTerms ? Colors.primary : Colors.textQuaternary)
          .borderRadius(Radius.button)
          .shadow({ radius: 12, color: 'rgba(14, 165, 233, 0.3)', offsetY: 4 })
          .margin({ top: 24 })
          .enabled(this.agreeTerms)
          .onClick(() => {
            this.handleRegister();
          })

          // 登录入口
          Row() {
            Text('已有账号？')
              .fontSize(FontSizes.bodySmall)
              .fontColor(Colors.textTertiary)
            Text('立即登录')
              .fontSize(FontSizes.bodySmall)
              .fontColor(Colors.primary)
              .fontWeight(FontWeight.Medium)
              .margin({ left: 4 })
              .onClick(() => {
                router.back();
              })
          }
          .margin({ top: 24, bottom: 48 })
        }
        .width('100%')
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgPrimary)
  }

  @Builder
  InputField(label: string, icon: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(FontSizes.bodySmall)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.textSecondary)
        .margin({ bottom: 8, left: 4 })

      Row() {
        Text(icon)
          .fontSize(18)
          .margin({ right: 12 })

        TextInput({ placeholder: placeholder, text: value })
          .layoutWeight(1)
          .backgroundColor('transparent')
          .fontSize(FontSizes.body)
          .fontColor(Colors.textPrimary)
          .placeholderColor(Colors.textQuaternary)
          .caretColor(Colors.primary)
          .onChange(onChange)
      }
      .width('100%')
      .height(Sizes.inputHeight)
      .padding({ left: 16, right: 16 })
      .backgroundColor(Colors.bgSecondary)
      .borderRadius(Radius.input)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 16 })
  }

  sendVerifyCode() {
    if (!this.account) {
      return;
    }
    this.countdown = 60;
    const timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(timer);
      }
    }, 1000);
  }

  handleRegister() {
    if (!this.nickname || !this.account || !this.verifyCode || !this.password || !this.confirmPassword) {
      return;
    }
    if (this.password !== this.confirmPassword) {
      return;
    }

    this.isLoading = true;
    setTimeout(() => {
      this.isLoading = false;
      router.replaceUrl({ url: 'pages/Index' });
    }, 1500);
  }
}
