/**
 * 编辑资料页面 - 真实输入与 API 保存
 */

import { ApiService, ApiUser, UpdateProfileParams } from '../../services/ApiService';

type GenderType = '男' | '女' | '保密';

// ==================== 自定义输入弹窗 ====================
@CustomDialog
struct TextInputDialog {
  controller: CustomDialogController
  title: string = ''
  placeholder: string = ''
  textValue: string = ''
  maxLength: number = 20
  isTextArea: boolean = false
  onConfirm: (value: string) => void = () => {}

  build() {
    Column() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E293B')
        .margin({ top: 24, bottom: 16 })

      if (this.isTextArea) {
        TextArea({ text: this.textValue, placeholder: this.placeholder })
          .height(100)
          .maxLength(this.maxLength)
          .backgroundColor('#F1F5F9')
          .padding(12)
          .margin({ left: 20, right: 20, bottom: 24 })
          .onChange((value: string) => { this.textValue = value })
      } else {
        TextInput({ text: this.textValue, placeholder: this.placeholder })
          .height(48)
          .maxLength(this.maxLength)
          .backgroundColor('#F1F5F9')
          .padding({ left: 16, right: 16 })
          .margin({ left: 20, right: 20, bottom: 24 })
          .onChange((value: string) => { this.textValue = value })
      }

      Row() {
        Text('取消')
          .fontSize(16)
          .fontColor('#64748B')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => { this.controller.close() })

        Column().width(1).height(24).backgroundColor('#E2E8F0')

        Text('确定')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#38BDF8')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.onConfirm(this.textValue);
            this.controller.close();
          })
      }
      .width('100%')
      .height(50)
      .border({ width: { top: 1 }, color: '#F1F5F9' })
    }
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .width('80%')
  }
}

// ==================== 主页面 ====================
@Entry
@Component
struct EditProfilePage {
  @State nickname: string = '';
  @State bio: string = '';
  @State gender: GenderType = '保密';
  @State birthday: string = '1995-06-15';
  @State location: string = '上海';
  @State traquickId: string = '';
  @State avatar: string = '';

  @State isLoading: boolean = false;

