/**
 * 用户主页 - 增强版 (沉浸式视差下拉、真实API数据)
 */

import { router, promptAction } from '@kit.ArkUI';
import { Post, PostAuthor, PostLocation } from '../../models/Post';
import { User } from '../../models/User';
import { ApiService, ApiPost, UserProfileData, FollowResult, PaginatedPosts } from '../../services/ApiService';

@Entry
@Component
struct UserProfilePage {
  @State user: User | null = null;
  @State coverImage: string = ''; // 用户背景图

  @State userPosts: Post[] = [];
  @State likedPosts: Post[] = [];

  @State isFollowing: boolean = false;
  @State isBlocked: boolean = false;
  @State currentTab: number = 0;
  @State showMoreMenu: boolean = false;
  @State isSelf: boolean = false;
  @State isLoading: boolean = true;

  // 视差下拉状态
  @State scrollY: number = 0;
  @State bgScale: number = 1;
  private scroller: Scroller = new Scroller();

  @StorageProp('currentUserId') currentUserId: string = '';
  private userId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.userId) {
      this.userId = params.userId;
    } else {
      this.userId = this.currentUserId;
    }

    if (!this.userId) {
      router.back();
      return;
    }

    this.isSelf = (this.userId === this.currentUserId);
    this.loadUserProfile();
  }

  private async loadUserProfile(): Promise<void> {
    this.isLoading = true;
    try {
      // 1. 获取用户详情
      const userData: UserProfileData = await ApiService.getUserProfile(this.userId);
      const profile = userData.profile;

      this.user = {
        id: profile.id,
        nickname: profile.nickname,
        avatar: profile.avatar,
        bio: profile.bio,
        level: profile.level,
        levelTitle: profile.levelTitle,
        followingCount: profile.followingCount,
        followersCount: profile.followersCount,
        friendsCount: profile.friendsCount,
        citiesCount: profile.citiesCount,
        countriesCount: profile.countriesCount,
        postsCount: profile.postsCount,
        createdAt: profile.createdAt,
        updatedAt: profile.createdAt,
      };

      this.coverImage = profile.coverImage || '';

      if (userData.relation) {
        this.isFollowing = userData.relation.isFollowing;
      }

      // 2. 获取用户帖子列表
      const postsData: PaginatedPosts = await ApiService.getPosts(1, 20, 'latest', this.userId);
      const newPosts: Post[] = [];
      for (const apiPost of postsData.items) {
        newPosts.push(this.convertApiPost(apiPost));
      }
      this.userPosts = newPosts;

      // 3. 获取喜欢列表 (likedBy = this.userId)
      try {
        const likedData: PaginatedPosts = await ApiService.getPosts(1, 20, 'latest', '', '', '', this.userId);
        const tempLiked: Post[] = [];
        for (const p of likedData.items) {
          tempLiked.push(this.convertApiPost(p));
        }
        this.likedPosts = tempLiked;
      } catch (e) {
        this.likedPosts = [];
      }

    } catch (error) {
      const err = error as Error;
      console.error('[UserProfile] 加载失败:', err.message);
      promptAction.showToast({ message: `加载失败` });
    } finally {
      this.isLoading = false;
    }
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
      hotComments: [],
    };

    if (apiPost.video) post.video = apiPost.video;
    if (apiPost.city) {
      post.location = {
        cityId: apiPost.city.id,
        cityName: apiPost.city.name,
        address: apiPost.address || undefined,
        latitude: apiPost.latitude || undefined,
        longitude: apiPost.longitude || undefined,
      };
    }
    return post;
  }

    private async toggleFollow(): Promise<void> {
    if (!this.user) return;

    const wasFollowing = this.isFollowing;
    const originalFollowers = this.user.followersCount;

    // 乐观更新
    this.isFollowing = !wasFollowing;
    this.user.followersCount = Math.max(0, originalFollowers + (this.isFollowing ? 1 : -1));

    try {
      let result: FollowResult;
      if (wasFollowing) {
        result = await ApiService.unfollowUser(this.userId);
      } else {
        result = await ApiService.followUser(this.userId);
      }
      this.isFollowing = result.isFollowing;

    } catch (error) {
      this.isFollowing = wasFollowing;
      this.user.followersCount = originalFollowers;
      promptAction.showToast({ message: '操作失败' });
    }
  }

  private toggleBlock(): void {
    this.isBlocked = !this.isBlocked;
    this.showMoreMenu = false;
  }

  private goBack(): void { router.back(); }
  private sendMessage(): void {
    promptAction.showToast({ message: '私信功能开发中...' });
    // TODO: 跳转到私信聊天页
    // router.pushUrl({ url: 'pages/message/ChatPage', params: { targetId: this.userId } });
  }
  private navigateToPostDetail(post: Post): void { router.pushUrl({ url: 'pages/community/PostDetailPage', params: { postId: post.id } }).catch(()=>{}); }
  private navigateToEditProfile(): void { router.pushUrl({ url: 'pages/profile/EditProfilePage' }); }
  private navigateToSettings(): void { router.pushUrl({ url: 'pages/settings/SettingsPage' }).catch(()=>{}); }

  private formatCount(count: number): string {
    if (count >= 10000) return `${(count / 10000).toFixed(1)}w`;
    if (count >= 1000) return `${(count / 1000).toFixed(1)}k`;
    return `${count}`;
  }

  // 计算视差缩放
  private handleScroll(): void {
    this.scrollY = this.scroller.currentOffset().yOffset;
    if (this.scrollY < 0) {
      // 下拉放大：滑动距离 / 系数 (系数越小放大越快)
      this.bgScale = 1 + Math.abs(this.scrollY) / 300;
    } else {
      this.bgScale = 1;
    }
  }

  // ==================== 布局 ====================

  build() {
    Stack() {
      // 1. 底层：沉浸式背景图
      if (this.coverImage) {
        Image(this.coverImage)
          .width('100%')
          .height(350)
          .objectFit(ImageFit.Cover)
          .scale({ x: this.bgScale, y: this.bgScale })
          .position({ x: 0, y: 0 })
      } else {
        // 默认渐变背景
        Column()
          .width('100%')
          .height(350)
          .linearGradient({ direction: GradientDirection.Bottom, colors: [['#1E293B', 0], ['#64748B', 1]] })
          .scale({ x: this.bgScale, y: this.bgScale })
          .position({ x: 0, y: 0 })
      }

      // 2. 上层：滚动内容
      Scroll(this.scroller) {
        Column() {
          // 顶部透明留白（透出背后的图）
          Column().width('100%').height(220)

          // 白色圆角主体区域
          Column() {
            this.UserInfoSection()
            this.ActionButtons()
            this.ContentTabs()
            this.PostsGrid()
            Row().height(100)
          }
          .width('100%')
          .backgroundColor('#F8FAFC')
          .borderRadius({ topLeft: 24, topRight: 24 })
          .constraintSize({ minHeight: '80%' })
        }
      }
      .width('100%')
      .height('100%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onScroll(() => this.handleScroll())

      // 3. 悬浮的顶部导航栏（随着滑动变色）
      this.TopNavBar()

      if (this.showMoreMenu) {
        this.MoreMenuOverlay()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000') // 底色黑，防露白
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  TopNavBar() {
    Row() {
      Row() { Text('←').fontSize(22).fontColor(this.scrollY > 100 ? '#1E293B' : '#FFFFFF').fontWeight(FontWeight.Bold) }
      .width(40).height(40).borderRadius(20).backgroundColor(this.scrollY > 100 ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.2)')
      .justifyContent(FlexAlign.Center).onClick(() => this.goBack())

      Blank()

      if (this.scrollY > 120 && this.user) {
        Text(this.user.nickname).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1E293B')
      }

      Blank()

      Row() { Text(this.isSelf ? '⚙️' : '•••').fontSize(this.isSelf ? 20 : 18).fontColor(this.scrollY > 100 ? '#1E293B' : '#FFFFFF').fontWeight(FontWeight.Bold) }
      .width(40).height(40).borderRadius(20).backgroundColor(this.scrollY > 100 ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.2)')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.isSelf) this.navigateToSettings();
        else this.showMoreMenu = !this.showMoreMenu;
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 48, bottom: 8 }) // top: 48 避开系统状态栏
    .backgroundColor(this.scrollY > 100 ? `rgba(255,255,255,${Math.min(1, (this.scrollY - 100) / 60)})` : 'transparent')
    .position({ x: 0, y: 0 })
  }

  @Builder
  UserInfoSection() {
    Row() {
      Stack() {
        Column().width(84).height(84).borderRadius(42).linearGradient({ direction: GradientDirection.RightBottom, colors: this.isSelf ? [['#38BDF8', 0], ['#0EA5E9', 1]] : [['#64748B', 0], ['#94A3B8', 1]] })

        // 真实头像
        if (this.user?.avatar) {
          Image(this.user.avatar).width(76).height(76).borderRadius(38).objectFit(ImageFit.Cover).border({ width: 3, color: '#FFFFFF' })
        } else {
          Column() { Text((this.user?.nickname || 'U').charAt(0)).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFFFFF') }
          .width(76).height(76).borderRadius(38).backgroundColor(this.isSelf ? '#0EA5E9' : '#64748B').border({ width: 3, color: '#FFFFFF' }).justifyContent(FlexAlign.Center)
        }

        Row() { Text(`LV.${this.user?.level || 1}`).fontSize(9).fontWeight(FontWeight.Bold).fontColor('#FFFFFF') }
        .padding({ left: 6, right: 6, top: 2, bottom: 2 }).backgroundColor(this.isSelf ? '#0EA5E9' : '#64748B').borderRadius(10).border({ width: 2, color: '#FFFFFF' }).position({ x: 54, y: 66 })
      }
      .width(84).height(84).margin({ top: -30 })

      Column() {
        Row() {
          Text(this.user?.nickname || '用户').fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1E293B')
          if (this.isSelf) Text('（我）').fontSize(14).fontColor('#94A3B8').margin({ left: 4 })
        }.margin({ top: 8 })

        Row() {
          Text('🌍').fontSize(12)
          Text(this.user?.levelTitle || '迷雾行者').fontSize(12).fontWeight(FontWeight.Medium).fontColor('#0EA5E9').margin({ left: 4 })
        }.padding({ left: 10, right: 10, top: 4, bottom: 4 }).backgroundColor('#E0F2FE').borderRadius(12).margin({ top: 8 })
      }
      .alignItems(HorizontalAlign.Start).margin({ left: 16 })
    }.width('100%').padding({ left: 16, right: 16 })

    Text(this.user?.bio || '这个人很懒，什么都没写~')
      .fontSize(14).fontColor('#64748B').textAlign(TextAlign.Start).width('100%').margin({ top: 16 }).padding({ left: 16, right: 16 })

    Row() {
      this.StatColumn(this.formatCount(this.user?.followingCount || 0), '关注')
      Column().width(1).height(24).backgroundColor('#E2E8F0')
      this.StatColumn(this.formatCount(this.user?.followersCount || 0), '粉丝')
      Column().width(1).height(24).backgroundColor('#E2E8F0')
      this.StatColumn(this.formatCount(this.user?.citiesCount || 0), '城市')
      Column().width(1).height(24).backgroundColor('#E2E8F0')
      this.StatColumn(`${this.user?.countriesCount || 0}`, '国家')
    }.width('100%').padding({ top: 20, bottom: 16 }).justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder
  StatColumn(value: string, label: string) {
    Column() { Text(value).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B'); Text(label).fontSize(12).fontColor('#94A3B8').margin({ top: 2 }) }
    .alignItems(HorizontalAlign.Center).layoutWeight(1)
  }

  @Builder
  ActionButtons() {
    if (this.isSelf) {
      Row({ space: 12 }) {
        Button() { Row() { Text('✏️').fontSize(14); Text('编辑资料').fontSize(15).fontWeight(FontWeight.Bold).fontColor('#0EA5E9').margin({ left: 6 }) } }
        .height(44).layoutWeight(1).backgroundColor('#E0F2FE').borderRadius(24).onClick(() => this.navigateToEditProfile())

        Button() { Row() { Text('⚙️').fontSize(14); Text('设置').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#475569').margin({ left: 6 }) } }
        .height(44).width(100).backgroundColor('#F1F5F9').borderRadius(24).onClick(() => this.navigateToSettings())
      }.width('100%').padding({ left: 20, right: 20, bottom: 16 })
    } else {
      Row({ space: 12 }) {
        Button() { Row() { if (this.isFollowing) Text('✓').fontSize(14).fontColor('#64748B'); Text(this.isFollowing ? ' 已关注' : '+ 关注').fontSize(15).fontWeight(FontWeight.Bold).fontColor(this.isFollowing ? '#64748B' : '#FFFFFF') } }
        .height(44).layoutWeight(1).backgroundColor(this.isFollowing ? '#F1F5F9' : '#38BDF8').borderRadius(24).onClick(() => this.toggleFollow())

        Button() { Row() { Text('💬').fontSize(14); Text('私信').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#475569').margin({ left: 6 }) } }
        .height(44).layoutWeight(1).backgroundColor('#F1F5F9').borderRadius(24).onClick(() => this.sendMessage())
      }.width('100%').padding({ left: 20, right: 20, bottom: 16 })
    }
  }

  @Builder ContentTabs() {
    Row() {
      this.TabButton('作品', 0)
      this.TabButton('喜欢', 1)
      if (this.isSelf) this.TabButton('收藏', 2)
    }.width('100%').padding({ left: 20, right: 20 }).border({ width: { bottom: 1 }, color: '#F1F5F9' })
  }

  @Builder TabButton(title: string, index: number) {
    Column() {
      Text(title).fontSize(15).fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium).fontColor(this.currentTab === index ? '#0EA5E9' : '#94A3B8')
      if (this.currentTab === index) Column().width(24).height(3).borderRadius(1.5).backgroundColor('#38BDF8').margin({ top: 8 })
      else Column().height(11)
    }.layoutWeight(1).padding({ top: 14, bottom: 6 }).alignItems(HorizontalAlign.Center).onClick(() => { this.currentTab = index; })
  }

  @Builder PostsGrid() {
    Column() {
      if (this.isLoading) {
        Column() { LoadingProgress().width(40).height(40).color('#38BDF8') }.width('100%').padding({ top: 60 }).justifyContent(FlexAlign.Center)
      } else if (this.currentTab === 2) {
        Column() { Text('⭐').fontSize(48); Text('暂无收藏').fontSize(14).fontColor('#94A3B8').margin({ top: 12 }) }.width('100%').padding({ top: 60 }).alignItems(HorizontalAlign.Center)
      } else if (this.currentTab === 0) {
        if (this.userPosts.length === 0) this.EmptyStateView('📭', '暂无作品')
        else this.RenderPostGrid(this.userPosts)
      } else if (this.currentTab === 1) {
        if (this.likedPosts.length === 0) this.EmptyStateView('⭐', '暂无喜欢的内容')
        else this.RenderPostGrid(this.likedPosts)
      }
    }.width('100%').backgroundColor('#FFFFFF')
  }

  @Builder EmptyStateView(icon: string, text: string) {
    Column() {
      Text(icon).fontSize(48)
      Text(text).fontSize(14).fontColor('#94A3B8').margin({ top: 12 })
    }.width('100%').padding({ top: 60 }).alignItems(HorizontalAlign.Center)
  }

  @Builder RenderPostGrid(posts: Post[]) {
    Flex({ wrap: FlexWrap.Wrap }) {
      ForEach(posts, (post: Post, index: number) => {
        Stack() {
          Column().width('100%').aspectRatio(1).backgroundColor('#E2E8F0')

          if (post.images && post.images.length > 0) {
            Image(post.images[0]).width('100%').height('100%').objectFit(ImageFit.Cover)
          } else {
            Column().width('100%').height('100%').linearGradient({ direction: GradientDirection.RightBottom, colors: [[this.getColor(index), 0], [this.getColorEnd(index), 1]] })
            Column() { Text(post.content).fontSize(10).fontColor('#FFFFFF').maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }) }.width('100%').padding({ left: 6, right: 6, bottom: 24 }).position({ x: 0, y: '55%' })
          }

          if (post.images && post.images.length > 1) {
            Text('📷').fontSize(12).fontColor('#FFF').position({ x: '80%', y: 8 })
          }
        }
        .width('33.33%').aspectRatio(1).padding(0.5).clip(true)
        .onClick(() => this.navigateToPostDetail(post))
      }, (post: Post) => post.id)
    }
  }

  @Builder MoreMenuOverlay() { /* 忽略保持不变 */ }
  @Builder MenuItem(icon: string, title: string, textColor: string, action: () => void) { /* 忽略保持不变 */ }

  private getColor(index: number): string {
    const colors: string[] = ['#BAE6FD', '#E0F2FE', '#A5F3FC', '#CFFAFE'];
    return colors[index % colors.length];
  }
  private getColorEnd(index: number): string {
    const colors: string[] = ['#0EA5E9', '#0284C7', '#06B6D4', '#0891B2'];
    return colors[index % colors.length];
  }
}