/**
 * 个人中心页面 - 符合设计原型
 */

import { Colors, FontSizes, Spacing, Radius, Sizes } from '../../utils/Constants';
import { mockCurrentUser } from '../../services/MockData';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

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

interface PhotoItem {
  id: number;
  likes: number;
  isMultiple: boolean;
}

@Entry
@Component
export struct ProfilePage {
  @State currentTab: number = 0;  // 0: 作品, 1: 足迹, 2: 收藏
  @State exploredCities: number = 42;
  
  // 地球展开/收起状态
  @State isGlobeExpanded: boolean = false;
  @State globeScale: number = 0;
  @State globeOpacity: number = 0;
  @State globeHeight: number = 0;
  @State arrowRotation: number = 0;
  @State dragOffset: number = 0;
  @State isDragging: boolean = false;
  @State coverBgIndex: number = 0;  // 背景切换索引
  @State showCoverMenu: boolean = false;
  private readonly MAX_EXPAND_HEIGHT: number = 320;
  private readonly MIN_HEIGHT: number = 0;
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

  @State photos: PhotoItem[] = [
    { id: 1, likes: 1200, isMultiple: true },
    { id: 2, likes: 856, isMultiple: false },
    { id: 3, likes: 2100, isMultiple: false },
    { id: 4, likes: 1500, isMultiple: true },
    { id: 5, likes: 430, isMultiple: false },
    { id: 6, likes: 780, isMultiple: false },
    { id: 7, likes: 920, isMultiple: false },
    { id: 8, likes: 1100, isMultiple: false },
  ];

  @State menuItems: MenuItemData[] = [
    { icon: '⏳', title: '时空胶囊', value: '3', route: 'pages/explore/TimeCapsulePage', badge: 1 },
    { icon: '🍾', title: '漂流瓶', value: '5', route: 'pages/explore/DriftBottlePage', badge: 2 },
    { icon: '⚙️', title: '设置', value: '', route: 'pages/profile/SettingsPage' },
  ];

  private navigateToMenu(item: MenuItemData): void {
    if (item.route) {
      router.pushUrl({ url: item.route }).catch(() => {});
    }
  }

  private navigateToSettings(): void {
    router.pushUrl({ url: 'pages/profile/SettingsPage' }).catch(() => {});
  }

  private navigateToEditProfile(): void {
    router.pushUrl({ url: 'pages/profile/EditProfilePage' }).catch(() => {});
  }

