/**
 * 动态详情页 - 抖音风格评论区
 * 支持：查看所有评论、点赞回复评论、点击头像跳转用户主页、过渡动画
 */

import { router, promptAction } from '@kit.ArkUI';
import { ApiService, ApiPost, CommentListData, ApiComment, CreateCommentParams, CollectResult, LikeResult } from '../../services/ApiService';
import { Post, PostComment, PostAuthor, PostLocation, CommentReply,PostUpdateInfo } from '../../models/Post';

@Entry
@Component
struct PostDetailPage {
  @State post: Post | null = null;
  @State comments: PostComment[] = [];
  @State commentText: string = '';
  @State isLiked: boolean = false;
  @State isCollected: boolean = false;
  @State replyTo: PostComment | null = null;
  @State showSharePanel: boolean = false;
  @State pageEnterAnim: number = 0;
  @State commentAreaAnim: number = 0;
  @State likeCount: number = 0;
  @State collectCount: number = 0;
  @State commentCount: number = 0;
  @State shareCount: number = 0;
  @State hasChanged: boolean = false; // 标记是否有数据变更

  // 新增：关注相关状态
  @State isFollowing: boolean = false;
  @State isSelf: boolean = false;
  @StorageProp('currentUserId') currentUserId: string = '';

  private postId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.postId) {
      this.postId = params.postId;
      this.loadPostDetail();
    }
    animateTo({ duration: 350, curve: Curve.EaseOut }, () => {
      this.pageEnterAnim = 1;
    });
    setTimeout(() => {
      animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
        this.commentAreaAnim = 1;
      });
    }, 200);
  }

  private async loadPostDetail(): Promise<void> {
    try {
      const apiPost: ApiPost = await ApiService.getPostDetail(this.postId);

      this.post = this.convertApiPost(apiPost);
      this.isLiked = apiPost.isLiked;
      this.isCollected = apiPost.isCollected;
      this.likeCount = apiPost.likeCount;
      this.collectCount = apiPost.collectCount;
      this.commentCount = apiPost.commentCount;
      this.shareCount = apiPost.shareCount;

      // 检查是否是自己的帖子
      this.isSelf = (apiPost.author.id === this.currentUserId);

      // 如果不是自己的帖子，查询是否已关注
      if (!this.isSelf) {
        const userProfile = await ApiService.getUserProfile(apiPost.author.id);
        if (userProfile.relation) {
          this.isFollowing = userProfile.relation.isFollowing;
        }
      }

      await this.loadComments();

    } catch (error) {
      const err = error as Error;
      console.error('[PostDetail] 加载失败:', err.message);
    }
  }

  // 新增：处理关注/取消关注逻辑
  private async handleFollow(): Promise<void> {
    if (!this.post) return;

    // 乐观更新
    const wasFollowing = this.isFollowing;
    this.isFollowing = !wasFollowing;

    try {
      if (wasFollowing) {
        await ApiService.unfollowUser(this.post.author.id);
        promptAction.showToast({ message: '已取消关注' });
      } else {
        await ApiService.followUser(this.post.author.id);
        promptAction.showToast({ message: '关注成功' });
      }
      this.hasChanged = true; // 可能会影响列表页或其他页面的刷新
    } catch (error) {
      // 失败回滚
      this.isFollowing = wasFollowing;
      promptAction.showToast({ message: '操作失败' });
      console.error('[PostDetail] 关注/取消关注失败:', (error as Error).message);
    }
  }

  private async loadComments(): Promise<void> {
    try {
      const result: CommentListData = await ApiService.getComments(this.postId, 1, 50);

      const flatComments: PostComment[] = [];

      for (const apiComment of result.items) {
        flatComments.push(this.convertApiComment(apiComment));
        if (apiComment.children && apiComment.children.length > 0) {
          for (const child of apiComment.children) {
            flatComments.push(this.convertApiComment(child));
          }
        }
      }
      this.comments = flatComments;

    } catch (error) {
      const err = error as Error;
      console.error('[PostDetail] 加载评论失败:', err.message);
    }
  }

  private goBack(): void {
    if (this.hasChanged && this.post) {
      // 构造更新对象
      const updateInfo: PostUpdateInfo = {
        postId: this.post.id,
        isLiked: this.isLiked,
        isCollected: this.isCollected,
        likeCount: this.likeCount,
        collectCount: this.collectCount,
        commentCount: this.commentCount,
        shareCount: this.shareCount
      };

      // 写入 AppStorage (转为 JSON 字符串以避免引用传递问题)
      AppStorage.setOrCreate('communityPostUpdate', JSON.stringify(updateInfo));
    }
    router.back();
  }

  private navigateToUser(userId: string): void {
    router.pushUrl({
      url: 'pages/community/UserProfilePage',
      params: { userId: userId }
    }).catch(() => {});
  }

  private openImagePreview(index: number): void {
    if (!this.post) return;
    router.pushUrl({
      url: 'pages/community/ImagePreviewPage',
      params: { postId: this.post.id, imageIndex: index }
    }).catch(() => {});
  }

  private async sendComment(): Promise<void> {
    if (!this.commentText.trim()) {
      return;
    }

    const params = new CreateCommentParams();
    params.postId = this.postId;
    params.content = this.commentText.trim();

    if (this.replyTo !== null) {
      params.parentId = this.replyTo.id;
      params.replyToUserId = this.replyTo.userId;
    }

    try {
      await ApiService.createComment(params);
      this.commentText = '';
      this.replyTo = null;
      this.commentCount += 1;
      this.hasChanged = true;

      await this.loadComments();

    } catch (error) {
      const err = error as Error;
      console.error('[PostDetail] 发送评论失败:', err.message);
    }
  }

  private async togglePostLike(): Promise<void> {
    if (!this.post) return;

    const wasLiked = this.isLiked;
    const originalCount = this.likeCount;

    this.isLiked = !wasLiked;
    this.likeCount = Math.max(0, originalCount + (this.isLiked ? 1 : -1));
    this.hasChanged = true;

    try {
      let result: LikeResult;
      if (wasLiked) {
        result = await ApiService.unlikePost(this.post.id);
      } else {
        result = await ApiService.likePost(this.post.id);
      }
      this.likeCount = result.likeCount;
    } catch (error) {
      this.isLiked = wasLiked;
      this.likeCount = originalCount;
      const err = error as Error;
      console.error('[PostDetail] 点赞失败:', err.message);
    }
  }

  private async togglePostCollect(): Promise<void> {
    if (!this.post) return;

    const wasCollected = this.isCollected;
    const originalCount = this.collectCount;

    this.isCollected = !wasCollected;
    this.collectCount = Math.max(0, originalCount + (this.isCollected ? 1 : -1));
    this.hasChanged = true;

    try {
      let result: CollectResult;
      if (wasCollected) {
        result = await ApiService.uncollectPost(this.post.id);
      } else {
        result = await ApiService.collectPost(this.post.id);
      }
      this.collectCount = result.collectCount;
    } catch (error) {
      this.isCollected = wasCollected;
      this.collectCount = originalCount;
      const err = error as Error;
      console.error('[PostDetail] 收藏失败:', err.message);
    }
  }

  private toggleCommentLike(commentId: string): void {
    const idx = this.comments.findIndex(c => c.id === commentId);
    if (idx !== -1) {
      const c = this.comments[idx];
      const updated: PostComment = {
        id: c.id, postId: c.postId, userId: c.userId,
        userNickname: c.userNickname, userAvatar: c.userAvatar,
        content: c.content, likeCount: Math.max(0, c.likeCount + (c.isLiked ? -1 : 1)),
        isLiked: !c.isLiked, replyTo: c.replyTo, createdAt: c.createdAt,
      };
      const newArr: PostComment[] = [];
      for (let i = 0; i < this.comments.length; i++) {
        newArr.push(i === idx ? updated : this.comments[i]);
      }
      this.comments = newArr;
    }
  }

  private startReply(comment: PostComment): void {
    this.replyTo = comment;
  }

  private cancelReply(): void {
    this.replyTo = null;
  }

  private formatTime(isoString: string): string {
    const now = new Date();
    const date = new Date(isoString);
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);
    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  private formatCount(count: number): string {
    if (count >= 10000) return `${(count / 10000).toFixed(1)}w`;
    if (count >= 1000) return `${(count / 1000).toFixed(1)}k`;
    return `${count}`;
  }

  build() {
    Column() {
      this.NavigationBar()

      if (this.post) {
        Scroll() {
          Column() {
            Column() {
              this.AuthorSection()
              this.ContentSection()
              if (this.post.images && this.post.images.length > 0) {
                this.ImagesSection()
              }
              this.MetaSection()
              this.InteractionBar()
            }
            .opacity(this.pageEnterAnim)
            .translate({ y: (1 - this.pageEnterAnim) * 20 })

            Column() {
              Divider().strokeWidth(8).color('#F1F5F9')
              this.CommentsSection()
            }
            .opacity(this.commentAreaAnim)
            .translate({ y: (1 - this.commentAreaAnim) * 30 })

            Column().height(100)
          }
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)

        this.CommentInputBar()
      } else {
        Column() {
          LoadingProgress().width(40).height(40)
          Text('加载中...').fontSize(14).fontColor('#94A3B8').margin({ top: 12 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  NavigationBar() {
    Row() {
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor('#1E293B')
          .fontWeight(FontWeight.Bold)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.goBack())

      Blank()

      Text('动态详情')
        .fontSize(16)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E293B')

      Blank()

      Row() {
        Text('↗️')
          .fontSize(18)
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(56)
    .padding({ left: 8, right: 8, top: 40 })
    .backgroundColor('rgba(255, 255, 255, 0.75)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: { bottom: 0.5 }, color: '#F1F5F9' })
  }

  @Builder
  AuthorSection() {
    Row() {
      Column() {
        Text((this.post!.author.nickname || 'A').charAt(0))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .linearGradient({
        direction: GradientDirection.RightBottom,
        colors: [['#38BDF8', 0], ['#0EA5E9', 1]]
      })
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.navigateToUser(this.post!.author.id))

      Column() {
        Text(this.post!.author.nickname)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
        Text(this.post!.author.levelTitle || '')
          .fontSize(11)
          .fontColor('#94A3B8')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ left: 12 })
      .onClick(() => this.navigateToUser(this.post!.author.id))

      Blank()

      // 只有不是看自己的帖子时，才显示关注按钮
      if (!this.isSelf) {
        Button(this.isFollowing ? '已关注' : '+ 关注')
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isFollowing ? '#64748B' : '#FFFFFF')
          .backgroundColor(this.isFollowing ? '#F1F5F9' : '#38BDF8')
          .borderRadius(20)
          .height(34)
          .padding({ left: 16, right: 16 })
          .onClick(() => this.handleFollow())
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  @Builder
  ContentSection() {
    Column() {
      Text(this.post!.content)
        .fontSize(15)
        .fontColor('#1E293B')
        .lineHeight(24)

      if (this.post!.tags && this.post!.tags.length > 0) {
        Row() {
          ForEach(this.post!.tags, (tag: string) => {
            Text(`#${tag}`)
              .fontSize(13)
              .fontColor('#38BDF8')
              .margin({ right: 10 })
          })
        }
        .margin({ top: 10 })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14 })
    .alignItems(HorizontalAlign.Start)
    .gesture(
      TapGesture({ count: 2 }).onAction(() => {
        this.togglePostLike()
      })
    )
  }

  @Builder
  ImagesSection() {
    Column() {
      this.PostImageGrid(this.post!.images)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12 })
  }

  @Builder
  MetaSection() {
    Row() {
      if (this.post!.location) {
        Row() {
          Text('📍')
            .fontSize(12)
          Text(`${this.post!.location.cityName}${this.post!.location.address ? ' · ' + this.post!.location.address : ''}`)
            .fontSize(12)
            .fontColor('#38BDF8')
            .margin({ left: 4 })
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .backgroundColor('#E0F2FE')
        .borderRadius(8)
      }

      Blank()

      Text(this.formatTime(this.post!.createdAt))
        .fontSize(12)
        .fontColor('#94A3B8')
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 14, bottom: 8 })
  }

  @Builder
  InteractionBar() {
    Row() {
      Column() {
        Text(this.isLiked ? '❤️' : '🤍')
          .fontSize(22)
        Text(this.formatCount(this.likeCount))
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isLiked ? '#EF4444' : '#64748B')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .onClick(() => this.togglePostLike())

      Column() {
        Text('💬')
          .fontSize(22)
          .opacity(0.6)
        Text(this.formatCount(this.commentCount))
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#64748B')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)

      Column() {
        Text(this.isCollected ? '⭐' : '☆')
          .fontSize(22)
        Text(this.formatCount(this.collectCount))
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isCollected ? '#F59E0B' : '#64748B')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .onClick(() => this.togglePostCollect())

      Column() {
        Text('↗️')
          .fontSize(22)
          .opacity(0.6)
        Text(this.formatCount(this.shareCount))
          .fontSize(12)
          .fontWeight(FontWeight.Bold)
          .fontColor('#64748B')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8, bottom: 16 })
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  CommentsSection() {
    Column() {
      Row() {
        Text('评论')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
        Text(` ${this.comments.length}`)
          .fontSize(14)
          .fontColor('#94A3B8')

        Blank()

        Row() {
          Text('🔥 最热')
            .fontSize(12)
            .fontColor('#475569')
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('#F1F5F9')
        .borderRadius(12)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 16 })

      ForEach(this.comments, (comment: PostComment, index: number) => {
        this.CommentItemView(comment, index)
      }, (comment: PostComment) => `${comment.id}_${comment.isLiked}_${comment.likeCount}`)

      if (this.comments.length === 0) {
        Column() {
          Text('💬')
            .fontSize(36)
          Text('暂无评论，快来抢沙发吧~')
            .fontSize(14)
            .fontColor('#94A3B8')
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ top: 40, bottom: 40 })
        .alignItems(HorizontalAlign.Center)
      }
    }
  }

  @Builder
  CommentItemView(comment: PostComment, index: number) {
    Row() {
      Column() {
        Text((comment.userNickname || 'U').charAt(0))
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
      }
      .width(36)
      .height(36)
      .borderRadius(18)
      .backgroundColor(this.getAvatarColor(index))
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.navigateToUser(comment.userId))

      Column() {
        Row() {
          Text(comment.userNickname)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#475569')
            .onClick(() => this.navigateToUser(comment.userId))
          Blank()
          Text(this.formatTime(comment.createdAt))
            .fontSize(11)
            .fontColor('#CBD5E1')
        }
        .width('100%')

        if (comment.replyTo) {
          Row() {
            Text('回复')
              .fontSize(12)
              .fontColor('#94A3B8')
            Text(` @${comment.replyTo.authorName}`)
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('#38BDF8')
          }
          .margin({ top: 4 })
        }

        Text(comment.content)
          .fontSize(14)
          .fontColor('#1E293B')
          .lineHeight(22)
          .margin({ top: 6 })
          .width('100%')

        Row() {
          Row() {
            Text(comment.isLiked ? '❤️' : '🤍')
              .fontSize(14)
            if (comment.likeCount > 0) {
              Text(`${comment.likeCount}`)
                .fontSize(12)
                .fontColor(comment.isLiked ? '#38BDF8' : '#94A3B8')
                .margin({ left: 4 })
            }
          }
          .onClick(() => this.toggleCommentLike(comment.id))

          Text('回复')
            .fontSize(12)
            .fontColor('#94A3B8')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 24 })
            .onClick(() => this.startReply(comment))
        }
        .margin({ top: 10 })
      }
      .layoutWeight(1)
      .margin({ left: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 20 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  CommentInputBar() {
    Column() {
      if (this.replyTo) {
        Row() {
          Text(`回复 @${this.replyTo.userNickname}`)
            .fontSize(12)
            .fontColor('#64748B')
          Blank()
          Text('✕')
            .fontSize(14)
            .fontColor('#94A3B8')
            .onClick(() => this.cancelReply())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 4 })
      }

      Row() {
        TextInput({
          placeholder: this.replyTo ? `回复 ${this.replyTo.userNickname}...` : '写评论...',
          text: this.commentText
        })
          .layoutWeight(1)
          .height(40)
          .backgroundColor('#F1F5F9')
          .borderRadius(20)
          .padding({ left: 16, right: 16 })
          .fontSize(14)
          .onChange((value: string) => {
            this.commentText = value;
          })

        Text('😊')
          .fontSize(22)
          .margin({ left: 10 })

        if (this.commentText.trim()) {
          Text('发送')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#38BDF8')
            .margin({ left: 10 })
            .onClick(() => this.sendComment())
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 34 })
    }
    .width('100%')
    .backgroundColor('rgba(255, 255, 255, 0.8)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .border({ width: { top: 0.5 }, color: '#F1F5F9' })
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: -2 })
  }

  @Builder
  PostImageGrid(images: string[]) {
    Column() {
      if (images.length === 1) {
        this.ImageItem(images, 0, 180, 180)
      } else if (images.length === 2) {
        Row({ space: 4 }) {
          this.ImageItem(images, 0, 120, 120)
          this.ImageItem(images, 1, 120, 120)
        }
      } else if (images.length === 3) {
        Row({ space: 4 }) {
          this.ImageItem(images, 0, 80, 80)
          this.ImageItem(images, 1, 80, 80)
          this.ImageItem(images, 2, 80, 80)
        }
      } else if (images.length === 4) {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(images, 0, 120, 120)
            this.ImageItem(images, 1, 120, 120)
          }
          Row({ space: 4 }) {
            this.ImageItem(images, 2, 120, 120)
            this.ImageItem(images, 3, 120, 120)
          }
        }
      } else if (images.length === 5) {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(images, 0, 120, 120)
            this.ImageItem(images, 1, 120, 120)
          }
          Row({ space: 4 }) {
            this.ImageItem(images, 2, 78, 78)
            this.ImageItem(images, 3, 78, 78)
            this.ImageItem(images, 4, 78, 78)
          }
        }
      } else if (images.length === 6) {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(images, 0, 78, 78)
            this.ImageItem(images, 1, 78, 78)
            this.ImageItem(images, 2, 78, 78)
          }
          Row({ space: 4 }) {
            this.ImageItem(images, 3, 78, 78)
            this.ImageItem(images, 4, 78, 78)
            this.ImageItem(images, 5, 78, 78)
          }
        }
      } else {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.ImageItem(images, 0, 78, 78)
            this.ImageItem(images, 1, 78, 78)
            this.ImageItem(images, 2, 78, 78)
          }
          Row({ space: 4 }) {
            this.ImageItem(images, 3, 78, 78)
            this.ImageItem(images, 4, 78, 78)
            this.ImageItem(images, 5, 78, 78)
          }
          if (images.length > 6) {
            Row({ space: 4 }) {
              this.ImageItem(images, 6, 78, 78)
              if (images.length > 7) {
                this.ImageItem(images, 7, 78, 78)
              }
              if (images.length > 8) {
                this.ImageItem(images, 8, 78, 78)
              }
            }
          }
        }
      }
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  ImageItem(images: string[], index: number, w: number, h: number) {
    Stack() {
      Image(images[index])
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    }
    .width(w)
    .height(h)
    .backgroundColor('#F1F5F9')
    .borderRadius(8)
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [
        [this.getImgColor(index), 0],
        [this.getImgColorEnd(index), 1]
      ]
    })
    .onClick(() => this.openImagePreview(index))
  }

  private getAvatarColor(index: number): string {
    const colors = ['#38BDF8', '#0EA5E9', '#06B6D4', '#14B8A6', '#10B981', '#F59E0B', '#8B5CF6', '#EC4899'];
    return colors[index % colors.length];
  }

  private getImgColor(index: number): string {
    const colors = ['#E0F2FE', '#CFFAFE', '#BAE6FD', '#F0F9FF'];
    return colors[index % colors.length];
  }

  private getImgColorEnd(index: number): string {
    const colors = ['#0EA5E9', '#06B6D4', '#38BDF8', '#0284C7'];
    return colors[index % colors.length];
  }

  private convertApiComment(apiComment: ApiComment): PostComment {
    const comment: PostComment = {
      id: apiComment.id,
      postId: this.postId,
      userId: apiComment.user.id,
      userNickname: apiComment.user.nickname,
      userAvatar: apiComment.user.avatar,
      content: apiComment.content,
      likeCount: apiComment.likeCount,
      isLiked: false,
      createdAt: apiComment.createdAt,
    };

    if (apiComment.replyToUser !== null) {
      const reply: CommentReply = {
        id: apiComment.replyToUser.id,
        authorName: apiComment.replyToUser.nickname,
      };
      comment.replyTo = reply;
    }

    return comment;
  }

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
}