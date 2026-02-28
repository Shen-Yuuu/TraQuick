/**
 * 漂流瓶页面 - 对接真实 API (严格模式)
 */

import { router, promptAction } from '@kit.ArkUI';
import { ApiService, ApiDriftBottle, CreateBottleParams } from '../../services/ApiService';

// ====== 状态类定义 ======
class BottleItem {
  id: string = '';
  content: string = '';
  senderNickname: string = '';
  senderCity: string = '';
  createdAt: string = '';
  type: string = 'wish';

  constructor() {}
}

class BottleTypeOption {
  key: string = '';
  label: string = '';
  icon: string = '';
  desc: string = '';
  color: string = '';

  constructor(key: string, label: string, icon: string, desc: string, color: string) {
    this.key = key;
    this.label = label;
    this.icon = icon;
    this.desc = desc;
    this.color = color;
  }
}

@Entry
@Component
struct DriftBottlePage {
  @State currentTab: number = 0; // 0:捡瓶, 1:投瓶, 2:我的
  @State pickedBottle: BottleItem | null = null;
  @State myContent: string = '';
  @State selectedType: string = 'wish';
  @State isPicking: boolean = false;
  @State isThrowing: boolean = false;

  @State mySentBottles: BottleItem[] = [];
  @State myPickedBottles: BottleItem[] = []; // 本页面为了简化展示，目前"我的"Tab只显示我投出的

  @State bottleFloat: number = 0;
  @State isLoading: boolean = false;

  private typeOptions: BottleTypeOption[] = [
    new BottleTypeOption('wish', '许愿', '🌟', '许下心愿', '#FEF3C7'),
    new BottleTypeOption('story', '故事', '📖', '分享故事', '#DBEAFE'),
    new BottleTypeOption('question', '提问', '❓', '抛出问题', '#FCE7F3'),
  ];

  aboutToAppear(): void {
    this.startBottleAnimation();
  }

  onPageShow(): void {
    if (this.currentTab === 2 && this.mySentBottles.length === 0) {
      this.loadMyBottles();
    }
  }

  private startBottleAnimation(): void {
    setInterval(() => {
      animateTo({ duration: 2000, curve: Curve.EaseInOut }, () => {
        this.bottleFloat = this.bottleFloat === 0 ? -12 : 0;
      });
    }, 2000);
  }

  /**
   * 加载我投出的瓶子
   */
  private async loadMyBottles(): Promise<void> {
    this.isLoading = true;
    try {
      const apiBottles: ApiDriftBottle[] = await ApiService.getMySentBottles();
      const newBottles: BottleItem[] = [];

      for (const ab of apiBottles) {
        newBottles.push(this.convertApiBottle(ab));
      }
      this.mySentBottles = newBottles;

    } catch (error) {
      console.error('[DriftBottle] 加载我的瓶子失败:', (error as Error).message);
    } finally {
      this.isLoading = false;
    }
  }

  private convertApiBottle(ab: ApiDriftBottle): BottleItem {
    const item = new BottleItem();
    item.id = ab.id;
    item.content = ab.content;
    item.senderNickname = ab.senderNickname;
    item.senderCity = ab.senderCity || '未知海域';
    item.createdAt = ab.createdAt;
    item.type = ab.type;
    return item;
  }

  /**
   * 捡瓶子
   */
  private async pickBottle(): Promise<void> {
    if (this.isPicking) return;
    this.isPicking = true;
    this.pickedBottle = null;

    try {
      const apiBottle = await ApiService.pickBottle();

      // 故意延迟1秒增加"寻找"的沉浸感
      setTimeout(() => {
        this.pickedBottle = this.convertApiBottle(apiBottle);
        this.isPicking = false;
      }, 1000);

    } catch (error) {
      setTimeout(() => {
        this.isPicking = false;
        promptAction.showToast({ message: (error as Error).message || '海面上空空如也，过会再来吧' });
      }, 1000);
    }
  }

