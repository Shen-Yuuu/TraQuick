/**
 * 社区页面 - 对接真实 API
 */

import { router } from '@kit.ArkUI';
import { SharePanel } from '../../components/common/SharePanel';
import { Post, PostAuthor, PostLocation, PostUpdateInfo } from '../../models/Post';
import { ApiService, ApiPost, PaginatedPosts, LikeResult, CollectResult } from '../../services/ApiService';
import { formatTime, formatCount } from '../../utils/Formatter';

@Component
export struct CommunityPage {
  @State currentMainTab: number = 1; // 0: 视频, 1: 社区
  @State currentSubTab: number = 0; // 0: 推荐, 1: 关注, 2: 朋友
  @State postList: Post[] = [];
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  @State showSharePanel: boolean = false;
  @State sharePost: Post | null = null;
  @State errorMessage: string = '';
  @State showRefreshToast: boolean = false;
  @State toastMessage: string = '';
  @StorageLink('communityPostUpdate') @Watch('onPostUpdateChange') postUpdateJson: string = '';

  private mainTabs: string[] = ['视频', '社区'];
  private subTabs: string[] = ['推荐', '关注', '朋友'];

  aboutToAppear(): void {
    // 初始化 AppStorage
    if (!AppStorage.has('communityPostUpdate')) {
      AppStorage.setOrCreate('communityPostUpdate', '');
    }
    this.loadPosts(true);
  }

  onPostUpdateChange(): void {
    if (!this.postUpdateJson) {
      return;
    }

    try {
      const update = JSON.parse(this.postUpdateJson) as PostUpdateInfo;

      // 查找并替换
      const index = this.postList.findIndex(p => p.id === update.postId);
      if (index !== -1) {
        const original = this.postList[index];
        const updated = this.clonePost(original);

        // 覆盖最新数据
        updated.isLiked = update.isLiked;
        updated.isCollected = update.isCollected;
        updated.likeCount = update.likeCount;
        updated.collectCount = update.collectCount;
        updated.commentCount = update.commentCount;
        updated.shareCount = update.shareCount;

        // 必须替换整个数组才能触发 UI 更新
        const newList: Post[] = [];
        for (let i = 0; i < this.postList.length; i++) {
          newList.push(i === index ? updated : this.postList[i]);
        }
        this.postList = newList;

        console.info(`[Community] 局部更新帖子 ${update.postId} 成功`);
      }
    } catch (e) {
      console.error('[Community] 解析更新数据失败');
    }

    // 消费完毕后清空，避免下次进入列表时重复触发
    AppStorage.setOrCreate('communityPostUpdate', '');
  }

  /**
   * 局部更新单条帖子，不影响滚动位置
   */
  private applyPostUpdate(update: PostUpdateInfo): void {
    const index = this.postList.findIndex(p => p.id === update.postId);
    if (index === -1) {
      return; // 列表中找不到该帖子，忽略
    }

    const original = this.postList[index];
    const updated = this.clonePost(original);

    // 用详情页返回的最新数据覆盖
    updated.isLiked = update.isLiked;
    updated.isCollected = update.isCollected;
    updated.likeCount = update.likeCount;
    updated.collectCount = update.collectCount;
    updated.commentCount = update.commentCount;
    updated.shareCount = update.shareCount;

    // 仅替换这一条，整个数组引用更新以触发 @State 响应
    const newList: Post[] = [];
    for (let i = 0; i < this.postList.length; i++) {
      if (i === index) {
        newList.push(updated);
      } else {
        newList.push(this.postList[i]);
      }
    }
    this.postList = newList;

    console.info(`[Community] 局部更新帖子 ${update.postId} 成功`);
  }

