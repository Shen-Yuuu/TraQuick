/**
 * 个人中心页面
 */

import { router, promptAction } from '@kit.ArkUI';
import { ApiService, ApiPost, UserProfileData, PaginatedPosts } from '../../services/ApiService';
import { Post, PostAuthor, PostLocation } from '../../models/Post';

interface BadgeItem {
  icon: string;
  name: string;
  unlocked: boolean;
  bgColor: string;
}

interface MenuItemData {
  icon: string;
  title: string;
  value?: string;
  route?: string;
  badge?: number;
}

@Entry
@Component
export struct ProfilePage {
  @State currentTab: number = 0;  // 0: 作品, 1: 喜欢, 2: 收藏

  // 真实数据状态
  @State nickname: string = '';
  @State avatar: string = '';
  @State bio: string = '';
  @State level: number = 1;
  @State levelTitle: string = '';
  @State followingCount: number = 0;
  @State followersCount: number = 0;
  @State countriesCount: number = 0;
  @State citiesCount: number = 0;
  @State postsCount: number = 0;

  @State myPosts: Post[] = [];
  @State likedPosts: Post[] = [];
  @State collectedPosts: Post[] = [];
  @State isLoading: boolean = true;

  // 地球状态
  @State isGlobeExpanded: boolean = false;
  @State globeScale: number = 0;
  @State globeOpacity: number = 0;
  @State globeHeight: number = 0;
  @State arrowRotation: number = 0;
  @State isDragging: boolean = false;
  @State coverBgIndex: number = 0;

  private readonly MAX_EXPAND_HEIGHT: number = 320;
  private readonly MIN_HEIGHT: number = 0;
  private currentUserId: string = '';

  // 用于手势判定
  private dragStartY: number = 0;

  private coverGradients: string[][] = [
    ['#0A1628', '#0F2647', '#1E3A5F', '#38BDF8'],
    ['#1A0A28', '#2F0647', '#5F1E3A', '#F838BD'],
    ['#0A2818', '#06472F', '#1E5F3A', '#38F8BD'],
    ['#28200A', '#47360F', '#5F4A1E', '#F8C838'],
    ['#0A1828', '#0F3047', '#1E4A5F', '#38D4F8'],
  ];

  @State badges: BadgeItem[] = [
    { icon: '🐼', name: '成都', unlocked: true, bgColor: '#DCFCE7' },
    { icon: '🗼', name: '巴黎', unlocked: true, bgColor: '#DBEAFE' },
    { icon: '⛩️', name: '东京', unlocked: true, bgColor: '#FEE2E2' },
    { icon: '🗽', name: '纽约', unlocked: true, bgColor: '#FEF9C3' },
    { icon: '🎡', name: '伦敦', unlocked: false, bgColor: '#F3E8FF' },
    { icon: '🌉', name: '旧金山', unlocked: false, bgColor: '#E0F2FE' },
  ];

  @State menuItems: MenuItemData[] = [
    { icon: '⏳', title: '时空胶囊', value: '3', route: 'pages/explore/TimeCapsulePage', badge: 1 },
    { icon: '🍾', title: '漂流瓶', value: '5', route: 'pages/explore/DriftBottlePage', badge: 2 },
    { icon: '⚙️', title: '设置', value: '', route: 'pages/profile/SettingsPage' },
  ];

  aboutToAppear(): void {
    this.currentUserId = AppStorage.get<string>('currentUserId') || '';
    if (this.currentUserId) {
      this.loadMyProfile();
    }
  }

  onPageShow(): void {
    if (this.currentUserId && !this.isLoading) {
      this.loadMyProfile();
    }
  }

