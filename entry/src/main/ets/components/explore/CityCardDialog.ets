/**
 * 城市卡片弹窗组件 - 盲盒摇一摇结果
 * 符合设计图样式
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { City } from '../../models/City';

@Component
export struct CityCardDialog {
  @Link isShow: boolean;
  @Prop city: City;
  onExplore: () => void = () => {};
  onClose: () => void = () => {};
  onShuffle: () => void = () => {};

  // 城市地标映射
  private getCityLandmark(): string {
    const landmarks: Record<string, string> = {
      '巴黎': '埃菲尔铁塔',
      '东京': '东京铁塔',
      '纽约': '自由女神像',
      '伦敦': '大本钟',
      '北京': '万里长城',
      '上海': '东方明珠',
      '成都': '大熊猫基地',
      '西安': '兵马俑',
      '黄山': '迎客松',
    };
    return landmarks[this.city.name] || '著名景点';
  }

  // 城市描述映射
  private getCityDescription(): string {
    const descriptions: Record<string, string> = {
      '巴黎': '浪漫之都。在塞纳河畔感受法式优雅，在卢浮宫邂逅艺术瑰宝。',
      '东京': '传统与现代的完美融合，在这里体验最前沿的潮流文化。',
      '纽约': '不夜城的繁华，时代广场的霓虹，在这里追逐梦想。',
      '伦敦': '雾都伦敦，皇室风范。感受英伦绅士的优雅与历史的厚重。',
      '北京': '不到长城非好汉。体验千年的历史沉淀，感受中华文明的壮丽与雄浑。',
      '上海': '魔都上海，东西方文化的交汇点，现代与复古完美融合。',
      '成都': '天府之国，慢生活的代名词。品尝美食，看熊猫卖萌。',
      '西安': '十三朝古都，穿越千年的历史记忆。',
      '黄山': '五岳归来不看山，黄山归来不看岳。云海奇松，美不胜收。',
    };
    return descriptions[this.city.name] || this.city.description || '探索这座城市的独特魅力。';
  }

  build() {
    if (this.isShow) {
      Stack() {
        // 毛玻璃遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.5)')
          .blur(20)
          .onClick(() => {
            this.isShow = false;
            this.onClose();
          })

        // 顶部标签和关闭按钮
        Row() {
          // 3D EARTH VIEW 标签
          Row() {
            Column()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor('#38BDF8')
            Text('3D EARTH VIEW')
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .margin({ left: 8 })
          }
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor('rgba(255,255,255,0.2)')
          .borderRadius(20)

          Blank()

          // 关闭按钮
          Column() {
            Text('✕')
              .fontSize(18)
              .fontColor('#64748B')
          }
          .width(44)
          .height(44)
          .backgroundColor('#F1F5F9')
          .borderRadius(22)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.isShow = false;
            this.onClose();
          })
        }
        .width('100%')
        .padding({ left: 20, right: 20, top: 56 })
        .position({ x: 0, y: 0 })
        .zIndex(10)

        // 主卡片内容
        Column() {
          // 城市图片区域
          Stack() {
            // 城市风景图背景
            Column()
              .width('100%')
              .height('100%')
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [
                  [this.getCityGradientStart(), 0],
                  [this.getCityGradientEnd(), 1]
                ]
              })
              .borderRadius(20)

            // 城市图片占位（使用大emoji模拟）
            Column() {
              Text(this.getCityEmoji())
                .fontSize(120)
                .opacity(0.9)
            }
            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .borderRadius(20)

            // 图片底部渐变遮罩
            Column()
              .width('100%')
              .height(80)
              .linearGradient({
                direction: GradientDirection.Top,
                colors: [['rgba(0,0,0,0.3)', 0], ['transparent', 1]]
              })
              .position({ x: 0, y: '100%' })
              .translate({ y: '-100%' })
              .borderRadius({ bottomLeft: 20, bottomRight: 20 })
          }
          .width('100%')
          .height(280)
          .borderRadius(20)
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.15)', offsetY: 8 })

          // 城市名称
          Text(this.city.name)
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .margin({ top: 24 })

          // 地标名称
          Text(this.getCityLandmark())
            .fontSize(16)
            .fontColor('#38BDF8')
            .margin({ top: 4 })

          // 信息标签区
          Row() {
            // 距离标签
            Row() {
              Text('📍')
                .fontSize(14)
              Text(`距你 ${this.formatDistance()} km`)
                .fontSize(13)
                .fontColor('#64748B')
                .margin({ left: 4 })
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('#F1F5F9')
            .borderRadius(20)

            // 类型标签
            Row() {
              Text('🏛️')
                .fontSize(14)
              Text(this.getCityType())
                .fontSize(13)
                .fontColor('#64748B')
                .margin({ left: 4 })
            }
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .backgroundColor('#F1F5F9')
            .borderRadius(20)
            .margin({ left: 12 })
          }
          .margin({ top: 20 })

          // 城市描述
          Text(this.getCityDescription())
            .fontSize(14)
            .fontColor('#64748B')
            .lineHeight(24)
            .textAlign(TextAlign.Center)
            .margin({ top: 20, left: 16, right: 16 })

          // 操作按钮
          Column() {
            // 立即前往按钮
            Button() {
              Row() {
                Text('立即前往')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('→')
                  .fontSize(16)
                  .fontColor('#FFFFFF')
                  .margin({ left: 8 })
              }
            }
            .width('100%')
            .height(52)
            .backgroundColor('#38BDF8')
            .borderRadius(26)
            .shadow({ radius: 12, color: 'rgba(14, 165, 233, 0.4)', offsetY: 4 })
            .onClick(() => {
              this.isShow = false;
              this.onExplore();
            })

            // 再摇一次按钮
            Button() {
              Row() {
                Text('🔄')
                  .fontSize(16)
                Text('再摇一次')
                  .fontSize(15)
                  .fontColor('#64748B')
                  .margin({ left: 6 })
              }
            }
            .width('100%')
            .height(48)
            .backgroundColor('#FFFFFF')
            .border({ width: 1.5, color: '#E2E8F0' })
            .borderRadius(24)
            .margin({ top: 12 })
            .onClick(() => {
              this.onShuffle();
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ top: 28 })
        }
        .width('88%')
        .padding({ top: 16, bottom: 28 })
        .backgroundColor('#FFFFFF')
        .borderRadius(28)
        .shadow({ radius: 30, color: 'rgba(0,0,0,0.2)', offsetY: 10 })

        // 底部提示
        Text('TAP BACKGROUND TO CLOSE')
          .fontSize(12)
          .fontColor('rgba(255,255,255,0.6)')
          .letterSpacing(1)
          .position({ x: '50%', y: '95%' })
          .translate({ x: '-50%' })
      }
      .width('100%')
      .height('100%')
    }
  }

  getCityEmoji(): string {
    const cityEmojis: Record<string, string> = {
      '巴黎': '🗼',
      '东京': '🗾',
      '纽约': '🗽',
      '伦敦': '🎡',
      '北京': '🏯',
      '上海': '🌃',
      '成都': '🐼',
      '西安': '🏛️',
      '黄山': '⛰️',
    };
    return cityEmojis[this.city.name] || '🌍';
  }

  getCityGradientStart(): string {
    const gradients: Record<string, string> = {
      '巴黎': '#FDB99B',
      '东京': '#FF6B95',
      '纽约': '#667EEA',
      '伦敦': '#A8EDEA',
      '北京': '#F6D365',
      '上海': '#764BA2',
      '成都': '#11998E',
      '西安': '#C6FFDD',
      '黄山': '#F093FB',
    };
    return gradients[this.city.name] || '#667EEA';
  }

  getCityGradientEnd(): string {
    const gradients: Record<string, string> = {
      '巴黎': '#FFE29F',
      '东京': '#FF8A5B',
      '纽约': '#764BA2',
      '伦敦': '#Fed6E3',
      '北京': '#FDA085',
      '上海': '#667EEA',
      '成都': '#38EF7D',
      '西安': '#FBC2EB',
      '黄山': '#F5576C',
    };
    return gradients[this.city.name] || '#764BA2';
  }

  getCityType(): string {
    const types: Record<string, string> = {
      '巴黎': '浪漫之都',
      '东京': '现代都市',
      '纽约': '国际大都会',
      '伦敦': '历史名城',
      '北京': '历史古迹',
      '上海': '魔幻都市',
      '成都': '休闲之都',
      '西安': '千年古都',
      '黄山': '自然风光',
    };
    return types[this.city.name] || '热门城市';
  }

  formatDistance(): string {
    const distances: Record<string, number> = {
      '巴黎': 8942,
      '东京': 1876,
      '纽约': 11234,
      '伦敦': 8123,
      '北京': 1240,
      '上海': 1120,
      '成都': 1580,
      '西安': 1380,
      '黄山': 680,
    };
    const dist = distances[this.city.name] || Math.floor(Math.random() * 5000 + 500);
    return dist.toLocaleString();
  }

  formatCount(count: number): string {
    if (count >= 10000) {
      return (count / 10000).toFixed(1) + 'w';
    } else if (count >= 1000) {
      return (count / 1000).toFixed(1) + 'k';
    }
    return count.toString();
  }
}