  /**
   * 加载帖子列表
   */
  private async loadPosts(isRefresh: boolean = false): Promise<void> {
    if (isRefresh) {
      this.currentPage = 1;
      this.isRefreshing = true;
      this.errorMessage = '';
    } else {
      if (this.isLoadingMore || this.currentPage >= this.totalPages) {
        return;
      }
      this.isLoadingMore = true;
      this.currentPage += 1;
    }

    try {
      const orderBy = this.currentSubTab === 0 ? 'latest' : 'hot';

      let feedType = '';
      if (this.currentSubTab === 1) {
        feedType = 'following'; // 关注栏
      } else if (this.currentSubTab === 2) {
        feedType = 'friends';   // 朋友栏
      }

      const result: PaginatedPosts = await ApiService.getPosts(this.currentPage, 20, orderBy,'', '', '', '', '', feedType);

      const newPosts: Post[] = [];
      for (const apiPost of result.items) {
        newPosts.push(this.convertApiPost(apiPost));
      }

      if (isRefresh) {
        this.postList = newPosts;
        // 显示刷新成功气泡
        this.showRefreshSuccess(`已刷新 ${newPosts.length} 条动态`);
      } else {
        const combined: Post[] = [];
        for (const p of this.postList) {
          combined.push(p);
        }
        for (const p of newPosts) {
          combined.push(p);
        }
        this.postList = combined;
      }

      this.totalPages = result.totalPages;
      this.errorMessage = '';

    } catch (error) {
      const err = error as Error;
      this.errorMessage = err.message || '加载失败';
      console.error('[Community] 加载帖子失败:', err.message);
    } finally {
      this.isRefreshing = false;
      this.isLoadingMore = false;
    }
  }

  /**
   * 显示刷新成功气泡
   */
  private showRefreshSuccess(message: string): void {
    this.toastMessage = message;
    this.showRefreshToast = true;

    // 2秒后自动消失
    setTimeout(() => {
      this.showRefreshToast = false;
    }, 2000);
  }

  /**
   * 转换后端数据为前端 Post 结构
   */
  private convertApiPost(apiPost: ApiPost): Post {
    const author: PostAuthor = {
      id: apiPost.author.id,
      nickname: apiPost.author.nickname,
      avatar: apiPost.author.avatar,
      level: apiPost.author.level,
      levelTitle: apiPost.author.levelTitle,
    };

    const post: Post = {
      id: apiPost.id,
      author: author,
      content: apiPost.content,
      images: apiPost.images,
      tags: apiPost.tags,
      likeCount: apiPost.likeCount,
      commentCount: apiPost.commentCount,
      shareCount: apiPost.shareCount,
      collectCount: apiPost.collectCount,
      isLiked: apiPost.isLiked,
      isCollected: apiPost.isCollected,
      createdAt: apiPost.createdAt,
      type: apiPost.type as 'image' | 'video',
      hotComments: [],
    };

    if (apiPost.video) {
      post.video = apiPost.video;
    }

    if (apiPost.city !== null) {
      const location: PostLocation = {
        cityId: apiPost.city.id,
        cityName: apiPost.city.name,
      };
      if (apiPost.address) {
        location.address = apiPost.address;
      }
      if (apiPost.latitude) {
        location.latitude = apiPost.latitude;
      }
      if (apiPost.longitude) {
        location.longitude = apiPost.longitude;
      }
      post.location = location;
    }

    return post;
  }

  /**
   * 下拉刷新
   */
  private onRefresh(): void {
    console.info('[Community] 触发下拉刷新');
    this.loadPosts(true);
  }

  /**
   * 上拉加载更多
   */
  private onReachEnd(): void {
    console.info(`[Community] 触发上拉加载: 当前页=${this.currentPage}, 总页数=${this.totalPages}`);
    if (!this.isLoadingMore && this.currentPage < this.totalPages) {
      this.loadPosts(false);
    }
  }

  /**
   * 点赞/取消点赞
   */
  private async onLike(post: Post): Promise<void> {
    const index = this.postList.findIndex(p => p.id === post.id);
    if (index === -1) return;

    const originalPost = this.postList[index];
    const wasLiked = originalPost.isLiked;

    // 乐观更新
    const updatedPost = this.clonePost(originalPost);
    updatedPost.isLiked = !wasLiked;
    updatedPost.likeCount = Math.max(0, originalPost.likeCount + (updatedPost.isLiked ? 1 : -1));

    const newList: Post[] = [];
    for (let i = 0; i < this.postList.length; i++) {
      if (i === index) {
        newList.push(updatedPost);
      } else {
        newList.push(this.postList[i]);
      }
    }
    this.postList = newList;

    try {
      let result: LikeResult;
      if (wasLiked) {
        result = await ApiService.unlikePost(post.id);
      } else {
        result = await ApiService.likePost(post.id);
      }

      // 用后端返回的真实计数更新
      const syncPost = this.clonePost(updatedPost);
      syncPost.likeCount = result.likeCount;

      const syncList: Post[] = [];
      for (let i = 0; i < this.postList.length; i++) {
        if (i === index) {
          syncList.push(syncPost);
        } else {
          syncList.push(this.postList[i]);
        }
      }
      this.postList = syncList;

    } catch (error) {
      // 回滚
      const rollbackList: Post[] = [];
      for (let i = 0; i < this.postList.length; i++) {
        if (i === index) {
          rollbackList.push(originalPost);
        } else {
          rollbackList.push(this.postList[i]);
        }
      }
      this.postList = rollbackList;

      const err = error as Error;
      console.error('[Community] 点赞失败:', err.message);
    }
  }

