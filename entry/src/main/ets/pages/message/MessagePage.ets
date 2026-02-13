/**
 * 消息页面 - 符合设计
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';

interface QuickAction {
  icon: string;
  title: string;
  color: string;
  badge: number;
}

interface SystemNotice {
  icon: string;
  iconBg: string;
  title: string;
  desc: string;
  time: string;
  isNew: boolean;
}

interface ChatItem {
  id: string;
  avatar: string;
  nickname: string;
  lastMessage: string;
  time: string;
  unreadCount: number;
  isOnline: boolean;
  isGroup: boolean;
  memberCount?: number;
}

@Entry
@Component
export struct MessagePage {
  @State quickActions: QuickAction[] = [
    { icon: '❤️', title: '点赞', color: '#EF4444', badge: 1 },
    { icon: '💬', title: '回复', color: '#7DD3FC', badge: 0 },
    { icon: '✈️', title: '私信', color: '#38BDF8', badge: 3 },
  ];

  @State systemNotices: SystemNotice[] = [
    {
      icon: '⏳',
      iconBg: '#DBEAFE',
      title: '时空胶囊信息',
      desc: '您在巴黎埋下的胶囊《2023的回忆》已解锁。',
      time: '14:02',
      isNew: false
    },
    {
      icon: '🍾',
      iconBg: '#DBEAFE',
      title: '漂流瓶信箱',
      desc: '捡到一个来自 @Explorer_X 的瓶子...',
      time: '昨天',
      isNew: true
    },
  ];

  @State chatList: ChatItem[] = [
    {
      id: '1',
      avatar: '👩',
      nickname: 'Sarah Chen',
      lastMessage: '那个巴黎铁塔附近的咖啡馆叫什么名字？',
      time: '刚刚',
      unreadCount: 0,
      isOnline: true,
      isGroup: false
    },
    {
      id: '2',
      avatar: '👨',
      nickname: 'Mike Ross',
      lastMessage: '我也解锁了伦敦的迷雾地图！太酷了...',
      time: '10:30',
      unreadCount: 1,
      isOnline: false,
      isGroup: false
    },
    {
      id: '3',
      avatar: '🌍',
      nickname: 'TraQuick 官方助手',
      lastMessage: '[系统通知] 恭喜获得 "城市漫步" 勋章',
      time: '周一',
      unreadCount: 0,
      isOnline: false,
      isGroup: false
    },
    {
      id: '4',
      avatar: '👥',
      nickname: '欧洲背包客群',
      lastMessage: 'Alex: 谁在罗马？求组队～',
      time: '周日',
      unreadCount: 0,
      isOnline: false,
      isGroup: true,
      memberCount: 428
    },
  ];

  @State showSearch: boolean = false;
  @State searchText: string = '';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text('消息')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        Blank()

        // 搜索按钮
        Column() {
          Text('🔍')
            .fontSize(18)
        }
        .width(36)
        .height(36)
        .backgroundColor('#F1F5F9')
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .margin({ right: 12 })
        .onClick(() => {
          this.showSearch = !this.showSearch;
        })

        Column() {
          Text('⋯')
            .fontSize(16)
        }
        .width(36)
        .height(36)
        .backgroundColor('#F1F5F9')
        .borderRadius(18)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 40, bottom: 10 })
      .backgroundBlurStyle(BlurStyle.Regular)
      .backgroundColor('rgba(255, 255, 255, 0.75)')

      // 搜索栏
      if (this.showSearch) {
        Row() {
          Text('🔍')
            .fontSize(14)
          TextInput({ placeholder: '搜索联系人、聊天记录、漂流瓶...', text: this.searchText })
            .layoutWeight(1)
            .height(36)
            .backgroundColor('transparent')
            .fontSize(14)
            .fontColor('#1E293B')
            .margin({ left: 8 })
            .onChange((value: string) => {
              this.searchText = value;
            })
          Text('取消')
            .fontSize(13)
            .fontColor('#38BDF8')
            .margin({ left: 8 })
            .onClick(() => {
              this.showSearch = false;
              this.searchText = '';
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 6, bottom: 6 })
        .margin({ left: Spacing.pagePadding, right: Spacing.pagePadding })
        .backgroundColor('#F1F5F9')
        .borderRadius(18)
        .alignItems(VerticalAlign.Center)
      }

      Scroll() {
        Column() {
          // 快捷入口
          Row() {
            ForEach(this.quickActions, (action: QuickAction) => {
              Column() {
                Stack() {
                  Column() {
                    Text(action.icon)
                      .fontSize(24)
                  }
                  .width(56)
                  .height(56)
                  .backgroundColor('#F1F5F9')
                  .borderRadius(16)
                  .justifyContent(FlexAlign.Center)

                  if (action.badge > 0) {
                    Text(action.badge.toString())
                      .fontSize(10)
                      .fontColor('#FFFFFF')
                      .padding({ left: 5, right: 5, top: 2, bottom: 2 })
                      .backgroundColor('#EF4444')
                      .borderRadius(8)
                      .position({ x: 40, y: 0 })
                  }
                }

                Text(action.title)
                  .fontSize(12)
                  .fontColor('#64748B')
                  .margin({ top: 8 })
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Center)
            })
          }
          .width('100%')
          .padding({ left: 24, right: 24, top: 16, bottom: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 16 })

          // 系统通知
          Column() {
            ForEach(this.systemNotices, (notice: SystemNotice, index: number) => {
              Row() {
                Column() {
                  Text(notice.icon)
                    .fontSize(20)
                }
                .width(44)
                .height(44)
                .backgroundColor(notice.iconBg)
                .borderRadius(12)
                .justifyContent(FlexAlign.Center)

                Column() {
                  Row() {
                    Text(notice.title)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#1E293B')
                    Blank()
                    Text(notice.time)
                      .fontSize(12)
                      .fontColor('#94A3B8')
                  }
                  .width('100%')

                  Text(notice.desc)
                    .fontSize(13)
                    .fontColor('#64748B')
                    .margin({ top: 4 })
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .margin({ left: 12 })

                if (notice.isNew) {
                  Column()
                    .width(8)
                    .height(8)
                    .backgroundColor('#38BDF8')
                    .borderRadius(4)
                    .margin({ left: 8 })
                }
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#EFF6FF')
              .borderRadius(16)
              .margin({ bottom: index < this.systemNotices.length - 1 ? 8 : 0 })
            })
          }
          .width('100%')
          .margin({ bottom: 24 })

          // 最近联系人
          Text('最近联系人')
            .fontSize(13)
            .fontColor('#94A3B8')
            .width('100%')
            .margin({ bottom: 12, left: 4 })

          Column() {
            ForEach(this.chatList, (chat: ChatItem, index: number) => {
              Row() {
                // 头像
                Stack() {
                  Column() {
                    Text(chat.avatar)
                      .fontSize(24)
                  }
                  .width(50)
                  .height(50)
                  .backgroundColor('#F1F5F9')
                  .borderRadius(25)
                  .justifyContent(FlexAlign.Center)

                  if (chat.isOnline) {
                    Column()
                      .width(12)
                      .height(12)
                      .backgroundColor('#10B981')
                      .borderRadius(6)
                      .border({ width: 2, color: '#FFFFFF' })
                      .position({ x: 38, y: 38 })
                  }
                }

                // 聊天信息
                Column() {
                  Row() {
                    Text(chat.isGroup ? `${chat.nickname} (${chat.memberCount})` : chat.nickname)
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .fontColor('#1E293B')
                      .layoutWeight(1)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })

                    Text(chat.time)
                      .fontSize(12)
                      .fontColor('#94A3B8')
                  }
                  .width('100%')

                  Row() {
                    Text(chat.lastMessage)
                      .fontSize(13)
                      .fontColor('#64748B')
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .layoutWeight(1)

                    if (chat.unreadCount > 0) {
                      Text(chat.unreadCount.toString())
                        .fontSize(11)
                        .fontColor('#FFFFFF')
                        .padding({ left: 7, right: 7, top: 3, bottom: 3 })
                        .backgroundColor('#EF4444')
                        .borderRadius(10)
                    }
                  }
                  .width('100%')
                  .margin({ top: 6 })
                }
                .layoutWeight(1)
                .margin({ left: 12 })
              }
              .width('100%')
              .padding({ top: 12, bottom: 12 })

              if (index < this.chatList.length - 1) {
                Divider().color('#F1F5F9').margin({ left: 62 })
              }
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
        }
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 16, bottom: 90 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F4F8')
  }
}
