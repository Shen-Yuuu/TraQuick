/**
 * 城市详情页 - 对接真实 API (严格模式)
 */

import { router, promptAction } from '@kit.ArkUI';
import { Post, PostAuthor, PostLocation, PostComment } from '../../models/Post';
import { formatTime, formatCount } from '../../utils/Formatter';
import { ApiService, ApiCity, PaginatedPosts, ApiPost, LikeResult, CollectResult } from '../../services/ApiService';

// ====== 数据类定义 ======
class CityTabItem { title: string = ''; }
class AttractionItem { icon: string = ''; name: string = ''; rating: string = ''; desc: string = ''; }
class FoodItem { icon: string = ''; name: string = ''; desc: string = ''; }
class CityBasicInfo { label: string = ''; value: string = ''; icon: string = ''; }

@Entry
@Component
struct CityDetailPage {
  @State cityName: string = '';
  @State cityId: string = '';
  @State currentTab: number = 0;
  @State scrollY: number = 0;
  @State imageScale: number = 1.3;
  @State communitySubTab: number = 1;

  // 真实数据状态
  @State cityInfo: ApiCity | null = null;
  @State cityPosts: Post[] = [];
  @State isLoading: boolean = true;
  @State isCheckingIn: boolean = false;

  private scroller: Scroller = new Scroller();
  private tabs: CityTabItem[] = [{ title: '城市' }, { title: '社区' }, { title: '驴友' }, { title: '攻略' }];