  private async onCollect(post: Post): Promise<void> {
    const index = this.postList.findIndex(p => p.id === post.id);
    if (index === -1) return;

    const originalPost = this.postList[index];
    const wasCollected = originalPost.isCollected;

    const updatedPost = this.clonePost(originalPost);
    updatedPost.isCollected = !wasCollected;
    updatedPost.collectCount = Math.max(0, originalPost.collectCount + (updatedPost.isCollected ? 1 : -1));

    const newList: Post[] = [];
    for (let i = 0; i < this.postList.length; i++) {
      if (i === index) {
        newList.push(updatedPost);
      } else {
        newList.push(this.postList[i]);
      }
    }
    this.postList = newList;

    try {
      let result: CollectResult;
      if (wasCollected) {
        result = await ApiService.uncollectPost(post.id);
      } else {
        result = await ApiService.collectPost(post.id);
      }

      const syncPost = this.clonePost(updatedPost);
      syncPost.collectCount = result.collectCount;

      const syncList: Post[] = [];
      for (let i = 0; i < this.postList.length; i++) {
        if (i === index) {
          syncList.push(syncPost);
        } else {
          syncList.push(this.postList[i]);
        }
      }
      this.postList = syncList;

    } catch (error) {
      const rollbackList: Post[] = [];
      for (let i = 0; i < this.postList.length; i++) {
        if (i === index) {
          rollbackList.push(originalPost);
        } else {
          rollbackList.push(this.postList[i]);
        }
      }
      this.postList = rollbackList;

      const err = error as Error;
      console.error('[Community] 收藏失败:', err.message);
    }
  }

  private onComment(post: Post): void {
    router.pushUrl({
      url: 'pages/community/PostDetailPage',
      params: { postId: post.id }
    }).catch(() => {});
  }

  private onShare(post: Post): void {
    this.sharePost = post;
    this.showSharePanel = true;
  }

  private openImagePreview(post: Post, imageIndex: number): void {
    router.pushUrl({
      url: 'pages/community/ImagePreviewPage',
      params: { postId: post.id, images: post.images, imageIndex: imageIndex }
    }).catch(() => {});
  }

  private navigateToUser(userId: string): void {
    router.pushUrl({
      url: 'pages/community/UserProfilePage',
      params: { userId: userId }
    }).catch(() => {});
  }

  private clonePost(source: Post): Post {
    const authorCopy: PostAuthor = {
      id: source.author.id,
      nickname: source.author.nickname,
      avatar: source.author.avatar,
      level: source.author.level,
      levelTitle: source.author.levelTitle,
    };

    const cloned: Post = {
      id: source.id,
      author: authorCopy,
      content: source.content,
      images: source.images.slice(),
      tags: source.tags.slice(),
      likeCount: source.likeCount,
      commentCount: source.commentCount,
      shareCount: source.shareCount,
      collectCount: source.collectCount,
      isLiked: source.isLiked,
      isCollected: source.isCollected,
      createdAt: source.createdAt,
      type: source.type,
    };

    if (source.video) {
      cloned.video = source.video;
    }

    if (source.location) {
      const locCopy: PostLocation = {
        cityId: source.location.cityId,
        cityName: source.location.cityName,
      };
      if (source.location.address) {
        locCopy.address = source.location.address;
      }
      cloned.location = locCopy;
    }

    return cloned;
  }

