/**
 * 用户主页 - 对接真实 API
 */

import { router } from '@kit.ArkUI';
import { ApiService, ApiPost, UserProfileData, FollowResult, PaginatedPosts } from '../../services/ApiService';
import { Post, PostAuthor, PostLocation } from '../../models/Post';
import { User } from '../../models/User';

@Entry
@Component
struct UserProfilePage {
  @State user: User | null = null;
  @State userPosts: Post[] = [];
  @State likedPosts: Post[] = [];
  @State isFollowing: boolean = false;
  @State isBlocked: boolean = false;
  @State currentTab: number = 0;
  @State showMoreMenu: boolean = false;
  @State scrollY: number = 0;
  @State isSelf: boolean = false;
  @State isLoading: boolean = true;
  @StorageProp('currentUserId') currentUserId: string = '';
  private userId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.userId) {
      this.userId = params.userId;
    } else {
      this.userId = this.currentUserId;
    }

    // 如果没有 userId 且没有 currentUserId，可能是异常状态
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

      this.user = {
        id: userData.profile.id,
        nickname: userData.profile.nickname,
        avatar: userData.profile.avatar,
        bio: userData.profile.bio,
        level: userData.profile.level,
        levelTitle: userData.profile.levelTitle,
        followingCount: userData.profile.followingCount,
        followersCount: userData.profile.followersCount,
        friendsCount: userData.profile.friendsCount,
        citiesCount: userData.profile.citiesCount,
        countriesCount: userData.profile.countriesCount,
        postsCount: userData.profile.postsCount,
        createdAt: userData.profile.createdAt,
        updatedAt: userData.profile.createdAt,
      };

      if (userData.relation) {
        this.isFollowing = userData.relation.isFollowing;
      }

      // 2. 获取用户帖子列表
      const postsData: PaginatedPosts = await ApiService.getPosts(1, 20, 'latest', this.userId);
      const newPosts = postsData.items.map(apiPost => this.convertApiPost(apiPost));

      this.userPosts.splice(0, this.userPosts.length);
      for (const p of newPosts) {
        this.userPosts.push(p);
      }

      this.likedPosts = [];

    } catch (error) {
      const err = error as Error;
      console.error('[UserProfile] 加载失败:', err.message);
    } finally {
      this.isLoading = false;
    }
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

      // 重新拉取一次最新计数以防偏差
      const userData = await ApiService.getUserProfile(this.userId);
      this.user.followersCount = userData.profile.followersCount;

    } catch (error) {
      // 回滚
      this.isFollowing = wasFollowing;
      this.user.followersCount = originalFollowers;
      const err = error as Error;
      console.error('[UserProfile] 关注失败:', err.message);
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
    };

    if (apiPost.video) post.video = apiPost.video;
    if (apiPost.city) {
      post.location = {
        cityId: apiPost.city.id,
        cityName: apiPost.city.name,
        address: apiPost.address,
        latitude: apiPost.latitude,
        longitude: apiPost.longitude,
      };
    }
    return post;
  }

  private toggleBlock(): void {
    this.isBlocked = !this.isBlocked;
    this.showMoreMenu = false;
  }

  private goBack(): void {
    router.back();
  }

  private sendMessage(): void {
    console.info('[UserProfile] 跳转私信页面');
  }

  private navigateToPostDetail(post: Post): void {
    router.pushUrl({
      url: 'pages/community/PostDetailPage',
      params: { postId: post.id }
    }).catch((err: Error) => {
      console.error(`[UserProfile] 跳转失败: ${err.message}`);
    });
  }

  private navigateToEditProfile(): void {
    router.pushUrl({ url: 'pages/profile/EditProfilePage' });
  }

  private navigateToSettings(): void {
    router.pushUrl({
      url: 'pages/settings/SettingsPage'
    }).catch((err: Error) => {
      console.error(`[UserProfile] 跳转设置失败: ${err.message}`);
    });
  }

  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}w`;
    } else if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}k`;
    }
    return `${count}`;
  }

  private getCurrentPosts(): Post[] {
    return this.currentTab === 0 ? this.userPosts : this.likedPosts;
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column() {
            this.CoverAndInfo()
            this.ActionButtons()
            this.ContentTabs()
            this.PostsGrid()
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onScroll((_xOffset: number, yOffset: number) => {
          this.scrollY = Math.max(0, this.scrollY + yOffset);
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8FAFC')

      this.TopNavBar()

      if (this.showMoreMenu) {
        this.MoreMenuOverlay()
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TopNavBar() {
    Row() {
      Row() {
        Text('←')
          .fontSize(22)
          .fontColor(this.scrollY > 100 ? '#1E293B' : '#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor(this.scrollY > 100 ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.2)')
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.goBack())

      Blank()

      if (this.scrollY > 120) {
        Text(this.user?.nickname || '')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
      }

      Blank()

      Row() {
        Text(this.isSelf ? '⚙️' : '•••')
          .fontSize(this.isSelf ? 20 : 18)
          .fontColor(this.scrollY > 100 ? '#1E293B' : '#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor(this.scrollY > 100 ? 'rgba(255,255,255,0.8)' : 'rgba(0,0,0,0.2)')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        if (this.isSelf) {
          this.navigateToSettings();
        } else {
          this.showMoreMenu = !this.showMoreMenu;
        }
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 48, bottom: 8 })
    .backgroundColor(this.scrollY > 100 ? `rgba(255,255,255,${Math.min(1, (this.scrollY - 100) / 60)})` : 'transparent')
    .position({ x: 0, y: 0 })
  }

  @Builder
  CoverAndInfo() {
    Column() {
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: this.isSelf
              ? [['#0C4A6E', 0], ['#0369A1', 0.4], ['#0EA5E9', 0.8], ['#38BDF8', 1]]
              : [['#1E293B', 0], ['#334155', 0.5], ['#64748B', 1]]
          })

        Column()
          .width(200)
          .height(200)
          .borderRadius(100)
          .backgroundColor(this.isSelf ? '#7DD3FC' : '#94A3B8')
          .opacity(0.15)
          .blur(60)
          .position({ x: '60%', y: 10 })
          .translate({ y: -this.scrollY * 0.3 })

        Column()
          .width(140)
          .height(140)
          .borderRadius(70)
          .backgroundColor(this.isSelf ? '#BAE6FD' : '#CBD5E1')
          .opacity(0.12)
          .blur(50)
          .position({ x: '5%', y: 50 })
          .translate({ y: -this.scrollY * 0.2 })

        Column()
          .width(80)
          .height(80)
          .borderRadius(40)
          .backgroundColor('#E0F2FE')
          .opacity(0.1)
          .blur(30)
          .position({ x: '80%', y: 120 })
          .translate({ y: -this.scrollY * 0.15 })

        Column()
          .width('100%')
          .height('100%')
          .opacity(0.05)
          .border({ width: 1, color: '#FFFFFF' })
      }
      .width('100%')
      .height(220)
      .clip(true)

      Column() {
        Stack() {
          Column()
            .width(92)
            .height(92)
            .borderRadius(46)
            .linearGradient({
              direction: GradientDirection.RightBottom,
              colors: this.isSelf
                ? [['#38BDF8', 0], ['#0EA5E9', 0.5], ['#0284C7', 1]]
                : [['#64748B', 0], ['#94A3B8', 1]]
            })

          Column() {
            Text((this.user?.nickname || 'U').charAt(0))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(82)
          .height(82)
          .borderRadius(41)
          .backgroundColor(this.isSelf ? '#0EA5E9' : '#64748B')
          .border({ width: 3, color: '#FFFFFF' })
          .justifyContent(FlexAlign.Center)

          Row() {
            Text(`LV.${this.user?.level || 1}`)
              .fontSize(9)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor(this.isSelf ? '#0EA5E9' : '#64748B')
          .borderRadius(10)
          .border({ width: 2, color: '#FFFFFF' })
          .position({ x: 58, y: 72 })

          if (this.isSelf) {
            Column() {
              Text('📷')
                .fontSize(12)
            }
            .width(24)
            .height(24)
            .borderRadius(12)
            .backgroundColor('#38BDF8')
            .border({ width: 2, color: '#FFFFFF' })
            .justifyContent(FlexAlign.Center)
            .position({ x: 62, y: 2 })
            .onClick(() => {
              console.info('[UserProfile] 更换头像');
            })
          }
        }
        .width(92)
        .height(92)
        .margin({ top: -46 })

        Row() {
          Text(this.user?.nickname || '用户')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')

          if (this.isSelf) {
            Text('（我）')
              .fontSize(14)
              .fontColor('#94A3B8')
              .margin({ left: 4 })
          }
        }
        .margin({ top: 12 })

        Row() {
          Text('🌍')
            .fontSize(12)
          Text(this.user?.levelTitle || '迷雾行者')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0EA5E9')
            .margin({ left: 4 })
        }
        .padding({ left: 10, right: 10, top: 4, bottom: 4 })
        .backgroundColor('#E0F2FE')
        .borderRadius(12)
        .margin({ top: 8 })

        Text(this.user?.bio || '这个人很懒，什么都没写~')
          .fontSize(14)
          .fontColor('#64748B')
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 10 })
          .padding({ left: 32, right: 32 })

        Row() {
          this.StatColumn(this.formatCount(this.user?.followingCount || 0), '关注')
          Column().width(1).height(24).backgroundColor('#E2E8F0')
          this.StatColumn(this.formatCount(this.user?.followersCount || 0), '粉丝')
          Column().width(1).height(24).backgroundColor('#E2E8F0')
          this.StatColumn(this.formatCount(this.user?.citiesCount || 0), '城市')
          Column().width(1).height(24).backgroundColor('#E2E8F0')
          this.StatColumn(`${this.user?.countriesCount || 0}`, '国家')
        }
        .width('100%')
        .padding({ top: 20, bottom: 16 })
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF')
    }
  }

  @Builder
  StatColumn(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E293B')
      Text(label)
        .fontSize(12)
        .fontColor('#94A3B8')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
  }

  @Builder
  ActionButtons() {
    if (this.isSelf) {
      Row({ space: 12 }) {
        Button() {
          Row() {
            Text('✏️')
              .fontSize(14)
            Text('编辑资料')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0EA5E9')
              .margin({ left: 6 })
          }
        }
        .height(44)
        .layoutWeight(1)
        .backgroundColor('#E0F2FE')
        .borderRadius(24)
        .onClick(() => this.navigateToEditProfile())

        Button() {
          Row() {
            Text('⚙️')
              .fontSize(14)
            Text('设置')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#475569')
              .margin({ left: 6 })
          }
        }
        .height(44)
        .width(100)
        .backgroundColor('#F1F5F9')
        .borderRadius(24)
        .onClick(() => this.navigateToSettings())
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 16 })
    } else {
      Row({ space: 12 }) {
        Button() {
          Row() {
            if (this.isFollowing) {
              Text('✓')
                .fontSize(14)
                .fontColor('#64748B')
            }
            Text(this.isFollowing ? ' 已关注' : '+ 关注')
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isFollowing ? '#64748B' : '#FFFFFF')
          }
        }
        .height(44)
        .layoutWeight(1)
        .backgroundColor(this.isFollowing ? '#F1F5F9' : '#38BDF8')
        .borderRadius(24)
        .onClick(() => this.toggleFollow())

        Button() {
          Row() {
            Text('💬')
              .fontSize(14)
            Text('私信')
              .fontSize(15)
              .fontWeight(FontWeight.Medium)
              .fontColor('#475569')
              .margin({ left: 6 })
          }
        }
        .height(44)
        .layoutWeight(1)
        .backgroundColor('#F1F5F9')
        .borderRadius(24)
        .onClick(() => this.sendMessage())
      }
      .width('100%')
      .padding({ left: 20, right: 20, bottom: 16 })
    }
  }

  @Builder
  ContentTabs() {
    Row() {
      this.TabButton('作品', 0, `${this.userPosts.length}`)
      this.TabButton('喜欢', 1, `${this.likedPosts.length}`)
      if (this.isSelf) {
        this.TabButton('收藏', 2, '0')
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
    .border({ width: { bottom: 1 }, color: '#F1F5F9' })
  }

  @Builder
  TabButton(title: string, index: number, count: string) {
    Column() {
      Row() {
        Text(title)
          .fontSize(15)
          .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
          .fontColor(this.currentTab === index ? '#0EA5E9' : '#94A3B8')

        Text(` ${count}`)
          .fontSize(11)
          .fontColor(this.currentTab === index ? '#38BDF8' : '#CBD5E1')
      }

      if (this.currentTab === index) {
        Column()
          .width(24)
          .height(3)
          .borderRadius(1.5)
          .backgroundColor('#38BDF8')
          .margin({ top: 8 })
      } else {
        Column().height(11)
      }
    }
    .layoutWeight(1)
    .padding({ top: 14, bottom: 6 })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentTab = index;
    })
  }

  @Builder
  PostsGrid() {
    Column() {
      if (this.currentTab === 2) {
        Column() {
          Text('⭐')
            .fontSize(48)
          Text('暂无收藏')
            .fontSize(14)
            .fontColor('#94A3B8')
            .margin({ top: 12 })
          Text('浏览社区时收藏喜欢的内容')
            .fontSize(12)
            .fontColor('#CBD5E1')
            .margin({ top: 4 })
        }
        .width('100%')
        .padding({ top: 60 })
        .alignItems(HorizontalAlign.Center)
      } else if (this.currentTab === 0) {
        // 直接传递 @State 变量 userPosts，保证绝对的响应式
        this.PostGridContent(this.userPosts, '暂无作品')
      } else if (this.currentTab === 1) {
        // 直接传递 @State 变量 likedPosts
        this.PostGridContent(this.likedPosts, '暂无喜欢的内容')
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  PostGridContent(posts: Post[], emptyText: string) {
    if (posts.length === 0) {
      Column() {
        Text('📭')
          .fontSize(48)
        Text(emptyText)
          .fontSize(14)
          .fontColor('#94A3B8')
          .margin({ top: 12 })

        if (this.isSelf && this.currentTab === 0) {
          Button('去发布第一条动态')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .backgroundColor('#38BDF8')
            .borderRadius(20)
            .height(36)
            .margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/publish/PublishPostPage' });
            })
        }
      }
      .width('100%')
      .padding({ top: 60 })
      .alignItems(HorizontalAlign.Center)
    } else {
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(posts, (post: Post, index: number) => {
          Stack() {
            Column()
              .width('100%')
              .aspectRatio(1)
              .linearGradient({
                direction: GradientDirection.RightBottom,
                colors: [
                  [this.getColor(index), 0],
                  [this.getColorEnd(index), 1]
                ]
              })

            Column() {
              Text(post.content)
                .fontSize(10)
                .fontColor('#FFFFFF')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .padding({ left: 6, right: 6, bottom: 24 })
            .position({ x: 0, y: '55%' })

            Row() {
              if (post.images.length > 1) {
                Row() {
                  Text('🖼️')
                    .fontSize(8)
                  Text(`${post.images.length}`)
                    .fontSize(9)
                    .fontColor('#FFFFFF')
                    .fontWeight(FontWeight.Bold)
                    .margin({ left: 2 })
                }
                .padding({ left: 4, right: 4, top: 2, bottom: 2 })
                .backgroundColor('rgba(0,0,0,0.4)')
                .borderRadius(6)
              }

              Blank()

              Row() {
                Text('❤️')
                  .fontSize(8)
                Text(`${this.formatCount(post.likeCount)}`)
                  .fontSize(9)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 2 })
              }
              .padding({ left: 4, right: 4, top: 2, bottom: 2 })
              .backgroundColor('rgba(0,0,0,0.4)')
              .borderRadius(6)
            }
            .width('100%')
            .padding({ left: 6, right: 6, bottom: 6 })
            .position({ x: 0, y: '100%' })
            .translate({ y: -28 })
          }
          .width('33.33%')
          .aspectRatio(1)
          .padding(0.5)
          .clip(true)
          .onClick(() => this.navigateToPostDetail(post))
        }, (post: Post, index: number) => `${post.id}_${index}`)
      }
    }
  }

  @Builder
  MoreMenuOverlay() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .onClick(() => {
          this.showMoreMenu = false;
        })

      Column() {
        Column() {
          this.MenuItem('⚠️', this.isBlocked ? '取消拉黑' : '拉黑该用户',
            this.isBlocked ? '#0EA5E9' : '#EF4444',
            () => this.toggleBlock())
          Divider().strokeWidth(0.5).color('#F1F5F9')
          this.MenuItem('🚫', '举报', '#EF4444', () => {
            this.showMoreMenu = false;
          })
          Divider().strokeWidth(0.5).color('#F1F5F9')
          this.MenuItem('🔗', '复制主页链接', '#475569', () => {
            this.showMoreMenu = false;
          })
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
        .borderRadius(16)

        Column() {
          Text('取消')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#64748B')
        }
        .width('100%')
        .height(52)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ top: 8 })
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .onClick(() => {
          this.showMoreMenu = false;
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .position({ x: 0, y: '100%' })
      .translate({ y: -220 })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })
  }

  @Builder
  MenuItem(icon: string, title: string, textColor: string, action: () => void) {
    Row() {
      Text(icon)
        .fontSize(18)
      Text(title)
        .fontSize(15)
        .fontColor(textColor)
        .margin({ left: 12 })
    }
    .width('100%')
    .height(52)
    .padding({ left: 20 })
    .alignItems(VerticalAlign.Center)
    .onClick(action)
  }

  private getColor(index: number): string {
    const colors: string[] = ['#BAE6FD', '#E0F2FE', '#A5F3FC', '#CFFAFE', '#BAE6FD', '#F0F9FF', '#E0F2FE', '#A5F3FC'];
    return colors[index % colors.length];
  }

  private getColorEnd(index: number): string {
    const colors: string[] = ['#0EA5E9', '#0284C7', '#06B6D4', '#0891B2', '#38BDF8', '#0369A1', '#0EA5E9', '#0891B2'];
    return colors[index % colors.length];
  }
}