/**
 * 时空胶囊页面 - 对接真实 API (严格模式)
 */

import { router, promptAction } from '@kit.ArkUI';
import { ApiService, ApiTimeCapsule, CreateCapsuleParams } from '../../services/ApiService';

// ====== 状态类定义 ======
class CapsuleItem {
  id: string = '';
  content: string = '';
  images: string[] = [];
  targetDate: string = '';
  cityName: string = '';
  address: string = '';
  status: string = 'locked'; // 'locked' | 'unlocked'
  createdAt: string = '';

  constructor() {}
}

@Entry
@Component
struct TimeCapsulePage {
  @State currentTab: number = 0; // 0: 埋胶囊, 1: 我的胶囊
  @State content: string = '';
  @State targetDate: string = '';

  @State myCapsules: CapsuleItem[] = [];
  @State isLoading: boolean = false;
  @State isBurying: boolean = false;

  @State selectedYearIndex: number = 0;
  @State capsuleFloat: number = 0;
  private capsuleAnimateTimer: number = -1;

  private yearOptions: string[] = ['1年后', '2年后', '5年后', '10年后'];
  private yearValues: number[] = [1, 2, 5, 10];

  aboutToAppear(): void {
    this.setTargetYear(0);
    this.startFloatAnimation();
  }

  onPageShow(): void {
    if (this.currentTab === 1 && this.myCapsules.length === 0) {
      this.loadMyCapsules();
    }
  }

  private startFloatAnimation(): void {
    this.capsuleAnimateTimer = setInterval(() => {
      animateTo({ duration: 2500, curve: Curve.EaseInOut }, () => {
        this.capsuleFloat = this.capsuleFloat === 0 ? -8 : 0;
      });
    }, 2500);
  }

  aboutToDisappear(): void {
    if (this.capsuleAnimateTimer !== -1) {
      clearInterval(this.capsuleAnimateTimer);
      this.capsuleAnimateTimer = -1;
    }
  }

  private setTargetYear(index: number): void {
    this.selectedYearIndex = index;
    const future = new Date();
    future.setFullYear(future.getFullYear() + this.yearValues[index]);
    this.targetDate = future.toISOString().split('T')[0];
  }

  private showCustomDatePicker(): void {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1); // 至少是明天

    const maxDate = new Date();
    maxDate.setFullYear(maxDate.getFullYear() + 10); // 最多 10 年后

