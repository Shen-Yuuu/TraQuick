/**
 * 社区页面 - 动态广场
 * 优化UI匹配设计原型
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { PostCard } from '../../components/common/PostCard';
import { SharePanel } from '../../components/common/SharePanel';
import { Post, PostComment } from '../../models/Post';
import { mockPosts, getRecommendPosts } from '../../services/MockData';
import { router } from '@kit.ArkUI';

@Entry
@Component
export struct CommunityPage {
  @State currentMainTab: number = 0;    // 0: 社区, 1: 视频
  @State currentSubTab: number = 0;     // 0: 推荐, 1: 关注, 2: 朋友
  @State postList: Post[] = [];
  @State isRefreshing: boolean = false;
  @State showSharePanel: boolean = false;
  @State sharePost: Post | null = null;
  @StorageLink('communityRefreshTrigger') @Watch('onRefreshTriggerChange') refreshTrigger: number = 0;

  private mainTabs: string[] = ['视频', '社区'];
  private subTabs: string[] = ['推荐', '关注', '朋友'];

  aboutToAppear(): void {
    // 初始化全局刷新触发器
    if (!AppStorage.has('communityRefreshTrigger')) {
      AppStorage.setOrCreate('communityRefreshTrigger', 0);
    }
    this.loadPosts();
    this.currentMainTab = 1; // 默认选中社区
  }

  // 监听刷新触发器变化
  onRefreshTriggerChange(): void {
    if (this.refreshTrigger > 0) {
      this.onRefresh();
    }
  }

  private loadPosts(): void {
    this.postList = mockPosts;
  }

  private onRefresh(): void {
    this.isRefreshing = true;
    setTimeout(() => {
      this.postList = getRecommendPosts(1, 5);
      this.isRefreshing = false;
    }, 1000);
  }

  private onLike(post: Post): void {
    const index = this.postList.findIndex(p => p.id === post.id);
    if (index !== -1) {
      const source = this.postList[index];
      const updatedPost = this.clonePost(source);
      updatedPost.isLiked = !source.isLiked;
      updatedPost.likeCount = source.likeCount + (updatedPost.isLiked ? 1 : -1);
      this.postList[index] = updatedPost;
    }
  }

  private onComment(post: Post): void {
    router.pushUrl({
      url: 'pages/community/PostDetailPage',
      params: { postId: post.id }
    }).catch(() => {});
  }

  private onCollect(post: Post): void {
    const index = this.postList.findIndex(p => p.id === post.id);
    if (index !== -1) {
      const source = this.postList[index];
      const updatedPost = this.clonePost(source);
      updatedPost.isCollected = !source.isCollected;
      updatedPost.collectCount = source.collectCount + (updatedPost.isCollected ? 1 : -1);
      this.postList[index] = updatedPost;
    }
  }

  private clonePost(source: Post): Post {
    return {
      id: source.id,
      author: source.author,
      content: source.content,
      images: source.images ? source.images.slice() : [],
      video: source.video,
      location: source.location,
      tags: source.tags ? source.tags.slice() : [],
      likeCount: source.likeCount,
      commentCount: source.commentCount,
      shareCount: source.shareCount,
      collectCount: source.collectCount,
      isLiked: source.isLiked,
      isCollected: source.isCollected,
      createdAt: source.createdAt,
      type: source.type,
      hotComments: source.hotComments,
    };
  }

  private onShare(post: Post): void {
    this.sharePost = post;
    this.showSharePanel = true;
  }

  private openImagePreview(post: Post, imageIndex: number): void {
    router.pushUrl({
      url: 'pages/community/ImagePreviewPage',
      params: { postId: post.id, imageIndex: imageIndex }
    }).catch(() => {});
  }

  private navigateToUser(userId: string): void {
    router.pushUrl({
      url: 'pages/community/UserProfilePage',
      params: { userId: userId }
    }).catch(() => {});
  }

  build() {
    Stack() {
      // 内容区域（底层）
      Column() {
        // 顶部占位（为固定的TopTabBar和SubTabBar留出空间）
        Row().height(108) // 28(状态栏) + 42(TopTabBar) + 38(SubTabBar)

        // 内容区域
        if (this.currentMainTab === 1) {
          // 社区 - 图文列表
          this.CommunityContent()
        } else {
          // 视频 - 视频卡
          this.VideoContent()
        }
      }
      .width('100%')
      .height('100%')

      // 顶部Tab栏（悬浮层）
      Column() {
        this.TopTabBar()
        this.SubTabBar()
      }
      .width('100%')
      .position({ x: 0, y: 0 })

      // 转发分享弹窗
      SharePanel({
        isShow: this.showSharePanel,
        onClose: () => { this.showSharePanel = false; },
        onShareToUser: (userId: string, text: string) => {
          this.showSharePanel = false;
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F4F8')
  }

  @Builder
  TopTabBar() {
    Column() {
      // 状态栏占位
      Row().height(28)

      // Tab内容区域
      Row() {
        ForEach(this.mainTabs, (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(17)
              .fontWeight(this.currentMainTab === index ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.currentMainTab === index ? '#1E3A5F' : '#94A3B8')
              .onClick(() => {
                this.currentMainTab = index;
              })

            if (this.currentMainTab === index) {
              Row()
                .width(18)
                .height(3)
                .backgroundColor('#38BDF8')
                .borderRadius(1.5)
                .margin({ top: 4 })
            } else {
              Row().height(7)
            }
          }
          .margin({ left: index === 0 ? 0 : 40 })
        })
      }
      .width('100%')
      .height(42)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .backgroundBlurStyle(BlurStyle.Regular)
    .backgroundColor('rgba(255, 255, 255, 0.5)')
    .shadow({ radius: 6, color: 'rgba(0,0,0,0.03)', offsetY: 1 })
  }

  @Builder
  SubTabBar() {
    Row() {
      ForEach(this.subTabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.currentSubTab === index ? '#0284C7' : '#64748B')
            .padding({ left: 0, right: 0, top: 6, bottom: 6 })
            .width('100%')
            .textAlign(TextAlign.Center)
            .backgroundColor(this.currentSubTab === index ? '#E0F2FE' : 'transparent')
            .borderRadius(16)
        }
        .layoutWeight(1)
        .padding({ left: 6, right: 6 })
        .onClick(() => {
          this.currentSubTab = index;
        })
      })
    }
    .width('100%')
    .height(36)
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.SpaceAround)
    .backgroundBlurStyle(BlurStyle.Thin)
    .backgroundColor('rgba(255, 255, 255, 0.55)')
  }

  @Builder
  CommunityContent() {
    Refresh({ refreshing: $$this.isRefreshing }) {
      List() {
        ForEach(this.postList, (post: Post, index: number) => {
          ListItem() {
            this.EnhancedPostCard(post)
          }
        }, (post: Post) => post.id)

        // 底部安全区域，为悬浮的dock栏留出空间
        ListItem() {
          Row().height(80)
        }
      }
      .width('100%')
      .padding({ left: 12, right: 12 })
      .scrollBar(BarState.Off)
      .divider({ strokeWidth: 0 })
      .edgeEffect(EdgeEffect.Spring)
    }
    .onRefreshing(() => this.onRefresh())
    .width('100%')
    .layoutWeight(1)
  }

  // 优化的帖子卡片 - 抖音/微博风格
  @Builder
  EnhancedPostCard(post: Post) {
    Row() {
      // 左侧头像 - 点击跳转用户主页
      Column() {
        Text(post.author.nickname.charAt(0))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(42)
      .height(42)
      .borderRadius(21)
      .linearGradient({
        direction: GradientDirection.RightBottom,
        colors: [['#7DD3FC', 0], ['#0EA5E9', 1]]
      })
      .justifyContent(FlexAlign.Center)
      .margin({ right: 12 })
      .onClick(() => this.navigateToUser(post.author.id))

      // 右侧内容区
      Column() {
        // 用户名 + 更多按钮
        Row() {
          Column() {
            Text(post.author.nickname)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E293B')
            Text(post.author.levelTitle || '')
              .fontSize(11)
              .fontColor('#94A3B8')
              .margin({ top: 1 })
          }
          .alignItems(HorizontalAlign.Start)
          .onClick(() => this.navigateToUser(post.author.id))

          Blank()

          Text('···')
            .fontSize(18)
            .fontColor('#C0C0C0')
        }
        .width('100%')

        // 内容文本
        Column() {
          Column() {
            Text(post.content)
              .fontSize(15)
              .fontColor('#333333')
              .lineHeight(22)
              .margin({ top: 6 })
              .width('100%')
              .maxLines(4)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .onClick(() => this.onComment(post))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .gesture(
            TapGesture({ count: 2 }).onAction(() => {
              this.onLike(post)
            })
          )

          // 图片网格
          if (post.images && post.images.length > 0) {
            Column() {
              this.WechatStyleImageGrid(post.images, post)
            }
            .margin({ top: 10 })
            .alignItems(HorizontalAlign.Start)
          }

          Column() {
            // 位置 + 时间
            Row() {
              Row() {
                if (post.location && post.location.cityName) {
                  Text(post.location.cityName)
                    .fontSize(12)
                    .fontColor('#38BDF8')
                    .margin({ right: 8 })
                }
                Text(this.formatTime(post.createdAt))
                  .fontSize(12)
                  .fontColor('#B0B0B0')
              }
            }
            .width('100%')
            .margin({ top: 10 })
            .onClick(() => this.onComment(post))

            // 热门评论（1-2条）
            if (post.hotComments && post.hotComments.length > 0) {
              Column() {
                ForEach(post.hotComments.slice(0, 2), (comment: PostComment) => {
                  Row() {
                    Text(comment.userNickname)
                      .fontSize(13)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#475569')
                      .onClick(() => this.navigateToUser(comment.userId))
                    Text(`：${comment.content}`)
                      .fontSize(13)
                      .fontColor('#64748B')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)
                      .onClick(() => this.onComment(post))
                  }
                  .width('100%')
                  .margin({ bottom: 4 })
                })

                // 查看全部评论
                if (post.commentCount > 2) {
                  Text(`查看全部 ${post.commentCount} 条评论`)
                    .fontSize(12)
                    .fontColor('#94A3B8')
                    .margin({ top: 2 })
                    .onClick(() => this.onComment(post))
                }
              }
              .width('100%')
              .padding({ left: 10, right: 10, top: 8, bottom: 8 })
              .backgroundColor('#F8FAFC')
              .borderRadius(8)
              .margin({ top: 8 })
              .onClick(() => this.onComment(post))
            }

            Row().height(6).width('100%').onClick(() => this.onComment(post))
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .gesture(
            TapGesture({ count: 2 }).onAction(() => {
              this.onLike(post)
            })
          )
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 操作按钮栏
        Row() {
          // 点赞
          Row() {
            Text(post.isLiked ? '❤️' : '🤍')
              .fontSize(14)
            if (post.likeCount > 0) {
              Text(`${this.formatCount(post.likeCount)}`)
                .fontSize(12)
                .fontColor(post.isLiked ? '#38BDF8' : '#888888')
                .margin({ left: 4 })
            }
          }
          .onClick(() => this.onLike(post))

          // 评论
          Row() {
            Text('💬')
              .fontSize(14)
            if (post.commentCount > 0) {
              Text(`${this.formatCount(post.commentCount)}`)
                .fontSize(12)
                .fontColor('#888888')
                .margin({ left: 4 })
            }
          }
          .onClick(() => this.onComment(post))

          // 转发
          Row() {
            Text('↗️')
              .fontSize(14)
            if (post.shareCount > 0) {
              Text(`${this.formatCount(post.shareCount)}`)
                .fontSize(12)
                .fontColor('#888888')
                .margin({ left: 4 })
            }
          }
          .onClick(() => this.onShare(post))
        }
        .width('100%')
        .margin({ top: 10 })
        .justifyContent(FlexAlign.SpaceAround)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .alignItems(VerticalAlign.Top)
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#ECECEC' })
  }

  // 微信朋友圈风格图片网格
  @Builder
  WechatStyleImageGrid(images: string[], post: Post) {
    Column() {
      if (images.length === 1) {
        // 单图 - 较大尺寸
        this.ImageItem(post, images, 0, 180, 180)
      } else if (images.length === 2) {
        // 2张图 - 横向并排
        Row({ space: 4 }) {
          this.ImageItem(post, images, 0, 120, 120)
          this.ImageItem(post, images, 1, 120, 120)
        }
      } else if (images.length === 3) {
        // 3张图 - 横向并排
        Row({ space: 4 }) {
          this.ImageItem(post, images, 0, 80, 80)
          this.ImageItem(post, images, 1, 80, 80)
          this.ImageItem(post, images, 2, 80, 80)
        }
      } else if (images.length === 4) {
        // 4张图 - 2x2网格
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(post, images, 0, 120, 120)
            this.ImageItem(post, images, 1, 120, 120)
          }
          Row({ space: 4 }) {
            this.ImageItem(post, images, 2, 120, 120)
            this.ImageItem(post, images, 3, 120, 120)
          }
        }
      } else if (images.length === 5) {
        // 5张图 - 上面2张+ 下面3张
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(post, images, 0, 120, 120)
            this.ImageItem(post, images, 1, 120, 120)
          }
          Row({ space: 4 }) {
            this.ImageItem(post, images, 2, 78, 78)
            this.ImageItem(post, images, 3, 78, 78)
            this.ImageItem(post, images, 4, 78, 78)
          }
        }
      } else if (images.length === 6) {
        // 6张图 - 3x2网格
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(post, images, 0, 78, 78)
            this.ImageItem(post, images, 1, 78, 78)
            this.ImageItem(post, images, 2, 78, 78)
          }
          Row({ space: 4 }) {
            this.ImageItem(post, images, 3, 78, 78)
            this.ImageItem(post, images, 4, 78, 78)
            this.ImageItem(post, images, 5, 78, 78)
          }
        }
      } else {
        // 7-9张图 - 3x3网格
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(post, images, 0, 78, 78)
            this.ImageItem(post, images, 1, 78, 78)
            this.ImageItem(post, images, 2, 78, 78)
          }
          Row({ space: 4 }) {
            this.ImageItem(post, images, 3, 78, 78)
            this.ImageItem(post, images, 4, 78, 78)
            this.ImageItem(post, images, 5, 78, 78)
          }
          if (images.length > 6) {
            Row({ space: 4 }) {
              this.ImageItem(post, images, 6, 78, 78)
              if (images.length > 7) {
                this.ImageItem(post, images, 7, 78, 78)
              }
              if (images.length > 8) {
                this.ImageItem(post, images, 8, 78, 78)
              }
            }
          }
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  // 单个图片集- 带尺寸参数
  @Builder
  ImageItem(post: Post, images: string[], index: number, w: number, h: number) {
    Stack() {
      Image(images[index])
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    }
    .width(w)
    .height(h)
    .backgroundColor('#E8E8E8')
    .borderRadius(4)
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [
        [this.getGridColor(index), 0],
        [this.getGridColorEnd(index), 1]
      ]
    })
    .onClick(() => this.openImagePreview(post, index))
  }

  // 保留旧的ImageGrid以兼容
  @Builder
  ImageGrid(images: string[], post: Post) {
    this.WechatStyleImageGrid(images, post)
  }

  private getGridColor(index: number): string {
    const colors = ['#E0F2FE', '#CFFAFE', '#BAE6FD', '#A5F3FC', '#BAE6FD', '#D1D5DB'];
    return colors[index % colors.length];
  }

  private getGridColorEnd(index: number): string {
    const colors = ['#7DD3FC', '#4F46E5', '#38BDF8', '#6366F1', '#38BDF8', '#6B7280'];
    return colors[index % colors.length];
  }

  private formatTime(dateStr: string): string {
    const date = new Date(dateStr);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    if (hours < 1) return '刚刚';
    if (hours < 24) return `${hours}小时前`;
    const days = Math.floor(hours / 24);
    if (days < 7) return `${days}天前`;
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}万`;
    } else if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}k`;
    }
    return `${count}`;
  }

  @Builder
  VideoContent() {
    Scroll() {
      Column() {
        this.VideoCard('🏔️', '我在云南香格里拉', '背包客小凡', '2.3w', '1280')
        this.VideoCard('🌊', '巴厘岛冲浪日记', '冲浪少女', '1.8w', '956')
        this.VideoCard('🗼', '巴黎铁塔的日落', '旅行摄影师', '3.1w', '2341')
        this.VideoCard('🏯', '日本京都和服体验', '和风旅人', '1.5w', '876')
        this.VideoCard('🌸', '樱花季的东京', '樱花控', '2.7w', '1567')
        this.VideoCard('🏜️', '穿越撒哈拉沙漠', '极限挑战者', '4.2w', '3210')

        // 底部安全区域
        Row().height(80)
      }
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: Spacing.md })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  @Builder
  VideoCard(emoji: string, title: string, author: string, views: string, likes: string) {
    Column() {
      Stack() {
        Column()
          .width('100%')
          .height(200)
          .backgroundColor('#E0F2FE')
          .borderRadius({ topLeft: Radius.card, topRight: Radius.card })

        Text(emoji)
          .fontSize(60)

        Column() {
          Text('▶')
            .fontSize(24)
            .fontColor(Colors.textWhite)
        }
        .width(56)
        .height(56)
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(28)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Row() {
          Text('播放')
            .fontSize(12)
            .fontColor(Colors.textWhite)
          Text(views)
            .fontSize(FontSizes.small)
            .fontColor(Colors.textWhite)
            .margin({ left: 4 })
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(Radius.full)
        .position({ x: 12, y: 166 })
      }

      Column() {
        Text(title)
          .fontSize(FontSizes.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text('👤')
            .fontSize(12)
          Text(author)
            .fontSize(FontSizes.small)
            .fontColor(Colors.textTertiary)
            .margin({ left: 4 })

          Blank()

          Text('❤️')
            .fontSize(12)
          Text(likes)
            .fontSize(FontSizes.small)
            .fontColor(Colors.textTertiary)
            .margin({ left: 4 })
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(12)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor(Colors.bgPrimary)
    .borderRadius(Radius.card)
    .margin({ bottom: Spacing.cardMargin })
  }
}
