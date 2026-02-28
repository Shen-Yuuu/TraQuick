/**
 * 消息页面 - 支持 API 集成与下拉刷新 (严格模式)
 */

import { router, promptAction } from '@kit.ArkUI';
import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { ApiService, ApiMessageGroup } from '../../services/ApiService';

// ====== 状态类定义 ======

class QuickActionItem {
  icon: string = '';
  title: string = '';
  color: string = '';
  badge: number = 0;
  type: string = '';

  constructor(icon: string, title: string, color: string, type: string) {
    this.icon = icon;
    this.title = title;
    this.color = color;
    this.type = type;
  }
}

class SystemNoticeItem {
  groupType: string = '';
  icon: string = '';
  iconBg: string = '';
  title: string = '';
  desc: string = '';
  time: string = '';
  isNew: boolean = false;
  unreadCount: number = 0;
  messageId: string = '';

  constructor() {}
}

@Component
export struct MessagePage {
  @State quickActions: QuickActionItem[] = [
    new QuickActionItem('❤️', '点赞', '#EF4444', 'like'),
    new QuickActionItem('💬', '评论', '#7DD3FC', 'comment'),
    new QuickActionItem('👤', '关注', '#38BDF8', 'follow'),
  ];

  @State systemNotices: SystemNoticeItem[] = [];
  @State isLoading: boolean = true;
  @State isRefreshing: boolean = false;
  @State totalUnread: number = 0;

  aboutToAppear(): void {
    this.loadMessages();
  }

  onPageShow(): void {
    // 每次显示页面时，静默刷新数据
    if (!this.isLoading) {
      this.loadMessages(true);
    }
  }

  /**
   * 加载真实消息数据
   */
  private async loadMessages(silent: boolean = false): Promise<void> {
    if (!silent) {
      this.isLoading = true;
    }

    try {
      // 1. 获取后端真实分组数据
      const groups: ApiMessageGroup[] = await ApiService.getMessageGroups();

      let newTotalUnread = 0;
      const newNotices: SystemNoticeItem[] = [];
      const newActions: QuickActionItem[] = [
        new QuickActionItem('❤️', '点赞', '#EF4444', 'like'),
        new QuickActionItem('💬', '评论', '#7DD3FC', 'comment'),
        new QuickActionItem('👤', '关注', '#38BDF8', 'follow'),
      ];

      // 2. 解析数据并分发
      for (const group of groups) {
        newTotalUnread += group.unreadCount;

        // 互动类 -> 更新 QuickActions
        if (group.type === 'like' || group.type === 'comment' || group.type === 'follow') {
          const actionIndex = newActions.findIndex(a => a.type === group.type);
          if (actionIndex !== -1) {
            newActions[actionIndex].badge = group.unreadCount;
          }
        }
        // 通知类 -> 构建 SystemNotices
        else if ((group.type === 'system' || group.type === 'capsule' || group.type === 'bottle') && group.latestMessage !== null) {
          const notice = new SystemNoticeItem();
          notice.groupType = group.type;
          notice.unreadCount = group.unreadCount;
          notice.messageId = group.latestMessage.id;
          notice.isNew = !group.latestMessage.isRead;
          notice.time = this.formatTime(group.latestMessage.createdAt);
          notice.desc = group.latestMessage.content;

          // 设置样式
          if (group.type === 'capsule') {
            notice.icon = '⏳';
            notice.iconBg = '#DBEAFE';
            notice.title = '时空胶囊信息';
          } else if (group.type === 'bottle') {
            notice.icon = '🍾';
            notice.iconBg = '#E0E7FF';
            notice.title = '漂流瓶信箱';
          } else {
            notice.icon = '🔔';
            notice.iconBg = '#FEF3C7';
            notice.title = '系统通知';
          }

          newNotices.push(notice);
        }
      }

      this.quickActions = newActions;

      // 通知按时间倒序排列（假定返回未排序时）
      // 实际应用中，如果需要准确排序，应保存原始 Date 对象，此处简化处理
      this.systemNotices = newNotices.sort((a, b) => 0);

      // 如果后端没有返回任何系统通知，插入一条占位欢迎通知
      if (this.systemNotices.length === 0) {
        const welcomeNotice = new SystemNoticeItem();
        welcomeNotice.groupType = 'system';
        welcomeNotice.icon = '🔔';
        welcomeNotice.iconBg = '#FEF3C7';
        welcomeNotice.title = '系统通知';
        welcomeNotice.desc = '欢迎来到 TraQuick！开始你的探索之旅吧。';
        welcomeNotice.time = '刚刚';
        welcomeNotice.isNew = true;
        welcomeNotice.unreadCount = 1;
        welcomeNotice.messageId = 'mock_welcome';
        this.systemNotices.push(welcomeNotice);
      }

      this.totalUnread = newTotalUnread;

    } catch (error) {
      console.error('[Message] 加载消息失败:', (error as Error).message);
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
    }
  }

  private onRefresh(): void {
    this.isRefreshing = true;
    this.loadMessages();
  }

