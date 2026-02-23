/**
 * 发布图文动态页面 - 对接真实 API
 */
import { router } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ApiService, CreatePostParams } from '../../services/ApiService';
@Entry
@Component
struct PublishPostPage {
  @State content: string = '';
  @State selectedImages: string[] = [];
  @State location: string = '北京';
  @State locationDetail: string = '朝阳区 · 三里屯';
  @State selectedTopic: string = '#旅行日记';
  @State postVisibility: string = '公开';
  @State isPublishing: boolean = false;
  @State coordinates: string = '39.9042° N, 116.4074° E';
  @State errorMessage: string = '';

  private readonly MAX_IMAGE_COUNT: number = 9;

  build() {
    Column() {
      // 顶部导航
      Row() {
        Text('取消')
          .fontSize(15)
          .fontColor('#64748B')
          .onClick(() => {
            router.back();
          })

        Blank()

        Button() {
          Row() {
            if (this.isPublishing) {
              LoadingProgress()
                .width(16)
                .height(16)
                .color('#FFFFFF')
                .margin({ right: 6 })
            }
            Text(this.isPublishing ? '发布中...' : '发布')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
        }
        .height(36)
        .padding({ left: 20, right: 20 })
        .backgroundColor(this.canPublish() ? '#38BDF8' : '#CBD5E1')
        .borderRadius(18)
        .enabled(this.canPublish() && !this.isPublishing)
        .onClick(() => {
          this.handlePublish();
        })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 52, bottom: 12 })
      .backgroundColor('#FFFFFF')

      Divider().color('#F1F5F9')

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
        .padding({ left: 20, right: 20, top: 10, bottom: 10 })
        .backgroundColor('#FEF2F2')
      }

      Scroll() {
        Column() {
          // 内容输入区
          Column() {
            Text('此刻，你想记录些什么...')
              .fontSize(18)
              .fontColor(this.content ? '#1E293B' : '#94A3B8')
              .width('100%')

            Text('Share your journey...')
              .fontSize(15)
              .fontColor('#CBD5E1')
              .fontStyle(FontStyle.Italic)
              .width('100%')
              .margin({ top: 4 })
              .visibility(this.content ? Visibility.None : Visibility.Visible)

            TextArea({ placeholder: '', text: this.content })
              .width('100%')
              .height(120)
              .fontSize(16)
              .fontColor('#1E293B')
              .placeholderColor('#CBD5E1')
              .backgroundColor('transparent')
              .caretColor('#38BDF8')
              .margin({ top: 16 })
              .onChange((value: string) => {
                this.content = value;
                this.errorMessage = '';
              })
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 24 })
          .alignItems(HorizontalAlign.Start)

          // 图片选择器
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.selectedImages, (imageUri: string, index: number) => {
              Stack() {
                Column()
                  .width('100%')
                  .height('100%')
                  .backgroundColor('#E2E8F0')
                  .borderRadius(8)

                Image(imageUri)
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Cover)
                  .borderRadius(8)

                Column() {
                  Text('✕')
                    .fontSize(10)
                    .fontColor('#FFFFFF')
                }
                .width(20)
                .height(20)
                .backgroundColor('rgba(0,0,0,0.6)')
                .borderRadius(10)
                .justifyContent(FlexAlign.Center)
                .position({ x: '100%', y: 0 })
                .translate({ x: -24, y: 4 })
                .onClick(() => {
                  this.removeImage(index);
                })
              }
              .width(this.getGridItemWidth())
              .aspectRatio(1)
              .margin({ right: index % 3 === 2 ? 0 : '3%', bottom: 8 })
            }, (imageUri: string, index: number) => `${imageUri}_${index}`)

