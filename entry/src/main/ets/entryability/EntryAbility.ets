import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    AppStorage.setOrCreate('userToken', '');
    AppStorage.setOrCreate('currentUserId', '');
    AppStorage.setOrCreate('currentUserNickname', '');
    AppStorage.setOrCreate('currentUserAvatar', '');
    AppStorage.setOrCreate('currentUserEmail', '');
    AppStorage.setOrCreate('isLoggedIn', false);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 1. 开启全屏沉浸式布局
    windowStage.getMainWindow((err, windowClass) => {
      if (err.code) {
        console.error('Failed to obtain the main window.', err);
        return;
      }

      windowClass.setWindowLayoutFullScreen(true, (err) => {
        if (err.code) {
          console.error('Failed to set the window layout to full-screen mode.', err);
          return;
        }
        console.info('Succeeded in setting the window layout to full-screen mode.');
      });

      windowClass.setWindowSystemBarProperties({
        statusBarContentColor: '#000000', // 状态栏文字黑色
        navigationBarContentColor: '#000000'
      });
    });

    const isLoggedIn = AppStorage.get<boolean>('isLoggedIn') || false;
    const token = AppStorage.get<string>('userToken') || '';
    let startPage: string;

    if (isLoggedIn && token) {
      startPage = 'pages/Index';
    } else {
      startPage = 'pages/auth/LoginPage';
    }

    windowStage.loadContent(startPage, (err) => {
      if (err) return;
    });
  }
}