  /**
   * 扔瓶子
   */
  private async throwBottle(): Promise<void> {
    if (!this.myContent.trim() || this.isThrowing) return;
    this.isThrowing = true;

    try {
      const params = new CreateBottleParams();
      params.content = this.myContent;
      params.type = this.selectedType;

      await ApiService.createBottle(params);

      promptAction.showToast({ message: '瓶子已随波逐流...' });
      this.myContent = '';

      // 清空本地缓存强制重新加载
      this.mySentBottles = [];
      this.currentTab = 2; // 跳转到"我的"

    } catch (error) {
      promptAction.showToast({ message: '扔瓶子失败: ' + (error as Error).message });
    } finally {
      this.isThrowing = false;
    }
  }

  private formatTime(isoString: string): string {
    if (!isoString) return '';
    const date = new Date(isoString);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
  }

  private getTypeInfo(type: string): BottleTypeOption {
    const found = this.typeOptions.find(t => t.key === type);
    return found ? found : new BottleTypeOption('wish', '许愿', '🌟', '', '#FEF3C7');
  }

  build() {
    Stack() {
      // 海洋背景
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#E0F2FE', 0], ['#BAE6FD', 0.3], ['#7DD3FC', 0.6], ['#38BDF8', 0.85], ['#0EA5E9', 1]]
        })

