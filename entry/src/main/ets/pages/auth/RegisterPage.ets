/**
 * 注册页面 - 对接真实 API
 */
import { router } from '@kit.ArkUI';
import { authService } from '../../services/AuthService';

@Entry
@Component
struct RegisterPage {
  @State email: string = '';
  @State nickname: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State isPasswordVisible: boolean = false;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  build() {
    Column() {
      Column()
        .width('100%')
        .height('30%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#E0F2FE', 0], ['#F0F9FF', 0.5], ['#FFFFFF', 1]]
        })
        .position({ x: 0, y: 0 })

      Column() {
        // 顶部导航
        Row() {
          Text('←')
            .fontSize(28)
            .fontColor('#38BDF8')
            .onClick(() => {
              router.back();
            })
          Blank()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 48 })

        // 标题
        Column() {
          Text('创建账号')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')

          Text('开始你的探索之旅')
            .fontSize(14)
            .fontColor('#94A3B8')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 24 })
        .alignItems(HorizontalAlign.Start)
        .margin({ top: 20, bottom: 32 })

        // 表单
        Scroll() {
          Column() {
            // 错误提示
            if (this.errorMessage) {
              Row() {
                Text('⚠️')
                  .fontSize(14)
                Text(this.errorMessage)
                  .fontSize(13)
                  .fontColor('#EF4444')
                  .margin({ left: 6 })
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor('#FEF2F2')
              .borderRadius(10)
              .margin({ bottom: 16 })
            }

            // 昵称
            this.InputField('昵称', '👤', '给自己取个名字', this.nickname, InputType.Normal, (v: string) => {
              this.nickname = v;
              this.errorMessage = '';
            })

            // 邮箱
            this.InputField('邮箱', '📧', '请输入邮箱', this.email, InputType.Email, (v: string) => {
              this.email = v;
              this.errorMessage = '';
            })

            // 密码
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

                TextInput({ placeholder: '至少6位密码', text: this.password })
                  .layoutWeight(1)
                  .backgroundColor('transparent')
                  .fontSize(15)
                  .fontColor('#1E293B')
                  .placeholderColor('#CBD5E1')
                  .type(this.isPasswordVisible ? InputType.Normal : InputType.Password)
                  .onChange((v: string) => {
                    this.password = v;
                    this.errorMessage = '';
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

            // 确认密码
            this.InputField('确认密码', '🔒', '再次输入密码', this.confirmPassword, InputType.Password, (v: string) => {
              this.confirmPassword = v;
              this.errorMessage = '';
            })

            // 注册按钮
            Button() {
              Row() {
                if (this.isLoading) {
                  LoadingProgress()
                    .width(24)
                    .height(24)
                    .color('#FFFFFF')
                } else {
                  Text('注册')
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text('🚀')
                    .fontSize(16)
                    .margin({ left: 8 })
                }
              }
            }
            .width('100%')
            .height(52)
            .backgroundColor(this.canRegister() ? '#38BDF8' : '#CBD5E1')
            .borderRadius(26)
            .margin({ top: 32 })
            .enabled(this.canRegister() && !this.isLoading)
            .onClick(() => {
              this.handleRegister();
            })

            // 已有账号
            Row() {
              Text('已有账号？')
                .fontSize(14)
                .fontColor('#94A3B8')
              Text('去登录')
                .fontSize(14)
                .fontColor('#38BDF8')
                .fontWeight(FontWeight.Bold)
                .margin({ left: 4 })
                .onClick(() => {
                  router.back();
                })
            }
            .margin({ top: 24, bottom: 48 })
          }
          .padding({ left: 24, right: 24 })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  InputField(label: string, icon: string, placeholder: string, value: string, type: InputType, onChange: (v: string) => void) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontWeight(FontWeight.Medium)
        .fontColor('#64748B')
        .margin({ bottom: 10, left: 4 })

      Row() {
        Text(icon)
          .fontSize(18)
          .margin({ right: 12 })

        TextInput({ placeholder: placeholder, text: value })
          .layoutWeight(1)
          .backgroundColor('transparent')
          .fontSize(15)
          .fontColor('#1E293B')
          .placeholderColor('#CBD5E1')
          .type(type)
          .onChange(onChange)
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
  }

  private canRegister(): boolean {
    return this.email.trim().length > 0
      && this.nickname.trim().length > 0
      && this.password.length >= 6
      && this.confirmPassword.length > 0;
  }

  private async handleRegister(): Promise<void> {
    // 前端校验
    if (this.password !== this.confirmPassword) {
      this.errorMessage = '两次密码输入不一致';
      return;
    }

    if (this.password.length < 6) {
      this.errorMessage = '密码至少6位';
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      const result = await authService.register(this.email, this.password, this.nickname);
      if (!result.success || !result.user) {
        this.errorMessage = result.message || '注册失败，请重试';
        return;
      }

      AppStorage.setOrCreate('currentUserEmail', result.user.email);
      console.info(`[Register] 注册成功: ${result.user.nickname}`);

      router.replaceUrl({ url: 'pages/Index' });

    } catch (error) {
      const err = error as Error;
      this.errorMessage = err.message || '注册失败，请重试';
      console.error(`[Register] 注册失败: ${err.message}`);
    } finally {
      this.isLoading = false;
    }
  }
}