import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化 AppStorage 默认值
    // PersistentStorage 在 ArkTS 中通过 AppStorage 配合 @StorageProp 使用
    AppStorage.setOrCreate('userToken', '');
    AppStorage.setOrCreate('currentUserId', '');
    AppStorage.setOrCreate('currentUserNickname', '');
    AppStorage.setOrCreate('currentUserAvatar', '');
    AppStorage.setOrCreate('currentUserEmail', '');
    AppStorage.setOrCreate('isLoggedIn', false);

    console.info('[EntryAbility] AppStorage 初始化完成');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 根据登录状态决定首页
    const isLoggedIn = AppStorage.get<boolean>('isLoggedIn') || false;
    const token = AppStorage.get<string>('userToken') || '';

    let startPage: string;
    if (isLoggedIn && token) {
      startPage = 'pages/Index';
    } else {
      startPage = 'pages/auth/LoginPage';
    }

    windowStage.loadContent(startPage, (err) => {
      if (err) {
        console.error(`[EntryAbility] 加载页面失败: ${JSON.stringify(err)}`);
        return;
      }
      console.info(`[EntryAbility] 加载页面: ${startPage}`);
    });
  }
}