/**
 * 设置页面 - iOS 风格分组列表 (修复 ArkTS 严格模式类型)
 * 功能：账号安全、通用设置、关于、退出登录
 */

import { authService } from '../../services/AuthService';
import { storage, StorageKeys } from '../../utils/Storage';
import { hidebug } from '@kit.PerformanceAnalysisKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State darkMode: boolean = false;
  @State language: string = '简体中文';
  @State isLoggingOut: boolean = false;

  // 真实计算的状态变量
  @State cacheSize: string = '计算中...';

  // 获取应用上下文，用于读取沙箱路径
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    this.loadSettings();
    this.calculateSystemUsage();
  }

  private async loadSettings(): Promise<void> {
    this.darkMode = await storage.getBoolean(StorageKeys.THEME_MODE, false);
  }

  // ============================
  // 计算运行内存和沙箱缓存
  // ============================
  private calculateSystemUsage(): void {

    // 获取应用缓存大小 (ROM)
    try {
      const cacheDirPath = this.context.cacheDir;
      const sizeBytes = this.getDirectorySize(cacheDirPath);
      const sizeMB = (sizeBytes / (1024 * 1024)).toFixed(2);
      this.cacheSize = `${sizeMB} MB`;
    } catch (e) {
      console.error('[Settings] 获取缓存失败:', e);
      this.cacheSize = '0.00 MB';
    }
  }

  /**
   * 递归计算指定目录的文件总大小（字节）
   */
  private getDirectorySize(dirPath: string): number {
    let size = 0;
    try {
      const isDir = fs.statSync(dirPath).isDirectory();
      if (!isDir) {
        return fs.statSync(dirPath).size;
      }

      const files = fs.listFileSync(dirPath);
      for (const file of files) {
        const fullPath = `${dirPath}/${file}`;
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
          size += this.getDirectorySize(fullPath);
        } else {
          size += stat.size;
        }
      }
    } catch (e) {
      console.error(`[Settings] 计算目录大小失败: ${dirPath}`, e);
    }
    return size;
  }

  // ============================
  // 真实清除缓存逻辑
  // ============================
  private clearCache(): void {
    promptAction.showDialog({
      title: '清除缓存',
      message: `确定要清除 ${this.cacheSize} 的缓存数据吗？\n清除后一些图片可能需要重新加载。`,
      buttons: [
        { text: '取消', color: '#64748B' },
        { text: '清除', color: '#EF4444' }
      ]
    }).then((res) => {
      if (res.index === 1) {
        try {
          const cacheDirPath = this.context.cacheDir;
          this.emptyDirectory(cacheDirPath);
          this.cacheSize = '0.00 MB';
          promptAction.showToast({ message: '缓存已清除' });
        } catch (e) {
          promptAction.showToast({ message: '清除失败' });
        }
      }
    });
  }

  /**
   * 递归删除目录下的所有文件（但不删除根目录本身）
   */
  private emptyDirectory(dirPath: string): void {
    try {
      const files = fs.listFileSync(dirPath);
      for (const file of files) {
        const fullPath = `${dirPath}/${file}`;
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
          this.emptyDirectory(fullPath);
          fs.rmdirSync(fullPath);
        } else {
          fs.unlinkSync(fullPath);
        }
      }
    } catch (e) {
      console.error(`[Settings] 清空目录失败: ${dirPath}`, e);
    }
  }

  private async toggleDarkMode(isOn: boolean): Promise<void> {
    this.darkMode = isOn;
    await storage.setBoolean(StorageKeys.THEME_MODE, isOn);
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
      .padding({ left: 16, right: 16, top: 44, bottom: 16 }) // 适配状态栏
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
              promptAction.showToast({ message: '功能开发中' });
            })
            this.CellDivider()
            this.SettingCell('📱', '绑定手机', '已绑定', () => {})
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
            Row() {
              Column() { Text('🌙').fontSize(18) }.width(36).height(36).backgroundColor('#E0F2FE').borderRadius(10).justifyContent(FlexAlign.Center)
              Text('深色模式').fontSize(16).fontColor('#1E293B').margin({ left: 14 }).layoutWeight(1)
              Toggle({ type: ToggleType.Switch, isOn: this.darkMode })
                .selectedColor('#38BDF8').switchPointColor('#FFFFFF')
                .onChange((isOn: boolean) => { this.toggleDarkMode(isOn); })
            }
            .width('100%').height(56).padding({ left: 16, right: 16 })

            this.CellDivider()
            this.SettingCell('🌐', '语言', this.language, () => {})

            this.CellDivider()
            this.SettingCell('🗑️', '清除应用缓存', this.cacheSize, () => { this.clearCache(); })
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
            this.SettingCell('🔏', '隐私政策', '', () => {})
            this.CellDivider()
            this.SettingCell('📋', '用户协议', '', () => {})
            this.CellDivider()

            Row() {
              Column() { Text('ℹ️').fontSize(18) }.width(36).height(36).backgroundColor('#E0F2FE').borderRadius(10).justifyContent(FlexAlign.Center)
              Text('版本号').fontSize(16).fontColor('#1E293B').margin({ left: 14 }).layoutWeight(1)
              Text('v1.0.0').fontSize(14).fontColor('#94A3B8')
            }
            .width('100%').height(56).padding({ left: 16, right: 16 })
          }
          .width('100%')
          .backgroundColor('#FFFFFF')
          .borderRadius(12)
          .margin({ bottom: 40 })

          // ==========================================
          // 退出登录
          // ==========================================
          Column() {
            Text('退出登录').fontSize(16).fontColor('#EF4444').fontWeight(FontWeight.Medium)
          }
          .width('100%').height(52).backgroundColor('#FFFFFF').borderRadius(12)
          .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
          .onClick(() => { this.showLogoutConfirm(); })

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
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  SettingCell(icon: string, title: string, value: string, onTap: () => void, showArrow: boolean = true) {
    Row() {
      Column() { Text(icon).fontSize(18) }.width(36).height(36).backgroundColor('#E0F2FE').borderRadius(10).justifyContent(FlexAlign.Center)
      Text(title).fontSize(16).fontColor('#1E293B').margin({ left: 14 }).layoutWeight(1)
      if (value.length > 0) { Text(value).fontSize(14).fontColor('#94A3B8').margin({ right: showArrow ? 6 : 0 }) }
      if (showArrow) { Text('›').fontSize(20).fontColor('#CBD5E1') }
    }
    .width('100%').height(56).padding({ left: 16, right: 16 }).onClick(onTap)
  }

  @Builder
  CellDivider() {
    Row() {
      Column().width(66)
      Divider().color('#F1F5F9').layoutWeight(1)
    }.width('100%')
  }

  private showLogoutConfirm(): void {
    if (this.isLoggingOut) return;
    promptAction.showDialog({
      title: '退出登录',
      message: '确定要退出当前账号吗？退出后需要重新登录。',
      buttons: [
        { text: '取消', color: '#64748B' },
        { text: '退出', color: '#EF4444' }
      ]
    }).then((res) => {
      if (res.index === 1) {
        this.handleLogout();
      }
    });
  }

  private async handleLogout(): Promise<void> {
    this.isLoggingOut = true;
    try {
      await authService.logout();
      this.getUIContext().getRouter().replaceUrl({ url: 'pages/auth/LoginPage' });
    } catch (e) {
      console.error(`[Settings] 退出登录异常: ${e}`);
    } finally {
      this.isLoggingOut = false;
    }
  }
}