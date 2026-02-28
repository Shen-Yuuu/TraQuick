/**
 * 动态卡片组件- 朋友圈式图文
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { Post } from '../../models/Post';
import { UserAvatar } from './UserAvatar';
import { formatTime, formatCount } from '../../utils/Formatter';

@Component
export struct PostCard {
  @Prop post: Post;
  onLike: () => void = () => {};
  onComment: () => void = () => {};
  onShare: () => void = () => {};
  onCollect: () => void = () => {};
  onUserClick: () => void = () => {};
  onImageClick: (index: number) => void = () => {};
  onLocationClick: () => void = () => {};

  build() {
    Column() {
      // 用户信息区
      Row() {
        UserAvatar({
          src: this.post.author.avatar,
          avatarSize: 40,
          level: this.post.author.level,
          showLevel: false
        })
        .onClick(() => this.onUserClick())

        Column() {
          Text(this.post.author.nickname)
            .fontSize(FontSizes.body)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)

          Text(`LV.${this.post.author.level} ${this.post.author.levelTitle}`)
            .fontSize(FontSizes.mini)
            .fontColor(Colors.textTertiary)
            .margin({ top: 2 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 10 })
        .onClick(() => this.onUserClick())

        Blank()

          Text('•••')
          .fontSize(FontSizes.bodyLarge)
          .fontColor(Colors.textQuaternary)
          .padding(8)
      }
      .width('100%')
      .margin({ bottom: 12 })

      // 内容文字
      if (this.post.content) {
        Text() {
          Span(this.post.content)
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)
          ForEach(this.post.tags, (tag: string) => {
            Span(` #${tag}`)
              .fontSize(FontSizes.body)
              .fontColor(Colors.primary)
          })
        }
        .lineHeight(22)
        .margin({ bottom: 12 })
      }

      // 图片网格
      if (this.post.images && this.post.images.length > 0) {
        this.ImageGrid()
      }

      // 位置和时间
      Row() {
        if (this.post.location) {
          Row() {
            Text('📍')
              .fontSize(FontSizes.small)
            Text(`${this.post.location.cityName}${this.post.location.address ? ' · ' + this.post.location.address : ''}`)
              .fontSize(FontSizes.small)
              .fontColor(Colors.primary)
              .margin({ left: 4 })
          }
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(Colors.primaryLightest)
          .borderRadius(Radius.tag)
          .onClick(() => this.onLocationClick())
        }

        Blank()

        Text(formatTime(this.post.createdAt))
          .fontSize(FontSizes.mini)
          .fontColor(Colors.textQuaternary)
      }
      .width('100%')
      .margin({ top: 12, bottom: 12 })

      // 互动栏
      Row() {
        this.ActionButton('❤️', this.post.likeCount, this.post.isLiked, () => this.onLike())
        this.ActionButton('💬', this.post.commentCount, false, () => this.onComment())
        this.ActionButton('⭐', this.post.collectCount, this.post.isCollected, () => this.onCollect())
        this.ActionButton('↗️', 0, false, () => this.onShare())
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(Spacing.cardPadding)
    .backgroundColor(Colors.bgPrimary)
    .borderRadius(Radius.card)
  }

  @Builder
  ImageGrid() {
    if (this.post.images.length === 1) {
      // 单图大图展示
      Image(this.post.images[0])
        .width('100%')
        .aspectRatio(1.5)
        .objectFit(ImageFit.Cover)
        .borderRadius(Radius.md)
        .backgroundColor(Colors.bgTertiary)
        .onClick(() => this.onImageClick(0))
    } else if (this.post.images.length === 2) {
      // 双图并排
      Row() {
        ForEach(this.post.images, (img: string, index: number) => {
          Image(img)
            .layoutWeight(1)
            .aspectRatio(1)
            .objectFit(ImageFit.Cover)
            .borderRadius(Radius.sm)
            .backgroundColor(Colors.bgTertiary)
            .margin({ left: index === 0 ? 0 : 4 })
            .onClick(() => this.onImageClick(index))
        })
      }
      .width('100%')
    } else if (this.post.images.length === 4) {
      // 四图2x2
      Grid() {
        ForEach(this.post.images.slice(0, 4), (img: string, index: number) => {
          GridItem() {
            Image(img)
              .width('100%')
              .aspectRatio(1)
              .objectFit(ImageFit.Cover)
              .borderRadius(Radius.sm)
              .backgroundColor(Colors.bgTertiary)
              .onClick(() => this.onImageClick(index))
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .rowsTemplate('1fr 1fr')
      .columnsGap(4)
      .rowsGap(4)
      .width('100%')
      .aspectRatio(1)
    } else {
      // 3图或5-9图用九宫格
      Grid() {
        ForEach(this.post.images.slice(0, 9), (img: string, index: number) => {
          GridItem() {
            Stack() {
              Image(img)
                .width('100%')
                .aspectRatio(1)
                .objectFit(ImageFit.Cover)
                .borderRadius(Radius.sm)
                .backgroundColor(Colors.bgTertiary)

              // 超过9张显示数量
              if (index === 8 && this.post.images.length > 9) {
                Column() {
                  Text(`+${this.post.images.length - 9}`)
                    .fontSize(FontSizes.h3)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Colors.textWhite)
                }
                .width('100%')
                .height('100%')
                .backgroundColor('rgba(0,0,0,0.4)')
                .borderRadius(Radius.sm)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
              }
            }
            .onClick(() => this.onImageClick(index))
          }
        })
      }
      .columnsTemplate('1fr 1fr 1fr')
      .rowsTemplate(this.post.images.length <= 3 ? '1fr' :
                   this.post.images.length <= 6 ? '1fr 1fr' : '1fr 1fr 1fr')
      .columnsGap(4)
      .rowsGap(4)
      .width('100%')
      .aspectRatio(this.post.images.length <= 3 ? 3 :
                  this.post.images.length <= 6 ? 1.5 : 1)
    }
  }

  @Builder
  ActionButton(icon: string, count: number, isActive: boolean, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(FontSizes.bodyLarge)
        .opacity(isActive ? 1 : 0.8)

      if (count > 0) {
        Text(formatCount(count))
          .fontSize(FontSizes.small)
          .fontColor(isActive ? Colors.primary : Colors.textTertiary)
          .margin({ left: 4 })
      }
    }
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .onClick(onClick)
  }

  // formatCount / formatTime → 已抽取到 utils/Formatter.ets
}
