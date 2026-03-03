/**
 * 图片预览页 - 全屏滑动查看 (支持点赞联动与保存相册)
 */

import { router, promptAction } from '@kit.ArkUI';
import { ApiService } from '../../services/ApiService';
import { http } from '@kit.NetworkKit';
import { fileIo as fs } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';

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
  @State isPostLiked: boolean = false; // 代表整个帖子的点赞状态

  @State toastText: string = '';
  @State isSaving: boolean = false; // 防抖

  // 用于控制当前图片的缩放和拖拽
  @State currentScale: number = 1;
  @State lastScale: number = 1;
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State lastOffsetX: number = 0;
  @State lastOffsetY: number = 0;

  // 控制 UI 栏的显示与隐藏
  @State showBars: boolean = true;

  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    const params = router.getParams() as ImagePreviewParams;
    if (params) {
      this.postId = params.postId || '';

      if (params.isLiked !== undefined) {
        this.isPostLiked = params.isLiked as boolean;
      }

      if (params.images && params.images.length > 0) {
        this.images = params.images.slice();
      }

      const indexParam = params.imageIndex !== undefined ? Number(params.imageIndex) : 0;
      const safeIndex = Math.min(Math.max(indexParam, 0), Math.max(this.images.length - 1, 0));
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

    const wasLiked = this.isPostLiked;
    // 1. 乐观更新当前页 UI
    this.isPostLiked = !wasLiked;

    // 2. 触发全局通知，让底层的详情页/列表页同步刷新
    // 我们复用之前设计的 communityPostUpdate 通道，只传必要状态
    const trigger = AppStorage.get<number>('communityRefreshTrigger') || 0;
    AppStorage.setOrCreate('communityRefreshTrigger', trigger + 1);

    try {
      // 3. 调接口
      if (wasLiked) {
        await ApiService.unlikePost(this.postId);
      } else {
        await ApiService.likePost(this.postId);
      }
    } catch (error) {
      // 4. 回滚
      this.isPostLiked = wasLiked;
      this.showToast('点赞失败');
    }
  }

  /**
   * 保存当前图片到本地相册
   */
  private async saveImage(): Promise<void> {
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

      // 2. 先写入沙箱临时文件
      const fileName: string = `TraQuick_${Date.now()}.jpg`;
      const cacheDir: string = this.context.cacheDir;
      const tempFilePath: string = `${cacheDir}/${fileName}`;

      const tempFile: fs.File = fs.openSync(tempFilePath, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
      fs.writeSync(tempFile.fd, arrayBuffer);
      fs.closeSync(tempFile);

      // 3. 使用 phAccessHelper 创建相册资源并写入
      const phAccessHelper: photoAccessHelper.PhotoAccessHelper =
        photoAccessHelper.getPhotoAccessHelper(this.context);

      // 使用 createAsset 的双参数重载，返回 string（uri）
      const assetUri: string = await phAccessHelper.createAsset(
        photoAccessHelper.PhotoType.IMAGE,
        'jpg'
      );

      // 4. 将沙箱临时文件内容写入相册 URI
      const assetFile: fs.File = fs.openSync(assetUri, fs.OpenMode.READ_WRITE);
      const srcFile: fs.File = fs.openSync(tempFilePath, fs.OpenMode.READ_ONLY);

      const bufSize: number = arrayBuffer.byteLength;
      const buf: ArrayBuffer = new ArrayBuffer(bufSize);
      const readLen: number = fs.readSync(srcFile.fd, buf);
      fs.writeSync(assetFile.fd, buf, { length: readLen });

      fs.closeSync(srcFile);
      fs.closeSync(assetFile);

      // 5. 删除临时文件
      fs.unlinkSync(tempFilePath);

      this.showToast('已保存到系统相册');
    } catch (error) {
      const errMsg: string = (error as Error).message || '未知错误';
      console.error(`[ImagePreview] 保存图片失败: ${errMsg}`);
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
                  .scale(this.currentIndex === index ? { x: this.currentScale, y: this.currentScale } : { x: 1, y: 1 })
                  .translate(this.currentIndex === index ? { x: this.offsetX, y: this.offsetY } : { x: 0, y: 0 })
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
                      // ⚠️ 修复：双击全屏图片，统一执行“点赞该帖子”
                      if (!this.isPostLiked) {
                        this.togglePostLike();
                      }
                      animateTo({ duration: 300 }, () => { this.resetGestureState(); });
                    }),
                  TapGesture({ count: 1 })
                    .onAction(() => {
                      animateTo({ duration: 200 }, () => { this.showBars = !this.showBars; });
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
          Column() { Text('图片加载中...').fontSize(14).fontColor('#94A3B8') }.layoutWeight(1).justifyContent(FlexAlign.Center)
        }
      }
      .width('100%')
      .height('100%')

      // 2. 顶栏
      if (this.showBars) {
        Column() { this.TopBar() }.position({ x: 0, y: 0 }).transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      }

      // 3. 底栏
      if (this.showBars) {
        Column() { this.BottomBar() }.position({ x: 0, y: '100%' }).translate({ y: '-100%' }).transition(TransitionEffect.OPACITY.animation({ duration: 200 }))
      }

      // 4. Toast 提示
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
      Row() { Text('←').fontSize(28).fontColor('#FFFFFF').fontWeight(FontWeight.Medium) }
      .width(44).height(44).justifyContent(FlexAlign.Center).onClick(() => this.goBack())

      Blank()

      Text(`${this.currentIndex + 1} / ${Math.max(this.images.length, 1)}`)
        .fontSize(16).fontColor('#FFFFFF').fontWeight(FontWeight.Bold).letterSpacing(2)

      Blank()

      Row().width(44).height(44)
    }
    .width('100%').padding({ left: 8, right: 8, top: 48, bottom: 12 })
    .linearGradient({ direction: GradientDirection.Bottom, colors: [['rgba(0,0,0,0.5)', 0], ['transparent', 1]] })
  }

  @Builder
  BottomBar() {
    Row() {
      // 点赞帖子按钮
      Row() {
        Column() {
          Text(this.isPostLiked ? '❤️' : '🤍').fontSize(22)
        }
        .width(44).height(44).backgroundColor('rgba(255,255,255,0.15)').borderRadius(22).justifyContent(FlexAlign.Center)

        Text(this.isPostLiked ? '已喜欢' : '喜欢').fontSize(13).fontColor('#FFFFFF').margin({ left: 8 })
      }
      .onClick(() => this.togglePostLike())

      // 保存图片按钮
      Row() {
        Column() {
          if (this.isSaving) {
            LoadingProgress().width(20).height(20).color('#FFFFFF')
          } else {
            Text('⬇️').fontSize(20)
          }
        }
        .width(44).height(44).backgroundColor('rgba(255,255,255,0.15)').borderRadius(22).justifyContent(FlexAlign.Center)

        Text('保存').fontSize(13).fontColor('#FFFFFF').margin({ left: 8 })
      }
      .onClick(() => this.saveImage())
    }
    .width('100%').padding({ left: 32, right: 32, top: 20, bottom: 40 })
    .justifyContent(FlexAlign.SpaceBetween)
    .linearGradient({ direction: GradientDirection.Top, colors: [['rgba(0,0,0,0.5)', 0], ['transparent', 1]] })
  }
}