/**
 * 登录页面 - 对接真实 API
 */
import { router } from '@kit.ArkUI';
import { ApiService, AuthData, LoginParams } from '../../services/ApiService';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State account: string = '';
  @State password: string = '';
  @State isPasswordVisible: boolean = false;
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

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
        // Logo 区域
        Column() {
          Stack() {
            Column()
              .width(100)
              .height(100)
              .borderRadius(50)
              .border({ width: 2, color: 'rgba(14, 165, 233, 0.2)' })

            Column()
              .width(80)
              .height(80)
              .borderRadius(40)
              .border({ width: 1.5, color: 'rgba(14, 165, 233, 0.3)' })

            Column()
              .width(60)
              .height(60)
              .borderRadius(30)
              .backgroundColor('rgba(14, 165, 233, 0.1)')

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

          // 邮箱输入
          Column() {
            Text('邮箱')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor('#64748B')
              .margin({ bottom: 10, left: 4 })

            Row() {
              Text('📧')
                .fontSize(18)
                .margin({ right: 12 })

              TextInput({ placeholder: '请输入邮箱', text: this.account })
                .layoutWeight(1)
                .backgroundColor('transparent')
                .fontSize(15)
                .fontColor('#1E293B')
                .placeholderColor('#CBD5E1')
                .caretColor('#38BDF8')
                .type(InputType.Email)
                .onChange((value: string) => {
                  this.account = value;
                  this.errorMessage = '';
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
          .backgroundColor(this.canLogin() ? '#38BDF8' : '#CBD5E1')
          .borderRadius(26)
          .shadow({ radius: 16, color: 'rgba(14, 165, 233, 0.35)', offsetY: 6 })
          .margin({ top: 32 })
          .enabled(this.canLogin() && !this.isLoading)
          .onClick(() => {
            this.handleLogin();
          })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

        // 底部区域
        Column() {
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

          Row() {
            this.ThirdPartyIcon('💬')
            this.ThirdPartyIcon('👁️')
            this.ThirdPartyIcon('🌐')
          }
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 36 })

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

  private canLogin(): boolean {
    return this.account.trim().length > 0 && this.password.trim().length > 0;
  }

  /**
   * 真实登录
   */
  private async handleLogin(): Promise<void> {
    if (!this.canLogin()) {
      return;
    }

    this.isLoading = true;
    this.errorMessage = '';

    try {
      // 构造参数对象
      const params = new LoginParams();
      params.email = this.account;
      params.password = this.password;

      const result: AuthData = await ApiService.login(params);

      // 存储 Token 和用户信息
      AppStorage.setOrCreate('userToken', result.accessToken);
      AppStorage.setOrCreate('currentUserId', result.user.id);
      AppStorage.setOrCreate('currentUserNickname', result.user.nickname);
      AppStorage.setOrCreate('currentUserAvatar', result.user.avatar);
      AppStorage.setOrCreate('currentUserEmail', result.user.email);
      AppStorage.setOrCreate('isLoggedIn', true);

      console.info(`[Login] 登录成功: ${result.user.nickname}`);
      router.replaceUrl({ url: 'pages/Index' });

    } catch (error) {
      const err = error as Error;
      this.errorMessage = err.message || '登录失败，请检查邮箱和密码';
      console.error(`[Login] 登录失败: ${err.message}`);
    } finally {
      this.isLoading = false;
    }
  }
}