  // Mock 静态数据（用于展示未入库的风景/美食等次要信息）
  private mockBasicInfo: CityBasicInfo[] = [];
  private mockAttractions: AttractionItem[] = [
    { icon: '🗼', name: '地标建筑', rating: '4.8', desc: '不容错过的城市标志' },
    { icon: '🖼️', name: '博物馆', rating: '4.9', desc: '感受深厚的历史底蕴' },
    { icon: '🌳', name: '城市公园', rating: '4.5', desc: '本地人最爱的休闲去处' },
  ];
  private mockFoods: FoodItem[] = [
    { icon: '🍜', name: '特色小吃', desc: '正宗地道，回味无穷' },
    { icon: '🍰', name: '招牌甜点', desc: '网红打卡必备' },
    { icon: '☕', name: '手冲咖啡', desc: '享受惬意的午后时光' },
  ];

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params) {
      if (params['cityId']) this.cityId = params['cityId'] as string;
      if (params['cityName']) this.cityName = params['cityName'] as string;
    }
    this.loadData();
  }

  private async loadData(): Promise<void> {
    this.isLoading = true;
    try {
      // 1. 获取城市详情
      if (this.cityId) {
        this.cityInfo = await ApiService.getCityDetail(this.cityId);
        this.cityName = this.cityInfo.name;

        // 组装 Mock Basic Info
        this.mockBasicInfo = [
          { icon: '🗣️', label: '国家', value: this.cityInfo.country },
          { icon: '📍', label: '省份/州', value: this.cityInfo.province || '暂无' },
          { icon: '🔢', label: '国家代码', value: this.cityInfo.countryCode },
        ];
      }

      // 2. 获取该城市的帖子
      // ApiService.getPosts(page, limit, orderBy, authorId, cityId, tag)
      const postsData: PaginatedPosts = await ApiService.getPosts(1, 20, 'hot', '', this.cityId, '');
      const newPosts: Post[] = [];
      for (const apiPost of postsData.items) {
        newPosts.push(this.convertApiPost(apiPost));
      }
      this.cityPosts = newPosts;

    } catch (error) {
      console.error('[CityDetail] 加载失败:', (error as Error).message);
      promptAction.showToast({ message: '加载城市信息失败' });
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 签到打卡
   */
  private async checkIn(): Promise<void> {
    if (!this.cityId || !this.cityInfo || this.isCheckingIn) return;

    if (this.cityInfo.isUnlocked) {
      promptAction.showToast({ message: '您已经点亮过该城市啦！' });
      return;
    }

    this.isCheckingIn = true;
    try {
      const res = await ApiService.checkInCity(this.cityId);
      this.cityInfo.isUnlocked = true;
      this.cityInfo.visitorsCount += 1;
      promptAction.showToast({ message: res.message });

      // 通知个人主页刷新（点亮城市数增加了）
      const trigger = AppStorage.get<number>('communityRefreshTrigger') || 0;
      AppStorage.setOrCreate('communityRefreshTrigger', trigger + 1);

    } catch (error) {
      console.error('[CityDetail] 打卡失败:', (error as Error).message);
      promptAction.showToast({ message: (error as Error).message || '打卡失败' });
    } finally {
      this.isCheckingIn = false;
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
      post.location = {
        cityId: apiPost.city.id,
        cityName: apiPost.city.name,
        address: apiPost.address || undefined,
      };
    }
    return post;
  }

  private updateImageEffect(): void {
    if (this.scrollY <= 0) {
      this.imageScale = 1.3 + Math.abs(this.scrollY) / 800;
      if (this.imageScale > 1.4) this.imageScale = 1.4;
    } else {
      this.imageScale = 1.3 - this.scrollY / 1500;
      if (this.imageScale < 1.0) this.imageScale = 1.0;
    }
  }

  // ============== 点赞 ==============
  private async onPostLike(post: Post): Promise<void> {
    const index = this.cityPosts.findIndex(p => p.id === post.id);
    if (index === -1) return;

    const originalPost = this.cityPosts[index];
    const wasLiked = originalPost.isLiked;

    const updatedPost = this.clonePost(originalPost);
    updatedPost.isLiked = !wasLiked;
    updatedPost.likeCount = Math.max(0, originalPost.likeCount + (updatedPost.isLiked ? 1 : -1));

    const newList: Post[] = [];
    for (let i = 0; i < this.cityPosts.length; i++) {
      newList.push(i === index ? updatedPost : this.cityPosts[i]);
    }
    this.cityPosts = newList;

    try {
      let result: LikeResult;
      if (wasLiked) result = await ApiService.unlikePost(post.id);
      else result = await ApiService.likePost(post.id);

      const syncPost = this.clonePost(updatedPost);
      syncPost.likeCount = result.likeCount;
      const syncList: Post[] = [];
      for (let i = 0; i < this.cityPosts.length; i++) syncList.push(i === index ? syncPost : this.cityPosts[i]);
      this.cityPosts = syncList;
    } catch (error) {
      const rollbackList: Post[] = [];
      for (let i = 0; i < this.cityPosts.length; i++) rollbackList.push(i === index ? originalPost : this.cityPosts[i]);
      this.cityPosts = rollbackList;
    }
  }

  private clonePost(source: Post): Post {
    const authorCopy: PostAuthor = { id: source.author.id, nickname: source.author.nickname, avatar: source.author.avatar, level: source.author.level, levelTitle: source.author.levelTitle };
    const cloned: Post = { id: source.id, author: authorCopy, content: source.content, images: source.images.slice(), tags: source.tags.slice(), likeCount: source.likeCount, commentCount: source.commentCount, shareCount: source.shareCount, collectCount: source.collectCount, isLiked: source.isLiked, isCollected: source.isCollected, createdAt: source.createdAt, type: source.type };
    if (source.video) cloned.video = source.video;
    if (source.location) cloned.location = { cityId: source.location.cityId, cityName: source.location.cityName, address: source.location.address };
    return cloned;
  }

  private navigateToPostDetail(post: Post): void { router.pushUrl({ url: 'pages/community/PostDetailPage', params: { postId: post.id } }).catch(()=>{}); }
  private openImagePreview(post: Post, imageIndex: number): void { router.pushUrl({ url: 'pages/community/ImagePreviewPage', params: { postId: post.id, images: post.images, imageIndex: imageIndex } }).catch(()=>{}); }
  private navigateToUser(userId: string): void { router.pushUrl({ url: 'pages/community/UserProfilePage', params: { userId: userId } }).catch(()=>{}); }

  private getImageColor(index: number): string {
    const colors: string[] = ['#E0F2FE', '#CFFAFE', '#BAE6FD', '#A5F3FC'];
    return colors[index % colors.length];
  }
  private getImageColorEnd(index: number): string {
    const colors: string[] = ['#7DD3FC', '#4F46E5', '#38BDF8', '#6366F1'];
    return colors[index % colors.length];
  }

  // ==================== 主布局 ====================

  build() {
    Stack() {
      this.BackgroundImage()

      Scroll(this.scroller) {
        Column() {
          Column().width('100%').height('80%')

          Column() {
            Column().width(40).height(4).borderRadius(2).backgroundColor('rgba(0,0,0,0.15)').margin({ top: 12, bottom: 16 })

            this.CityHeader()

            if (this.isLoading) {
              LoadingProgress().width(40).height(40).color('#38BDF8').margin({ top: 40 })
            } else {
              if (this.currentTab === 0) this.CityInfoContent()
              else if (this.currentTab === 1) this.CommunityContent()
              else if (this.currentTab === 2) this.TravelersContent()
              else this.GuideContent()
            }
          }
          .width('100%').constraintSize({ minHeight: '100%' }).backgroundColor('#F8FAFC').borderRadius({ topLeft: 24, topRight: 24 })
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.1)', offsetY: -4 }).padding({ bottom: 80 })
        }
        .width('100%')
      }
      .scrollable(ScrollDirection.Vertical).scrollBar(BarState.Off).edgeEffect(EdgeEffect.Spring)
      .onScroll(() => { this.scrollY = this.scroller.currentOffset().yOffset; this.updateImageEffect(); })

      this.FloatingHeader()
      this.FloatingTabBar()
    }
    .width('100%').height('100%').backgroundColor('#000000')
  }

  @Builder BackgroundImage() {
    Stack() {
      if (this.cityInfo && this.cityInfo.coverImage) {
        Image(this.cityInfo.coverImage)
          .width('100%').height('100%').objectFit(ImageFit.Cover).scale({ x: this.imageScale, y: this.imageScale })
      } else {
        Image($r('app.media.paris')) // 本地兜底
          .width('100%').height('100%').objectFit(ImageFit.Cover).scale({ x: this.imageScale, y: this.imageScale })
      }

      Column().width('100%').height('25%').linearGradient({ direction: GradientDirection.Top, colors: [['rgba(248,250,252,0.95)', 0], ['rgba(248,250,252,0.1)', 0.8], ['transparent', 1]] }).position({ x: 0, y: '75%' })
    }.width('100%').height('100%').clip(true)
  }

  @Builder FloatingHeader() {
    Row() {
      Column() { Text('←').fontSize(22).fontWeight(FontWeight.Medium).fontColor('#1E293B') }
      .width(38).height(38).borderRadius(19).backgroundColor('rgba(255,255,255,0.9)').justifyContent(FlexAlign.Center).shadow({ radius: 12, color: 'rgba(0,0,0,0.1)', offsetY: 2 }).onClick(() => { router.back(); })

      Blank()
    }.width('100%').padding({ left: 20, right: 20, top: 40 }).position({ x: 0, y: 0 })
  }

  @Builder CityHeader() {
    Row() {
      Column() {
        Text(this.cityName).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Row() {
          Text('📍').fontSize(13)
          Text(`${this.cityInfo?.country || '探索中'} · ${this.cityInfo?.nameEn || 'City'}`).fontSize(13).fontColor('#64748B').margin({ left: 4 })
        }.margin({ top: 4 })
      }.alignItems(HorizontalAlign.Start).layoutWeight(1)

      // 点亮按钮
      Column() {
        if (this.cityInfo?.isUnlocked) {
          Text('已点亮').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#10B981').padding({ left: 16, right: 16, top: 8, bottom: 8 }).backgroundColor('#D1FAE5').borderRadius(16)
        } else {
          Row() {
            if (this.isCheckingIn) LoadingProgress().width(14).height(14).color('#FFFFFF').margin({ right: 4 })
            Text('✨ 点亮').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          }
          .padding({ left: 16, right: 16, top: 8, bottom: 8 }).backgroundColor('#38BDF8').borderRadius(16)
          .onClick(() => this.checkIn())
        }
      }.alignItems(HorizontalAlign.Center)
    }.width('100%').padding({ left: 20, right: 20, bottom: 16 })

    Row({ space: 8 }) {
      this.StatTag('👥', `${this.cityInfo?.visitorsCount || 0}人打卡`)
      this.StatTag('📝', `${this.cityInfo?.postsCount || 0}篇动态`)
    }.width('100%').padding({ left: 20, right: 20, bottom: 20 })
  }

  @Builder StatTag(icon: string, text: string) {
    Row() { Text(icon).fontSize(12); Text(text).fontSize(12).fontColor('#475569').margin({ left: 4 }) }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 }).backgroundColor('#F1F5F9').borderRadius(16)
  }

  @Builder FloatingTabBar() {
    Column() {
      Row() {
        ForEach(this.tabs, (tab: CityTabItem, index: number) => {
          Column() { Text(tab.title).fontSize(14).fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium).fontColor(this.currentTab === index ? '#38BDF8' : '#64748B') }
          .layoutWeight(1).alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center).height('100%').onClick(() => { this.currentTab = index; })
        })
      }.width('100%').height(50).padding({ left: 4, right: 4 })
    }.width('88%').backgroundBlurStyle(BlurStyle.Regular).backgroundColor('rgba(255, 255, 255, 0.45)').borderRadius(25).border({ width: 0.5, color: 'rgba(255, 255, 255, 0.6)' }).shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.08)', offsetY: 4 }).position({ x: '6%', y: '100%' }).translate({ y: -75 })
  }

  @Builder CityInfoContent() {
    Column({ space: 16 }) {
      Column() {
        Row() { Text('🏙️').fontSize(18); Text('城市简介').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 }) }.width('100%').margin({ bottom: 14 })
        Text(this.cityInfo?.description || '暂无简介').fontSize(14).fontColor('#475569').lineHeight(24)
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Row() { Text('📋').fontSize(18); Text('基本信息').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B').margin({ left: 8 }) }.width('100%').margin({ bottom: 14 })
        ForEach(this.mockBasicInfo, (info: CityBasicInfo, index: number) => {
          Row() {
            Row() { Text(info.icon).fontSize(16); Text(info.label).fontSize(14).fontColor('#64748B').margin({ left: 8 }) }
            Blank()
            Text(info.value).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E293B')
          }.width('100%').padding({ top: 12, bottom: 12 }).border({ width: { bottom: index < this.mockBasicInfo.length - 1 ? 1 : 0 }, color: '#F1F5F9' })
        })
      }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column().height(20)
    }.width('100%').padding({ left: 16, right: 16 })
  }

  @Builder CommunityContent() {
    Column() {
      if (this.cityPosts.length > 0) {
        ForEach(this.cityPosts, (post: Post) => {
          Column() {
            Row() {
              Column() { Text(post.author.nickname.charAt(0)).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF') }
              .width(40).height(40).borderRadius(20).linearGradient({ direction: GradientDirection.RightBottom, colors: [['#7DD3FC', 0], ['#0EA5E9', 1]] }).justifyContent(FlexAlign.Center).margin({ right: 12 }).onClick(() => { this.navigateToUser(post.author.id); })

              Column() {
                Text(post.author.nickname).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#1E293B')
                Text(formatTime(post.createdAt)).fontSize(11).fontColor('#94A3B8').margin({ top: 2 })
              }.alignItems(HorizontalAlign.Start).layoutWeight(1).onClick(() => { this.navigateToUser(post.author.id); })
            }.width('100%')

            Text(post.content).fontSize(14).fontColor('#333333').lineHeight(22).margin({ top: 8 }).width('100%').maxLines(4).textOverflow({ overflow: TextOverflow.Ellipsis }).onClick(() => { this.navigateToPostDetail(post); })

            if (post.images && post.images.length > 0) { this.CityPostImageGrid(post) }

            Row() {
              Row() { Text(post.isLiked ? '❤️' : '🤍').fontSize(14); if(post.likeCount>0){ Text(`${formatCount(post.likeCount)}`).fontSize(12).fontColor(post.isLiked?'#38BDF8':'#888888').margin({left:4}) } }.onClick(() => { this.onPostLike(post); })
              Row() { Text('💬').fontSize(14); if(post.commentCount>0){ Text(`${formatCount(post.commentCount)}`).fontSize(12).fontColor('#888888').margin({left:4}) } }.onClick(() => { this.navigateToPostDetail(post); })
            }.width('100%').margin({ top: 12 }).justifyContent(FlexAlign.SpaceAround)
          }.width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(16).shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 }).margin({ bottom: 12 })
        }, (post: Post) => `${post.id}_${post.isLiked}_${post.likeCount}`)
      } else {
        Column() { Text('📭').fontSize(48).margin({ bottom: 12 }); Text('该城市暂无动态').fontSize(15).fontColor('#94A3B8') }.width('100%').height(200).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).backgroundColor('#FFFFFF').borderRadius(16)
      }
      Column().height(20)
    }.width('100%').padding({ left: 16, right: 16 })
  }

  @Builder CityPostImageGrid(post: Post) {
    Column() {
      if (post.images.length === 1) { this.CityImageItem(post, 0, 180, 180) }
      else if (post.images.length === 2) { Row({ space: 4 }) { this.CityImageItem(post, 0, 120, 120); this.CityImageItem(post, 1, 120, 120) } }
      else { Row({ space: 4 }) { this.CityImageItem(post, 0, 80, 80); this.CityImageItem(post, 1, 80, 80); this.CityImageItem(post, 2, 80, 80) } }
    }.margin({ top: 10 }).alignItems(HorizontalAlign.Start)
  }

  @Builder CityImageItem(post: Post, index: number, w: number, h: number) {
    Stack() { Image(post.images[index]).width('100%').height('100%').objectFit(ImageFit.Cover) }.width(w).height(h).backgroundColor('#E8E8E8').borderRadius(6).onClick(() => { this.openImagePreview(post, index); })
  }

  @Builder TravelersContent() { Column(){ Text('驴友功能开发中').fontColor('#94A3B8') }.width('100%').height(200).justifyContent(FlexAlign.Center) }
  @Builder GuideContent() { Column(){ Text('攻略功能开发中').fontColor('#94A3B8') }.width('100%').height(200).justifyContent(FlexAlign.Center) }
}