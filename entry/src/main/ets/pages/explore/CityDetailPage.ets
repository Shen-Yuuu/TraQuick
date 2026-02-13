/**
 * 城市详情页 - 抽屉式背景图 + 悬浮Tab栏
 */

import { router } from '@kit.ArkUI';

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
  }

  /**
   * 根据滚动位置计算背景图缩放
   * 初始状态（抽屉在底部）：图片放大到1.3倍，显示局部
   * 上滑（内容覆盖背景）：图片逐渐缩小到1.0倍，显示全貌
   */
  private updateImageEffect(): void {
    // scrollY = 0 时抽屉在最底部（占位80%），图片最大
    // scrollY 越大，抽屉越往上滑，图片越小
    // 占位80%的屏幕，大约滑动到一半时图片就该到1.0了

    if (this.scrollY <= 0) {
      // 下拉超出：继续放大，最大1.4
      this.imageScale = 1.3 + Math.abs(this.scrollY) / 800;
      if (this.imageScale > 1.4) {
        this.imageScale = 1.4;
      }
    } else {
      // 上滑：从1.3逐渐缩小到1.0
      this.imageScale = 1.3 - this.scrollY / 1500;
      if (this.imageScale < 1.0) {
        this.imageScale = 1.0;
      }
    }
  }

  build() {
    Stack() {
      // ① 背景图（全屏固定，带动效）
      this.BackgroundImage()

      // ② 可滚动内容区域（抽屉）
      Scroll(this.scroller) {
        Column() {
          // 占位空间（90%屏幕高度，让背景图充分露出）
          Column()
            .width('100%')
            .height('80%')

          // 内容卡片区域
          Column() {
            // 拖拽指示条
            Column()
              .width(40)
              .height(4)
              .borderRadius(2)
              .backgroundColor('rgba(0,0,0,0.15)')
              .margin({ top: 12, bottom: 16 })

            // 城市名称头部
            this.CityHeader()

            // Tab 内容
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

      // ③ 悬浮顶部按钮
      this.FloatingHeader()

      // ④ 悬浮底部 Tab 栏
      this.FloatingTabBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#000000')
  }

  // ==================== 背景图（全屏 + 动效） ====================

  @Builder
  BackgroundImage() {
    Stack() {
      // 全屏背景图 - 始终 >= 1.0 倍，不会有黑边
      Image($r('app.media.paris'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .scale({ x: this.imageScale, y: this.imageScale })
        .animation({
          duration: 80,
          curve: Curve.EaseOut
        })

      // 底部渐变蒙版
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

  // ==================== 悬浮顶部按钮（白底黑字） ====================

  @Builder
  FloatingHeader() {
    Row() {
      // 返回按钮
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

      // 更多按钮
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
          .onClick(() => {
            this.currentTab = index;
          })
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
      // 城市简介
      Column() {
        Row() {
          Text('🏙️')
            .fontSize(18)
          Text('城市简介')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 14 })

        Text(MOCK_CITY_INFO.description)
          .fontSize(14)
          .fontColor('#475569')
          .lineHeight(24)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      // 基本信息
      Column() {
        Row() {
          Text('📋')
            .fontSize(18)
          Text('基本信息')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 14 })

        ForEach(MOCK_BASIC_INFO, (info: CityBasicInfo, index: number) => {
          Row() {
            Row() {
              Text(info.icon)
                .fontSize(16)
              Text(info.label)
                .fontSize(14)
                .fontColor('#64748B')
                .margin({ left: 8 })
            }

            Blank()

            Text(info.value)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1E293B')
          }
          .width('100%')
          .padding({ top: 12, bottom: 12 })
          .border({
            width: { bottom: index < MOCK_BASIC_INFO.length - 1 ? 1 : 0 },
            color: '#F1F5F9'
          })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      // 最佳旅行季节
      Column() {
        Row() {
          Text('📅')
            .fontSize(18)
          Text('最佳旅行季节')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 14 })

        Column() {
          Text('🌸')
            .fontSize(32)
          Text(MOCK_CITY_INFO.bestSeason)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ top: 8 })
          Text('春夏两季气候宜人，适合户外观光')
            .fontSize(12)
            .fontColor('#64748B')
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Center)
        .width('100%')
        .padding({ top: 8, bottom: 8 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      // 著名景点
      Column() {
        Row() {
          Text('🗺️')
            .fontSize(18)
          Text('著名景点')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 14 })

        Column({ space: 10 }) {
          ForEach(MOCK_ATTRACTIONS, (item: AttractionItem) => {
            Row() {
              Column() {
                Text(item.icon)
                  .fontSize(28)
              }
              .width(56)
              .height(56)
              .backgroundColor('#F1F5F9')
              .borderRadius(12)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Row() {
                  Text(item.name)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1E293B')

                  Blank()

                  Row() {
                    Text('⭐')
                      .fontSize(11)
                    Text(item.rating)
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#F59E0B')
                      .margin({ left: 2 })
                  }
                }
                .width('100%')

                Text(item.desc)
                  .fontSize(12)
                  .fontColor('#94A3B8')
                  .margin({ top: 4 })
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 12 })
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#FAFBFC')
            .borderRadius(12)
          })
        }
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      // 美食推荐
      Column() {
        Row() {
          Text('🍽️')
            .fontSize(18)
          Text('美食推荐')
            .fontSize(17)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 14 })

        Scroll() {
          Row({ space: 12 }) {
            ForEach(MOCK_FOODS, (food: FoodItem) => {
              Column() {
                Text(food.icon)
                  .fontSize(36)
                  .margin({ bottom: 8 })

                Text(food.name)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1E293B')

                Text(food.desc)
                  .fontSize(11)
                  .fontColor('#94A3B8')
                  .margin({ top: 4 })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .textAlign(TextAlign.Center)
              }
              .width(120)
              .padding(12)
              .backgroundColor('#FAFBFC')
              .borderRadius(12)
              .alignItems(HorizontalAlign.Center)
            })
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column()
        .height(20)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  // ==================== 社区 Tab ====================

  @Builder
  CommunityContent() {
    Column({ space: 12 }) {
      ForEach([1, 2, 3], (item: number) => {
        Column() {
          Row() {
            Column() {
              Text('🧑‍✈️')
                .fontSize(20)
            }
            .width(40)
            .height(40)
            .backgroundColor('#DBEAFE')
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`旅行者 ${item}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1E293B')
              Text('2小时前')
                .fontSize(11)
                .fontColor('#94A3B8')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 10 })
            .layoutWeight(1)

            Text('⋯')
              .fontSize(18)
              .fontColor('#94A3B8')
          }
          .width('100%')
          .margin({ bottom: 12 })

          Text('埃菲尔铁塔的夜景真的太美了！灯光闪烁的时刻让人永生难忘！推荐晚上8点以后去，刚好可以看到灯光秀 ✨ #巴黎')
            .fontSize(14)
            .fontColor('#475569')
            .lineHeight(22)
            .margin({ bottom: 12 })

          Column()
            .width('100%')
            .aspectRatio(1.6)
            .borderRadius(12)
            .linearGradient({
              direction: GradientDirection.RightBottom,
              colors: [['#93C5FD', 0], ['#38BDF8', 1]]
            })

          Row() {
            Row() {
              Text('❤️')
                .fontSize(14)
              Text(`${item * 234}`)
                .fontSize(12)
                .fontColor('#64748B')
                .margin({ left: 4 })
            }

            Row() {
              Text('💬')
                .fontSize(14)
              Text(`${item * 12}`)
                .fontSize(12)
                .fontColor('#64748B')
                .margin({ left: 4 })
            }
            .margin({ left: 24 })

            Blank()

            Text('🔖')
              .fontSize(16)
          }
          .width('100%')
          .margin({ top: 12 })
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })
      })

      Column().height(20)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  // ==================== 驴友 Tab ====================

  @Builder
  TravelersContent() {
    Column({ space: 16 }) {
      Column() {
        Row() {
          Column()
            .width(8)
            .height(8)
            .borderRadius(4)
            .backgroundColor('#22C55E')
          Text('在此处')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ left: 8 })
          Text('(3人)')
            .fontSize(13)
            .fontColor('#94A3B8')
            .margin({ left: 4 })
        }
        .width('100%')
        .margin({ bottom: 14 })

        ForEach([1, 2, 3], (item: number) => {
          Row() {
            Column() {
              Text('🧑‍✈️')
                .fontSize(18)
            }
            .width(44)
            .height(44)
            .backgroundColor('#DBEAFE')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`旅行者 ${item}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1E293B')
              Text('正在探索埃菲尔铁塔附近')
                .fontSize(12)
                .fontColor('#94A3B8')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            .layoutWeight(1)

            Row() {
              Text('打招呼')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#38BDF8')
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('#EFF6FF')
            .borderRadius(16)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FAFBFC')
          .borderRadius(12)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column() {
        Row() {
          Text('📅')
            .fontSize(16)
          Text('计划中')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ left: 8 })
          Text('(12人)')
            .fontSize(13)
            .fontColor('#94A3B8')
            .margin({ left: 4 })
        }
        .width('100%')
        .margin({ bottom: 14 })

        ForEach([1, 2], (item: number) => {
          Row() {
            Column() {
              Text('🧳')
                .fontSize(18)
            }
            .width(44)
            .height(44)
            .backgroundColor('#FEF3C7')
            .borderRadius(22)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Text(`计划者 ${item}`)
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#1E293B')
              Text('计划 3月15日 出发')
                .fontSize(12)
                .fontColor('#94A3B8')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 12 })
            .layoutWeight(1)

            Row() {
              Text('结伴')
                .fontSize(12)
                .fontWeight(FontWeight.Medium)
                .fontColor('#F59E0B')
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('#FFFBEB')
            .borderRadius(16)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FAFBFC')
          .borderRadius(12)
          .margin({ bottom: 8 })
        })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column().height(20)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  // ==================== 攻略 Tab ====================

  @Builder
  GuideContent() {
    Column({ space: 16 }) {
      Column() {
        Text('📝')
          .fontSize(48)
          .margin({ bottom: 12 })
        Text('攻略功能开发中')
          .fontSize(15)
          .fontColor('#94A3B8')
        Text('敬请期待')
          .fontSize(13)
          .fontColor('#CBD5E1')
          .margin({ top: 4 })
      }
      .width('100%')
      .height(200)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.04)', offsetY: 2 })

      Column().height(20)
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}