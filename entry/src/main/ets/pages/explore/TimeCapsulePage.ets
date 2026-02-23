/**
 * 时空胶囊页面 - 星空主题沉浸式设计
 */

import { router } from '@kit.ArkUI';
import { TimeCapsule, CapsuleLocation } from '../../models/TimeCapsule'; 

@Entry
@Component
struct TimeCapsulePage {
  @State currentTab: number = 0;
  @State content: string = '';
  @State targetDate: string = '';
  @State myCapsules: TimeCapsule[] = [];
  @State selectedYearIndex: number = 0;
  @State capsuleFloat: number = 0;

  private yearOptions: string[] = ['1年后', '2年后', '5年后', '10年后'];
  private yearValues: number[] = [1, 2, 5, 10];

  aboutToAppear(): void {
    this.loadMyCapsules();
    this.setTargetYear(0);
    this.startFloatAnimation();
  }

  private startFloatAnimation(): void {
    setInterval(() => {
      animateTo({ duration: 2500, curve: Curve.EaseInOut }, () => {
        this.capsuleFloat = this.capsuleFloat === 0 ? -8 : 0;
      });
    }, 2500);
  }

  private setTargetYear(index: number): void {
    this.selectedYearIndex = index;
    const future = new Date();
    future.setFullYear(future.getFullYear() + this.yearValues[index]);
    this.targetDate = future.toISOString().split('T')[0];
  }

  private loadMyCapsules(): void {
    this.myCapsules = [
      {
        id: 'capsule_001',
        content: '希望明年的自己已经实现了环球旅行的梦想！加油！💪',
        images: [],
        targetDate: '2026-12-31',
        createdAt: new Date(Date.now() - 30 * 86400000).toISOString(),
        location: { cityName: '北京', address: '国贸' },
        status: 'locked',
      },
      {
        id: 'capsule_002',
        content: '今天是毕业旅行的最后一天，和最好的朋友们在鼓浪屿看了最美的日落...',
        images: [],
        targetDate: '2024-06-01',
        createdAt: new Date(Date.now() - 365 * 86400000).toISOString(),
        location: { cityName: '厦门', address: '鼓浪屿' },
        status: 'unlocked',
      },
      {
        id: 'capsule_003',
        content: '🔐 内容已加密，等待解封...',
        images: [],
        targetDate: '2028-01-01',
        createdAt: new Date(Date.now() - 60 * 86400000).toISOString(),
        location: { cityName: '成都', address: '宽窄巷子' },
        status: 'locked',
      },
    ];
  }

  private buryCapsule(): void {
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
    this.currentTab = 1;
  }

  private formatDate(dateStr: string): string {
    const date = new Date(dateStr);
    return `${date.getFullYear()}.${(date.getMonth() + 1).toString().padStart(2, '0')}.${date.getDate().toString().padStart(2, '0')}`;
  }

  private getDaysRemaining(targetDate: string): number {
    const target = new Date(targetDate);
    const now = new Date();
    const diff = target.getTime() - now.getTime();
    return Math.max(0, Math.ceil(diff / 86400000));
  }