  private navigateToBadgeWall(): void {
    router.pushUrl({ url: 'pages/profile/BadgeWallPage' }).catch(() => {});
  }

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
      if (result.index === 0) {
        promptAction.showToast({ message: '相册选择功能开发中...', duration: 1500 });
      } else if (result.index >= 1 && result.index <= 5) {
        this.coverBgIndex = result.index - 1;
        promptAction.showToast({ message: '背景已更换', duration: 1000 });
      }
    }).catch(() => {});
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          // 抖音风格封面背景图
          this.CoverSection()

          // 用户信息区域
          this.UserInfoSection()

          // 统计数据
          this.StatsRow()

          // 迷雾地球
          this.FogGlobeSection()

          // 勋章墙
          this.BadgeWallSection()

          // 内容标签
          this.ContentTabsSection()
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
      // 背景渐变 (可更换)
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

      // 光效装饰
      Column()
        .width(200)
        .height(200)
        .borderRadius(100)
        .backgroundColor('#7DD3FC')
        .opacity(0.15)
        .blur(80)
        .position({ x: '60%', y: 30 })

      Column()
        .width(160)
        .height(160)
        .borderRadius(80)
        .backgroundColor('#60A5FA')
        .opacity(0.1)
        .blur(60)
        .position({ x: '10%', y: 80 })

      // 星点装饰
      Column().width(4).height(4).borderRadius(2).backgroundColor('#FFFFFF').opacity(0.6)
        .position({ x: '20%', y: 50 })
      Column().width(3).height(3).borderRadius(1.5).backgroundColor('#FFFFFF').opacity(0.4)
        .position({ x: '75%', y: 80 })
      Column().width(5).height(5).borderRadius(2.5).backgroundColor('#FFFFFF').opacity(0.3)
        .position({ x: '85%', y: 40 })
      Column().width(3).height(3).borderRadius(1.5).backgroundColor('#FFFFFF').opacity(0.5)
        .position({ x: '45%', y: 30 })

      // ⭐ 右上角按钮（跟随页面滚动）
      Row({ space: 10 }) {
        Column() {
          Text('+')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .width(34)
        .height(34)
        .borderRadius(17)
        .backgroundColor('rgba(255,255,255,0.15)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text('⚙️')
            .fontSize(18)
        }
        .width(34)
        .height(34)
        .borderRadius(17)
        .backgroundColor('rgba(255,255,255,0.15)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => this.navigateToSettings())
      }
      .position({ x: '100%', y: 0 })
      .translate({ x: -98 })
      .padding({ top: 40 })

      // 更换背景按钮（右下角）
      Row() {
        Text('📷')
          .fontSize(12)
        Text('更换背景')
          .fontSize(11)
          .fontColor('#FFFFFF')
          .margin({ left: 4 })
      }
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .backgroundColor('rgba(0,0,0,0.35)')
      .borderRadius(14)
      .position({ x: '60%', y: 180 })
      .onClick(() => this.changeCoverBg())
    }
    .width('100%')
    .height(220)
  }

  @Builder
  HeaderBar() {
    Row() {
      Blank()

      Row() {
        // + 按钮 (只保留 +)
        Column() {
          Text('+')
            .fontSize(24)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .width(34)
        .height(34)
        .borderRadius(17)
        .backgroundColor('rgba(255,255,255,0.15)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: 12 })

        // 设置按钮
        Column() {
          Text('⚙️')
            .fontSize(18)
        }
        .width(34)
        .height(34)
        .borderRadius(17)
        .backgroundColor('rgba(255,255,255,0.15)')
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.navigateToSettings())
      }
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 36, bottom: 10 })
    .position({ x: 0, y: 0 })
  }

  @Builder
  UserInfoSection() {
    Row() {
      // 头像容器
      Stack() {
        // 渐变边框
        Column()
          .width(84)
          .height(84)
          .borderRadius(42)
          .linearGradient({
            direction: GradientDirection.RightBottom,
            colors: [['#7DD3FC', 0], ['#0EA5E9', 1]]
          })

        // 头像占位
        Column() {
          Text((mockCurrentUser.nickname || 'A').charAt(0))
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
        }
        .width(76)
        .height(76)
        .borderRadius(38)
        .backgroundColor('#38BDF8')
        .border({ width: 3, color: '#FFFFFF' })
        .justifyContent(FlexAlign.Center)

        // 等级标签
        Text(`LV.${mockCurrentUser.level}`)
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .padding({ left: 6, right: 6, top: 2, bottom: 2 })
          .backgroundColor('#38BDF8')
          .borderRadius(10)
          .border({ width: 2, color: '#FFFFFF' })
          .position({ x: 54, y: 66 })
      }
      .width(84)
      .height(84)

      // 用户信息
      Column() {
        Text(mockCurrentUser.nickname || 'Alex Walker')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        // 称号标签
        Row() {
          Text('🌍')
            .fontSize(12)
          Text('Intercontinental Explorer')
            .fontSize(11)
            .fontWeight(FontWeight.Medium)
            .fontColor('#38BDF8')
            .margin({ left: 4 })
        }
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#DBEAFE')
        .borderRadius(8)
        .margin({ top: 6 })

        Text(mockCurrentUser.bio || 'Walking the world, one step at a time.')
          .fontSize(13)
          .fontColor('#64748B')
          .margin({ top: 6 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        // 编辑资料按钮
        Row() {
          Text('✏️')
            .fontSize(12)
          Text('编辑资料')
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#475569')
            .margin({ left: 4 })
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor('#F1F5F9')
        .borderRadius(16)
        .border({ width: 1, color: '#E2E8F0' })
        .margin({ top: 10 })
        .onClick(() => this.navigateToEditProfile())
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 8 })
    .margin({ top: -30 })  // 向上覆盖封面底部
  }

  @Builder
  StatsRow() {
    Row() {
      this.StatItem('128', '关注')
      this.StatItem('4.5k', '粉丝')
      this.StatItem('23', '国家')
      this.StatItem('142', '城市')
    }
    .width('100%')
    .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 24 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  StatItem(value: string, label: string) {
    Column() {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1E293B')
      Text(label)
        .fontSize(11)
        .fontColor('#64748B')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
  }

  // 处理拖拽更新
  private handleGlobeDragUpdate(offsetY: number): void {
    this.isDragging = true;
    const currentBase = this.isGlobeExpanded ? this.MAX_EXPAND_HEIGHT : this.MIN_HEIGHT;
    let newHeight = currentBase + offsetY;
    
    // 限制范围
    newHeight = Math.max(this.MIN_HEIGHT, Math.min(this.MAX_EXPAND_HEIGHT, newHeight));
    
    // 计算进度 (0-1)
    const progress = (newHeight - this.MIN_HEIGHT) / (this.MAX_EXPAND_HEIGHT - this.MIN_HEIGHT);
    
    // 更新视觉状态
    this.globeHeight = newHeight;
    this.globeScale = 0.3 + progress * 0.7;
    this.globeOpacity = progress;
    this.arrowRotation = progress * 180;
  }

  // 处理拖拽结束
  private handleGlobeDragEnd(): void {
    this.isDragging = false;
    const progress = (this.globeHeight - this.MIN_HEIGHT) / (this.MAX_EXPAND_HEIGHT - this.MIN_HEIGHT);
    
    // 根据当前进度决定展开或收起
    if (progress > 0.4) {
      // 展开
      this.expandGlobe();
    } else {
      // 收起
      this.collapseGlobe();
    }
  }

  // 展开动画
  private expandGlobe(): void {
    this.isGlobeExpanded = true;
    animateTo({
      duration: 300,
      curve: Curve.EaseOut,
    }, () => {
      this.globeScale = 1;
      this.globeOpacity = 1;
      this.globeHeight = this.MAX_EXPAND_HEIGHT;
      this.arrowRotation = 180;
    });
  }

  // 收起动画
  private collapseGlobe(): void {
    animateTo({
      duration: 300,
      curve: Curve.EaseOut,
      onFinish: () => {
        this.isGlobeExpanded = false;
      }
    }, () => {
      this.globeScale = 0;
      this.globeOpacity = 0;
      this.globeHeight = 0;
      this.arrowRotation = 0;
    });
  }

  @Builder
  FogGlobeSection() {
    Column() {
      // 可点击的标题栏- 点击展开/收起
      Row() {
        // 左侧图标和标签
        Row() {
          Column() {
            Text('🌍')
              .fontSize(24)
          }
          .width(44)
          .height(44)
          .backgroundColor('#DBEAFE')
          .borderRadius(12)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

          Column() {
            Text('我的轨迹')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E293B')
            
            Text(`已探索 ${this.exploredCities} 座城市`)
              .fontSize(12)
              .fontColor('#64748B')
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
        }

        Blank()

        // 收起/展开箭头
        Row() {
          Column() {
            Text('⌄')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#94A3B8')
          }
          .width(36)
          .height(36)
          .backgroundColor('#F1F5F9')
          .borderRadius(18)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
          .rotate({ angle: this.arrowRotation })
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .border({ width: 1, color: '#F1F5F9' })
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
      .gesture(
        PanGesture({ direction: PanDirection.Vertical })
          .onActionUpdate((event: GestureEvent) => {
            this.handleGlobeDragUpdate(event.offsetY);
          })
          .onActionEnd(() => {
            this.handleGlobeDragEnd();
          })
      )

      // 可折叠的地球容器
      Column() {
        // 迷雾地球
        Stack() {
          // 背景渐变
          Column()
            .width('100%')
            .height('100%')
            .borderRadius(140)
            .radialGradient({
              center: [140, 140],
              radius: 140,
              colors: [['rgba(14, 165, 233, 0.15)', 0], ['rgba(99, 102, 241, 0.1)', 0.5], ['transparent', 1]]
            })

          // 地球背景
          Column()
            .width('100%')
            .height('100%')
            .borderRadius(140)
            .backgroundColor('#1E3A5F')
            .shadow({ radius: 30, color: 'rgba(14, 165, 233, 0.3)', offsetY: 0 })

          // 地球表面
          Text('🌍')
            .fontSize(180)
            .opacity(0.6)

          // 发光点装饰
          Column()
            .width(60)
            .height(60)
            .borderRadius(30)
            .backgroundColor('#38BDF8')
            .opacity(0.3)
            .blur(30)
            .position({ x: 80, y: 70 })

          Column()
            .width(80)
            .height(80)
            .borderRadius(40)
            .backgroundColor('#7DD3FC')
            .opacity(0.3)
            .blur(30)
            .position({ x: 180, y: 160 })

          // 星星装饰
          Column()
            .width(6)
            .height(6)
            .borderRadius(3)
            .backgroundColor('#FFFFFF')
            .shadow({ radius: 8, color: 'rgba(255,255,255,0.8)', offsetY: 0 })
            .position({ x: 50, y: 40 })

          Column()
            .width(4)
            .height(4)
            .borderRadius(2)
            .backgroundColor('#FFFFFF')
            .opacity(0.7)
            .shadow({ radius: 6, color: 'rgba(255,255,255,0.8)', offsetY: 0 })
            .position({ x: 220, y: 80 })

          Column()
            .width(5)
            .height(5)
            .borderRadius(2.5)
            .backgroundColor('#FFFFFF')
            .opacity(0.5)
            .position({ x: 240, y: 130 })

          // 遮罩层
          Column()
            .width('100%')
            .height('100%')
            .borderRadius(140)
            .backgroundColor('rgba(0,0,0,0.15)')
            .blur(1)

          // 中心内容
          Column() {
            Text(`${this.exploredCities}`)
              .fontSize(48)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .shadow({ radius: 10, color: 'rgba(0,0,0,0.3)', offsetY: 2 })

            Text('已探索城市')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(255,255,255,0.9)')
              .letterSpacing(2)
              .margin({ top: 4 })

            // 查看迷雾地图按钮
            Row() {
              Text('🗺️')
                .fontSize(14)
              Text('查看迷雾地图')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .margin({ left: 6 })
            }
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor('rgba(255,255,255,0.2)')
            .borderRadius(20)
            .border({ width: 1, color: 'rgba(255,255,255,0.4)' })
            .margin({ top: 16 })
            .onClick(() => {
              router.pushUrl({ url: 'pages/explore/ExplorePage' }).catch(() => {});
            })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width(280)
        .height(280)
        .border({ width: 2, color: 'rgba(14, 165, 233, 0.2)' })
        .borderRadius(140)
        .scale({ x: this.globeScale, y: this.globeScale })
      }
      .width('100%')
      .height(this.globeHeight)
      .opacity(this.globeOpacity)
      .padding({ top: this.globeHeight > 0 ? 16 : 0 })
      .alignItems(HorizontalAlign.Center)
      .clip(true)
    }
    .width('100%')
    .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 12, bottom: this.globeHeight > 0 ? 8 : 0 })
    .gesture(
      PanGesture({ direction: PanDirection.Vertical })
        .onActionUpdate((event: GestureEvent) => {
          this.handleGlobeDragUpdate(event.offsetY);
        })
        .onActionEnd(() => {
          this.handleGlobeDragEnd();
        })
    )
  }

  @Builder
  BadgeWallSection() {
    Column() {
      Row() {
        Text('勋章墙')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        Blank()

        Row() {
          Text('全部')
            .fontSize(12)
            .fontColor('#38BDF8')
            .fontWeight(FontWeight.Medium)
          Text('›')
            .fontSize(14)
            .fontColor('#38BDF8')
            .margin({ left: 2 })
        }
        .onClick(() => this.navigateToBadgeWall())
      }
      .width('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding })
      .margin({ bottom: 12 })

      // 横向滚动勋章
      Scroll() {
        Row() {
          ForEach(this.badges, (badge: BadgeItem) => {
            Column() {
              Column() {
                Text(badge.icon)
                  .fontSize(28)
                  .opacity(badge.unlocked ? 1 : 0.3)
              }
              .width(64)
              .height(64)
              .backgroundColor(badge.unlocked ? badge.bgColor : '#F1F5F9')
              .borderRadius(16)
              .border({ width: 1, color: badge.unlocked ? 'transparent' : '#E2E8F0' })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              Text(badge.name)
                .fontSize(11)
                .fontWeight(FontWeight.Medium)
                .fontColor(badge.unlocked ? '#1E293B' : '#94A3B8')
                .margin({ top: 8 })
            }
            .width(80)
            .alignItems(HorizontalAlign.Center)
          })
        }
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .margin({ bottom: 16 })
  }

  @Builder
  ContentTabsSection() {
    Column() {
      // 白色圆角卡片容器
      Column() {
        // Tab栏
        Row() {
          this.TabItem('作品', 0)
          this.TabItem('足迹', 1)
          this.TabItem('收藏', 2)
        }
        .width('100%')
        .border({ width: { bottom: 1 }, color: '#F1F5F9' })

        // 内容区域 - 照片网格
        this.PhotoGrid()
      }
      .width('100%')
      .backgroundColor('#FFFFFF')
      .borderRadius({ topLeft: 24, topRight: 24 })
      .shadow({ radius: 20, color: 'rgba(0,0,0,0.05)', offsetY: -4 })
    }
    .width('100%')
  }

  @Builder
  TabItem(title: string, index: number) {
    Column() {
      Text(title)
        .fontSize(15)
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
        .fontColor(this.currentTab === index ? '#38BDF8' : '#64748B')

      // 指示条
      if (this.currentTab === index) {
        Column()
          .width(4)
          .height(4)
          .borderRadius(2)
          .backgroundColor('#38BDF8')
          .margin({ top: 8 })
      }
    }
    .layoutWeight(1)
    .padding({ top: 16, bottom: 12 })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentTab = index;
    })
  }

  @Builder
  PhotoGrid() {
    Column() {
      // 使用Grid布局模拟3列网格
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.photos, (photo: PhotoItem, index: number) => {
          Stack() {
            // 照片占位
            Column()
              .width('100%')
              .aspectRatio(1)
              .backgroundColor('#E2E8F0')

            // 模拟照片内容
            Column()
              .width('100%')
              .height('100%')
              .linearGradient({
                direction: GradientDirection.RightBottom,
                colors: [
                  [this.getPhotoColor(index), 0],
                  [this.getPhotoColorEnd(index), 1]
                ]
              })

            // 多图标识
            if (photo.isMultiple) {
              Text('📷')
                .fontSize(14)
                .position({ x: '80%', y: 8 })
            }

            // 点赞
            if (photo.likes > 1000) {
              Row() {
                Text('❤️')
                  .fontSize(10)
                Text(this.formatLikes(photo.likes))
                  .fontSize(9)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                  .margin({ left: 2 })
              }
              .position({ x: '60%', y: '85%' })
            }
          }
          .width('33.33%')
          .aspectRatio(1)
          .padding(0.5)
        })

        // 新建按钮
        Column() {
          Text('+')
            .fontSize(28)
            .fontColor('#94A3B8')
          Text('新建')
            .fontSize(11)
            .fontColor('#94A3B8')
            .margin({ top: 4 })
        }
        .width('33.33%')
        .aspectRatio(1)
        .backgroundColor('#F1F5F9')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .padding(0.5)
      }
    }
    .width('100%')
    .padding(1)
  }

  private getPhotoColor(index: number): string {
    const colors = ['#93C5FD', '#BFDBFE', '#A5B4FC', '#C7D2FE', '#93C5FD', '#DBEAFE', '#BAE6FD', '#A5B4FC'];
    return colors[index % colors.length];
  }

  private getPhotoColorEnd(index: number): string {
    const colors = ['#38BDF8', '#0EA5E9', '#4F46E5', '#4338CA', '#7DD3FC', '#0284C7', '#0284C7', '#6366F1'];
    return colors[index % colors.length];
  }

  private formatLikes(count: number): string {
    if (count >= 1000) {
      return `${(count / 1000).toFixed(1)}k`;
    }
    return `${count}`;
  }
}