  /**
   * 标记通知为已读
   */
  private async markNoticeRead(notice: SystemNoticeItem): Promise<void> {
    if (!notice.isNew) {
      promptAction.showToast({ message: `打开 ${notice.title} 详情` });
      return;
    }

    // 乐观更新 UI
    // 乐观更新 UI
    const idx = this.systemNotices.findIndex(n => n.messageId === notice.messageId);
    if (idx !== -1) {
      const newList = [...this.systemNotices];
      // 创建新对象触发刷新，手动赋值以符合 ArkTS 严格模式
      const updatedNotice = new SystemNoticeItem();
      const originalNotice = this.systemNotices[idx];

      updatedNotice.groupType = originalNotice.groupType;
      updatedNotice.icon = originalNotice.icon;
      updatedNotice.iconBg = originalNotice.iconBg;
      updatedNotice.title = originalNotice.title;
      updatedNotice.desc = originalNotice.desc;
      updatedNotice.time = originalNotice.time;
      updatedNotice.messageId = originalNotice.messageId;

      // 更新状态
      updatedNotice.isNew = false;
      updatedNotice.unreadCount = 0;

      newList[idx] = updatedNotice;

      this.systemNotices = newList;
      this.totalUnread = Math.max(0, this.totalUnread - notice.unreadCount);
    }

    try {
      if (notice.messageId !== 'mock_welcome') {
        // 调用后端标记已读
        await ApiService.markAllRead(notice.groupType);
      }
    } catch (error) {
      console.error('[Message] 标记已读失败:', (error as Error).message);
    }
  }

  /**
   * 工具：格式化时间显示
   */
  private formatTime(isoString: string): string {
    if (!isoString) return '';
    const date = new Date(isoString);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(diff / 3600000);
    const days = Math.floor(diff / 86400000);

    if (minutes < 1) return '刚刚';
    if (minutes < 60) return `${minutes}分钟前`;
    if (hours < 24) return `${hours}小时前`;
    if (days === 1) return '昨天';
    return `${date.getMonth() + 1}-${date.getDate()}`;
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('消息')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        Blank()

        Column() {
          Text('⋯').fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor('#F1F5F9')
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .onClick(() => {
          promptAction.showActionMenu({
            title: '消息选项',
            buttons: [
              { text: '全部标记为已读', color: '#38BDF8' },
            ]
          }).then(async (res) => {
            if (res.index === 0) {
              try {
                this.isRefreshing = true;
                await ApiService.markAllRead();
                promptAction.showToast({ message: '所有消息已读' });
                await this.loadMessages(true);
              } catch (e) {
                promptAction.showToast({ message: '操作失败' });
              } finally {
                this.isRefreshing = false;
              }
            }
          });
        })
      }
      .width('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 40, bottom: 10 })
      .backgroundBlurStyle(BlurStyle.Regular)
      .backgroundColor('rgba(255, 255, 255, 0.75)')

      Refresh({ refreshing: $$this.isRefreshing }) {
        Scroll() {
          Column() {
            // 快捷入口
            Row() {
              ForEach(this.quickActions, (action: QuickActionItem) => {
                Column() {
                  Stack() {
                    Column() {
                      Text(action.icon).fontSize(24)
                    }
                    .width(56).height(56).backgroundColor('#F1F5F9').borderRadius(16).justifyContent(FlexAlign.Center)

                    if (action.badge > 0) {
                      Text(action.badge > 99 ? '99+' : action.badge.toString())
                        .fontSize(10)
                        .fontColor('#FFFFFF')
                        .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                        .backgroundColor('#EF4444')
                        .borderRadius(8)
                        .position({ x: 40, y: 0 })
                    }
                  }
                  Text(action.title).fontSize(12).fontColor('#64748B').margin({ top: 8 })
                }
                .layoutWeight(1).alignItems(HorizontalAlign.Center)
                .onClick(() => {
                  // 跳转到消息列表页
                  router.pushUrl({
                    url: 'pages/message/MessageListPage',
                    params: {
                      type: action.type,
                      title: action.title
                    }
                  }).catch((err: Error) => {
                    console.error('[Message] 跳转失败:', err.message);
                  });
                })
              }, (action: QuickActionItem) => action.type)
            }
            .width('100%')
            .padding({ left: 24, right: 24, top: 16, bottom: 16 })
            .backgroundColor('#FFFFFF')
            .borderRadius(16)
            .margin({ bottom: 16 })

            // 系统通知
            if (this.systemNotices.length > 0) {
              Column() {
                ForEach(this.systemNotices, (notice: SystemNoticeItem, index: number) => {
                  Row() {
                    Column() { Text(notice.icon).fontSize(20) }
                    .width(44).height(44).backgroundColor(notice.iconBg).borderRadius(12).justifyContent(FlexAlign.Center)

                    Column() {
                      Row() {
                        Text(notice.title).fontSize(15).fontWeight(FontWeight.Medium).fontColor('#1E293B')
                        Blank()
                        Text(notice.time).fontSize(12).fontColor('#94A3B8')
                      }.width('100%')

                      Text(notice.desc).fontSize(13).fontColor('#64748B').margin({ top: 4 }).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .layoutWeight(1).margin({ left: 12 })

                    if (notice.isNew) {
                      Column().width(8).height(8).backgroundColor('#EF4444').borderRadius(4).margin({ left: 8 })
                    }
                  }
                  .width('100%').padding(16).backgroundColor('#EFF6FF').borderRadius(16)
                  .margin({ bottom: index < this.systemNotices.length - 1 ? 8 : 0 })
                  .onClick(() => { this.markNoticeRead(notice); })
                }, (notice: SystemNoticeItem) => notice.messageId)
              }
              .width('100%').margin({ bottom: 24 })
            }

          }
          .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 16, bottom: 90 })
        }
        .width('100%').layoutWeight(1).scrollBar(BarState.Off)
      }
      .onRefreshing(() => { this.onRefresh(); })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F4F8')
  }
}