/**
 * 时空胶囊页面 - 埋下与挖掘
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { router } from '@kit.ArkUI';

interface TimeCapsule {
  id: string;
  content: string;
  images: string[];
  targetDate: string;      // 解封日期
  createdAt: string;
  location: CapsuleLocation;
  status: 'locked' | 'unlocked';
}

interface CapsuleLocation {
  cityName: string;
  address: string;
}

@Entry
@Component
struct TimeCapsulePage {
  @State currentTab: number = 0;  // 0: 埋下胶囊, 1: 我的胶囊
  @State content: string = '';
  @State targetDate: string = '';
  @State myCapsules: TimeCapsule[] = [];

  private tabs: string[] = ['埋下胶囊', '我的胶囊'];

  aboutToAppear(): void {
    this.loadMyCapsules();
    // 默认设置为一年后
    const nextYear = new Date();
    nextYear.setFullYear(nextYear.getFullYear() + 1);
    this.targetDate = nextYear.toISOString().split('T')[0];
  }

  // 加载我的胶囊
  private loadMyCapsules(): void {
    this.myCapsules = [
      {
        id: 'capsule_001',
        content: '希望明年的自己已经实现了环球旅行的梦想！',
        images: [],
        targetDate: '2025-12-31',
        createdAt: new Date(Date.now() - 30 * 86400000).toISOString(),
        location: { cityName: '北京', address: '国贸' },
        status: 'locked',
      },
      {
        id: 'capsule_002',
        content: '今天是毕业旅行的最后一天，和最好的朋友们一起...',
        images: [],
        targetDate: '2024-06-01',
        createdAt: new Date(Date.now() - 365 * 86400000).toISOString(),
        location: { cityName: '厦门', address: '鼓浪屿' },
        status: 'unlocked',
      },
    ];
  }

  // 埋下胶囊
  private buryCapusle(): void {
    if (!this.content.trim()) return;

    const newCapsule: TimeCapsule = {
      id: `capsule_${Date.now()}`,
      content: this.content,
      images: [],
      targetDate: this.targetDate,
      createdAt: new Date().toISOString(),
      location: { cityName: '北京', address: '当前位置' },
      status: 'locked',
    };
    this.myCapsules = [newCapsule, ...this.myCapsules];
    this.content = '';
    this.currentTab = 1;  // 切换到我的胶囊
  }

  // 返回
  private goBack(): void {
    router.back();
  }

  // 格式化日期
  private formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
  }

  // 计算剩余天数
  private getDaysRemaining(targetDate: string): number {
    const target = new Date(targetDate);
    const now = new Date();
    const diff = target.getTime() - now.getTime();
    return Math.max(0, Math.ceil(diff / 86400000));
  }

  build() {
    Column() {
      // 导航栏
      this.NavigationBar()

      // Tab栏
      this.TabBar()

      // 内容区域
      if (this.currentTab === 0) {
        this.BuryContent()
      } else {
        this.MyCapsulesContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgSecondary)
  }

  @Builder
  NavigationBar() {
    Row() {
      Row() {
        Text('←')
          .fontSize(24)
          .fontColor(Colors.textPrimary)
      }
      .width(44)
      .height(44)
      .justifyContent(FlexAlign.Center)
      .onClick(() => this.goBack())

      Blank()

      Text('时空胶囊')
        .fontSize(FontSizes.body)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textPrimary)

      Blank()

      Row().width(44).height(44)
    }
    .width('100%')
    .height(56)
    .padding({ left: 4, right: 4, top: 48 })
    .backgroundColor(Colors.bgPrimary)
  }

  @Builder
  TabBar() {
    Row() {
      ForEach(this.tabs, (tab: string, index: number) => {
        Column() {
          Text(tab)
            .fontSize(FontSizes.body)
            .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(this.currentTab === index ? Colors.primary : Colors.textTertiary)
            .onClick(() => {
              this.currentTab = index;
            })

          if (this.currentTab === index) {
            Row()
              .width(24)
              .height(3)
              .backgroundColor(Colors.primary)
              .borderRadius(2)
              .margin({ top: 8 })
          } else {
            Row().height(11)
          }
        }
      })
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.SpaceEvenly)
    .backgroundColor(Colors.bgPrimary)
  }

  @Builder
  BuryContent() {
    Scroll() {
      Column() {
        // 胶囊图标
        Column() {
          Text('💊')
            .fontSize(64)
          Text('写给未来的自己')
            .fontSize(FontSizes.h4)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
            .margin({ top: 16 })
          Text('这封信将在指定日期解封')
            .fontSize(FontSizes.bodySmall)
            .fontColor(Colors.textTertiary)
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ top: 32, bottom: 32 })

        // 内容输入
        Column() {
          Text('写下你想说的话')
            .fontSize(FontSizes.bodySmall)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
            .width('100%')
            .margin({ bottom: 12 })

          TextArea({ placeholder: '写给未来的自己，或者记录此刻的心情...', text: this.content })
            .width('100%')
            .height(180)
            .fontSize(FontSizes.body)
            .backgroundColor(Colors.bgPrimary)
            .borderRadius(Radius.card)
            .padding(16)
            .onChange((value: string) => {
              this.content = value;
            })
        }
        .width('100%')
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding })

        // 解封日期
        Column() {
          Text('选择解封日期')
            .fontSize(FontSizes.bodySmall)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
            .width('100%')
            .margin({ bottom: 12 })

          Row() {
            Text('📅')
              .fontSize(20)
            Text(this.formatDate(this.targetDate))
              .fontSize(FontSizes.body)
              .fontColor(Colors.textPrimary)
              .margin({ left: 12 })
            Blank()
            Text(`还有 ${this.getDaysRemaining(this.targetDate)} 天`)
              .fontSize(FontSizes.small)
              .fontColor(Colors.primary)
          }
          .width('100%')
          .height(56)
          .padding({ left: 16, right: 16 })
          .backgroundColor(Colors.bgPrimary)
          .borderRadius(Radius.card)

          // 快捷选择
          Row() {
            ForEach(['1年后', '2年后', '5年后', '10年后'], (label: string, index: number) => {
              Text(label)
                .fontSize(FontSizes.small)
                .fontColor(Colors.textSecondary)
                .padding({ left: 12, right: 12, top: 8, bottom: 8 })
                .backgroundColor(Colors.bgPrimary)
                .borderRadius(Radius.full)
                .onClick(() => {
                  const years = [1, 2, 5, 10][index];
                  const future = new Date();
                  future.setFullYear(future.getFullYear() + years);
                  this.targetDate = future.toISOString().split('T')[0];
                })
            })
          }
          .width('100%')
          .margin({ top: 12 })
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 24 })

        // 添加图片
        Column() {
          Text('添加照片（可选）')
            .fontSize(FontSizes.bodySmall)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
            .width('100%')
            .margin({ bottom: 12 })

          Row() {
            Column() {
              Text('+')
                .fontSize(32)
                .fontColor(Colors.textTertiary)
            }
            .width(80)
            .height(80)
            .backgroundColor(Colors.bgPrimary)
            .borderRadius(Radius.md)
            .justifyContent(FlexAlign.Center)
            .border({ width: 1, color: Colors.border, style: BorderStyle.Dashed })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 24 })

        // 埋下按钮
        Button('💊 埋下时空胶囊')
          .width('80%')
          .height(56)
          .fontSize(FontSizes.bodyLarge)
          .fontColor(Colors.textWhite)
          .backgroundColor(this.content ? Colors.primary : Colors.bgTertiary)
          .borderRadius(Radius.full)
          .margin({ top: 40, bottom: 40 })
          .enabled(!!this.content)
          .onClick(() => this.buryCapusle())
      }
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  MyCapsulesContent() {
    if (this.myCapsules.length > 0) {
      List() {
        ForEach(this.myCapsules, (capsule: TimeCapsule) => {
          ListItem() {
            Column() {
              // 状态和日期
              Row() {
                Row() {
                  Text(capsule.status === 'locked' ? '🔒' : '🔓')
                    .fontSize(16)
                  Text(capsule.status === 'locked' ? '待解封' : '已解封')
                    .fontSize(FontSizes.small)
                    .fontColor(capsule.status === 'locked' ? Colors.textTertiary : Colors.success)
                    .margin({ left: 6 })
                }
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(capsule.status === 'locked' ? Colors.bgSecondary : '#E6F7E6')
                .borderRadius(Radius.tag)

                Blank()

                Text(this.formatDate(capsule.createdAt.split('T')[0]))
                  .fontSize(FontSizes.small)
                  .fontColor(Colors.textQuaternary)
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 内容
              if (capsule.status === 'unlocked') {
                Text(capsule.content)
                  .fontSize(FontSizes.body)
                  .fontColor(Colors.textPrimary)
                  .lineHeight(22)
                  .width('100%')
              } else {
                Row() {
                  Text('🔐 内容已加密')
                    .fontSize(FontSizes.body)
                    .fontColor(Colors.textTertiary)
                }
                .width('100%')
                .height(60)
                .backgroundColor(Colors.bgSecondary)
                .borderRadius(Radius.md)
                .justifyContent(FlexAlign.Center)
              }

              // 解封日期
              Row() {
                Text('📍')
                  .fontSize(FontSizes.small)
                Text(capsule.location.cityName)
                  .fontSize(FontSizes.small)
                  .fontColor(Colors.textTertiary)
                  .margin({ left: 4 })

                Blank()

                if (capsule.status === 'locked') {
                  Text(`${this.formatDate(capsule.targetDate)} 解封`)
                    .fontSize(FontSizes.small)
                    .fontColor(Colors.primary)
                } else {
                  Text('点击查看完整内容')
                    .fontSize(FontSizes.small)
                    .fontColor(Colors.primary)
                }
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding(Spacing.cardPadding)
            .backgroundColor(Colors.bgPrimary)
            .borderRadius(Radius.card)
          }
          .margin({ bottom: Spacing.cardMargin })
        })
      }
      .width('100%')
      .height('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 16, bottom: 16 })
      .scrollBar(BarState.Off)
    } else {
      Column() {
        Text('💊')
          .fontSize(60)
          .opacity(0.5)
        Text('还没有埋下时空胶囊')
          .fontSize(FontSizes.body)
          .fontColor(Colors.textTertiary)
          .margin({ top: 16 })
        Button('埋一个')
          .fontSize(FontSizes.bodySmall)
          .fontColor(Colors.primary)
          .backgroundColor(Colors.primaryLightest)
          .borderRadius(Radius.full)
          .height(36)
          .padding({ left: 24, right: 24 })
          .margin({ top: 16 })
          .onClick(() => {
            this.currentTab = 0;
          })
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
  }
}
