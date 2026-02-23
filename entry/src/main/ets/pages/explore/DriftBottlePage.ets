/**
 * 漂流瓶页面 - 海洋主题沉浸式设计
 */

import { router } from '@kit.ArkUI';
import { DriftBottle, DriftBottleTypeOption } from '../../models/DriftBottle';

@Entry
@Component
struct DriftBottlePage {
  @State currentTab: number = 0;
  @State pickedBottle: DriftBottle | null = null;
  @State myContent: string = '';
  @State selectedType: 'wish' | 'story' | 'question' = 'wish';
  @State isPicking: boolean = false;
  @State myBottles: DriftBottle[] = [];
  @State bottleFloat: number = 0;

  private typeOptions: DriftBottleTypeOption[] = [
    { key: 'wish', label: '许愿', icon: '🌟', desc: '许下心愿', color: '#FEF3C7' },
    { key: 'story', label: '故事', icon: '📖', desc: '分享故事', color: '#DBEAFE' },
    { key: 'question', label: '提问', icon: '❓', desc: '抛出问题', color: '#FCE7F3' },
  ];

  aboutToAppear(): void {
    this.loadMyBottles();
    this.startBottleAnimation();
  }

  private startBottleAnimation(): void {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.EaseInOut }, () => {
        this.bottleFloat = this.bottleFloat === 0 ? -12 : 0;
      });
    }, 2000);
  }

  private loadMyBottles(): void {
    this.myBottles = [
      {
        id: 'bottle_001',
        content: '希望今年能去一次日本看樱花 🌸',
        senderNickname: '我',
        senderCity: '北京',
        createdAt: new Date(Date.now() - 86400000).toISOString(),
        type: 'wish',
      },
      {
        id: 'bottle_002',
        content: '在成都吃到了超级好吃的火锅，分享给有缘人 🌶️',
        senderNickname: '我',
        senderCity: '成都',
        createdAt: new Date(Date.now() - 172800000).toISOString(),
        type: 'story',
      },
      {
        id: 'bottle_003',
        content: '一个人旅行是什么感觉？有没有人分享一下经验？',
        senderNickname: '我',
        senderCity: '上海',
        createdAt: new Date(Date.now() - 259200000).toISOString(),
        type: 'question',
      },
    ];
  }

  private pickBottle(): void {
    if (this.isPicking) return;
    this.isPicking = true;
    this.pickedBottle = null;

    setTimeout(() => {
      this.isPicking = false;
      this.pickedBottle = {
        id: `bottle_${Date.now()}`,
        content: '希望每个看到这条消息的人都能开心每一天！遇见美好，遇见幸福 ✨',
        senderNickname: '漂流者',
        senderCity: '上海',
        createdAt: new Date(Date.now() - 3600000 * 5).toISOString(),
        type: 'wish',
      };
    }, 2000);
  }

  private throwBottle(): void {
    if (!this.myContent.trim()) return;

    const newBottle: DriftBottle = {
      id: `bottle_${Date.now()}`,
      content: this.myContent,
      senderNickname: '我',
      senderCity: '北京',
      createdAt: new Date().toISOString(),
      type: this.selectedType,
    };
    this.myBottles = [newBottle, ...this.myBottles];
    this.myContent = '';
  }

  private formatTime(isoString: string): string {
    const date = new Date(isoString);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (hours < 1) return '刚刚';
    if (hours < 24) return `${hours}小时前`;
    if (days < 7) return `${days}天前`;
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  private getTypeInfo(type: string): DriftBottleTypeOption {
    return this.typeOptions.find(t => t.key === type) ||
      { key: 'wish' as 'wish', label: '许愿', icon: '🌟', desc: '', color: '#FEF3C7' };
  }

  build() {
    Stack() {
      // 海洋背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            ['#E0F2FE', 0],
            ['#BAE6FD', 0.3],
            ['#7DD3FC', 0.6],
            ['#38BDF8', 0.85],
            ['#0EA5E9', 1]
          ]
        })

      // 内容
      Column() {
        // 导航栏
        this.NavigationBar()

        // Tab 栏
        this.TabBar()

        // 内容区
        if (this.currentTab === 0) {
          this.PickContent()
        } else if (this.currentTab === 1) {
          this.ThrowContent()
        } else {
          this.MyBottlesContent()
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
      // 标题居中
      Column() {
        Text('漂流瓶')
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
        Text('来自世界各地的声音')
          .fontSize(11)
          .fontColor('#64748B')
          .margin({ top: 2 })
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')

      // 返回按钮靠左
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
        .backgroundColor('rgba(255,255,255,0.8)')
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
        ForEach(['捡瓶', '投瓶', '我的'], (tab: string, index: number) => {
          Column() {
            Text(tab)
              .fontSize(14)
              .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium)
              .fontColor(this.currentTab === index ? '#0369A1' : 'rgba(0,0,0,0.4)')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .height('100%')
          .onClick(() => { this.currentTab = index; })
        })
      }
      .width('70%')
      .height(40)
      .backgroundColor('rgba(255,255,255,0.5)')
      .borderRadius(20)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .margin({ top: 4, bottom: 8 })
  }

  // ==================== 捡瓶子 ====================

  @Builder
  PickContent() {
    Column() {
      Blank()

      if (this.isPicking) {
        // 捡瓶子动画
        Column({ space: 16 }) {
          Text('🍾')
            .fontSize(80)
            .translate({ y: this.bottleFloat })

          Text('正在海上寻找漂流瓶...')
            .fontSize(15)
            .fontColor('rgba(255,255,255,0.9)')

          LoadingProgress()
            .width(28)
            .height(28)
            .color(Color.White)
        }
        .alignItems(HorizontalAlign.Center)

      } else if (this.pickedBottle !== null) {
        // 捡到瓶子的结果
        Column() {
          Text('🎉')
            .fontSize(40)
            .margin({ bottom: 8 })

          Text('你捡到了一个漂流瓶')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')

          // 瓶子内容卡片
          Column() {
            // 类型标签
            Row() {
              Text(this.getTypeInfo(this.pickedBottle.type).icon)
                .fontSize(14)
              Text(this.getTypeInfo(this.pickedBottle.type).label)
                .fontSize(12)
                .fontColor('#64748B')
                .margin({ left: 4 })
            }
            .padding({ left: 12, right: 12, top: 6, bottom: 6 })
            .backgroundColor(this.getTypeInfo(this.pickedBottle.type).color)
            .borderRadius(12)
            .alignSelf(ItemAlign.Start)

            // 内容
            Text(this.pickedBottle.content)
              .fontSize(16)
              .fontColor('#1E293B')
              .lineHeight(26)
              .margin({ top: 16 })

            // 分隔线
            Column()
              .width('100%')
              .height(1)
              .backgroundColor('#F1F5F9')
              .margin({ top: 20, bottom: 16 })

            // 发送者信息
            Row() {
              Column() {
                Text('🧑‍✈️')
                  .fontSize(18)
              }
              .width(36)
              .height(36)
              .backgroundColor('#EFF6FF')
              .borderRadius(18)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)

              Column() {
                Text(this.pickedBottle.senderNickname)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#1E293B')
                Row() {
                  Text(`📍 ${this.pickedBottle.senderCity}`)
                    .fontSize(11)
                    .fontColor('#94A3B8')
                  Text(` · ${this.formatTime(this.pickedBottle.createdAt)}`)
                    .fontSize(11)
                    .fontColor('#94A3B8')
                }
                .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .shadow({ radius: 20, color: 'rgba(0,0,0,0.08)', offsetY: 4 })
          .margin({ top: 20 })

          // 操作按钮
          Row({ space: 12 }) {
            Row() {
              Text('💬 回复TA')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#0369A1')
            }
            .layoutWeight(1)
            .height(46)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('rgba(255,255,255,0.9)')
            .borderRadius(23)

            Row() {
              Text('🌊 再捡一个')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
            }
            .layoutWeight(1)
            .height(46)
            .justifyContent(FlexAlign.Center)
            .backgroundColor('rgba(255,255,255,0.25)')
            .borderRadius(23)
            .border({ width: 1, color: 'rgba(255,255,255,0.4)' })
            .onClick(() => { this.pickBottle(); })
          }
          .width('100%')
          .margin({ top: 20 })
        }
        .width('100%')
        .padding({ left: 24, right: 24 })

      } else {
        // 初始状态
        Column({ space: 12 }) {
          // 漂流瓶漂浮动画
          Text('🍾')
            .fontSize(90)
            .translate({ y: this.bottleFloat })

          Text('大海里藏着很多故事')
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
            .fontColor('rgba(255,255,255,0.95)')
            .margin({ top: 16 })

          Text('点击下方按钮，捡一个漂流瓶')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.6)')
        }
        .alignItems(HorizontalAlign.Center)
      }

      Blank()

      // 捡瓶子按钮
      if (this.pickedBottle === null) {
        Column() {
          Row() {
            Text('🍾')
              .fontSize(18)
            Text('捡一个漂流瓶')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#0369A1')
              .margin({ left: 8 })
          }
          .width('80%')
          .height(52)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255,255,255,0.9)')
          .borderRadius(26)
          .shadow({ radius: 16, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
          .onClick(() => { this.pickBottle(); })
        }
        .margin({ bottom: 60 })
      }
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  // ==================== 投瓶子 ====================

  @Builder
  ThrowContent() {
    Column() {
      Scroll() {
        Column() {
          // 类型选择
          Column() {
            Text('选择漂流瓶类型')
              .fontSize(13)
              .fontColor('rgba(255,255,255,0.7)')
              .margin({ bottom: 12 })

            Row({ space: 12 }) {
              ForEach(this.typeOptions, (option: DriftBottleTypeOption) => {
                Column() {
                  Text(option.icon)
                    .fontSize(28)
                  Text(option.label)
                    .fontSize(13)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.selectedType === option.key ? '#0369A1' : '#64748B')
                    .margin({ top: 6 })
                  Text(option.desc)
                    .fontSize(10)
                    .fontColor('#94A3B8')
                    .margin({ top: 2 })
                }
                .layoutWeight(1)
                .padding({ top: 16, bottom: 16 })
                .backgroundColor(this.selectedType === option.key ? 'rgba(255,255,255,0.95)' : 'rgba(255,255,255,0.6)')
                .borderRadius(16)
                .border({
                  width: 2,
                  color: this.selectedType === option.key ? '#38BDF8' : 'transparent'
                })
                .alignItems(HorizontalAlign.Center)
                .shadow(this.selectedType === option.key ?
                  { radius: 12, color: 'rgba(56,189,248,0.2)', offsetY: 4 } :
                  { radius: 0, color: 'transparent', offsetY: 0 })
                .onClick(() => { this.selectedType = option.key; })
              })
            }
            .width('100%')
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 20 })
          .alignItems(HorizontalAlign.Center)

          // 内容输入
          Column() {
            TextArea({
              placeholder: '写下你想说的话，让它漂向远方...',
              text: this.myContent
            })
              .width('100%')
              .height(180)
              .fontSize(15)
              .fontColor('#1E293B')
              .placeholderColor('#94A3B8')
              .backgroundColor('transparent')
              .padding(0)
              .onChange((value: string) => { this.myContent = value; })

            Row() {
              Blank()
              Text(`${this.myContent.length}/200`)
                .fontSize(12)
                .fontColor('#94A3B8')
            }
            .width('100%')
          }
          .width('100%')
          .padding(20)
          .margin({ left: 20, right: 20, top: 16 })
          .backgroundColor('rgba(255,255,255,0.85)')
          .borderRadius(20)
        }
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 投瓶按钮
      Column() {
        Row() {
          Text('🍾')
            .fontSize(18)
          Text('扔进大海')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.myContent.trim() ? '#FFFFFF' : 'rgba(255,255,255,0.5)')
            .margin({ left: 8 })
        }
        .width('80%')
        .height(52)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.myContent.trim() ? '#0369A1' : 'rgba(0,0,0,0.1)')
        .borderRadius(26)
        .shadow(this.myContent.trim() ?
          { radius: 16, color: 'rgba(3,105,161,0.3)', offsetY: 4 } :
          { radius: 0, color: 'transparent', offsetY: 0 })
        .onClick(() => { this.throwBottle(); })
      }
      .margin({ bottom: 60 })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  // ==================== 我的瓶子 ====================

  @Builder
  MyBottlesContent() {
    if (this.myBottles.length > 0) {
      Scroll() {
        Column({ space: 12 }) {
          // 统计信息
          Row({ space: 16 }) {
            Column() {
              Text(`${this.myBottles.length}`)
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('已投出')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.7)')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Center)

            Column()
              .width(1)
              .height(30)
              .backgroundColor('rgba(255,255,255,0.3)')

            Column() {
              Text('12')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('被捡起')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.7)')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Center)

            Column()
              .width(1)
              .height(30)
              .backgroundColor('rgba(255,255,255,0.3)')

            Column() {
              Text('5')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('收到回复')
                .fontSize(11)
                .fontColor('rgba(255,255,255,0.7)')
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Center)
          }
          .width('100%')
          .padding({ top: 16, bottom: 16 })
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255,255,255,0.15)')
          .borderRadius(16)

          // 瓶子列表
          ForEach(this.myBottles, (bottle: DriftBottle) => {
            Column() {
              Row() {
                // 类型标签
                Row() {
                  Text(this.getTypeInfo(bottle.type).icon)
                    .fontSize(12)
                  Text(this.getTypeInfo(bottle.type).label)
                    .fontSize(11)
                    .fontColor('#64748B')
                    .margin({ left: 4 })
                }
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(this.getTypeInfo(bottle.type).color)
                .borderRadius(10)

                Blank()

                Text(this.formatTime(bottle.createdAt))
                  .fontSize(11)
                  .fontColor('#94A3B8')
              }
              .width('100%')

              Text(bottle.content)
                .fontSize(14)
                .fontColor('#1E293B')
                .lineHeight(22)
                .margin({ top: 12 })

              Row() {
                Text(`📍 ${bottle.senderCity}`)
                  .fontSize(11)
                  .fontColor('#94A3B8')

                Blank()

                Row() {
                  Text('💬 0')
                    .fontSize(11)
                    .fontColor('#94A3B8')
                }
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding(16)
            .backgroundColor('rgba(255,255,255,0.9)')
            .borderRadius(16)
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
          Text('🍾')
            .fontSize(60)
            .opacity(0.6)
          Text('还没有投过漂流瓶')
            .fontSize(15)
            .fontColor('rgba(255,255,255,0.8)')
          Row() {
            Text('去投一个')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#0369A1')
          }
          .padding({ left: 24, right: 24, top: 10, bottom: 10 })
          .backgroundColor('rgba(255,255,255,0.9)')
          .borderRadius(20)
          .onClick(() => { this.currentTab = 1; })
        }
        .alignItems(HorizontalAlign.Center)
        Blank()
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}