    DatePickerDialog.show({
      start: tomorrow,
      end: maxDate,
      selected: this.targetDate ? new Date(this.targetDate) : tomorrow,
      onAccept: (value: DatePickerResult) => {
        const y = value.year;
        const m = (value.month! + 1).toString().padStart(2, '0');
        const d = value.day?.toString().padStart(2, '0');
        this.targetDate = `${y}-${m}-${d}`;
        this.selectedYearIndex = -1; // 取消快捷选择的高亮状态
      }
    });
  }

  /**
   * 加载我的胶囊
   */
  private async loadMyCapsules(): Promise<void> {
    this.isLoading = true;
    try {
      const apiCapsules = await ApiService.getMyCapsules();
      const newCapsules: CapsuleItem[] = [];

      for (const ac of apiCapsules) {
        const item = new CapsuleItem();
        item.id = ac.id;
        // 如果未解锁，后端直接返回了隐藏文本（或前端隐藏），这里取后端的
        item.content = ac.content;
        item.images = ac.images;
        item.targetDate = ac.targetDate;
        item.cityName = ac.cityName || '未知城市';
        item.address = ac.address || '未知地址';
        item.status = ac.status;
        item.createdAt = ac.createdAt;
        newCapsules.push(item);
      }
      this.myCapsules = newCapsules;

    } catch (error) {
      console.error('[TimeCapsule] 加载胶囊失败:', (error as Error).message);
    } finally {
      this.isLoading = false;
    }
  }

  /**
   * 埋下胶囊
   */
  private async buryCapsule(): Promise<void> {
    if (!this.content.trim() || this.isBurying) return;
    this.isBurying = true;

    try {
      const params = new CreateCapsuleParams();
      params.content = this.content;
      params.targetDate = new Date(this.targetDate).toISOString(); // 需要完整的 ISO String

      // 可以获取真实的 GPS，这里暂时 Mock
      params.cityName = '当前位置';
      params.address = '探索中';

      await ApiService.createCapsule(params);

      promptAction.showToast({ message: '胶囊已埋下，等待岁月解封' });
      this.content = '';

      // 清空缓存，切 Tab 触发重新加载
      this.myCapsules = [];
      this.currentTab = 1;

    } catch (error) {
      promptAction.showToast({ message: '埋入失败: ' + (error as Error).message });
    } finally {
      this.isBurying = false;
    }
  }

  private formatDate(dateStr: string): string {
    if (!dateStr) return '';
    const date = new Date(dateStr);
    return `${date.getFullYear()}.${(date.getMonth() + 1).toString().padStart(2, '0')}.${date.getDate().toString().padStart(2, '0')}`;
  }

  private getDaysRemaining(targetDate: string): number {
    if (!targetDate) return 0;
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
          colors: [['#0F172A', 0], ['#1E293B', 0.3], ['#1E3A5F', 0.6], ['#1E40AF', 0.85], ['#3B82F6', 1]]
        })

      // 星星与光效装饰 (省略...)
      Column().width(3).height(3).borderRadius(1.5).backgroundColor('#FFFFFF').opacity(0.6).position({ x: '15%', y: '8%' })
      Column().width(250).height(250).borderRadius(125).backgroundColor('#3B82F6').opacity(0.08).blur(80).position({ x: '60%', y: '10%' })

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

  @Builder
  NavigationBar() {
    Stack() {
      Column() {
        Text('时空胶囊').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        Text('写给未来的自己').fontSize(11).fontColor('rgba(255,255,255,0.5)').margin({ top: 2 })
      }.alignItems(HorizontalAlign.Center).width('100%')

      Row() {
        Column() { Text('←').fontSize(22).fontWeight(FontWeight.Medium).fontColor('#FFFFFF') }
        .width(38).height(38).borderRadius(19).backgroundColor('rgba(255,255,255,0.1)').justifyContent(FlexAlign.Center).onClick(() => { router.back(); })
      }.width('100%').justifyContent(FlexAlign.Start)
    }.width('100%').padding({ left: 20, right: 20, top: 44, bottom: 8 })
  }

  @Builder
  TabBar() {
    Row() {
      Row() {
        ForEach(['埋下胶囊', '我的胶囊'], (tab: string, index: number) => {
          Column() {
            Text(tab).fontSize(14).fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Medium).fontColor(this.currentTab === index ? '#FFFFFF' : 'rgba(255,255,255,0.4)')
          }.layoutWeight(1).justifyContent(FlexAlign.Center).height('100%')
          .onClick(() => {
            this.currentTab = index;
            if (index === 1 && this.myCapsules.length === 0) {
              this.loadMyCapsules();
            }
          })
        })
      }.width('65%').height(40).backgroundColor('rgba(255,255,255,0.1)').borderRadius(20)
    }.width('100%').justifyContent(FlexAlign.Center).margin({ top: 4, bottom: 8 })
  }

  @Builder
  BuryContent() {
    Scroll() {
      Column() {
        Column({ space: 8 }) {
          Text('⏳').fontSize(64).translate({ y: this.capsuleFloat })
          Text('封存此刻，寄往未来').fontSize(16).fontWeight(FontWeight.Medium).fontColor('rgba(255,255,255,0.9)').margin({ top: 12 })
        }.width('100%').alignItems(HorizontalAlign.Center).padding({ top: 24, bottom: 24 })

        Column() {
          Row() { Text('✏️').fontSize(14); Text('写下你想说的话').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E293B').margin({ left: 6 }) }.margin({ bottom: 12 })
          TextArea({ placeholder: '写给未来的自己，或者记录此刻的心情...', text: this.content })
            .width('100%').height(160).fontSize(14).backgroundColor('#F8FAFC').borderRadius(12).padding(14).onChange((value: string) => { this.content = value; })
          Row() { Blank(); Text(`${this.content.length}/500`).fontSize(11).fontColor('#94A3B8') }.width('100%').margin({ top: 6 })
        }.width('100%').padding(20).margin({ left: 20, right: 20 }).backgroundColor('rgba(255,255,255,0.92)').borderRadius(20)

        Column() {
          Row() { Text('📅').fontSize(14); Text('选择解封时间').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#1E293B').margin({ left: 6 }) }.margin({ bottom: 16 })
          Row() {
            Column() {
              Text(this.formatDate(this.targetDate)).fontSize(18).fontWeight(FontWeight.Bold).fontColor('#1E293B')
              Text(`还有 ${this.getDaysRemaining(this.targetDate)} 天`).fontSize(12).fontColor('#3B82F6').margin({ top: 4 })
            }.alignItems(HorizontalAlign.Start)
            Blank()
            Text('⏳').fontSize(28)
          }.width('100%').padding(16).backgroundColor('#F0F9FF').borderRadius(14).margin({ bottom: 14 })

          Row({ space: 8 }) {
            ForEach(this.yearOptions, (label: string, index: number) => {
              Column() {
                Text(label).fontSize(13)
                  .fontWeight(this.selectedYearIndex === index ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(this.selectedYearIndex === index ? '#FFFFFF' : '#64748B')
              }
              .layoutWeight(1).height(38).justifyContent(FlexAlign.Center)
              .backgroundColor(this.selectedYearIndex === index ? '#3B82F6' : '#F1F5F9').borderRadius(19)
              .onClick(() => { this.setTargetYear(index); })
            })

            Column() {
              Text('自定义').fontSize(13)
                .fontWeight(this.selectedYearIndex === -1 ? FontWeight.Bold : FontWeight.Medium)
                .fontColor(this.selectedYearIndex === -1 ? '#FFFFFF' : '#64748B')
            }
            .layoutWeight(1).height(38).justifyContent(FlexAlign.Center)
            .backgroundColor(this.selectedYearIndex === -1 ? '#3B82F6' : '#F1F5F9').borderRadius(19)
            .onClick(() => { this.showCustomDatePicker(); })
          }.width('100%')
        }.width('100%').padding(20).margin({ left: 20, right: 20, top: 16 }).backgroundColor('rgba(255,255,255,0.92)').borderRadius(20)

        Column() {
          Row() {
            if (this.isBurying) { LoadingProgress().width(20).height(20).color('#FFFFFF') }
            else { Text('⏳').fontSize(18); Text('封存这一刻').fontSize(16).fontWeight(FontWeight.Bold).fontColor(this.content.trim() ? '#FFFFFF' : 'rgba(255,255,255,0.4)').margin({ left: 8 }) }
          }.width('80%').height(52).justifyContent(FlexAlign.Center)
          .linearGradient({ direction: GradientDirection.Right, colors: this.content.trim() && !this.isBurying ? [['#3B82F6', 0], ['#8B5CF6', 1]] : [['rgba(255,255,255,0.1)', 0], ['rgba(255,255,255,0.1)', 1]] })
          .borderRadius(26).onClick(() => { this.buryCapsule(); })
        }.margin({ top: 32, bottom: 60 })
      }.width('100%').alignItems(HorizontalAlign.Center)
    }.layoutWeight(1).scrollBar(BarState.Off)
  }

  @Builder
  MyCapsulesContent() {
    if (this.isLoading) {
      Column() { LoadingProgress().width(40).height(40).color('#FFFFFF') }.width('100%').layoutWeight(1).justifyContent(FlexAlign.Center)
    } else if (this.myCapsules.length > 0) {
      Scroll() {
        Column({ space: 12 }) {
          Row({ space: 20 }) {
            Column() { Text(`${this.myCapsules.length}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF'); Text('总计').fontSize(11).fontColor('rgba(255,255,255,0.5)') }
            Column().width(1).height(28).backgroundColor('rgba(255,255,255,0.2)')
            Column() { Text(`${this.myCapsules.filter((c: CapsuleItem) => c.status === 'locked').length}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF'); Text('待解封').fontSize(11).fontColor('rgba(255,255,255,0.5)') }
            Column().width(1).height(28).backgroundColor('rgba(255,255,255,0.2)')
            Column() { Text(`${this.myCapsules.filter((c: CapsuleItem) => c.status === 'unlocked').length}`).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#FFFFFF'); Text('已解封').fontSize(11).fontColor('rgba(255,255,255,0.5)') }
          }.width('100%').padding({ top: 16, bottom: 16 }).justifyContent(FlexAlign.Center).backgroundColor('rgba(255,255,255,0.08)').borderRadius(16)

          ForEach(this.myCapsules, (capsule: CapsuleItem) => {
            Column() {
              Row() {
                Row() {
                  Text(capsule.status === 'locked' ? '🔒' : '✨').fontSize(13)
                  Text(capsule.status === 'locked' ? '待解封' : '已解封').fontSize(12).fontWeight(FontWeight.Medium).fontColor(capsule.status === 'locked' ? '#64748B' : '#059669').margin({ left: 4 })
                }.padding({ left: 10, right: 10, top: 5, bottom: 5 }).backgroundColor(capsule.status === 'locked' ? '#F1F5F9' : '#ECFDF5').borderRadius(10)
                Blank()
                Text(this.formatDate(capsule.createdAt)).fontSize(11).fontColor('#94A3B8')
              }.width('100%')

              if (capsule.status === 'unlocked') {
                Text(capsule.content).fontSize(14).fontColor('#1E293B').lineHeight(22).margin({ top: 14 }).width('100%')
              } else {
                Row() {
                  Column() { Text('🔐').fontSize(24) }.margin({ right: 12 })
                  Column() {
                    Text('内容已加密封存').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#64748B')
                    Row() {
                      Text(`${this.getDaysRemaining(capsule.targetDate)}`).fontSize(20).fontWeight(FontWeight.Bold).fontColor('#3B82F6')
                      Text(' 天后解封').fontSize(13).fontColor('#94A3B8')
                    }.margin({ top: 4 })
                  }.alignItems(HorizontalAlign.Start)
                }.width('100%').padding(14).backgroundColor('#F8FAFC').borderRadius(12).margin({ top: 14 })
              }

              Column().width('100%').height(1).backgroundColor('#F1F5F9').margin({ top: 14, bottom: 12 })
              Row() {
                Row() { Text('📍').fontSize(12); Text(`${capsule.cityName} · ${capsule.address}`).fontSize(12).fontColor('#94A3B8').margin({ left: 4 }) }
                Blank()
                Text(`${this.formatDate(capsule.targetDate)} 解封`).fontSize(12).fontColor(capsule.status === 'locked' ? '#3B82F6' : '#94A3B8')
              }.width('100%')
            }.width('100%').padding(18).backgroundColor('rgba(255,255,255,0.92)').borderRadius(18)
          }, (capsule: CapsuleItem) => capsule.id)
        }.padding({ left: 20, right: 20, top: 12, bottom: 80 })
      }.layoutWeight(1).scrollBar(BarState.Off)
    } else {
      Column() {
        Blank()
        Column({ space: 12 }) {
          Text('⏳').fontSize(60).opacity(0.5)
          Text('还没有埋下时空胶囊').fontSize(15).fontColor('rgba(255,255,255,0.7)')
          Row() { Text('埋下第一个').fontSize(14).fontWeight(FontWeight.Medium).fontColor('#3B82F6') }
          .padding({ left: 24, right: 24, top: 10, bottom: 10 }).backgroundColor('rgba(255,255,255,0.9)').borderRadius(20).onClick(() => { this.currentTab = 0; })
        }.alignItems(HorizontalAlign.Center)
        Blank()
      }.width('100%').layoutWeight(1)
    }
  }
}