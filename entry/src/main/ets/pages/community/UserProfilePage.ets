/**
 * 用户主页 - 抖音风格
 * 点击头像跳转至此，可查看用户信息、作品，支持关注/拉黑
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { Post } from '../../models/Post';
import { User } from '../../models/User';
import { mockUsers, mockPosts } from '../../services/MockData';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct UserProfilePage {
  @State user: User | null = null;
  @State userPosts: Post[] = [];
  @State isFollowing: boolean = false;
  @State isBlocked: boolean = false;
  @State currentTab: number = 0; // 0: 作品, 1: 喜欢
  @State showMoreMenu: boolean = false;
  @State headerOpacity: number = 0;
  private userId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params && params.userId) {
      this.userId = params.userId;
    }
    this.loadUserProfile();
  }

  private loadUserProfile(): void {
    this.user = mockUsers.find(u => u.id === this.userId) || {
      id: this.userId,
      nickname: '用户',
      avatar: '',
      bio: '这个人很懒，什么都没写~',
      level: 1,
      levelTitle: '迷雾行者',
      followingCount: 0,
      followersCount: 0,
      friendsCount: 0,
      citiesCount: 0,
      countriesCount: 0,
      postsCount: 0,
      createdAt: '',
      updatedAt: '',
    };
    this.userPosts = mockPosts.filter(p => p.author.id === this.userId);
    // 如果没有找到该用户的帖子，展示一些模拟数据
    if (this.userPosts.length === 0) {
      this.userPosts = mockPosts.slice(0, 3);
    }
  }

  private toggleFollow(): void {
    this.isFollowing = !this.isFollowing;
  }

  private toggleBlock(): void {
    this.isBlocked = !this.isBlocked;
    this.showMoreMenu = false;
  }

  private goBack(): void {
    router.back();
  }

  private sendMessage(): void {
    // TODO: 跳转私信页面
  }

  private navigateToPostDetail(post: Post): void {
    router.pushUrl({
      url: 'pages/community/PostDetailPage',
      params: { postId: post.id }
    }).catch(() => {});
  }

  private formatCount(count: number): string {
    if (count >= 10000) {
      return `${(count / 10000).toFixed(1)}w`;
    } else if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}k`;
    }
    return `${count}`;
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column() {
            // 封面背景 + 用户信息
            this.CoverAndInfo()

            // 操作按钮
            this.ActionButtons()

            // Tab栏
            this.ContentTabs()

            // 作品网格
            this.PostsGrid()
          }
          .width('100%')
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F8FAFC')

      // 顶部导航栏
      this.TopNavBar()

      // 更多菜单弹窗
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
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('rgba(0,0,0,0.2)')
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.goBack())

      Blank()

      Row() {
        Text('•••')
          .fontSize(18)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Bold)
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('rgba(0,0,0,0.2)')
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.showMoreMenu = !this.showMoreMenu;
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 48 })
    .position({ x: 0, y: 0 })
  }

  @Builder
  CoverAndInfo() {
    Column() {
      // 封面背景
      Stack() {
        Column()
          .width('100%')
          .height('100%')
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [['#0C4A6E', 0], ['#0369A1', 0.5], ['#38BDF8', 1]]
          })

        // 装饰光效
        Column()
          .width(180)
          .height(180)
          .borderRadius(90)
          .backgroundColor('#7DD3FC')
          .opacity(0.15)
          .blur(60)
          .position({ x: '65%', y: 20 })

        Column()
          .width(120)
          .height(120)
          .borderRadius(60)
          .backgroundColor('#BAE6FD')
          .opacity(0.1)
          .blur(40)
          .position({ x: '10%', y: 60 })
      }
      .width('100%')
      .height(200)

      // 用户信息区
      Column() {
        // 头像
        Stack() {
          Column()
            .width(88)
            .height(88)
            .borderRadius(44)
            .linearGradient({
              direction: GradientDirection.RightBottom,
              colors: [['#38BDF8', 0], ['#0EA5E9', 1]]
            })

          Column() {
            Text((this.user?.nickname || 'U').charAt(0))
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(80)
          .height(80)
          .borderRadius(40)
          .backgroundColor('#0EA5E9')
          .border({ width: 3, color: '#FFFFFF' })
          .justifyContent(FlexAlign.Center)

          // 等级
          Text(`LV.${this.user?.level || 1}`)
            .fontSize(9)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .backgroundColor('#0EA5E9')
            .borderRadius(10)
            .border({ width: 2, color: '#FFFFFF' })
            .position({ x: 56, y: 70 })
        }
        .width(88)
        .height(88)
        .margin({ top: -44 })

        // 昵称
        Text(this.user?.nickname || '用户')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
          .margin({ top: 12 })

        // 称号
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

        // 简介
        Text(this.user?.bio || '这个人很懒，什么都没写~')
          .fontSize(14)
          .fontColor('#64748B')
          .textAlign(TextAlign.Center)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 10 })
          .padding({ left: 32, right: 32 })

        // 统计数据
        Row() {
          this.StatColumn(this.formatCount(this.user?.followingCount || 0), '关注')
          Column()
            .width(1)
            .height(24)
            .backgroundColor('#E2E8F0')
          this.StatColumn(this.formatCount(this.user?.followersCount || 0), '粉丝')
          Column()
            .width(1)
            .height(24)
            .backgroundColor('#E2E8F0')
          this.StatColumn(this.formatCount(this.user?.citiesCount || 0), '城市')
          Column()
            .width(1)
            .height(24)
            .backgroundColor('#E2E8F0')
          this.StatColumn(`${this.user?.countriesCount || 0}`, '国家')
        }
        .width('100%')
        .padding({ top: 20, bottom: 16 })
        .justifyContent(FlexAlign.SpaceEvenly)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
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
    Row({ space: 12 }) {
      // 关注按钮
      Button(this.isFollowing ? '已关注' : '+ 关注')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isFollowing ? '#64748B' : '#FFFFFF')
        .backgroundColor(this.isFollowing ? '#F1F5F9' : '#38BDF8')
        .borderRadius(24)
        .height(44)
        .layoutWeight(1)
        .onClick(() => this.toggleFollow())

      // 私信按钮
      Button('💬 私信')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#475569')
        .backgroundColor('#F1F5F9')
        .borderRadius(24)
        .height(44)
        .layoutWeight(1)
        .onClick(() => this.sendMessage())
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 16 })
  }

  @Builder
  ContentTabs() {
    Row() {
      this.TabButton('作品', 0)
      this.TabButton('喜欢', 1)
    }
    .width('100%')
    .padding({ left: 20, right: 20 })
    .border({ width: { bottom: 1 }, color: '#F1F5F9' })
  }

  @Builder
  TabButton(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentTab === index ? '#0EA5E9' : '#94A3B8')

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
      if (this.userPosts.length === 0) {
        Column() {
          Text('📭')
            .fontSize(48)
          Text('暂无作品')
            .fontSize(14)
            .fontColor('#94A3B8')
            .margin({ top: 12 })
        }
        .width('100%')
        .padding({ top: 60 })
        .alignItems(HorizontalAlign.Center)
      } else {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.userPosts, (post: Post, index: number) => {
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

              // 底部信息
              Row() {
                Text('❤️')
                  .fontSize(10)
                Text(`${this.formatCount(post.likeCount)}`)
                  .fontSize(10)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 2 })
              }
              .padding({ left: 6, right: 6, top: 3, bottom: 3 })
              .backgroundColor('rgba(0,0,0,0.4)')
              .borderRadius(8)
              .position({ x: 6, y: '85%' })
            }
            .width('33.33%')
            .aspectRatio(1)
            .padding(0.5)
            .onClick(() => this.navigateToPostDetail(post))
          })
        }
      }
    }
    .width('100%')
    .padding(1)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  MoreMenuOverlay() {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.4)')
        .onClick(() => {
          this.showMoreMenu = false;
        })
    }
    .width('100%')
    .height('100%')
    .position({ x: 0, y: 0 })

    // 菜单面板
    Column() {
      this.MenuItem('⚠️', this.isBlocked ? '取消拉黑' : '拉黑该用户', () => this.toggleBlock())
      Divider().strokeWidth(0.5).color('#F1F5F9')
      this.MenuItem('🚫', '举报', () => {
        this.showMoreMenu = false;
      })
      Divider().strokeWidth(0.5).color('#F1F5F9')
      this.MenuItem('🔗', '复制主页链接', () => {
        this.showMoreMenu = false;
      })

      // 取消按钮
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
    .padding({ left: 16, right: 16, bottom: 34 })
    .position({ x: 0, y: '100%' })
    .translate({ y: -200 })
  }

  @Builder
  MenuItem(icon: string, title: string, action: () => void) {
    Row() {
      Text(icon)
        .fontSize(18)
      Text(title)
        .fontSize(15)
        .fontColor('#1E293B')
        .margin({ left: 12 })
    }
    .width('100%')
    .height(52)
    .padding({ left: 20 })
    .alignItems(VerticalAlign.Center)
    .backgroundColor('#FFFFFF')
    .onClick(action)
  }

  private getColor(index: number): string {
    const colors = ['#BAE6FD', '#E0F2FE', '#A5F3FC', '#CFFAFE', '#BAE6FD', '#F0F9FF', '#E0F2FE', '#A5F3FC'];
    return colors[index % colors.length];
  }

  private getColorEnd(index: number): string {
    const colors = ['#0EA5E9', '#0284C7', '#06B6D4', '#0891B2', '#38BDF8', '#0369A1', '#0EA5E9', '#0891B2'];
    return colors[index % colors.length];
  }
}
