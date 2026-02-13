/**
 * 城市详情页 - 抽屉式背景图 + 悬浮Tab栏
 */

import { router } from '@kit.ArkUI';
import { Post, PostComment } from '../../models/Post';
import { mockPosts } from '../../services/MockData';

// ==================== 数据接口 ====================

interface CityTabItem {
  title: string;
}

interface CityInfo {
  name: string;
  country: string;
  region: string;
  description: string;
  temperature: string;
  weather: string;
  bestSeason: string;
  population: string;
  area: string;
  timezone: string;
  language: string;
  currency: string;
  visitedCount: number;
}

interface AttractionItem {
  icon: string;
  name: string;
  rating: string;
  desc: string;
}

interface FoodItem {
  icon: string;
  name: string;
  desc: string;
}

interface CityBasicInfo {
  label: string;
  value: string;
  icon: string;
}

// ==================== Mock 数据 ====================

const MOCK_CITY_INFO: CityInfo = {
  name: '巴黎',
  country: '法国',
  region: '法兰西岛大区',
  description: '巴黎是法国的首都和最大城市，也是世界上最重要的文化和商业中心之一。这座"光之城"以其艺术、时尚、美食和浪漫氛围闻名于世。从埃菲尔铁塔到卢浮宫，从塞纳河畔到香榭丽舍大道，巴黎的每一个角落都散发着独特的魅力。',
  temperature: '12°C',
  weather: '多云',
  bestSeason: '4月 - 10月',
  population: '1,102万',
  area: '105.4 km²',
  timezone: 'UTC+1',
  language: '法语',
  currency: '欧元 (€)',
  visitedCount: 128,
};

const MOCK_BASIC_INFO: CityBasicInfo[] = [
  { icon: '👥', label: '人口', value: MOCK_CITY_INFO.population },
  { icon: '📐', label: '面积', value: MOCK_CITY_INFO.area },
  { icon: '🕐', label: '时区', value: MOCK_CITY_INFO.timezone },
  { icon: '🗣️', label: '语言', value: MOCK_CITY_INFO.language },
  { icon: '💰', label: '货币', value: MOCK_CITY_INFO.currency },
  { icon: '🌡️', label: '当前天气', value: `${MOCK_CITY_INFO.temperature} ${MOCK_CITY_INFO.weather}` },
];

const MOCK_ATTRACTIONS: AttractionItem[] = [
  { icon: '🗼', name: '埃菲尔铁塔', rating: '4.8', desc: '巴黎地标，登顶可俯瞰全城' },
  { icon: '🖼️', name: '卢浮宫', rating: '4.9', desc: '世界最大博物馆，蒙娜丽莎所在地' },
  { icon: '⛪', name: '巴黎圣母院', rating: '4.7', desc: '哥特式建筑杰作，正在修复中' },
  { icon: '🏛️', name: '凯旋门', rating: '4.6', desc: '拿破仑下令建造的标志性拱门' },
  { icon: '🎨', name: '奥赛博物馆', rating: '4.8', desc: '印象派艺术的殿堂' },
  { icon: '🌳', name: '卢森堡公园', rating: '4.5', desc: '巴黎人最爱的城市花园' },
];

const MOCK_FOODS: FoodItem[] = [
  { icon: '🥐', name: '可颂面包', desc: '法式经典早餐，酥脆可口' },
  { icon: '🐌', name: '法式蜗牛', desc: '蒜香黄油烤制，法国国菜' },
  { icon: '🧀', name: '奶酪拼盘', desc: '数百种奶酪，搭配红酒绝配' },
  { icon: '🍷', name: '波尔多红酒', desc: '世界顶级葡萄酒产区' },
  { icon: '🍰', name: '马卡龙', desc: '巴黎甜点之王，色彩缤纷' },
  { icon: '🥖', name: '法棍面包', desc: '法国人的灵魂主食' },
];

// ==================== 页面组件 ====================

@Entry
@Component
struct CityDetailPage {
  @State cityName: string = '巴黎';
  @State cityId: string = '';
  @State currentTab: number = 0;
  @State scrollY: number = 0;
  @State imageScale: number = 1.3;
  @State communitySubTab: number = 1;
  @State cityPosts: Post[] = [];

  private scroller: Scroller = new Scroller();