  build() {
    Stack() {
      Column() {
        Row().height(108)

        if (this.currentMainTab === 1) {
          this.CommunityContent()
        } else {
          this.VideoContent()
        }
      }
      .width('100%')
      .height('100%')

      Column() {
        this.TopTabBar()
        this.SubTabBar()
      }
      .width('100%')
      .position({ x: 0, y: 0 })

      SharePanel({
        isShow: this.showSharePanel,
        // TODO: 对接 API 获取好友/关注列表作为分享目标
        shareTargets: [],
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
      Row().height(28)

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
          if (this.currentSubTab !== index) {
            this.currentSubTab = index;
            this.loadPosts(true);
          }
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
    Stack() {
      Refresh({ refreshing: $$this.isRefreshing }) {
        List() {
          // 错误提示
          if (this.errorMessage) {
            ListItem() {
              Row() {
                Text('⚠️')
                  .fontSize(14)
                Text(this.errorMessage)
                  .fontSize(13)
                  .fontColor('#EF4444')
                  .margin({ left: 6 })
                Text(' 点击重试')
                  .fontSize(13)
                  .fontColor('#38BDF8')
              }
              .width('100%')
              .padding({ left: 16, right: 16, top: 10, bottom: 10 })
              .backgroundColor('#FEF2F2')
              .borderRadius(10)
              .margin({ top: 10, bottom: 10 })
              .onClick(() => {
                this.loadPosts(true);
              })
            }
          }

          // 空状态
          if (this.postList.length === 0 && !this.isRefreshing && !this.errorMessage) {
            ListItem() {
              Column() {
                Text('📭')
                  .fontSize(48)
                Text('暂无动态')
                  .fontSize(14)
                  .fontColor('#94A3B8')
                  .margin({ top: 12 })
                Text('下拉刷新试试')
                  .fontSize(12)
                  .fontColor('#CBD5E1')
                  .margin({ top: 4 })
              }
              .width('100%')
              .padding({ top: 80 })
              .alignItems(HorizontalAlign.Center)
            }
          }

          ForEach(this.postList, (post: Post) => {
            ListItem() {
              this.EnhancedPostCard(post)
            }
          }, (post: Post) => `${post.id}_${post.likeCount}_${post.collectCount}_${post.isLiked}_${post.isCollected}_${post.commentCount}`)

          // 加载更多
          if (this.isLoadingMore) {
            ListItem() {
              Row() {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color('#38BDF8')
                Text('加载中...')
                  .fontSize(13)
                  .fontColor('#94A3B8')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
            }
          } else if (this.currentPage >= this.totalPages && this.postList.length > 0) {
            ListItem() {
              Text('— 没有更多了 —')
                .fontSize(13)
                .fontColor('#CBD5E1')
                .width('100%')
                .height(50)
                .textAlign(TextAlign.Center)
            }
          }

          // 底部安全区
          ListItem() {
            Row().height(80)
          }
        }
        .width('100%')
        .padding({ left: 12, right: 12 })
        .scrollBar(BarState.Off)
        .divider({ strokeWidth: 0 })
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          this.onReachEnd();
        })
      }
      .onRefreshing(() => {
        this.onRefresh();
      })
      .width('100%')
      .layoutWeight(1)

      // 刷新成功气泡
      if (this.showRefreshToast) {
        Column() {
          Row() {
            Text('✓')
              .fontSize(14)
              .fontColor('#FFFFFF')
            Text(this.toastMessage)
              .fontSize(13)
              .fontColor('#FFFFFF')
              .margin({ left: 6 })
          }
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(0, 0, 0, 0.7)')
          .borderRadius(20)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .position({ x: 0, y: 10 })
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  EnhancedPostCard(post: Post) {
    Row() {
      // 左侧头像 - 点击跳转用户主页（阻止冒泡）
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
      .onClick((event: ClickEvent) => {
        // 阻止冒泡，只跳转用户
        this.navigateToUser(post.author.id);
      })

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
          .onClick((event: ClickEvent) => {
            this.navigateToUser(post.author.id);
          })

          Blank()

          Text('···')
            .fontSize(18)
            .fontColor('#C0C0C0')
            .onClick((event: ClickEvent) => {
              // 更多菜单
            })
        }
        .width('100%')

        // 内容文本（点击穿透到整卡）
        Column() {
          Text(post.content)
            .fontSize(15)
            .fontColor('#333333')
            .lineHeight(22)
            .margin({ top: 6 })
            .width('100%')
            .maxLines(4)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 图片网格（点击图片预览，阻止冒泡）
          if (post.images && post.images.length > 0) {
            Column() {
              this.WechatStyleImageGrid(post.images, post)
            }
            .margin({ top: 10 })
            .alignItems(HorizontalAlign.Start)
          }

          // 位置 + 时间
          Column() {
            Row() {
              if (post.location && post.location.cityName) {
                Text(post.location.cityName)
                  .fontSize(12)
                  .fontColor('#38BDF8')
                  .margin({ right: 8 })
              }
              Text(formatTime(post.createdAt))
                .fontSize(12)
                .fontColor('#B0B0B0')
            }
            .width('100%')
            .margin({ top: 10 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // 操作按钮栏（阻止冒泡）
        Row() {
          // 点赞
          Row() {
            Text(post.isLiked ? '❤️' : '🤍')
              .fontSize(14)
            if (post.likeCount > 0) {
              Text(`${formatCount(post.likeCount)}`)
                .fontSize(12)
                .fontColor(post.isLiked ? '#38BDF8' : '#888888')
                .margin({ left: 4 })
            }
          }
          .onClick((event: ClickEvent) => {
            this.onLike(post);
          })

          // 评论
          Row() {
            Text('💬')
              .fontSize(14)
            if (post.commentCount > 0) {
              Text(`${formatCount(post.commentCount)}`)
                .fontSize(12)
                .fontColor('#888888')
                .margin({ left: 4 })
            }
          }
          .onClick((event: ClickEvent) => {
            this.onComment(post);
          })

          // 收藏
          Row() {
            Text('⭐')
              .fontSize(14)
            if (post.collectCount > 0) {
              Text(`${formatCount(post.collectCount)}`)
                .fontSize(12)
                .fontColor(post.isCollected ? '#38BDF8' : '#888888')
                .margin({ left: 4 })
            }
          }
          .onClick((event: ClickEvent) => {
            this.onCollect(post);
          })

          // 转发
          Row() {
            Text('↗️')
              .fontSize(14)
            if (post.shareCount > 0) {
              Text(`${formatCount(post.shareCount)}`)
                .fontSize(12)
                .fontColor('#888888')
                .margin({ left: 4 })
            }
          }
          .onClick((event: ClickEvent) => {
            this.onShare(post);
          })
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
    .onClick(() => {
      // 整卡点击 -> 跳转详情
      this.onComment(post);
    })
  }

  @Builder
  WechatStyleImageGrid(images: string[], post: Post) {
    Column() {
      if (images.length === 1) {
        this.ImageItem(post, images, 0, 180, 180)
      } else if (images.length === 2) {
        Row({ space: 4 }) {
          this.ImageItem(post, images, 0, 120, 120)
          this.ImageItem(post, images, 1, 120, 120)
        }
      } else if (images.length === 3) {
        Row({ space: 4 }) {
          this.ImageItem(post, images, 0, 80, 80)
          this.ImageItem(post, images, 1, 80, 80)
          this.ImageItem(post, images, 2, 80, 80)
        }
      } else if (images.length === 4) {
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
      } else if (images.length >= 5) {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(post, images, 0, 78, 78)
            this.ImageItem(post, images, 1, 78, 78)
            this.ImageItem(post, images, 2, 78, 78)
          }
          Row({ space: 4 }) {
            this.ImageItem(post, images, 3, 78, 78)
            this.ImageItem(post, images, 4, 78, 78)
            if (images.length > 5) {
              this.ImageItem(post, images, 5, 78, 78)
            }
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

  @Builder
  ImageItem(post: Post, images: string[], index: number, w: number, h: number) {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#E8E8E8')
        .borderRadius(4)

      Image(images[index])
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .borderRadius(4)
    }
    .width(w)
    .height(h)
    .onClick((event: ClickEvent) => {
      // 阻止冒泡，只预览图片
      this.openImagePreview(post, index);
    })
  }

  // formatTime / formatCount → 已抽取到 utils/Formatter.ets

  @Builder
  VideoContent() {
    Column() {
      Text('视频功能开发中...')
        .fontSize(14)
        .fontColor('#94A3B8')
    }
    .width('100%')
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }
}