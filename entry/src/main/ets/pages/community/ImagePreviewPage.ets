/**
 * 图片预览页 - 全屏滑动查看 (支持点赞联动与保存相册)
 * 使用 SaveButton 安全组件保存图片，无需申请 WRITE_IMAGEVIDEO 权限
 */

import { router } from '@kit.ArkUI';
import { ApiService } from '../../services/ApiService';
import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

class ImagePreviewParams {
  images?: string[];
  imageIndex?: number;
  postId?: string;
  isLiked?: boolean;
}

@Entry
@Component
struct ImagePreviewPage {
  @State images: string[] = [];
  @State currentIndex: number = 0;

  // 帖子的相关状态
  private postId: string = '';
  @State isPostLiked: boolean = false;

  @State toastText: string = '';
  @State isSaving: boolean = false;

  // 用于控制当前图片的缩放和拖拽
  @State currentScale: number = 1;
  @State lastScale: number = 1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State lastOffsetX: number = 0;
  @State lastOffsetY: number = 0;

  // 控制 UI 栏的显示与隐藏
  @State showBars: boolean = true;

  // 控制保存弹窗
  @State showSaveDialog: boolean = false;

  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    const params: ImagePreviewParams = router.getParams() as ImagePreviewParams;
    if (params) {
      this.postId = params.postId || '';

      if (params.isLiked !== undefined) {
        this.isPostLiked = params.isLiked as boolean;
      }

      if (params.images && params.images.length > 0) {
        this.images = params.images.slice();
      }

      const indexParam: number = params.imageIndex !== undefined ? Number(params.imageIndex) : 0;
      const safeIndex: number = Math.min(Math.max(indexParam, 0), Math.max(this.images.length - 1, 0));
      this.currentIndex = safeIndex;
    }
  }

  private goBack(): void {
    router.back();
  }

  /**
   * 点赞当前所属的帖子
   */
  private async togglePostLike(): Promise<void> {
    if (!this.postId) {
      this.showToast('帖子信息缺失');
      return;
    }

    const wasLiked: boolean = this.isPostLiked;
    this.isPostLiked = !wasLiked;

    const trigger: number = AppStorage.get<number>('communityRefreshTrigger') || 0;
    AppStorage.setOrCreate('communityRefreshTrigger', trigger + 1);

    try {
      if (wasLiked) {
        await ApiService.unlikePost(this.postId);
      } else {
        await ApiService.likePost(this.postId);
      }
    } catch (error) {
      this.isPostLiked = wasLiked;
      this.showToast('点赞失败');
    }
  }

  /**
   * 实际保存逻辑 - 必须在 SaveButton 的 onClick 回调链内调用
   * 此时系统已临时授予 WRITE_IMAGEVIDEO 权限
   */
  private async doSaveImage(): Promise<void> {
    if (this.images.length === 0 || this.isSaving) {
      return;
    }
    this.isSaving = true;

    const currentUrl: string = this.images[this.currentIndex];

    try {
      this.showToast('正在保存...');

      // 1. 下载图片二进制数据
      const httpRequest: http.HttpRequest = http.createHttp();
      const response: http.HttpResponse = await httpRequest.request(currentUrl, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER
      });
      httpRequest.destroy();

      if (response.responseCode !== 200) {
        throw new Error('下载图片失败');
      }

      const arrayBuffer: ArrayBuffer = response.result as ArrayBuffer;

      // 2. 使用 photoAccessHelper 创建相册资源
      // 在 SaveButton onClick 回调链中调用，系统已临时授权
      const helper: photoAccessHelper.PhotoAccessHelper =
        photoAccessHelper.getPhotoAccessHelper(this.context);

      const assetUri: string = await helper.createAsset(
        photoAccessHelper.PhotoType.IMAGE,
        'jpg'
      );

      // 3. 将二进制数据写入相册文件
      const file: fs.File = fs.openSync(assetUri, fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, arrayBuffer);
      fs.closeSync(file);

      this.showToast('已保存到系统相册');
      this.showSaveDialog = false;

    } catch (error) {
      const businessError: BusinessError = error as BusinessError;
      console.error(`[ImagePreview] 保存图片失败, code: ${businessError.code}, msg: ${businessError.message}`);
      this.showToast('保存失败');
    } finally {
      this.isSaving = false;
    }
  }

  private showToast(msg: string): void {
    this.toastText = msg;
    setTimeout(() => {
      this.toastText = '';
    }, 1500);
  }

  private resetGestureState(): void {
    this.currentScale = 1;
    this.lastScale = 1;
    this.offsetX = 0;
    this.offsetY = 0;
    this.lastOffsetX = 0;
    this.lastOffsetY = 0;
  }

  build() {
    Stack() {
      // 1. 底层：滑动与图片区
      Column() {
        if (this.images.length > 0) {
          Swiper() {
            ForEach(this.images, (img: string, index: number) => {
              Stack() {
                Image(img)
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Contain)
                  .scale(this.currentIndex === index
                    ? { x: this.currentScale, y: this.currentScale }
                    : { x: 1, y: 1 })
                  .translate(this.currentIndex === index
                    ? { x: this.offsetX, y: this.offsetY }
                    : { x: 0, y: 0 })
              }
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .gesture(
                this.currentScale > 1
                  ? GestureGroup(GestureMode.Parallel,
                  PinchGesture()
                    .onActionUpdate((event: GestureEvent) => {
                      this.currentScale = Math.max(0.5, Math.min(this.lastScale * event.scale, 4));
                    })
                    .onActionEnd(() => {
                      if (this.currentScale <= 1) {
                        animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
                          this.currentScale = 1;
                          this.offsetX = 0;
                          this.offsetY = 0;
                        });
                      }
                      this.lastScale = this.currentScale;
                    }),
                  PanGesture()
                    .onActionUpdate((event: GestureEvent) => {
                      this.offsetX = this.lastOffsetX + event.offsetX;
                      this.offsetY = this.lastOffsetY + event.offsetY;
                    })
                    .onActionEnd(() => {
                      this.lastOffsetX = this.offsetX;
                      this.lastOffsetY = this.offsetY;
                    })
                )
                  : GestureGroup(GestureMode.Exclusive,
                  PinchGesture()
                    .onActionUpdate((event: GestureEvent) => {
                      this.currentScale = Math.max(0.5, Math.min(this.lastScale * event.scale, 4));
                    })
                    .onActionEnd(() => {
                      this.lastScale = this.currentScale;
                    }),
                  TapGesture({ count: 2 })
                    .onAction(() => {
                      if (!this.isPostLiked) {
                        this.togglePostLike();
                      }
                      animateTo({ duration: 300 }, () => {
                        this.resetGestureState();
                      });
                    }),
                  TapGesture({ count: 1 })
                    .onAction(() => {
                      animateTo({ duration: 200 }, () => {
                        this.showBars = !this.showBars;
                      });
                    })
                )
              )
            })
          }
          .layoutWeight(1)
          .index(this.currentIndex)
          .autoPlay(false)
          .indicator(false)
          .loop(false)
          .onChange((index: number) => {
            this.currentIndex = index;
            this.resetGestureState();
          })
        } else {
          Column() {
            Text('图片加载中...').fontSize(14).fontColor('#94A3B8')
          }.layoutWeight(1).justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')

      // 2. 顶栏
      if (this.showBars) {
        Column() {
          this.TopBar()
        }
        .position({ x: 0, y: 0 })
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      }

      // 3. 底栏
      if (this.showBars) {
        Column() {
          this.BottomBar()
        }
        .position({ x: 0, y: '100%' })
        .translate({ y: '-100%' })
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      }

      // 4. 保存弹窗 - 包含 SaveButton 安全组件
      if (this.showSaveDialog) {
        Column() {
          Column() {
            Text('保存图片到相册')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E293B')
              .margin({ bottom: 8 })

            Text('点击下方按钮确认保存')
              .fontSize(14)
              .fontColor('#64748B')
              .margin({ bottom: 24 })

            // SaveButton 安全组件 - 系统级授权，无需权限声明
            SaveButton({
              icon: SaveIconStyle.FULL_FILLED,
              text: SaveDescription.SAVE_IMAGE,
              buttonType: ButtonType.Capsule
            })
              .width(200)
              .height(44)
              .onClick(async (_event: ClickEvent, result: SaveButtonOnClickResult) => {
                if (result === SaveButtonOnClickResult.SUCCESS) {
                  await this.doSaveImage();
                } else {
                  this.showToast('授权失败，无法保存');
                  this.showSaveDialog = false;
                }
              })

            Text('取消')
              .fontSize(14)
              .fontColor('#64748B')
              .margin({ top: 16 })
              .onClick(() => {
                this.showSaveDialog = false;
              })
          }
          .width('80%')
          .padding(28)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .alignItems(HorizontalAlign.Center)
          .shadow({
            radius: 20,
            color: 'rgba(0,0,0,0.15)',
            offsetX: 0,
            offsetY: 4
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showSaveDialog = false;
        })
      }

      // 5. Toast 提示
      if (this.toastText) {
        Column() {
          Text(this.toastText)
            .fontSize(13)
            .fontColor('#FFFFFF')
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor('rgba(0,0,0,0.7)')
            .borderRadius(20)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .hitTestBehavior(HitTestMode.Transparent)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  TopBar() {
    Row() {
      Row() {
        Text('←').fontSize(28).fontColor('#FFFFFF').fontWeight(FontWeight.Medium)
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.goBack())

      Blank()

      Text(`${this.currentIndex + 1} / ${Math.max(this.images.length, 1)}`)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .fontWeight(FontWeight.Bold)
        .letterSpacing(2)

      Blank()

      Row().width(44).height(44)
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 48, bottom: 12 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['rgba(0,0,0,0.5)', 0], ['transparent', 1]]
    })
  }

  @Builder
  BottomBar() {
    Row() {
      // 点赞帖子按钮
      Row() {
        Column() {
          Text(this.isPostLiked ? '❤️' : '🤍').fontSize(22)
        }
        .width(44)
        .height(44)
        .backgroundColor('rgba(255,255,255,0.15)')
        .borderRadius(22)
        .justifyContent(FlexAlign.Center)

        Text(this.isPostLiked ? '已喜欢' : '喜欢')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .margin({ left: 8 })
      }
      .onClick(() => this.togglePostLike())

      // 保存图片按钮 - 点击弹出 SaveButton 弹窗
      Row() {
        Column() {
          if (this.isSaving) {
            LoadingProgress().width(20).height(20).color('#FFFFFF')
          } else {
            Text('⬇️').fontSize(20)
          }
        }
        .width(44)
        .height(44)
        .backgroundColor('rgba(255,255,255,0.15)')
        .borderRadius(22)
        .justifyContent(FlexAlign.Center)

        Text('保存')
          .fontSize(13)
          .fontColor('#FFFFFF')
          .margin({ left: 8 })
      }
      .onClick(() => {
        // 弹出包含 SaveButton 的弹窗
        this.showSaveDialog = true;
      })
    }
    .width('100%')
    .padding({ left: 32, right: 32, top: 20, bottom: 40 })
    .justifyContent(FlexAlign.SpaceBetween)
    .linearGradient({
      direction: GradientDirection.Top,
      colors: [['rgba(0,0,0,0.5)', 0], ['transparent', 1]]
    })
  }
}