            if (this.selectedImages.length < this.MAX_IMAGE_COUNT) {
              Column() {
                Text('+')
                  .fontSize(36)
                  .fontColor('#94A3B8')
                Text('添加照片')
                  .fontSize(10)
                  .fontColor('#CBD5E1')
                  .margin({ top: 2 })
              }
              .width(this.getGridItemWidth())
              .aspectRatio(1)
              .backgroundColor('#F8FAFC')
              .border({ width: 1, color: '#E2E8F0', style: BorderStyle.Dashed })
              .borderRadius(8)
              .justifyContent(FlexAlign.Center)
              .onClick(() => {
                this.openPhotoPicker();
              })
            }
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16 })

          if (this.selectedImages.length > 0) {
            Text(`${this.selectedImages.length}/${this.MAX_IMAGE_COUNT} 已选`)
              .fontSize(12)
              .fontColor('#94A3B8')
              .width('100%')
              .textAlign(TextAlign.End)
              .padding({ right: 20, top: 8 })
          }

          Divider().color('#F1F5F9').margin({ top: 24 })

          // 位置选择
          Row() {
            Column() {
              Text('📍')
                .fontSize(18)
            }
            .width(40)
            .height(40)
            .backgroundColor('#E0F2FE')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Column() {
              Row() {
                Text('我在')
                  .fontSize(15)
                  .fontColor('#64748B')
                Text(this.location)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#38BDF8')
              }

              Text(this.locationDetail)
                .fontSize(12)
                .fontColor('#94A3B8')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            .layoutWeight(1)

            Text('›')
              .fontSize(20)
              .fontColor('#CBD5E1')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })

          Divider().color('#F1F5F9')

          // 话题标签
          Row() {
            Column() {
              Text('#')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#38BDF8')
            }
            .width(40)
            .height(40)
            .backgroundColor('#E0F2FE')
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)

            Text('添加话题')
              .fontSize(15)
              .fontColor('#64748B')
              .margin({ left: 12 })
              .layoutWeight(1)

            Text(this.selectedTopic)
              .fontSize(13)
              .fontColor('#38BDF8')
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#E0F2FE')
              .borderRadius(12)
              .margin({ right: 12 })

            Text('›')
              .fontSize(20)
              .fontColor('#CBD5E1')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 16 })

          Divider().color('#F1F5F9')

          // 地图预览
          Column() {
            Stack() {
              Column()
                .width('100%')
                .height(120)
                .backgroundColor('#E0F2FE')
                .borderRadius(12)

              Text(this.coordinates)
                .fontSize(11)
                .fontColor('#64748B')
                .fontFamily('monospace')
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('rgba(255,255,255,0.9)')
                .borderRadius(8)
                .position({ x: 12, y: 88 })
            }
            .width('100%')
            .height(120)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 16, bottom: 48 })
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  private getGridItemWidth(): string {
    return ((100 - 6) / 3).toString() + '%';
  }

  private canPublish(): boolean {
    return this.content.trim().length > 0 || this.selectedImages.length > 0;
  }

  private removeImage(index: number): void {
    this.selectedImages.splice(index, 1);
    this.selectedImages = [...this.selectedImages];
  }

  private openPhotoPicker(): void {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const remainCount = this.MAX_IMAGE_COUNT - this.selectedImages.length;

      const options = new photoAccessHelper.PhotoSelectOptions();
      options.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      options.maxSelectNumber = remainCount;

      picker.select(options).then((result: photoAccessHelper.PhotoSelectResult) => {
        if (result && result.photoUris && result.photoUris.length > 0) {
          const newImages = [...this.selectedImages, ...result.photoUris];
          this.selectedImages = newImages.slice(0, this.MAX_IMAGE_COUNT);
        }
      }).catch((err: BusinessError) => {
        console.error(`[Publish] 选图失败: ${err.message}`);
      });
    } catch (error) {
      const err = error as BusinessError;
      console.error(`[Publish] PhotoViewPicker 错误: ${err.message}`);
    }
  }

  /**
   * 真实发布动态
   */
  private async handlePublish(): Promise<void> {
    if (!this.canPublish()) {
      return;
    }

    this.isPublishing = true;
    this.errorMessage = '';

    try {
      // 提取标签
      const tags: string[] = [];
      if (this.selectedTopic) {
        tags.push(this.selectedTopic.replace('#', ''));
      }

      // 调用后端 API 发布
      const postParams = new CreatePostParams();
      postParams.content = this.content;
      postParams.images = this.selectedImages;
      postParams.type = 'image';
      postParams.tags = tags;
      postParams.address = this.locationDetail;
      postParams.latitude = 39.9042;
      postParams.longitude = 116.4074;

      await ApiService.createPost(postParams);

      console.info('[Publish] 发布成功！');
      router.back();

    } catch (error) {
      const err = error as Error;
      this.errorMessage = err.message || '发布失败，请重试';
      console.error(`[Publish] 发布失败: ${err.message}`);
    } finally {
      this.isPublishing = false;
    }
  }
}