  private async loadMyProfile(): Promise<void> {
    this.isLoading = true;
    try {
      // 1. 获取个人资料
      const userData: UserProfileData = await ApiService.getUserProfile(this.currentUserId);
      const profile = userData.profile;

      this.nickname = profile.nickname;
      this.avatar = profile.avatar;
      this.bio = profile.bio || '这个人很懒，什么都没写~';
      this.level = profile.level;
      this.levelTitle = profile.levelTitle;
      this.followingCount = profile.followingCount;
      this.followersCount = profile.followersCount;
      this.countriesCount = profile.countriesCount;
      this.citiesCount = profile.citiesCount;
      this.postsCount = profile.postsCount;

      // 2. 获取我发布的帖子 (authorId = currentUserId)
      const myPostsData: PaginatedPosts = await ApiService.getPosts(1, 50, 'latest', this.currentUserId);
      const tempMyPosts: Post[] = [];
      for (const apiPost of myPostsData.items) {
        tempMyPosts.push(this.convertApiPost(apiPost));
      }
      this.myPosts = tempMyPosts;

      // 3. 获取我赞过的帖子
      const likedPostsData: PaginatedPosts = await ApiService.getPosts(1, 50, 'latest', '', '', '', this.currentUserId);
      const tempLikedPosts: Post[] = [];
      for (const apiPost of likedPostsData.items) {
        tempLikedPosts.push(this.convertApiPost(apiPost));
      }
      this.likedPosts = tempLikedPosts;

      // 4. 获取我收藏的帖子
      const collectedPostsData: PaginatedPosts = await ApiService.getPosts(1, 50, 'latest', '', '', '', this.currentUserId);
      const tempCollectedPosts: Post[] = [];
      for (const apiPost of collectedPostsData.items) {
        tempCollectedPosts.push(this.convertApiPost(apiPost));
      }
      this.collectedPosts = tempCollectedPosts;

    } catch (error) {
      console.error('[Profile] 加载个人信息失败:', (error as Error).message);
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
    if (apiPost.city !== null) {
      post.location = { cityId: apiPost.city.id, cityName: apiPost.city.name };
      if (apiPost.address) post.location.address = apiPost.address;
    }

    return post;
  }

  private navigateToSettings(): void { router.pushUrl({ url: 'pages/settings/SettingsPage' }).catch(() => {}); }
  private navigateToEditProfile(): void { router.pushUrl({ url: 'pages/profile/EditProfilePage' }).catch(() => {}); }
  private navigateToBadgeWall(): void { router.pushUrl({ url: 'pages/profile/BadgeWallPage' }).catch(() => {}); }
  private navigateToPostDetail(post: Post): void { router.pushUrl({ url: 'pages/community/PostDetailPage', params: { postId: post.id } }).catch(() => {}); }

  private changeCoverBg(): void {
    promptAction.showActionMenu({
      title: '更换背景',
      buttons: [
        { text: '从相册选择', color: '#1E293B' },
        { text: '星空蓝(默认)', color: '#1E293B' },
        { text: '梦幻紫', color: '#1E293B' },
        { text: '清新绿', color: '#1E293B' },
        { text: '暖阳金', color: '#1E293B' },
        { text: '极光青', color: '#1E293B' }
      ]
    }).then((result) => {
      if (result.index >= 1 && result.index <= 5) {
        this.coverBgIndex = result.index - 1;
      }
    });
  }

  // ==================== 地球手势处理（修复版） ====================

  private handleGlobeDragStart(offsetY: number): void {
    this.isDragging = true;
    this.dragStartY = offsetY;
  }

  private handleGlobeDragUpdate(offsetY: number): void {
    // 计算本次滑动的相对距离
    const deltaY = offsetY - this.dragStartY;

    // 增加阻尼感，滑动变慢
    const dampedDelta = deltaY * 0.6;

    const currentBase = this.isGlobeExpanded ? this.MAX_EXPAND_HEIGHT : this.MIN_HEIGHT;
    let newHeight = currentBase + dampedDelta;

    // 限制在有效高度内
    newHeight = Math.max(this.MIN_HEIGHT, Math.min(this.MAX_EXPAND_HEIGHT, newHeight));

    const progress = (newHeight - this.MIN_HEIGHT) / (this.MAX_EXPAND_HEIGHT - this.MIN_HEIGHT);

    this.globeHeight = newHeight;
    this.globeScale = 0.3 + progress * 0.7;
    this.globeOpacity = progress;
    this.arrowRotation = progress * 180;
  }

  private handleGlobeDragEnd(offsetY: number): void {
    this.isDragging = false;
    const deltaY = offsetY - this.dragStartY;

    // 如果往下滑动超过 30px，且原本是收起状态 -> 展开
    if (deltaY > 30 && !this.isGlobeExpanded) {
      this.expandGlobe();
    }
    // 如果往上滑动超过 30px，且原本是展开状态 -> 收起
    else if (deltaY < -30 && this.isGlobeExpanded) {
      this.collapseGlobe();
    }
    // 否则恢复原状
    else {
      if (this.isGlobeExpanded) {
        this.expandGlobe();
      } else {
        this.collapseGlobe();
      }
    }
  }

  private expandGlobe(): void {
    this.isGlobeExpanded = true;
    animateTo({ duration: 350, curve: Curve.Friction }, () => {
      this.globeScale = 1;
      this.globeOpacity = 1;
      this.globeHeight = this.MAX_EXPAND_HEIGHT;
      this.arrowRotation = 180;
    });
  }

  private collapseGlobe(): void {
    this.isGlobeExpanded = false;
    animateTo({ duration: 350, curve: Curve.Friction }, () => {
      this.globeScale = 0;
      this.globeOpacity = 0;
      this.globeHeight = 0;
      this.arrowRotation = 0;
    });
  }

  private formatCount(count: number): string {
    if (count >= 10000) return `${(count / 10000).toFixed(1)}w`;
    if (count >= 1000) return `${(count / 1000).toFixed(1)}k`;
    return `${count}`;
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          this.CoverSection()
          this.UserInfoSection()
          this.StatsRow()
          this.FogGlobeSection()
          this.BadgeWallSection()
          this.ContentTabsSection()

          Row().height(100)
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  CoverSection() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [this.coverGradients[this.coverBgIndex][0], 0],
            [this.coverGradients[this.coverBgIndex][1], 0.4],
            [this.coverGradients[this.coverBgIndex][2], 0.7],
            [this.coverGradients[this.coverBgIndex][3], 1]
          ]
        })

      Column().width(200).height(200).borderRadius(100).backgroundColor('#7DD3FC').opacity(0.15).blur(80).position({ x: '60%', y: 30 })
      Column().width(160).height(160).borderRadius(80).backgroundColor('#60A5FA').opacity(0.1).blur(60).position({ x: '10%', y: 80 })

      Row({ space: 10 }) {
        Column() { Text('+').fontSize(24).fontColor('#FFFFFF') }
        .width(34).height(34).borderRadius(17).backgroundColor('rgba(255,255,255,0.15)').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

        Column() { Text('⚙️').fontSize(18) }
        .width(34).height(34).borderRadius(17).backgroundColor('rgba(255,255,255,0.15)').justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        .onClick(() => this.navigateToSettings())
      }
      .position({ x: '100%', y: 0 }).translate({ x: -98 }).padding({ top: 40 })

      Row() {
        Text('📷').fontSize(12)
        Text('更换背景').fontSize(11).fontColor('#FFFFFF').margin({ left: 4 })
      }
      .padding({ left: 10, right: 10, top: 5, bottom: 5 }).backgroundColor('rgba(0,0,0,0.35)').borderRadius(14)
      .position({ x: '60%', y: 180 }).onClick(() => this.changeCoverBg())
    }
    .width('100%')
    .height(220)
  }

  @Builder
  UserInfoSection() {
    Row() {
      Stack() {
        Column().width(84).height(84).borderRadius(42).linearGradient({ direction: GradientDirection.RightBottom, colors: [['#7DD3FC', 0], ['#0EA5E9', 1]] })
        Column() {
          if (this.avatar) {
            Image(this.avatar).width(76).height(76).borderRadius(38).objectFit(ImageFit.Cover)
          } else {
            Text((this.nickname || '我').charAt(0)).fontSize(32).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
        }.width(76).height(76).borderRadius(38).backgroundColor('#38BDF8').border({ width: 3, color: '#FFFFFF' }).justifyContent(FlexAlign.Center)

        Text(`LV.${this.level}`).fontSize(9).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').padding({ left: 6, right: 6, top: 2, bottom: 2 }).backgroundColor('#38BDF8').borderRadius(10).border({ width: 2, color: '#FFFFFF' }).position({ x: 54, y: 66 })
      }.width(84).height(84)

      Column() {
        Text(this.nickname).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#1E293B')

        Row() {
          Text('🌍').fontSize(12)
          Text(this.levelTitle || '迷雾行者').fontSize(11).fontWeight(FontWeight.Medium).fontColor('#38BDF8').margin({ left: 4 })
        }.padding({ left: 8, right: 8, top: 4, bottom: 4 }).backgroundColor('#DBEAFE').borderRadius(8).margin({ top: 6 })

        Text(this.bio).fontSize(13).fontColor('#64748B').margin({ top: 6 }).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Text('✏️').fontSize(12)
          Text('编辑资料').fontSize(12).fontWeight(FontWeight.Medium).fontColor('#475569').margin({ left: 4 })
        }.padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor('#F1F5F9').borderRadius(16).border({ width: 1, color: '#E2E8F0' }).margin({ top: 10 })
        .onClick(() => this.navigateToEditProfile())
      }
      .alignItems(HorizontalAlign.Start).layoutWeight(1).margin({ left: 16 })
    }
    .width('100%').padding({ left: 16, right: 16, top: 8 }).margin({ top: -30 })
  }

  @Builder
  StatsRow() {
    Row() {
      this.StatItem(this.formatCount(this.followingCount), '关注')
      this.StatItem(this.formatCount(this.followersCount), '粉丝')
      this.StatItem(this.formatCount(this.countriesCount), '国家')
      this.StatItem(this.formatCount(this.citiesCount), '城市')
    }.width('100%').padding({ left: 16, right: 16, top: 24 }).justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  StatItem(value: string, label: string) {
    Column() {
      Text(value).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
      Text(label).fontSize(11).fontColor('#64748B').margin({ top: 2 })
    }.alignItems(HorizontalAlign.Center)
  }

  @Builder
  FogGlobeSection() {
    Column() {
      Row() {
        Row() {
          Column() { Text('🌍').fontSize(24) }.width(44).height(44).backgroundColor('#DBEAFE').borderRadius(12).justifyContent(FlexAlign.Center)
          Column() {
            Text('我的轨迹').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1E293B')
            Text(`已探索 ${this.citiesCount} 座城市`).fontSize(12).fontColor('#64748B').margin({ top: 2 })
          }.alignItems(HorizontalAlign.Start).margin({ left: 12 })
        }
        Blank()
        Row() {
          Column() { Text('⌄').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#94A3B8') }
          .width(36).height(36).backgroundColor('#F1F5F9').borderRadius(18).justifyContent(FlexAlign.Center).rotate({ angle: this.arrowRotation })
        }.alignItems(VerticalAlign.Center)
      }
      .width('100%').padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor('#FFFFFF').borderRadius(16).border({ width: 1, color: '#F1F5F9' })
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Stack() {
          Column().width('100%').height('100%').borderRadius(140).backgroundColor('#1E3A5F')
          Text('🌍').fontSize(180).opacity(0.6)
          Column() {
            Text(`${this.citiesCount}`).fontSize(48).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
            Text('已探索城市').fontSize(12).fontColor('rgba(255,255,255,0.9)').margin({ top: 4 })
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
        }
        .width(280).height(280).borderRadius(140).scale({ x: this.globeScale, y: this.globeScale })
      }
      .width('100%').height(this.globeHeight).opacity(this.globeOpacity)
      .padding({ top: this.globeHeight > 0 ? 16 : 0 }).alignItems(HorizontalAlign.Center).clip(true)
    }
    .width('100%').padding({ left: 16, right: 16, top: 12, bottom: this.globeHeight > 0 ? 8 : 0 })
    // 这里是关键：在整个容器外层绑定统一手势
    .gesture(
      PanGesture({ direction: PanDirection.Vertical, distance: 5 })
        .onActionStart((event: GestureEvent) => { this.handleGlobeDragStart(event.offsetY); })
        .onActionUpdate((event: GestureEvent) => { this.handleGlobeDragUpdate(event.offsetY); })
        .onActionEnd((event: GestureEvent) => { this.handleGlobeDragEnd(event.offsetY); })
    )
  }

  @Builder
  BadgeWallSection() {
    Column() {
      Row() {
        Text('勋章墙').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Blank()
        Row() {
          Text('全部').fontSize(12).fontColor('#38BDF8').fontWeight(FontWeight.Medium)
          Text('›').fontSize(14).fontColor('#38BDF8').margin({ left: 2 })
        }.onClick(() => this.navigateToBadgeWall())
      }.width('100%').padding({ left: 16, right: 16 }).margin({ bottom: 12 })

      Scroll() {
        Row() {
          ForEach(this.badges, (badge: BadgeItem) => {
            Column() {
              Column() { Text(badge.icon).fontSize(28).opacity(badge.unlocked ? 1 : 0.3) }
              .width(64).height(64).backgroundColor(badge.unlocked ? badge.bgColor : '#F1F5F9').borderRadius(16).justifyContent(FlexAlign.Center)
              Text(badge.name).fontSize(11).fontWeight(FontWeight.Medium).fontColor(badge.unlocked ? '#1E293B' : '#94A3B8').margin({ top: 8 })
            }.width(80).alignItems(HorizontalAlign.Center)
          })
        }.padding({ left: 16, right: 16 })
      }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
    }.width('100%').margin({ bottom: 16 })
  }

  @Builder
  ContentTabsSection() {
    Column() {
      Column() {
        Row() {
          // 修改为“喜欢”
          this.TabItem('作品', 0)
          this.TabItem('喜欢', 1)
          this.TabItem('收藏', 2)
        }.width('100%').border({ width: { bottom: 1 }, color: '#F1F5F9' })

        this.PhotoGrid()
      }
      .width('100%').backgroundColor('#FFFFFF').borderRadius({ topLeft: 24, topRight: 24 })
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.05)', offsetY: -4 })
    }.width('100%')
  }

  @Builder
  TabItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentTab === index ? '#38BDF8' : '#64748B')
      if (this.currentTab === index) {
        Column().width(4).height(4).borderRadius(2).backgroundColor('#38BDF8').margin({ top: 8 })
      }
    }
    .layoutWeight(1).padding({ top: 16, bottom: 12 }).alignItems(HorizontalAlign.Center)
    .onClick(() => { this.currentTab = index; })
  }

  @Builder
  PhotoGrid() {
    Column() {
      if (this.currentTab === 0) {
        this.GridContent(this.myPosts, '暂无作品')
      } else if (this.currentTab === 1) {
        this.GridContent(this.likedPosts, '暂无喜欢的内容')
      } else {
        this.GridContent(this.collectedPosts, '暂无收藏的内容')
      }
    }
    .width('100%').padding(1)
  }

  @Builder
  GridContent(posts: Post[], emptyText: string) {
    if (posts.length === 0) {
      Column() {
        Text('📭').fontSize(48)
        Text(emptyText).fontSize(14).fontColor('#94A3B8').margin({ top: 12 })
      }.width('100%').padding({ top: 60, bottom: 60 }).alignItems(HorizontalAlign.Center)
    } else {
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(posts, (post: Post, index: number) => {
          Stack() {
            Column().width('100%').aspectRatio(1).backgroundColor('#E2E8F0')

            if (post.images.length > 0) {
              Image(post.images[0]).width('100%').height('100%').objectFit(ImageFit.Cover)
            } else {
              Column()
                .width('100%').height('100%')
                .linearGradient({ direction: GradientDirection.RightBottom, colors: [[this.getPhotoColor(index), 0], [this.getPhotoColorEnd(index), 1]] })
              Text(post.content).fontSize(10).fontColor('#FFFFFF').padding(8).maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
            }

            if (post.images.length > 1) {
              Text('📷').fontSize(12).position({ x: '80%', y: 8 })
            }
          }
          .width('33.33%').aspectRatio(1).padding(0.5)
          .onClick(() => this.navigateToPostDetail(post))
        }, (post: Post) => post.id)
      }
    }
  }

  private getPhotoColor(index: number): string {
    const colors = ['#93C5FD', '#BFDBFE', '#A5B4FC', '#C7D2FE', '#93C5FD', '#DBEAFE', '#BAE6FD', '#A5B4FC'];
    return colors[index % colors.length];
  }

  private getPhotoColorEnd(index: number): string {
    const colors = ['#38BDF8', '#0EA5E9', '#4F46E5', '#4338CA', '#7DD3FC', '#0284C7', '#0284C7', '#6366F1'];
    return colors[index % colors.length];
  }
}