  build() {
    Stack() {
      // 星空背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#0F172A', 0],
            ['#1E293B', 0.3],
            ['#1E3A5F', 0.6],
            ['#1E40AF', 0.85],
            ['#3B82F6', 1]
          ]
        })

      // 星星装饰
      Column().width(3).height(3).borderRadius(1.5)
        .backgroundColor('#FFFFFF').opacity(0.6).position({ x: '15%', y: '8%' })
      Column().width(2).height(2).borderRadius(1)
        .backgroundColor('#FFFFFF').opacity(0.4).position({ x: '82%', y: '5%' })
      Column().width(4).height(4).borderRadius(2)
        .backgroundColor('#FFFFFF').opacity(0.3).position({ x: '45%', y: '3%' })
      Column().width(2).height(2).borderRadius(1)
        .backgroundColor('#FFFFFF').opacity(0.5).position({ x: '70%', y: '12%' })
      Column().width(3).height(3).borderRadius(1.5)
        .backgroundColor('#FFFFFF').opacity(0.25).position({ x: '25%', y: '15%' })
      Column().width(2).height(2).borderRadius(1)
        .backgroundColor('#FFFFFF').opacity(0.4).position({ x: '90%', y: '18%' })

      // 光效装饰
      Column()
        .width(250)
        .height(250)
        .borderRadius(125)
        .backgroundColor('#3B82F6')
        .opacity(0.08)
        .blur(80)
        .position({ x: '60%', y: '10%' })

      Column()
        .width(180)
        .height(180)
        .borderRadius(90)
        .backgroundColor('#8B5CF6')
        .opacity(0.06)
        .blur(60)
        .position({ x: '10%', y: '35%' })

      // 内容
      Column() {
        this.NavigationBar()
        this.TabBar()

        if (this.currentTab === 0) {
          this.BuryContent()
        } else {
          this.MyCapsulesContent()
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 导航栏 ====================

  @Builder
  NavigationBar() {
    Stack() {
      Column() {
        Text('时空胶囊')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
        Text('写给未来的自己')
          .fontSize(11)
          .fontColor('rgba(255,255,255,0.5)')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')

      Row() {
        Column() {
          Text('←')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
        }
        .width(38)
        .height(38)
        .borderRadius(19)
        .backgroundColor('rgba(255,255,255,0.1)')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => { router.back(); })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 44, bottom: 8 })
  }

  // ==================== Tab栏 ====================

  @Builder
  TabBar() {
    Row() {
      Row() {
        ForEach(['埋下胶囊', '我的胶囊'], (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.currentTab === index ? '#FFFFFF' : 'rgba(255,255,255,0.4)')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height('100%')
          .onClick(() => { this.currentTab = index; })
        })
      }
      .width('65%')
      .height(40)
      .backgroundColor('rgba(255,255,255,0.1)')
      .borderRadius(20)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 4, bottom: 8 })
  }

  // ==================== 埋下胶囊 ====================

  @Builder
  BuryContent() {
    Scroll() {
      Column() {
        // 胶囊图标 + 漂浮动画
        Column({ space: 8 }) {
          Text('⏳')
            .fontSize(64)
            .translate({ y: this.capsuleFloat })

          Text('封存此刻，寄往未来')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(255,255,255,0.9)')
            .margin({ top: 12 })

          Text('这封信将在你选择的日期解封')
            .fontSize(12)
            .fontColor('rgba(255,255,255,0.4)')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ top: 24, bottom: 24 })

        // 内容输入卡片
        Column() {
          Row() {
            Text('✏️')
              .fontSize(14)
            Text('写下你想说的话')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1E293B')
              .margin({ left: 6 })
          }
          .width('100%')
          .margin({ bottom: 12 })

          TextArea({
            placeholder: '写给未来的自己，或者记录此刻的心情...',
            text: this.content
          })
            .width('100%')
            .height(160)
            .fontSize(14)
            .fontColor('#1E293B')
            .placeholderColor('#94A3B8')
            .backgroundColor('#F8FAFC')
            .borderRadius(12)
            .padding(14)
            .onChange((value: string) => { this.content = value; })

          Row() {
            Blank()
            Text(`${this.content.length}/500`)
              .fontSize(11)
              .fontColor('#94A3B8')
          }
          .width('100%')
          .margin({ top: 6 })
        }
        .width('100%')
        .padding(20)
        .margin({ left: 20, right: 20 })
        .backgroundColor('rgba(255,255,255,0.92)')
        .borderRadius(20)

        // 解封日期选择
        Column() {
          Row() {
            Text('📅')
              .fontSize(14)
            Text('选择解封时间')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1E293B')
              .margin({ left: 6 })
          }
          .width('100%')
          .margin({ bottom: 16 })

          // 当前选择的日期
          Row() {
            Column() {
              Text(this.formatDate(this.targetDate))
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E293B')
              Text(`还有 ${this.getDaysRemaining(this.targetDate)} 天`)
                .fontSize(12)
                .fontColor('#3B82F6')
                .margin({ top: 4 })
            }
            .alignItems(HorizontalAlign.Start)

            Blank()

            Text('⏳')
              .fontSize(28)
          }
          .width('100%')
          .padding(16)
          .backgroundColor('#F0F9FF')
          .borderRadius(14)
          .margin({ bottom: 14 })

          // 快捷选择
          Row({ space: 8 }) {
            ForEach(this.yearOptions, (label: string, index: number) => {
              Column() {
                Text(label)
                  .fontSize(13)
                  .fontWeight(this.selectedYearIndex === index ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(this.selectedYearIndex === index ? '#FFFFFF' : '#64748B')
              }
              .layoutWeight(1)
              .height(38)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor(this.selectedYearIndex === index ? '#3B82F6' : '#F1F5F9')
              .borderRadius(19)
              .onClick(() => { this.setTargetYear(index); })
            })
          }
          .width('100%')
        }
        .width('100%')
        .padding(20)
        .margin({ left: 20, right: 20, top: 16 })
        .backgroundColor('rgba(255,255,255,0.92)')
        .borderRadius(20)

        // 添加照片
        Column() {
          Row() {
            Text('📷')
              .fontSize(14)
            Text('添加照片')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#1E293B')
              .margin({ left: 6 })

            Text('可选')
              .fontSize(11)
              .fontColor('#94A3B8')
              .margin({ left: 6 })
          }
          .width('100%')
          .margin({ bottom: 12 })

          Row() {
            Column() {
              Text('+')
                .fontSize(24)
                .fontColor('#94A3B8')
              Text('添加')
                .fontSize(10)
                .fontColor('#CBD5E1')
                .margin({ top: 4 })
            }
            .width(72)
            .height(72)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#F8FAFC')
            .borderRadius(12)
            .border({ width: 1.5, color: '#E2E8F0', style: BorderStyle.Dashed })
          }
          .width('100%')
        }
        .width('100%')
        .padding(20)
        .margin({ left: 20, right: 20, top: 16 })
        .backgroundColor('rgba(255,255,255,0.92)')
        .borderRadius(20)

        // 埋下按钮
        Column() {
          Row() {
            Text('⏳')
              .fontSize(18)
            Text('封存这一刻')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.content.trim() ? '#FFFFFF' : 'rgba(255,255,255,0.4)')
              .margin({ left: 8 })
          }
          .width('80%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .linearGradient({
            direction: GradientDirection.Right,
            colors: this.content.trim()
              ? [['#3B82F6', 0], ['#8B5CF6', 1]]
              : [['rgba(255,255,255,0.1)', 0], ['rgba(255,255,255,0.1)', 1]]
          })
          .borderRadius(26)
          .shadow(this.content.trim()
            ? { radius: 16, color: 'rgba(59,130,246,0.3)', offsetY: 4 }
            : { radius: 0, color: 'transparent', offsetY: 0 })
          .onClick(() => { this.buryCapsule(); })
        }
        .margin({ top: 32, bottom: 60 })
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  // ==================== 我的胶囊 ====================

  @Builder
  MyCapsulesContent() {
    if (this.myCapsules.length > 0) {
      Scroll() {
        Column({ space: 12 }) {
          // 统计
          Row({ space: 20 }) {
            Column() {
              Text(`${this.myCapsules.length}`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('总计')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.5)')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Center)

            Column()
              .width(1)
              .height(28)
              .backgroundColor('rgba(255,255,255,0.2)')

            Column() {
              Text(`${this.myCapsules.filter((c: TimeCapsule) => c.status === 'locked').length}`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('待解封')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.5)')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Center)

            Column()
              .width(1)
              .height(28)
              .backgroundColor('rgba(255,255,255,0.2)')

            Column() {
              Text(`${this.myCapsules.filter((c: TimeCapsule) => c.status === 'unlocked').length}`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('已解封')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.5)')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255,255,255,0.08)')
          .borderRadius(16)

          // 胶囊列表
          ForEach(this.myCapsules, (capsule: TimeCapsule) => {
            Column() {
              // 顶部：状态 + 日期
              Row() {
                Row() {
                  Text(capsule.status === 'locked' ? '🔒' : '✨')
                    .fontSize(13)
                  Text(capsule.status === 'locked' ? '待解封' : '已解封')
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(capsule.status === 'locked' ? '#64748B' : '#059669')
                    .margin({ left: 4 })
                }
                .padding({ left: 10, right: 10, top: 5, bottom: 5 })
                .backgroundColor(capsule.status === 'locked' ? '#F1F5F9' : '#ECFDF5')
                .borderRadius(10)

                Blank()

                Text(this.formatDate(capsule.createdAt.split('T')[0]))
                  .fontSize(11)
                  .fontColor('#94A3B8')
              }
              .width('100%')

              // 内容
              if (capsule.status === 'unlocked') {
                Text(capsule.content)
                  .fontSize(14)
                  .fontColor('#1E293B')
                  .lineHeight(22)
                  .margin({ top: 14 })
                  .maxLines(3)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              } else {
                // 加密内容
                Row() {
                  Column() {
                    Text('🔐')
                      .fontSize(24)
                  }
                  .margin({ right: 12 })

                  Column() {
                    Text('内容已加密封存')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#64748B')

                    Row() {
                      Text(`${this.getDaysRemaining(capsule.targetDate)}`)
                        .fontSize(20)
                        .fontWeight(FontWeight.Bold)
                        .fontColor('#3B82F6')
                      Text(' 天后解封')
                        .fontSize(13)
                        .fontColor('#94A3B8')
                    }
                    .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                }
                .width('100%')
                .padding(14)
                .backgroundColor('#F8FAFC')
                .borderRadius(12)
                .margin({ top: 14 })
              }

              // 底部：位置 + 解封日期
              Column()
                .width('100%')
                .height(1)
                .backgroundColor('#F1F5F9')
                .margin({ top: 14, bottom: 12 })

              Row() {
                Row() {
                  Text('📍')
                    .fontSize(12)
                  Text(`${capsule.location.cityName} · ${capsule.location.address}`)
                    .fontSize(12)
                    .fontColor('#94A3B8')
                    .margin({ left: 4 })
                }

                Blank()

                Text(`${this.formatDate(capsule.targetDate)} 解封`)
                  .fontSize(12)
                  .fontColor(capsule.status === 'locked' ? '#3B82F6' : '#94A3B8')
              }
              .width('100%')
            }
            .width('100%')
            .padding(18)
            .backgroundColor('rgba(255,255,255,0.92)')
            .borderRadius(18)
          })
        }
        .padding({ left: 20, right: 20, top: 12, bottom: 80 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    } else {
      Column() {
        Blank()
        Column({ space: 12 }) {
          Text('⏳')
            .fontSize(60)
            .opacity(0.5)
          Text('还没有埋下时空胶囊')
            .fontSize(15)
            .fontColor('rgba(255,255,255,0.7)')
          Row() {
            Text('埋下第一个')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#3B82F6')
          }
          .padding({ left: 24, right: 24, top: 10, bottom: 10 })
          .backgroundColor('rgba(255,255,255,0.9)')
          .borderRadius(20)
          .onClick(() => { this.currentTab = 0; })
        }
        .alignItems(HorizontalAlign.Center)
        Blank()
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}