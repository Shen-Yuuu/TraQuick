/**
 * 设置页面 - iOS 风格分组列表
 * 功能：账号安全、通用设置、关于、退出登录
 */

import { authService } from '../../services/AuthService';
import { storage, StorageKeys } from '../../utils/Storage';

@Entry
@Component
struct SettingsPage {
  @State darkMode: boolean = false;
  @State language: string = '简体中文';
  @State isLoggingOut: boolean = false;
  @State cacheSize: string = '计算中...';

  aboutToAppear(): void {
    this.loadSettings();
  }

  private async loadSettings(): Promise<void> {
    // 加载暗黑模式设置
    this.darkMode = await storage.getBoolean(StorageKeys.THEME_MODE, false);
    // 模拟缓存大小计算
    this.cacheSize = '23.5 MB';
  }

  private async toggleDarkMode(isOn: boolean): Promise<void> {
    this.darkMode = isOn;
    await storage.setBoolean(StorageKeys.THEME_MODE, isOn);
    // TODO: 应用主题切换
    console.info(`[Settings] 深色模式: ${isOn}`);
  }

  build() {
    Column() {
      // ====== 顶部导航 ======
      Row() {
        Column() {
          Text('←')
            .fontSize(28)
            .fontColor('#38BDF8')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Column().width(40)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 52, bottom: 16 })
      .backgroundColor('#FFFFFF')

      // ====== 设置列表 ======
      Scroll() {
        Column() {

          // ==========================================
          // 分组一：账号安全
          // ==========================================
          Text('账号安全')
            .fontSize(13)
            .fontColor('#94A3B8')
            .width('100%')
            .margin({ bottom: 8, left: 4 })

          Column() {
            this.SettingCell('🔑', '修改密码', '', () => {
              console.info('[Settings] 修改密码');
            })

            this.CellDivider()

            this.SettingCell('📱', '绑定手机', '已绑定', () => {
              console.info('[Settings] 绑定手机');
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 28 })

          // ==========================================
          // 分组二：通用设置
          // ==========================================
          Text('通用设置')
            .fontSize(13)
            .fontColor('#94A3B8')
            .width('100%')
            .margin({ bottom: 8, left: 4 })

          Column() {
            // 深色模式 - 带 Toggle
            Row() {
              Column() {
                Text('🌙')
                  .fontSize(18)
              }
              .width(36)
              .height(36)
              .backgroundColor('#E0F2FE')
              .borderRadius(10)
              .justifyContent(FlexAlign.Center)

              Text('深色模式')
                .fontSize(16)
                .fontColor('#1E293B')
                .margin({ left: 14 })
                .layoutWeight(1)

              Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
                .selectedColor('#38BDF8')
                .switchPointColor('#FFFFFF')
                .onChange((isOn: boolean) => {
                  this.toggleDarkMode(isOn);
                })
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })

            this.CellDivider()

            this.SettingCell('🌐', '语言', this.language, () => {
              console.info('[Settings] 语言设置');
            })

            this.CellDivider()

            this.SettingCell('🗑️', '清除缓存', this.cacheSize, () => {
              this.clearCache();
            })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 28 })

          // ==========================================
          // 分组三：关于
          // ==========================================
          Text('关于')
            .fontSize(13)
            .fontColor('#94A3B8')
            .width('100%')
            .margin({ bottom: 8, left: 4 })

          Column() {
            this.SettingCell('🔏', '隐私政策', '', () => {
              console.info('[Settings] 隐私政策');
            })

            this.CellDivider()

            this.SettingCell('📋', '用户协议', '', () => {
              console.info('[Settings] 用户协议');
            })

            this.CellDivider()

            // 版本号 - 无箭头，不可点击
            Row() {
              Column() {
                Text('ℹ️')
                  .fontSize(18)
              }
              .width(36)
              .height(36)
              .backgroundColor('#E0F2FE')
              .borderRadius(10)
              .justifyContent(FlexAlign.Center)

              Text('版本号')
                .fontSize(16)
                .fontColor('#1E293B')
                .margin({ left: 14 })
                .layoutWeight(1)

              Text('v1.0.0')
                .fontSize(14)
                .fontColor('#94A3B8')
            }
            .width('100%')
            .height(56)
            .padding({ left: 16, right: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 40 })

          // ==========================================
          // 退出登录
          // ==========================================
          Column() {
            Text('退出登录')
              .fontSize(16)
              .fontColor('#EF4444')
              .fontWeight(FontWeight.Medium)
          }
          .width('100%')
          .height(52)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .onClick(() => {
            this.showLogoutConfirm();
          })

          // 底部留白
          Column().height(60)
        }
        .padding({ left: 16, right: 16, top: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F2F3F5')
  }

  // ============================
  // 通用设置项（带箭头，可点击）
  // ============================
  @Builder
  SettingCell(icon: string, title: string, value: string, onTap: () => void) {
    Row() {
      Column() {
        Text(icon)
          .fontSize(18)
      }
      .width(36)
      .height(36)
      .backgroundColor('#E0F2FE')
      .borderRadius(10)
      .justifyContent(FlexAlign.Center)

      Text(title)
        .fontSize(16)
        .fontColor('#1E293B')
        .margin({ left: 14 })
        .layoutWeight(1)

      if (value.length > 0) {
        Text(value)
          .fontSize(14)
          .fontColor('#94A3B8')
          .margin({ right: 6 })
      }

      Text('›')
        .fontSize(20)
        .fontColor('#CBD5E1')
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(onTap)
  }

  // ============================
  // 分割线
  // ============================
  @Builder
  CellDivider() {
    Row() {
      Column().width(66) // 图标宽36 + 左padding16 + 间距14
      Divider()
        .color('#F1F5F9')
        .layoutWeight(1)
    }
    .width('100%')
  }

  // ============================
  // 退出登录确认弹窗（系统 AlertDialog）
  // ============================
  private showLogoutConfirm(): void {
    if (this.isLoggingOut) return;

    AlertDialog.show({
      title: '退出登录',
      message: '确定要退出当前账号吗？退出后需要重新登录。',
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        fontColor: '#64748B',
        action: () => {
          console.info('[Settings] 取消退出');
        }
      },
      secondaryButton: {
        value: '退出',
        fontColor: '#EF4444',
        action: () => {
          this.handleLogout();
        }
      }
    });
  }

  // ============================
  // 执行退出登录 - 使用 AuthService 统一清除
  // ============================
  private async handleLogout(): Promise<void> {
    this.isLoggingOut = true;
    try {
      await authService.logout();
      console.info('[Settings] 已退出登录，跳转登录页');

      this.getUIContext().getRouter().replaceUrl({
        url: 'pages/auth/LoginPage'
      }).catch((err: Error) => {
        console.error(`[Settings] 跳转失败: ${err.message}`);
      });
    } catch (e) {
      console.error(`[Settings] 退出登录异常: ${e}`);
    } finally {
      this.isLoggingOut = false;
    }
  }

  // ============================
  // 清除缓存
  // ============================
  private clearCache(): void {
    this.getUIContext().showAlertDialog({
      title: '清除缓存',
      message: `确定要清除 ${this.cacheSize} 的缓存数据吗？`,
      alignment: DialogAlignment.Center,
      primaryButton: {
        value: '取消',
        fontColor: '#64748B',
        action: () => {}
      },
      secondaryButton: {
        value: '清除',
        fontColor: '#EF4444',
        action: () => {
          // TODO: 实际清除缓存逻辑
          this.cacheSize = '0 MB';
          console.info('[Settings] 缓存已清除');
        }
      }
    });
  }
}