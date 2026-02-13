/**
 * 城市卡片弹窗组件 - 盲盒摇一摇结果
 * 简约沉浸式设计
 */

import { City } from '../../models/City';

@Component
export struct CityCardDialog {
  @Link isShow: boolean;
  @Prop city: City;
  onExplore: () => void = () => {};
  onClose: () => void = () => {};
  onShuffle: () => void = () => {};

  build() {
    if (this.isShow) {
      Stack() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('rgba(0,0,0,0.6)')
          .onClick(() => {
            this.isShow = false;
            this.onClose();
          })

        // 主卡片
        Column() {
          // 上部：城市图片区域（无边框，与内容渐变融合）
          Stack() {
            // 城市渐变背景
            Column()
              .width('100%')
              .height('100%')
              .linearGradient({
                direction: GradientDirection.Bottom,
                colors: [
                  [this.getCityGradientStart(), 0],
                  [this.getCityGradientMid(), 0.6],
                  [this.getCityGradientEnd(), 1]
                ]
              })

            // 城市 emoji
            Text(this.getCityEmoji())
              .fontSize(100)
              .opacity(0.85)
              .margin({ bottom: 40 })

            // 底部渐变蒙版（与白色内容区融合）
            Column()
              .width('100%')
              .height('50%')
              .linearGradient({
                direction: GradientDirection.Top,
                colors: [
                  ['#FFFFFF', 0],
                  ['rgba(255,255,255,0.8)', 0.3],
                  ['rgba(255,255,255,0)', 1]
                ]
              })
              .position({ x: 0, y: '50%' })
          }
          .width('100%')
          .height(220)

          // 下部：内容区域
          Column() {
            // 城市名 + 国家
            Text(this.city.name)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1E293B')

            Text(`${this.city.country} · ${this.getCityType()}`)
              .fontSize(13)
              .fontColor('#94A3B8')
              .margin({ top: 4 })

            // 分隔线
            Column()
              .width(32)
              .height(3)
              .borderRadius(1.5)
              .backgroundColor('#38BDF8')
              .margin({ top: 16, bottom: 16 })

            // 城市描述
            Text(this.getCityDescription())
              .fontSize(13)
              .fontColor('#64748B')
              .lineHeight(22)
              .textAlign(TextAlign.Center)
              .maxLines(3)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ left: 8, right: 8 })

            // 信息标签
            Row({ space: 8 }) {
              this.InfoChip('📍', this.formatDistance())
              this.InfoChip('👥', `${this.formatCount(this.city.visitorsCount)}人去过`)
              this.InfoChip('📝', `${this.formatCount(this.city.postsCount)}篇`)
            }
            .margin({ top: 20 })

            // 按钮组
            Column({ space: 10 }) {
              // 立即前往
              Row() {
                Text('探索这座城市')
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF')
                Text('→')
                  .fontSize(15)
                  .fontColor('rgba(255,255,255,0.8)')
                  .margin({ left: 8 })
              }
              .width('100%')
              .height(48)
              .justifyContent(FlexAlign.Center)
              .linearGradient({
                direction: GradientDirection.Right,
                colors: [['#38BDF8', 0], ['#0EA5E9', 1]]
              })
              .borderRadius(24)
              .shadow({ radius: 12, color: 'rgba(14,165,233,0.3)', offsetY: 4 })
              .onClick(() => {
                this.isShow = false;
                this.onExplore();
              })

              // 再摇一次
              Row() {
                Text('🎲')
                  .fontSize(15)
                Text('换一个')
                  .fontSize(14)
                  .fontColor('#64748B')
                  .margin({ left: 6 })
              }
              .width('100%')
              .height(44)
              .justifyContent(FlexAlign.Center)
              .backgroundColor('#F8FAFC')
              .borderRadius(22)
              .border({ width: 1, color: '#F1F5F9' })
              .onClick(() => {
                this.onShuffle();
              })
            }
            .width('100%')
            .margin({ top: 24 })
          }
          .width('100%')
          .padding({ left: 24, right: 24, bottom: 24 })
          .alignItems(HorizontalAlign.Center)
        }
        .width('85%')
        .backgroundColor('#FFFFFF')
        .borderRadius(24)
        .clip(true)
        .shadow({ radius: 30, color: 'rgba(0,0,0,0.15)', offsetY: 10 })

