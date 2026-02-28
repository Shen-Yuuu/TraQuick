/**
 * 图片预览页 - 全屏滑动查看
 * 支持：左右切换、双击点赞、保存提示*
 * 路由参数：
 *   - images: string[]   图片URL数组（优先使用）
 *   - imageIndex: number  初始显示的图片索引
 *   - postId?: string     帖子ID（可选，用于回传操作）
 */

import { router } from '@kit.ArkUI';

interface ImagePreviewParams {
  images?: string[];
  imageIndex?: number;
  postId?: string;
}

@Entry
@Component
struct ImagePreviewPage {
  @State images: string[] = [];
  @State currentIndex: number = 0;
  @State likedImages: boolean[] = [];
  @State toastText: string = '';
  private postId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as ImagePreviewParams;
    if (params) {
      this.postId = params.postId || '';

      // 优先从路由参数获取图片列表
      if (params.images && params.images.length > 0) {
        this.images = params.images.slice();
      }

      const indexParam = params.imageIndex !== undefined ? Number(params.imageIndex) : 0;
      this.likedImages = new Array(this.images.length).fill(false);
      const safeIndex = Math.min(Math.max(indexParam, 0), Math.max(this.images.length - 1, 0));
      this.currentIndex = safeIndex;
    }
  }

  private goBack(): void {
    router.back();
  }

  private toggleLike(index: number): void {
    if (!this.likedImages[index]) {
      this.likedImages[index] = true;
    } else {
      this.likedImages[index] = false;
    }
  }

  private saveImage(): void {
    this.toastText = '已保存';
    setTimeout(() => {
      this.toastText = '';
    }, 1200);
  }

  build() {
    Stack() {
      Column() {
        this.TopBar()

        if (this.images.length > 0) {
          Swiper() {
            ForEach(this.images, (img: string, index: number) => {
              Stack() {
                Image(img)
                  .width('100%')
                  .height('100%')
                  .objectFit(ImageFit.Contain)
              }
              .width('100%')
              .height('100%')
              .backgroundColor('#000000')
              .gesture(
                TapGesture({ count: 2 }).onAction(() => {
                  this.toggleLike(index)
                })
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
          })
        } else {
          Column() {
            Text('图片加载中...')
              .fontSize(14)
              .fontColor('#94A3B8')
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        }

        this.BottomBar()
      }
      .width('100%')
      .height('100%')

      if (this.toastText) {
        Column() {
          Text(this.toastText)
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor('rgba(0,0,0,0.65)')
            .borderRadius(12)
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  @Builder
  TopBar() {
    Row() {
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.goBack())

      Blank()

      Text(`${this.currentIndex + 1}/${Math.max(this.images.length, 1)}`)
        .fontSize(14)
        .fontColor('#FFFFFF')

      Blank()

      Row().width(40).height(40)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8, top: 40 })
    .backgroundColor('rgba(0, 0, 0, 0.3)')
  }

  @Builder
  BottomBar() {
    Row() {
      Row() {
        Text(this.likedImages[this.currentIndex] ? '❤️' : '🤍')
          .fontSize(18)
        Text('喜欢')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .margin({ left: 6 })
      }
      .onClick(() => this.toggleLike(this.currentIndex))

      Row() {
        Text('⬇️')
          .fontSize(16)
        Text('保存')
          .fontSize(12)
          .fontColor('#FFFFFF')
          .margin({ left: 6 })
      }
      .onClick(() => this.saveImage())
    }
    .width('100%')
    .height(56)
    .padding({ left: 32, right: 32, bottom: 24 })
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundColor('rgba(0, 0, 0, 0.3)')
  }
}