  private tabs: CityTabItem[] = [
    { title: '城市' },
    { title: '社区' },
    { title: '驴友' },
    { title: '攻略' },
  ];

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      if (params['cityName']) {
        this.cityName = params['cityName'] as string;
      }
      if (params['cityId']) {
        this.cityId = params['cityId'] as string;
      }
    }
    this.loadCityPosts();
  }

  private loadCityPosts(): void {
    this.cityPosts = mockPosts.filter((post: Post) => {
      return post.location !== undefined && post.location.cityName === this.cityName;
    });
    if (this.cityPosts.length === 0) {
      this.cityPosts = mockPosts;
    }
  }

  private updateImageEffect(): void {
    if (this.scrollY <= 0) {
      this.imageScale = 1.3 + Math.abs(this.scrollY) / 800;
      if (this.imageScale > 1.4) {
        this.imageScale = 1.4;
      }
    } else {
      this.imageScale = 1.3 - this.scrollY / 1500;
      if (this.imageScale < 1.0) {
        this.imageScale = 1.0;
      }
    }
  }

  private onPostLike(post: Post): void {
    const index = this.cityPosts.findIndex((p: Post) => p.id === post.id);
    if (index !== -1) {
      const source = this.cityPosts[index];
      const updated: Post = {
        id: source.id,
        author: source.author,
        content: source.content,
        images: source.images,
        video: source.video,
        location: source.location,
        tags: source.tags,
        likeCount: source.likeCount + (source.isLiked ? -1 : 1),
        commentCount: source.commentCount,
        shareCount: source.shareCount,
        collectCount: source.collectCount,
        isLiked: !source.isLiked,
        isCollected: source.isCollected,
        createdAt: source.createdAt,
        type: source.type,
        hotComments: source.hotComments,
      };
      this.cityPosts[index] = updated;
    }
  }

  private navigateToPostDetail(post: Post): void {
    router.pushUrl({
      url: 'pages/community/PostDetailPage',
      params: { postId: post.id }
    }).catch(() => {});
  }

  private navigateToUser(userId: string): void {
    router.pushUrl({
      url: 'pages/community/UserProfilePage',
      params: { userId: userId }
    }).catch(() => {});
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
    if (count >= 10000) return `${(count / 10000).toFixed(1)}万`;
    if (count >= 1000) return `${(count / 1000).toFixed(1)}k`;
    return `${count}`;
  }

  private getImageColor(index: number): string {
    const colors: string[] = ['#E0F2FE', '#CFFAFE', '#BAE6FD', '#A5F3FC', '#BAE6FD', '#D1D5DB'];
    return colors[index % colors.length];
  }

  private getImageColorEnd(index: number): string {
    const colors: string[] = ['#7DD3FC', '#4F46E5', '#38BDF8', '#6366F1', '#38BDF8', '#6B7280'];
    return colors[index % colors.length];
  }

  // ==================== 主布局 ====================

  build() {
    Stack() {
      this.BackgroundImage()

      Scroll(this.scroller) {
        Column() {
          Column()
            .width('100%')
            .height('80%')

          Column() {
            Column()
              .width(40)
              .height(4)
              .borderRadius(2)
              .backgroundColor('rgba(0,0,0,0.15)')
              .margin({ top: 12, bottom: 16 })

            this.CityHeader()

            if (this.currentTab === 0) {
              this.CityInfoContent()
            } else if (this.currentTab === 1) {
              this.CommunityContent()
            } else if (this.currentTab === 2) {
              this.TravelersContent()
            } else {
              this.GuideContent()
            }
          }
          .width('100%')
          .constraintSize({ minHeight: '100%' })
          .backgroundColor('#F8FAFC')
          .borderRadius({ topLeft: 24, topRight: 24 })
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.1)', offsetY: -4 })
          .padding({ bottom: 80 })
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .onScroll(() => {
        const offset = this.scroller.currentOffset();
        this.scrollY = offset.yOffset;
        this.updateImageEffect();
      })

      this.FloatingHeader()
      this.FloatingTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  // ==================== 背景图 ====================

  @Builder
  BackgroundImage() {
    Stack() {
      Image($r('app.media.paris'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .scale({ x: this.imageScale, y: this.imageScale })
        .animation({
          duration: 80,
          curve: Curve.EaseOut
        })

      Column()
        .width('100%')
        .height('25%')
        .linearGradient({
          direction: GradientDirection.Top,
          colors: [
            ['rgba(248,250,252,0.95)', 0],
            ['rgba(248,250,252,0.6)', 0.4],
            ['rgba(248,250,252,0.1)', 0.8],
            ['transparent', 1]
          ]
        })
        .position({ x: 0, y: '75%' })
    }
    .width('100%')
    .height('100%')
    .clip(true)
  }

  // ==================== 悬浮顶部按钮 ====================

  @Builder
  FloatingHeader() {
    Row() {
      Column() {
        Text('←')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1E293B')
      }
      .width(38)
      .height(38)
      .borderRadius(19)
      .backgroundColor('rgba(255,255,255,0.9)')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
      .onClick(() => { router.back(); })

      Blank()

      Column() {
        Text('⋯')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
      }
      .width(38)
      .height(38)
      .borderRadius(19)
      .backgroundColor('rgba(255,255,255,0.9)')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 40 })
    .position({ x: 0, y: 0 })
  }

  // ==================== 城市名称头部 ====================

  @Builder
  CityHeader() {
    Row() {
      Column() {
        Text(this.cityName)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        Row() {
          Text('📍')
            .fontSize(13)
          Text(`${MOCK_CITY_INFO.country} · ${MOCK_CITY_INFO.region}`)
            .fontSize(13)
            .fontColor('#64748B')
            .margin({ left: 4 })
        }
        .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Column() {
        Text(MOCK_CITY_INFO.temperature)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#38BDF8')
        Text(MOCK_CITY_INFO.weather)
          .fontSize(11)
          .fontColor('#94A3B8')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 16 })

    Row({ space: 8 }) {
      this.StatTag('👥', `${MOCK_CITY_INFO.visitedCount}人来过`)
      this.StatTag('🌡️', MOCK_CITY_INFO.temperature)
      this.StatTag('📍', '9,823km')
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 20 })
  }

  @Builder
  StatTag(icon: string, text: string) {
    Row() {
      Text(icon)
        .fontSize(12)
      Text(text)
        .fontSize(12)
        .fontColor('#475569')
        .margin({ left: 4 })
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor('#F1F5F9')
    .borderRadius(16)
  }

  // ==================== 悬浮Tab栏 ====================

  @Builder
  FloatingTabBar() {
    Column() {
      Row() {
        ForEach(this.tabs, (tab: CityTabItem, index: number) => {
          Column() {
            Text(tab.title)
              .fontSize(14)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.currentTab === index ? '#38BDF8' : '#64748B')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height('100%')
          .onClick(() => { this.currentTab = index; })
        })
      }
      .width('100%')
      .height(50)
      .padding({ left: 4, right: 4 })
    }
    .width('88%')
    .backgroundBlurStyle(BlurStyle.Regular)
    .backgroundColor('rgba(255, 255, 255, 0.45)')
    .borderRadius(25)
    .border({ width: 0.5, color: 'rgba(255, 255, 255, 0.6)' })
    .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.08)', offsetY: 4 })
    .position({ x: '6%', y: '100%' })
    .translate({ y: -45 })
  }

  // ==================== 城市信息 Tab ====================

  @Builder
  CityInfoContent() {
    Column({ space: 16 }) {
      Column() {
        Row() {
          Text('🏙️').fontSize(18)
          Text('城市简介').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 })
        }.width('100%').margin({ bottom: 14 })
        Text(MOCK_CITY_INFO.description).fontSize(14).fontColor('#475569').lineHeight(24)
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Row() {
          Text('📋').fontSize(18)
          Text('基本信息').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 })
        }.width('100%').margin({ bottom: 14 })
        ForEach(MOCK_BASIC_INFO, (info: CityBasicInfo, index: number) => {
          Row() {
            Row() {
              Text(info.icon).fontSize(16)
              Text(info.label).fontSize(14).fontColor('#64748B').margin({ left: 8 })
            }
            Blank()
            Text(info.value).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E293B')
          }.width('100%').padding({ top: 12, bottom: 12 })
          .border({ width: { bottom: index < MOCK_BASIC_INFO.length - 1 ? 1 : 0 }, color: '#F1F5F9' })
        })
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Row() {
          Text('📅').fontSize(18)
          Text('最佳旅行季节').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 })
        }.width('100%').margin({ bottom: 14 })
        Column() {
          Text('🌸').fontSize(32)
          Text(MOCK_CITY_INFO.bestSeason).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ top: 8 })
          Text('春夏两季气候宜人，适合户外观光').fontSize(12).fontColor('#64748B').margin({ top: 4 })
        }.alignItems(HorizontalAlign.Center).width('100%').padding({ top: 8, bottom: 8 })
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Row() {
          Text('🗺️').fontSize(18)
          Text('著名景点').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 })
        }.width('100%').margin({ bottom: 14 })
        Column({ space: 10 }) {
          ForEach(MOCK_ATTRACTIONS, (item: AttractionItem) => {
            Row() {
              Column() { Text(item.icon).fontSize(28) }
              .width(56).height(56).backgroundColor('#F1F5F9').borderRadius(12)
              .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
              Column() {
                Row() {
                  Text(item.name).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1E293B')
                  Blank()
                  Row() {
                    Text('⭐').fontSize(11)
                    Text(item.rating).fontSize(12).fontWeight(FontWeight.Medium).fontColor('#F59E0B').margin({ left: 2 })
                  }
                }.width('100%')
                Text(item.desc).fontSize(12).fontColor('#94A3B8').margin({ top: 4 })
                  .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: 12 })
            }.width('100%').padding(10).backgroundColor('#FAFBFC').borderRadius(12)
          })
        }
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Row() {
          Text('🍽️').fontSize(18)
          Text('美食推荐').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 })
        }.width('100%').margin({ bottom: 14 })
        Scroll() {
          Row({ space: 12 }) {
            ForEach(MOCK_FOODS, (food: FoodItem) => {
              Column() {
                Text(food.icon).fontSize(36).margin({ bottom: 8 })
                Text(food.name).fontSize(13).fontWeight(FontWeight.Medium).fontColor('#1E293B')
                Text(food.desc).fontSize(11).fontColor('#94A3B8').margin({ top: 4 })
                  .maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis }).textAlign(TextAlign.Center)
              }.width(120).padding(12).backgroundColor('#FAFBFC').borderRadius(12).alignItems(HorizontalAlign.Center)
            })
          }
        }.scrollable(ScrollDirection.Horizontal).scrollBar(BarState.Off)
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column().height(20)
    }.width('100%').padding({ left: 16, right: 16 })
  }

  // ==================== 社区 Tab ====================

  @Builder
  CommunityContent() {
    Column() {
      this.CommunitySubTabBar()

      if (this.communitySubTab === 1) {
        this.CommunityPostList()
      } else {
        this.CommunityVideoList()
      }
    }
    .width('100%')
  }

  @Builder
  CommunitySubTabBar() {
    Row() {
      ForEach(['视频', '社区'], (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(14)
            .fontWeight(this.communitySubTab === index ? FontWeight.Bold : FontWeight.Medium)
            .fontColor(this.communitySubTab === index ? '#0284C7' : '#94A3B8')

          if (this.communitySubTab === index) {
            Column()
              .width(18)
              .height(3)
              .borderRadius(1.5)
              .backgroundColor('#38BDF8')
              .margin({ top: 6 })
          } else {
            Column().height(9)
          }
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 12, bottom: 4 })
        .onClick(() => { this.communitySubTab = index; })
      })
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, bottom: 12 })
    .shadow({ radius: 4, color: 'rgba(0,0,0,0.03)', offsetY: 1 })
  }

  @Builder
  CommunityPostList() {
    Column() {
      if (this.cityPosts.length > 0) {
        ForEach(this.cityPosts, (post: Post) => {
          Row() {
            Column() {
              Text(post.author.nickname.charAt(0))
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
            }
            .width(40)
            .height(40)
            .borderRadius(20)
            .linearGradient({
              direction: GradientDirection.RightBottom,
              colors: [['#7DD3FC', 0], ['#0EA5E9', 1]]
            })
            .justifyContent(FlexAlign.Center)
            .margin({ right: 12 })
            .onClick(() => { this.navigateToUser(post.author.id); })

            Column() {
              Row() {
                Column() {
                  Text(post.author.nickname)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1E293B')
                  Text(post.author.levelTitle || '')
                    .fontSize(11)
                    .fontColor('#94A3B8')
                    .margin({ top: 1 })
                }
                .alignItems(HorizontalAlign.Start)
                .onClick(() => { this.navigateToUser(post.author.id); })

                Blank()

                Text('···')
                  .fontSize(18)
                  .fontColor('#C0C0C0')
              }
              .width('100%')

              Text(post.content)
                .fontSize(14)
                .fontColor('#333333')
                .lineHeight(22)
                .margin({ top: 8 })
                .width('100%')
                .maxLines(4)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .onClick(() => { this.navigateToPostDetail(post); })

              if (post.images && post.images.length > 0) {
                this.CityPostImageGrid(post)
              }

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
              .width('100%')
              .margin({ top: 10 })

              if (post.hotComments && post.hotComments.length > 0) {
                Column() {
                  ForEach(post.hotComments.slice(0, 2), (comment: PostComment) => {
                    Row() {
                      Text(comment.userNickname)
                        .fontSize(12)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#475569')
                      Text(`：${comment.content}`)
                        .fontSize(12)
                        .fontColor('#64748B')
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .layoutWeight(1)
                    }
                    .width('100%')
                    .margin({ bottom: 4 })
                  })

                  if (post.commentCount > 2) {
                    Text(`查看全部 ${post.commentCount} 条评论`)
                      .fontSize(11)
                      .fontColor('#94A3B8')
                      .margin({ top: 2 })
                      .onClick(() => { this.navigateToPostDetail(post); })
                  }
                }
                .width('100%')
                .padding({ left: 10, right: 10, top: 8, bottom: 8 })
                .backgroundColor('#F8FAFC')
                .borderRadius(8)
                .margin({ top: 8 })
                .onClick(() => { this.navigateToPostDetail(post); })
              }

              Row() {
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
                .onClick(() => { this.onPostLike(post); })

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
                .onClick(() => { this.navigateToPostDetail(post); })

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
              }
              .width('100%')
              .margin({ top: 10 })
              .justifyContent(FlexAlign.SpaceAround)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(16)
          .alignItems(VerticalAlign.Top)
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
          .margin({ bottom: 12 })
        })
      } else {
        Column() {
          Text('📭').fontSize(48).margin({ bottom: 12 })
          Text('该城市暂无动态').fontSize(15).fontColor('#94A3B8')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
      }

      Column().height(20)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  // ==================== 视频列表 ====================

  @Builder
  CommunityVideoList() {
    Column({ space: 12 }) {
      this.VideoCard('🗼', '巴黎铁塔的日落', '旅行摄影师', '3.1w', '2341')
      this.VideoCard('🌃', '巴黎塞纳河夜景', '夜景达人', '1.8w', '956')
      this.VideoCard('🥐', '巴黎美食探店', '美食家大宝', '2.5w', '1876')
      this.VideoCard('🎨', '卢浮宫一日游', '艺术旅人', '1.2w', '654')
      Column().height(20)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  VideoCard(emoji: string, title: string, author: string, views: string, likes: string) {
    Column() {
      Stack() {
        Column()
          .width('100%')
          .height(180)
          .borderRadius({ topLeft: 16, topRight: 16 })
          .linearGradient({
            direction: GradientDirection.RightBottom,
            colors: [['#E0F2FE', 0], ['#38BDF8', 1]]
          })

        Text(emoji)
          .fontSize(56)

        Column() {
          Text('▶')
            .fontSize(22)
            .fontColor('#FFFFFF')
        }
        .width(52)
        .height(52)
        .backgroundColor('rgba(0,0,0,0.4)')
        .borderRadius(26)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Row() {
          Text('▶').fontSize(10).fontColor('#FFFFFF')
          Text(views).fontSize(11).fontColor('#FFFFFF').margin({ left: 4 })
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('rgba(0,0,0,0.5)')
        .borderRadius(10)
        .position({ x: 12, y: 148 })
      }

      Column() {
        Text(title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1E293B')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Row() {
          Row() {
            Text('👤').fontSize(12)
            Text(author).fontSize(12).fontColor('#94A3B8').margin({ left: 4 })
          }
          Blank()
          Row() {
            Text('❤️').fontSize(12)
            Text(likes).fontSize(12).fontColor('#94A3B8').margin({ left: 4 })
          }
        }
        .width('100%')
        .margin({ top: 8 })
      }
      .width('100%')
      .padding(14)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
  }

  // ==================== 图片网格 ====================

  @Builder
  CityPostImageGrid(post: Post) {
    Column() {
      if (post.images.length === 1) {
        this.CityImageItem(post.images, 0, 180, 180)
      } else if (post.images.length === 2) {
        Row({ space: 4 }) {
          this.CityImageItem(post.images, 0, 120, 120)
          this.CityImageItem(post.images, 1, 120, 120)
        }
      } else if (post.images.length === 3) {
        Row({ space: 4 }) {
          this.CityImageItem(post.images, 0, 78, 78)
          this.CityImageItem(post.images, 1, 78, 78)
          this.CityImageItem(post.images, 2, 78, 78)
        }
      } else {
        Column({ space: 4 }) {
          Row({ space: 4 }) {
            this.CityImageItem(post.images, 0, 78, 78)
            this.CityImageItem(post.images, 1, 78, 78)
            this.CityImageItem(post.images, 2, 78, 78)
          }
          if (post.images.length > 3) {
            Row({ space: 4 }) {
              this.CityImageItem(post.images, 3, 78, 78)
              if (post.images.length > 4) {
                this.CityImageItem(post.images, 4, 78, 78)
              }
              if (post.images.length > 5) {
                this.CityImageItem(post.images, 5, 78, 78)
              }
            }
          }
        }
      }
    }
    .margin({ top: 10 })
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  CityImageItem(images: string[], index: number, w: number, h: number) {
    Stack() {
      Image(images[index])
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
    }
    .width(w)
    .height(h)
    .backgroundColor('#E8E8E8')
    .borderRadius(6)
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [
        [this.getImageColor(index), 0],
        [this.getImageColorEnd(index), 1]
      ]
    })
  }

  // ==================== 驴友 Tab ====================

  @Builder
  TravelersContent() {
    Column({ space: 16 }) {
      Column() {
        Row() {
          Column()
            .width(8).height(8).borderRadius(4).backgroundColor('#22C55E')
          Text('在此处').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 })
          Text('(3人)').fontSize(13).fontColor('#94A3B8').margin({ left: 4 })
        }.width('100%').margin({ bottom: 14 })

        ForEach([1, 2, 3], (item: number) => {
          Row() {
            Column() { Text('🧑‍✈️').fontSize(18) }
            .width(44).height(44).backgroundColor('#DBEAFE').borderRadius(22)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text(`旅行者 ${item}`).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E293B')
              Text('正在探索埃菲尔铁塔附近').fontSize(12).fontColor('#94A3B8').margin({ top: 2 })
            }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)

            Row() {
              Text('打招呼').fontSize(12).fontWeight(FontWeight.Medium).fontColor('#38BDF8')
            }.padding({ left: 14, right: 14, top: 8, bottom: 8 }).backgroundColor('#EFF6FF').borderRadius(16)
          }.width('100%').padding(12).backgroundColor('#FAFBFC').borderRadius(12).margin({ bottom: 8 })
        })
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Row() {
          Text('📅').fontSize(16)
          Text('计划中').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 })
          Text('(12人)').fontSize(13).fontColor('#94A3B8').margin({ left: 4 })
        }.width('100%').margin({ bottom: 14 })

        ForEach([1, 2], (item: number) => {
          Row() {
            Column() { Text('🧳').fontSize(18) }
            .width(44).height(44).backgroundColor('#FEF3C7').borderRadius(22)
            .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)

            Column() {
              Text(`计划者 ${item}`).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E293B')
              Text('计划 3月15日 出发').fontSize(12).fontColor('#94A3B8').margin({ top: 2 })
            }.alignItems(HorizontalAlign.Start).margin({ left: 12 }).layoutWeight(1)

            Row() {
              Text('结伴').fontSize(12).fontWeight(FontWeight.Medium).fontColor('#F59E0B')
            }.padding({ left: 14, right: 14, top: 8, bottom: 8 }).backgroundColor('#FFFBEB').borderRadius(16)
          }.width('100%').padding(12).backgroundColor('#FAFBFC').borderRadius(12).margin({ bottom: 8 })
        })
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column().height(20)
    }.width('100%').padding({ left: 16, right: 16 })
  }

  // ==================== 攻略 Tab ====================

  @Builder
  GuideContent() {
    Column({ space: 16 }) {
      Column() {
        Text('📝').fontSize(48).margin({ bottom: 12 })
        Text('攻略功能开发中').fontSize(15).fontColor('#94A3B8')
        Text('敬请期待').fontSize(13).fontColor('#CBD5E1').margin({ top: 4 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column().height(20)
    }.width('100%').padding({ left: 16, right: 16 })
  }
}