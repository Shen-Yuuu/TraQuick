/**
 * TraQuick 主页面- Tab容器
 */

import { ExplorePage } from './explore/ExplorePage';
import { CommunityPage } from './community/CommunityPage';
import { MessagePage } from './message/MessagePage';
import { ProfilePage } from './profile/ProfilePage';
import { PublishSelectDialog } from '../components/publish/PublishSelectDialog';
import { Colors, FontSizes, Radius, TabBarConfig } from '../utils/Constants';
import { router } from '@kit.ArkUI';

interface TabItem {
  icon: string;
  iconActive: string;
  label: string;
}

@Entry
@Component
struct Index {
  @State currentTabIndex: number = 0;
  @State showPublishDialog: boolean = false;
  @StorageLink('communityRefreshTrigger') communityRefreshTrigger: number = 0;
  @StorageLink('exploreShakeTrigger') exploreShakeTrigger: number = 0;
  @StorageLink('returnToPublish') returnToPublish: boolean = false;

  // 底部 Tab 显示项（包含发布按钮占位）
  private tabItems: TabItem[] = [
    { icon: '', iconActive: '', label: '探索' },
    { icon: '', iconActive: '', label: '社区' },
    { icon: '+', iconActive: '+', label: '' },  // 发布按钮占位
    { icon: '', iconActive: '', label: '消息' },
    { icon: '', iconActive: '', label: '我的' },
  ];

  aboutToAppear(): void {
    if (!AppStorage.has('returnToPublish')) {
      AppStorage.setOrCreate('returnToPublish', false);
    }
  }

  onPageShow(): void {
    if (this.returnToPublish) {
      this.returnToPublish = false;
      this.showPublishDialog = true;
    }
  }

  build() {
    Stack() {
      // 主内容区 - 使用 4 个实际的 Tab（不包含发布按钮）
      Column() {
        // Tab 内容 - 只有 4 个实际页面
        Tabs({ barPosition: BarPosition.End, index: this.currentTabIndex }) {
          // Tab 0: 探索
          TabContent() {
            ExplorePage()
          }

          // Tab 1: 社区
          TabContent() {
            CommunityPage()
          }

          // Tab 2: 消息
          TabContent() {
            MessagePage()
          }

          // Tab 3: 我的
          TabContent() {
            ProfilePage()
          }
        }
        .barHeight(0)  // 隐藏默认TabBar，使用自定义
        .scrollable(false)
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
        .layoutWeight(1)
      }
      .width('100%')
      .height('100%')

      // 自定义底部导航栏 - iOS风格悬浮胶囊
      Column() {
        Row() {
          ForEach(this.tabItems, (item: TabItem, index: number) => {
            if (index === 2) {
              // 中间发布按钮
              Column() {
                Column() {
                  Text('+')
                    .fontSize(24)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                }
                .width(46)
                .height(46)
                .linearGradient({
                  direction: GradientDirection.RightBottom,
                  colors: [['#7DD3FC', 0], ['#0EA5E9', 1]]
                })
                .borderRadius(23)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .shadow({ radius: 12, color: 'rgba(37, 99, 235, 0.4)', offsetY: 3 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                this.showPublishDialog = true;
              })
            } else {
              // 普通 Tab - 纯文本
              Column() {
                Text(item.label)
                  .fontSize(14)
                  .fontWeight(this.getActualIndex(index) === this.currentTabIndex ? FontWeight.Bold : FontWeight.Medium)
                  .fontColor(this.getActualIndex(index) === this.currentTabIndex ? '#38BDF8' : '#64748B')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .height('100%')
              .onClick(() => {
                const targetIndex = this.getActualIndex(index);
                if (targetIndex === 0 && this.currentTabIndex === 0) {
                  // 已在探索页，触发随机城市
                  this.exploreShakeTrigger++;
                } else if (targetIndex === 1 && this.currentTabIndex === 1) {
                  // 已在社区页，触发刷新
                  this.communityRefreshTrigger++;
                } else {
                  this.currentTabIndex = targetIndex;
                }
              })
            }
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

      // 发布选择弹窗
      PublishSelectDialog({
        isShow: this.showPublishDialog,
        onSelect: (type: string) => {
          this.handlePublishSelect(type);
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgPrimary)
  }

  // 处理Tab索引映射(跳过中间的发布按钮
  getActualIndex(displayIndex: number): number {
    if (displayIndex < 2) return displayIndex;
    if (displayIndex > 2) return displayIndex - 1;
    return -1;
  }

  // 处理发布选择
  handlePublishSelect(type: string) {
    console.info('选择发布类型:', type);
    // 根据类型跳转到对应的发布页面
    switch (type) {
      case 'post':
        router.pushUrl({ url: 'pages/publish/PublishPostPage' }).catch(() => {});
        break;
      case 'video':
        router.pushUrl({ url: 'pages/publish/PublishPostPage' }).catch(() => {});
        break;
      case 'capsule':
        router.pushUrl({ url: 'pages/publish/TimeCapsulePage' }).catch(() => {});
        break;
      case 'bottle':
        router.pushUrl({ url: 'pages/publish/DriftBottlePage' }).catch(() => {});
        break;
    }
  }
}