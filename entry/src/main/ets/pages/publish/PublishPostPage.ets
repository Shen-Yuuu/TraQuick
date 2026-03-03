/**
 * 发布图文动态页面 - 对接真实 API 与真实定位
 */
import { router, promptAction } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ApiService, CreatePostParams } from '../../services/ApiService';
import { common } from '@kit.AbilityKit';
import { LocationService, LocationInfo } from '../../utils/LocationService'; // 👈 引入新写的工具类

@Entry
@Component
struct PublishPostPage {
  @State content: string = '';
  @State selectedImages: string[] = [];

  // 真实定位状态
  @State cityName: string = '获取位置中...';
  @State address: string = '';
  @State latitude: number = 0;
  @State longitude: number = 0;
  @State isLocating: boolean = true;

  @State selectedTopic: string = '旅行日记'; // 去掉前面的#，方便传给后端
  @State postVisibility: string = '公开';
  @State isPublishing: boolean = false;
  @State errorMessage: string = '';
  @State matchedCityId: string = '';

  private readonly MAX_IMAGE_COUNT: number = 9;
  private context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    // 进入页面时自动尝试获取定位
    this.fetchRealLocation();
  }

  /**
   * 获取真实定位
   */
  private async fetchRealLocation(): Promise<void> {
    this.isLocating = true;
    try {
      // 1. 动态申请定位权限
      const hasPermission = await LocationService.requestLocationPermission(this.context);
      if (!hasPermission) {
        this.cityName = '定位未授权';
        this.address = '点击重试';
        return;
      }

      // 2. 获取真实坐标和城市名
      const locInfo: LocationInfo = await LocationService.getCurrentLocation();
      this.cityName = locInfo.cityName;
      this.address = locInfo.address;
      this.latitude = locInfo.latitude;
      this.longitude = locInfo.longitude;

      try {
        // 去掉市/省等后缀
        const searchKeyword = this.cityName.replace(/市|省|区/g, '');
        const cities = await ApiService.getCities(searchKeyword);
        if (cities && cities.length > 0) {
          this.matchedCityId = cities[0].id; // 匹配成功，存下 UUID
          console.info(`[Publish] 成功匹配到数据库城市: ${cities[0].name}, ID: ${this.matchedCityId}`);
        }
      } catch (e) {
        console.warn('[Publish] 城市匹配失败，不强制绑定城市ID');
      }

    } catch (error) {
      console.warn('[Publish] 定位失败:', error);
      this.cityName = '定位失败';
      this.address = '点击重试';
    } finally {
      this.isLocating = false;
    }
  }

  private getGridItemWidth(): string {
    return ((100 - 6) / 3).toString() + '%';
  }

  private canPublish(): boolean {
    return this.content.trim().length > 0 || this.selectedImages.length > 0;
  }

  private removeImage(index: number): void {
    const newImgs = [...this.selectedImages];
    newImgs.splice(index, 1);
    this.selectedImages = newImgs;
  }

  private async openPhotoPicker(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const remainCount = this.MAX_IMAGE_COUNT - this.selectedImages.length;

      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = remainCount;

      const result = await picker.select(options);
      if (result && result.photoUris && result.photoUris.length > 0) {
        const newImages = [...this.selectedImages, ...result.photoUris];
        this.selectedImages = newImages.slice(0, this.MAX_IMAGE_COUNT);
      }
    } catch (error) {
      console.error(`[Publish] 选图失败: ${(error as BusinessError).message}`);
    }
  }

  /**
   * 真实发布动态
   */
  private async handlePublish(): Promise<void> {
    if (!this.canPublish() || this.isPublishing) {
      return;
    }

    this.isPublishing = true;
    this.errorMessage = '';

    try {
      promptAction.showToast({ message: '正在上传动态...', duration: 2000 });

      // 1. 如果有图片，先上传到 OSS 获取网络 URL
      const uploadedUrls: string[] = [];
      if (this.selectedImages.length > 0) {
        for (const localUri of this.selectedImages) {
          const ossUrl = await ApiService.uploadImage(this.context, localUri);
          uploadedUrls.push(ossUrl);
        }
      }

      // 2. 构造后端需要的参数
      const tags: string[] = [];
      if (this.selectedTopic) {
        tags.push(this.selectedTopic);
      }

      const postParams = new CreatePostParams();
      postParams.content = this.content;
      postParams.images = uploadedUrls;
      postParams.type = 'image';
      postParams.tags = tags;

      if (this.matchedCityId) {
        postParams.cityId = this.matchedCityId;
      }

      // 传入真实定位
      if (this.latitude !== 0) {
        postParams.address = `${this.cityName} · ${this.address}`;
        postParams.latitude = this.latitude;
        postParams.longitude = this.longitude;
      }

      // 3. 调用发布接口
      await ApiService.createPost(postParams);

      promptAction.showToast({ message: '发布成功！' });

      // 4. 通知社区列表刷新并返回
      const trigger = AppStorage.get<number>('communityRefreshTrigger') || 0;
      AppStorage.setOrCreate('communityRefreshTrigger', trigger + 1);

      router.back();

    } catch (error) {
      const err = error as Error;
      this.errorMessage = err.message || '发布失败，请重试';
      promptAction.showToast({ message: '发布失败' });
    } finally {
      this.isPublishing = false;
    }
  }

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('取消').fontSize(15).fontColor('#64748B').onClick(() => router.back())
        Blank()
        Button() {
          Row() {
            if (this.isPublishing) {
              LoadingProgress().width(16).height(16).color('#FFFFFF').margin({ right: 6 })
            }
            Text(this.isPublishing ? '发布中...' : '发布')
              .fontSize(15).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
        }
        .height(36).padding({ left: 20, right: 20 })
        .backgroundColor(this.canPublish() ? '#38BDF8' : '#CBD5E1')
        .borderRadius(18).enabled(this.canPublish() && !this.isPublishing)
        .onClick(() => this.handlePublish())
      }
      .width('100%').padding({ left: 20, right: 20, top: 48, bottom: 12 }) // 避让状态栏
      .backgroundColor('#FFFFFF')

      Divider().color('#F1F5F9')

      if (this.errorMessage) {
        Row() { Text('⚠️').fontSize(14); Text(this.errorMessage).fontSize(13).fontColor('#EF4444').margin({ left: 6 }) }
        .width('100%').padding({ left: 20, right: 20, top: 10, bottom: 10 }).backgroundColor('#FEF2F2')
      }

      Scroll() {
        Column() {
          // 内容输入
          Column() {
            TextArea({ placeholder: '此刻，你想记录些什么...', text: this.content })
              .width('100%').height(120).fontSize(16).fontColor('#1E293B').backgroundColor('transparent')
              .caretColor('#38BDF8').padding(0).margin({ top: 16 })
              .onChange(v => { this.content = v; this.errorMessage = ''; })
          }.width('100%').padding({ left: 20, right: 20, top: 8 }).alignItems(HorizontalAlign.Start)

          // 图片选择网格
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.selectedImages, (imageUri: string, index: number) => {
              Stack() {
                Image(imageUri).width('100%').height('100%').objectFit(ImageFit.Cover).borderRadius(8)
                Column() { Text('✕').fontSize(10).fontColor('#FFFFFF') }
                .width(20).height(20).backgroundColor('rgba(0,0,0,0.6)').borderRadius(10).justifyContent(FlexAlign.Center)
                .position({ x: '100%', y: 0 }).translate({ x: -24, y: 4 })
                .onClick(() => this.removeImage(index))
              }
              .width(this.getGridItemWidth()).aspectRatio(1).margin({ right: index % 3 === 2 ? 0 : '3%', bottom: 8 })
            })

            if (this.selectedImages.length < this.MAX_IMAGE_COUNT) {
              Column() { Text('+').fontSize(36).fontColor('#94A3B8'); Text('添加照片').fontSize(10).fontColor('#CBD5E1').margin({ top: 2 }) }
              .width(this.getGridItemWidth()).aspectRatio(1).backgroundColor('#F8FAFC').border({ width: 1, color: '#E2E8F0', style: BorderStyle.Dashed }).borderRadius(8).justifyContent(FlexAlign.Center).onClick(() => this.openPhotoPicker())
            }
          }.width('100%').padding({ left: 20, right: 20, top: 16 })

          if (this.selectedImages.length > 0) {
            Text(`${this.selectedImages.length}/${this.MAX_IMAGE_COUNT} 已选`).fontSize(12).fontColor('#94A3B8').width('100%').textAlign(TextAlign.End).padding({ right: 20, top: 8 })
          }

          Divider().color('#F1F5F9').margin({ top: 24 })

          // ====== 真实位置显示区域 ======
          Row() {
            Column() { Text('📍').fontSize(18) }.width(40).height(40).backgroundColor('#E0F2FE').borderRadius(12).justifyContent(FlexAlign.Center)
            Column() {
              Row() {
                Text('我在').fontSize(15).fontColor('#64748B')
                if (this.isLocating) {
                  LoadingProgress().width(14).height(14).color('#38BDF8').margin({ left: 6 })
                } else {
                  Text(this.cityName).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#38BDF8').margin({ left: 4 })
                }
              }
              Text(this.address).fontSize(12).fontColor('#94A3B8').margin({ top: 2 }).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
            }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)

            // 点击刷新定位
            Column() { Text('🔄').fontSize(16).opacity(this.isLocating ? 0.3 : 1) }
            .padding(10).onClick(() => { if(!this.isLocating) this.fetchRealLocation(); })
          }.width('100%').padding({ left: 20, right: 20, top: 16, bottom: 16 })

          Divider().color('#F1F5F9')

          // ====== 话题标签 ======
          Row() {
            Column() { Text('#').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#38BDF8') }.width(40).height(40).backgroundColor('#E0F2FE').borderRadius(12).justifyContent(FlexAlign.Center)
            Text('添加话题').fontSize(15).fontColor('#64748B').margin({ left: 12 }).layoutWeight(1)
            Text(`#${this.selectedTopic}`).fontSize(13).fontColor('#38BDF8').padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor('#E0F2FE').borderRadius(12).margin({ right: 12 })
          }.width('100%').padding({ left: 20, right: 20, top: 16, bottom: 16 })

          Divider().color('#F1F5F9')

          // ====== 地图坐标展示 (Mock) ======
          Column() {
            Stack() {
              Column().width('100%').height(120).backgroundColor('#E0F2FE').borderRadius(12)
              Column().width('100%').height('100%').borderRadius(12).linearGradient({ direction: GradientDirection.Bottom, colors: [['rgba(14, 165, 233, 0.1)', 0], ['rgba(14, 165, 233, 0.05)', 1]] })

              if (this.latitude !== 0) {
                Text(`${this.latitude.toFixed(4)}° N, ${this.longitude.toFixed(4)}° E`)
                  .fontSize(11).fontColor('#64748B').fontFamily('monospace').padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor('rgba(255,255,255,0.9)').borderRadius(8).position({ x: 12, y: 88 })
              }
            }
            .width('100%').height(120)
          }.width('100%').padding({ left: 20, right: 20, top: 16, bottom: 48 })

        }
      }.layoutWeight(1).scrollBar(BarState.Off)
    }
    .width('100%').height('100%').backgroundColor('#FFFFFF')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}