      // 内容
      Column() {
        this.NavigationBar()
        this.TabBar()

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

  @Builder
  NavigationBar() {
    Stack() {
      Column() {
        Text('漂流瓶').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#1E293B')
        Text('来自世界各地的声音').fontSize(11).fontColor('#64748B').margin({ top: 2 })
      }.alignItems(HorizontalAlign.Center).width('100%')

      Row() {
        Column() { Text('←').fontSize(22).fontWeight(FontWeight.Medium).fontColor('#1E293B') }
        .width(38).height(38).borderRadius(19).backgroundColor('rgba(255,255,255,0.8)').justifyContent(FlexAlign.Center).onClick(() => { router.back(); })
      }.width('100%').justifyContent(FlexAlign.Start)
    }.width('100%').padding({ left: 20, right: 20, top: 44, bottom: 8 })
  }

  @Builder
  TabBar() {
    Row() {
      Row() {
        ForEach(['捡瓶', '投瓶', '我的'], (tab: string, index: number) => {
          Column() {
            Text(tab).fontSize(14).fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium).fontColor(this.currentTab === index ? '#0369A1' : 'rgba(0,0,0,0.4)')
          }.layoutWeight(1).justifyContent(FlexAlign.Center).height('100%')
          .onClick(() => {
            this.currentTab = index;
            if (index === 2 && this.mySentBottles.length === 0) {
              this.loadMyBottles();
            }
          })
        })
      }.width('70%').height(40).backgroundColor('rgba(255,255,255,0.5)').borderRadius(20)
    }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 4, bottom: 8 })
  }

  @Builder
  PickContent() {
    Column() {
      Blank()
      if (this.isPicking) {
        Column({ space: 16 }) {
          Text('🍾').fontSize(80).translate({ y: this.bottleFloat })
          Text('正在海上寻找漂流瓶...').fontSize(15).fontColor('rgba(255,255,255,0.9)')
          LoadingProgress().width(28).height(28).color(Color.White)
        }.alignItems(HorizontalAlign.Center)

      } else if (this.pickedBottle !== null) {
        Column() {
          Text('🎉').fontSize(40).margin({ bottom: 8 })
          Text('你捡到了一个漂流瓶').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')

          Column() {
            Row() {
              Text(this.getTypeInfo(this.pickedBottle.type).icon).fontSize(14)
              Text(this.getTypeInfo(this.pickedBottle.type).label).fontSize(12).fontColor('#64748B').margin({ left: 4 })
            }.padding({ left: 12, right: 12, top: 6, bottom: 6 }).backgroundColor(this.getTypeInfo(this.pickedBottle.type).color).borderRadius(12).alignSelf(ItemAlign.Start)

            Text(this.pickedBottle.content).fontSize(16).fontColor('#1E293B').lineHeight(26).margin({ top: 16 })

            Column().width('100%').height(1).backgroundColor('#F1F5F9').margin({ top: 20, bottom: 16 })

            Row() {
              Column() { Text('🧑‍✈️').fontSize(18) }.width(36).height(36).backgroundColor('#EFF6FF').borderRadius(18).justifyContent(FlexAlign.Center)
              Column() {
                Text(this.pickedBottle.senderNickname).fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E293B')
                Row() {
                  Text(`📍 ${this.pickedBottle.senderCity}`).fontSize(11).fontColor('#94A3B8')
                  Text(` · ${this.formatTime(this.pickedBottle.createdAt)}`).fontSize(11).fontColor('#94A3B8')
                }.margin({ top: 2 })
              }.alignItems(HorizontalAlign.Start).margin({ left: 10 })
            }
          }.width('100%').padding(20).backgroundColor('#FFFFFF').borderRadius(20).shadow({ radius: 20, color: 'rgba(0,0,0,0.08)', offsetY: 4 }).margin({ top: 20 })

          Row({ space: 12 }) {
            Row() { Text('💬 回复TA').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#0369A1') }
            .layoutWeight(1).height(46).justifyContent(FlexAlign.Center).backgroundColor('rgba(255,255,255,0.9)').borderRadius(23)
            .onClick(() => { promptAction.showToast({ message: '私信回复功能开发中' }); })

            Row() { Text('🌊 再捡一个').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#FFFFFF') }
            .layoutWeight(1).height(46).justifyContent(FlexAlign.Center).backgroundColor('rgba(255,255,255,0.25)').borderRadius(23).border({ width: 1, color: 'rgba(255,255,255,0.4)' })
            .onClick(() => { this.pickBottle(); })
          }.width('100%').margin({ top: 20 })
        }.width('100%').padding({ left: 24, right: 24 })

      } else {
        Column({ space: 12 }) {
          Text('🍾').fontSize(90).translate({ y: this.bottleFloat })
          Text('大海里藏着很多故事').fontSize(17).fontWeight(FontWeight.Medium).fontColor('rgba(255,255,255,0.95)').margin({ top: 16 })
          Text('点击下方按钮，捡一个漂流瓶').fontSize(13).fontColor('rgba(255,255,255,0.6)')
        }.alignItems(HorizontalAlign.Center)
      }

      Blank()

      if (this.pickedBottle === null) {
        Column() {
          Row() {
            Text('🍾').fontSize(18)
            Text('捡一个漂流瓶').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#0369A1').margin({ left: 8 })
          }.width('80%').height(52).justifyContent(FlexAlign.Center).backgroundColor('rgba(255,255,255,0.9)').borderRadius(26).shadow({ radius: 16, color: 'rgba(0,0,0,0.1)', offsetY: 4 })
          .onClick(() => { this.pickBottle(); })
        }.margin({ bottom: 60 })
      }
    }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
  }

  @Builder
  ThrowContent() {
    Column() {
      Scroll() {
        Column() {
          Column() {
            Text('选择漂流瓶类型').fontSize(13).fontColor('rgba(255,255,255,0.7)').margin({ bottom: 12 })
            Row({ space: 12 }) {
              ForEach(this.typeOptions, (option: BottleTypeOption) => {
                Column() {
                  Text(option.icon).fontSize(28)
                  Text(option.label).fontSize(13).fontWeight(FontWeight.Medium).fontColor(this.selectedType === option.key ? '#0369A1' : '#64748B').margin({ top: 6 })
                  Text(option.desc).fontSize(10).fontColor('#94A3B8').margin({ top: 2 })
                }
                .layoutWeight(1).padding({ top: 16, bottom: 16 }).backgroundColor(this.selectedType === option.key ? 'rgba(255,255,255,0.95)' : 'rgba(255,255,255,0.6)')
                .borderRadius(16).border({ width: 2, color: this.selectedType === option.key ? '#38BDF8' : 'transparent' })
                .alignItems(HorizontalAlign.Center).onClick(() => { this.selectedType = option.key; })
              }, (opt: BottleTypeOption) => opt.key)
            }.width('100%')
          }.width('100%').padding({ left: 20, right: 20, top: 20 }).alignItems(HorizontalAlign.Center)

          Column() {
            TextArea({ placeholder: '写下你想说的话，让它漂向远方...', text: this.myContent })
              .width('100%').height(180).fontSize(15).fontColor('#1E293B').placeholderColor('#94A3B8').backgroundColor('transparent').padding(0)
              .onChange((value: string) => { this.myContent = value; })
            Row() { Blank(); Text(`${this.myContent.length}/200`).fontSize(12).fontColor('#94A3B8') }.width('100%').margin({ top: 6 })
          }.width('100%').padding(20).margin({ left: 20, right: 20, top: 16 }).backgroundColor('rgba(255,255,255,0.85)').borderRadius(20)
        }
      }.layoutWeight(1).scrollBar(BarState.Off)

      Column() {
        Row() {
          if (this.isThrowing) {
            LoadingProgress().width(20).height(20).color('#FFFFFF')
          } else {
            Text('🍾').fontSize(18)
            Text('扔进大海').fontSize(16).fontWeight(FontWeight.Bold).fontColor(this.myContent.trim() ? '#FFFFFF' : 'rgba(255,255,255,0.5)').margin({ left: 8 })
          }
        }.width('80%').height(52).justifyContent(FlexAlign.Center).backgroundColor(this.myContent.trim() && !this.isThrowing ? '#0369A1' : 'rgba(0,0,0,0.2)').borderRadius(26)
        .onClick(() => { this.throwBottle(); })
      }.margin({ bottom: 60 })
    }.width('100%').layoutWeight(1).alignItems(HorizontalAlign.Center)
  }

  @Builder
  MyBottlesContent() {
    if (this.isLoading) {
      Column() { LoadingProgress().width(40).height(40).color('#FFFFFF') }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
    } else if (this.mySentBottles.length > 0) {
      Scroll() {
        Column({ space: 12 }) {
          Row({ space: 16 }) {
            Column() { Text(`${this.mySentBottles.length}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF'); Text('已投出').fontSize(11).fontColor('rgba(255,255,255,0.7)').margin({ top: 2 }) }.alignItems(HorizontalAlign.Center)
          }.width('100%').padding({ top: 16, bottom: 16 }).justifyContent(FlexAlign.Center).backgroundColor('rgba(255,255,255,0.15)').borderRadius(16)

          ForEach(this.mySentBottles, (bottle: BottleItem) => {
            Column() {
              Row() {
                Row() {
                  Text(this.getTypeInfo(bottle.type).icon).fontSize(12)
                  Text(this.getTypeInfo(bottle.type).label).fontSize(11).fontColor('#64748B').margin({ left: 4 })
                }.padding({ left: 10, right: 10, top: 4, bottom: 4 }).backgroundColor(this.getTypeInfo(bottle.type).color).borderRadius(10)
                Blank()
                Text(this.formatTime(bottle.createdAt)).fontSize(11).fontColor('#94A3B8')
              }.width('100%')

              Text(bottle.content).fontSize(14).fontColor('#1E293B').lineHeight(22).margin({ top: 12 }).width('100%').maxLines(3).textOverflow({ overflow: TextOverflow.Ellipsis })
            }.width('100%').padding(16).backgroundColor('rgba(255,255,255,0.9)').borderRadius(16)
          }, (bottle: BottleItem) => bottle.id)
        }.padding({ left: 20, right: 20, top: 12, bottom: 80 })
      }.layoutWeight(1).scrollBar(BarState.Off)
    } else {
      Column() {
        Blank()
        Column({ space: 12 }) {
          Text('🍾').fontSize(60).opacity(0.6)
          Text('还没有投过漂流瓶').fontSize(15).fontColor('rgba(255,255,255,0.8)')
          Row() { Text('去投一个').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#0369A1') }
          .padding({ left: 24, right: 24, top: 10, bottom: 10 }).backgroundColor('rgba(255,255,255,0.9)').borderRadius(20).onClick(() => { this.currentTab = 1; })
        }.alignItems(HorizontalAlign.Center)
        Blank()
      }.width('100%').layoutWeight(1)
    }
  }
}