        // 右上角关闭按钮（浮在卡片外）
        Column() {
          Text('✕')
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.8)')
        }
        .width(36)
        .height(36)
        .borderRadius(18)
        .backgroundColor('rgba(255,255,255,0.15)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: '89%', y: '12%' })
        .onClick(() => {
          this.isShow = false;
          this.onClose();
        })
      }
      .width('100%')
      .height('100%')
    }
  }

  @Builder
  InfoChip(icon: string, text: string) {
    Row() {
      Text(icon)
        .fontSize(11)
      Text(text)
        .fontSize(11)
        .fontColor('#64748B')
        .margin({ left: 3 })
    }
    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
    .backgroundColor('#F8FAFC')
    .borderRadius(14)
    .border({ width: 0.5, color: '#F1F5F9' })
  }

  // ==================== 数据方法 ====================

  private getCityEmoji(): string {
    const map: Record<string, string> = {
      '巴黎': '🗼', '东京': '🗾', '纽约': '🗽', '伦敦': '🎡',
      '北京': '🏯', '上海': '🌃', '成都': '🐼', '西安': '🏛️', '黄山': '⛰️',
    };
    return map[this.city.name] || '🌍';
  }

  private getCityGradientStart(): string {
    const map: Record<string, string> = {
      '巴黎': '#FDB99B', '东京': '#FF6B95', '纽约': '#667EEA', '伦敦': '#A8EDEA',
      '北京': '#F6D365', '上海': '#764BA2', '成都': '#11998E', '西安': '#C6FFDD', '黄山': '#F093FB',
    };
    return map[this.city.name] || '#667EEA';
  }

  private getCityGradientMid(): string {
    const map: Record<string, string> = {
      '巴黎': '#FDCDA1', '东京': '#FF9A8B', '纽约': '#7B8CEA', '伦敦': '#C4F0E8',
      '北京': '#F8DC7A', '上海': '#8B6CB2', '成都': '#2CB88A', '西安': '#D8FFE4', '黄山': '#F5A9D0',
    };
    return map[this.city.name] || '#8B8CEA';
  }

  private getCityGradientEnd(): string {
    const map: Record<string, string> = {
      '巴黎': '#FFE29F', '东京': '#FF8A5B', '纽约': '#764BA2', '伦敦': '#Fed6E3',
      '北京': '#FDA085', '上海': '#667EEA', '成都': '#38EF7D', '西安': '#FBC2EB', '黄山': '#F5576C',
    };
    return map[this.city.name] || '#764BA2';
  }

  private getCityType(): string {
    const map: Record<string, string> = {
      '巴黎': '浪漫之都', '东京': '现代都市', '纽约': '国际大都会', '伦敦': '历史名城',
      '北京': '历史古迹', '上海': '魔幻都市', '成都': '休闲之都', '西安': '千年古都', '黄山': '自然风光',
    };
    return map[this.city.name] || '热门城市';
  }

  private getCityDescription(): string {
    const map: Record<string, string> = {
      '巴黎': '浪漫之都，在塞纳河畔感受法式优雅，在卢浮宫邂逅艺术瑰宝。',
      '东京': '传统与现代的完美融合，体验最前沿的潮流文化与古老的东方韵味。',
      '纽约': '不夜城的繁华，时代广场的霓虹，在这里追逐属于你的梦想。',
      '伦敦': '雾都伦敦，皇室风范，感受英伦绅士的优雅与历史的厚重。',
      '北京': '千年古都的壮丽与雄浑，长城内外尽显中华文明的恢弘气势。',
      '上海': '东西方文化的交汇点，魔都的现代与复古在这里完美融合。',
      '成都': '天府之国，慢生活的代名词，品尝美食，看熊猫卖萌。',
      '西安': '十三朝古都，穿越千年的历史记忆，触摸文明的脉搏。',
      '黄山': '五岳归来不看山，黄山归来不看岳。云海奇松，美不胜收。',
    };
    return map[this.city.name] || this.city.description || '探索这座城市的独特魅力。';
  }

  private formatDistance(): string {
    const map: Record<string, number> = {
      '巴黎': 8942, '东京': 1876, '纽约': 11234, '伦敦': 8123,
      '北京': 1240, '上海': 1120, '成都': 1580, '西安': 1380, '黄山': 680,
    };
    const dist = map[this.city.name] || Math.floor(Math.random() * 5000 + 500);
    if (dist >= 10000) {
      return `${(dist / 10000).toFixed(1)}万km`;
    }
    return `${dist.toLocaleString()}km`;
  }

  private formatCount(count: number): string {
    if (count >= 10000) {
      return (count / 10000).toFixed(1) + 'w';
    } else if (count >= 1000) {
      return (count / 1000).toFixed(1) + 'k';
    }
    return count.toString();
  }
}