  // 昵称弹窗控制器
  nicknameDialogController: CustomDialogController = new CustomDialogController({
    builder: TextInputDialog({
      title: '修改昵称',
      placeholder: '请输入新昵称',
      textValue: this.nickname,
      maxLength: 15,
      isTextArea: false,
      onConfirm: (value: string) => {
        this.nickname = value;
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  // 简介弹窗控制器
  bioDialogController: CustomDialogController = new CustomDialogController({
    builder: TextInputDialog({
      title: '修改简介',
      placeholder: '介绍一下自己吧...',
      textValue: this.bio,
      maxLength: 50,
      isTextArea: true,
      onConfirm: (value: string) => {
        this.bio = value;
      }
    }),
    autoCancel: true,
    alignment: DialogAlignment.Center
  });

  aboutToAppear(): void {
    this.loadProfile();
  }

  private async loadProfile(): Promise<void> {
    try {
      const apiUser: ApiUser = await ApiService.getProfile();
      this.nickname = apiUser.nickname;
      this.bio = apiUser.bio || '';
      this.avatar = apiUser.avatar;
      this.traquickId = 'TraQuick_' + apiUser.id.substring(0, 8);
    } catch (error) {
      console.error('[EditProfile] 加载失败');
    }
  }

  private async saveProfile(): Promise<void> {
    if (this.isLoading) return;
    this.isLoading = true;

    try {
      const params = new UpdateProfileParams();
      params.nickname = this.nickname;
      params.bio = this.bio;
      params.avatar = this.avatar;

      await ApiService.updateProfile(params);

      // 更新本地缓存
      AppStorage.setOrCreate('currentUserNickname', this.nickname);
      AppStorage.setOrCreate('currentUserAvatar', this.avatar);

      this.getUIContext().getPromptAction().showToast({ message: '保存成功' });
      this.getUIContext().getRouter().back();

    } catch (error) {
      const err = error as Error;
      try {
        this.getUIContext().getPromptAction().showToast({ message: '保存失败: ' + err.message });
      } catch (e) {
        console.error('[EditProfile] Toast异常:', e);
      }
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      this.NavigationBar()

      Scroll() {
        Column() {
          this.AvatarSection()
          this.EditItemsList()
          Text('个人信息仅用于展示，保护你的隐私安全')
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ top: 32 })
        }
        .padding({ bottom: 50 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  NavigationBar() {
    Column() {
      Row().width('100%').height(48)
      Row() {
        Row() {
          Text('←')
            .fontSize(28)
            .fontColor('#1E293B')
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => { this.getUIContext().getRouter().back(); })

        Blank()
        Text('编辑资料')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
        Blank()

        if (this.isLoading) {
          LoadingProgress().width(24).height(24).color('#38BDF8')
        } else {
          Text('保存')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#38BDF8')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => { this.saveProfile(); })
        }
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  AvatarSection() {
    Column() {
      Stack() {
        Column()
          .width(108)
          .height(108)
          .borderRadius(54)
          .linearGradient({
            direction: GradientDirection.RightBottom,
            colors: [['#7DD3FC', 0], ['#0EA5E9', 1]]
          })

        Image(this.avatar || $r('app.media.layered_image'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 3, color: '#FFFFFF' })

        Column() {
          Text('📷').fontSize(14)
        }
        .width(32)
        .height(32)
        .backgroundColor('#38BDF8')
        .borderRadius(16)
        .border({ width: 2, color: '#FFFFFF' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 72, y: 72 })
      }
      .onClick(() => { this.showAvatarOptions(); })

      Text('点击更换头像')
        .fontSize(13)
        .fontColor('#64748B')
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 })
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  EditItemsList() {
    Column() {
      this.SectionHeader('基本信息')
      Column() {
        this.EditItem('昵称', this.nickname, () => {
          // 更新弹窗初始值
          this.nicknameDialogController = new CustomDialogController({
            builder: TextInputDialog({
              title: '修改昵称',
              placeholder: '请输入新昵称',
              textValue: this.nickname,
              maxLength: 15,
              onConfirm: (value: string) => { this.nickname = value; }
            }),
            autoCancel: true,
            alignment: DialogAlignment.Center
          });
          this.nicknameDialogController.open();
        })
        this.Divider()
        this.EditItem('TraQuick ID', this.traquickId, undefined, false)
        this.Divider()
        this.EditItem('简介', this.bio || '填写简介，让大家认识你', () => {
          this.bioDialogController = new CustomDialogController({
            builder: TextInputDialog({
              title: '修改简介',
              placeholder: '介绍一下自己吧...',
              textValue: this.bio,
              maxLength: 50,
              isTextArea: true,
              onConfirm: (value: string) => { this.bio = value; }
            }),
            autoCancel: true,
            alignment: DialogAlignment.Center
          });
          this.bioDialogController.open();
        })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })

      this.SectionHeader('个人信息')
      Column() {
        this.EditItemWithValue('性别', this.gender, () => { this.showGenderPicker(); })
        this.Divider()
        this.EditItemWithValue('生日', this.birthday, () => {
          try { this.getUIContext().getPromptAction().showToast({ message: '日期选择暂未接入' }); } catch (e) { /* ignore */ }
        })
        this.Divider()
        this.EditItemWithValue('地区', this.location, () => {
          try { this.getUIContext().getPromptAction().showToast({ message: '地区选择暂未接入' }); } catch (e) { /* ignore */ }
        })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })
    }
  }

  @Builder
  SectionHeader(title: string) {
    Text(title).fontSize(13).fontColor('#64748B').fontWeight(FontWeight.Medium).padding({ left: 28, top: 20, bottom: 8 })
  }

  @Builder
  EditItem(label: string, value: string, onClick?: () => void, showArrow: boolean = true) {
    Row() {
      Text(label).fontSize(15).fontColor('#1E293B').width(80)
      Text(value)
        .fontSize(15)
        .fontColor(value.includes('填写') ? '#94A3B8' : '#64748B')
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.End)
      if (showArrow) {
        Text('›').fontSize(18).fontColor('#CBD5E1').margin({ left: 8 })
      }
    }
    .width('100%').height(56).padding({ left: 16, right: 16 })
    .onClick(() => { if (onClick) onClick(); })
  }

  @Builder
  EditItemWithValue(label: string, value: string, onClick: () => void) {
    Row() {
      Text(label).fontSize(15).fontColor('#1E293B').width(80)
      Text(value).fontSize(15).fontColor('#64748B').layoutWeight(1).textAlign(TextAlign.End)
      Text('›').fontSize(18).fontColor('#CBD5E1').margin({ left: 8 })
    }
    .width('100%').height(56).padding({ left: 16, right: 16 })
    .onClick(() => onClick())
  }

  @Builder
  Divider() {
    Column().width('100%').height(1).backgroundColor('#F1F5F9').margin({ left: 16 })
  }

  private showAvatarOptions(): void {
    try {
      this.getUIContext().getPromptAction().showActionMenu({
        title: '更换头像',
        buttons: [{ text: '拍照', color: '#1E293B' }, { text: '相册', color: '#1E293B' }, { text: '取消', color: '#64748B' }]
      });
    } catch (e) {
      console.error('[EditProfile] showAvatarOptions异常:', e);
    }
  }

  private showGenderPicker(): void {
    try {
      this.getUIContext().getPromptAction().showActionMenu({
        title: '选择性别',
        buttons: [{ text: '男', color: '#1E293B' }, { text: '女', color: '#1E293B' }, { text: '保密', color: '#1E293B' }]
      }).then((res) => {
        const opts: GenderType[] = ['男', '女', '保密'];
        if (res.index >= 0 && res.index < 3) this.gender = opts[res.index];
      });
    } catch (e) {
      console.error('[EditProfile] showGenderPicker异常:', e);
    }
  }
}