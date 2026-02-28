import { router, promptAction } from '@kit.ArkUI';
import { ApiService, ApiUser, UpdateProfileParams } from '../../services/ApiService';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';

// ==================== 圆形裁剪预览弹窗 ====================
@CustomDialog
struct AvatarCropDialog {
  controller: CustomDialogController
  imageUri: string = ''
  onConfirm: (uri: string) => void = () => {}

  @State currentScale: number = 1
  @State lastScale: number = 1
  @State offsetX: number = 0
  @State offsetY: number = 0
  @State lastOffsetX: number = 0
  @State lastOffsetY: number = 0

  build() {
    Stack() {
      // 黑色背景
      Column().width('100%').height('100%').backgroundColor('#000000')

      // 可操作的图片
      Image(this.imageUri)
        .width('100%')
        .objectFit(ImageFit.Contain)
        .scale({ x: this.currentScale, y: this.currentScale })
        .translate({ x: this.offsetX, y: this.offsetY })
        .gesture(
          GestureGroup(GestureMode.Parallel,
            // 拖拽
            PanGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.offsetX = this.lastOffsetX + event.offsetX;
                this.offsetY = this.lastOffsetY + event.offsetY;
              })
              .onActionEnd(() => {
                this.lastOffsetX = this.offsetX;
                this.lastOffsetY = this.offsetY;
              }),
            // 缩放
            PinchGesture()
              .onActionUpdate((event: GestureEvent) => {
                this.currentScale = Math.max(0.5, Math.min(this.lastScale * event.scale, 3));
              })
              .onActionEnd(() => {
                this.lastScale = this.currentScale;
              })
          )
        )

      // 遮罩层 (超宽边框的透明圆，形成中间镂空的圆形裁剪框)
      Circle()
        .width(300)
        .height(300)
        .fill('transparent')
        .border({ width: 500, color: 'rgba(0,0,0,0.6)' })
        .hitTestBehavior(HitTestMode.Transparent) // 让手势穿透到下层的图片

      // 裁剪框白线
      Circle()
        .width(300)
        .height(300)
        .fill('transparent')
        .border({ width: 2, color: '#FFFFFF' })
        .hitTestBehavior(HitTestMode.Transparent)

      // 底部操作栏
      Row() {
        Text('取消').fontSize(16).fontColor('#FFFFFF').padding(20)
          .onClick(() => this.controller.close())
        Blank()
        Text('选取').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#38BDF8').padding(20)
          .onClick(() => {
            // MVP阶段：视觉裁剪，实际上传原图并在展示时套用 borderRadius(50)
            this.onConfirm(this.imageUri);
            this.controller.close();
          })
      }
      .width('100%')
      .position({ x: 0, y: '100%' })
      .translate({ y: -80 })
    }
    .width('100%')
    .height('100%')
  }
}

// ==================== 主页面 ====================
@Entry
@Component
struct EditProfilePage {
  @State nickname: string = '';
  @State bio: string = '';
  @State avatar: string = '';
  @State isLoading: boolean = false;

  private context = getContext(this) as common.UIAbilityContext;

  // 裁剪弹窗控制器
  cropDialogController: CustomDialogController = new CustomDialogController({
    builder: AvatarCropDialog({
      imageUri: '',
      onConfirm: async (uri: string) => {
        await this.handleUploadAvatar(uri);
      }
    }),
    customStyle: true,
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
    } catch (error) {}
  }

  // 1. 唤起相册
  private async pickAvatar(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = 1;

      const result = await picker.select(options);
      if (result && result.photoUris && result.photoUris.length > 0) {
        const uri = result.photoUris[0];
        // 唤起裁剪弹窗
        this.cropDialogController = new CustomDialogController({
          builder: AvatarCropDialog({
            imageUri: uri,
            onConfirm: async (croppedUri: string) => {
              await this.handleUploadAvatar(croppedUri);
            }
          }),
          customStyle: true
        });
        this.cropDialogController.open();
      }
    } catch (error) {
      console.error('[EditProfile] 选择照片失败', error);
    }
  }

  // 2. 上传头像并自动保存
  private async handleUploadAvatar(uri: string): Promise<void> {
    this.isLoading = true;
    try {
      promptAction.showToast({ message: '正在上传头像...' });
      const ossUrl = await ApiService.uploadImage(this.context, uri);
      this.avatar = ossUrl;

      // 直接保存到后端
      const params = new UpdateProfileParams();
      params.avatar = ossUrl;
      await ApiService.updateProfile(params);
      AppStorage.setOrCreate('currentUserAvatar', ossUrl);

      promptAction.showToast({ message: '头像更新成功' });
    } catch (error) {
      promptAction.showToast({ message: '头像上传失败' });
    } finally {
      this.isLoading = false;
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
      AppStorage.setOrCreate('currentUserNickname', this.nickname);

      promptAction.showToast({ message: '保存成功' });
      router.back();
    } catch (error) {
      promptAction.showToast({ message: '保存失败' });
    } finally {
      this.isLoading = false;
    }
  }

  build() {
    Column() {
      // 导航栏
      Row() {
        Text('←').fontSize(28).fontColor('#1E293B').width(44).height(44).onClick(() => router.back())
        Blank()
        Text('编辑资料').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Blank()
        if (this.isLoading) {
          LoadingProgress().width(24).height(24).color('#38BDF8')
        } else {
          Text('保存').fontSize(15).fontColor('#38BDF8').padding(8).onClick(() => this.saveProfile())
        }
      }.width('100%').height(56).padding({ left: 8, right: 16, top: 40 })

      Scroll() {
        Column() {
          // 头像
          Column() {
            Stack() {
              Image(this.avatar || $r('app.media.layered_image'))
                .width(100).height(100).borderRadius(50).objectFit(ImageFit.Cover).border({ width: 3, color: '#FFFFFF' })
              Column() { Text('📷').fontSize(14) }
              .width(32).height(32).backgroundColor('#38BDF8').borderRadius(16).border({ width: 2, color: '#FFFFFF' }).justifyContent(FlexAlign.Center).position({ x: 72, y: 72 })
            }.onClick(() => this.pickAvatar())
            Text('点击更换头像').fontSize(13).fontColor('#64748B').margin({ top: 12 })
          }.width('100%').padding(24)

          // 表单输入 (简化展示)
          Column() {
            Text('昵称').fontSize(13).fontColor('#64748B').margin({ bottom: 8 })
            TextInput({ text: this.nickname }).height(48).backgroundColor('#F1F5F9').onChange(v => this.nickname = v)

            Text('简介').fontSize(13).fontColor('#64748B').margin({ top: 20, bottom: 8 })
            TextArea({ text: this.bio }).height(100).backgroundColor('#F1F5F9').onChange(v => this.bio = v)
          }.width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(16).margin({ left: 16, right: 16 })

        }
      }.layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor('#F8FAFC')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}