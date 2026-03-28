/**
 * 消息分类列表页（点赞/评论/关注）- 严格模式
 */

import { router, promptAction } from '@kit.ArkUI';
import { ApiService, ApiMessage, MessageListData } from '../../services/ApiService';
import { formatTime } from '../../utils/Formatter';

class MessageListItem {
  id: string = '';
  type: string = '';
  title: string = '';
  subtitle: string = '';
  time: string = '';
  isRead: boolean = false;
  userId: string = '';
  userNickname: string = '';
  userAvatar: string = '';
  postId: string = '';

  constructor() {}
}

@Entry
@Component
struct MessageListPage {
  @State pageTitle: string = '消息';
  @State messageType: string = '';

  @State messageList: MessageListItem[] = [];
  @State isLoading: boolean = true;
  @State isRefreshing: boolean = false;
  @State isLoadingMore: boolean = false;
  @State currentPage: number = 1;
  @State totalPages: number = 1;
  @State errorMessage: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, string>;
    if (params) {
      if (params.type) this.messageType = params.type;
      if (params.title) this.pageTitle = params.title;
    }

    this.loadMessages(true);
  }

  /**
   * 加载数据
   */
  private async loadMessages(isRefresh: boolean = false): Promise<void> {
    if (isRefresh) {
      this.currentPage = 1;
      this.isRefreshing = true;
      this.errorMessage = '';
    } else {
      if (this.isLoadingMore || this.currentPage >= this.totalPages) {
        return;
      }
      this.isLoadingMore = true;
      this.currentPage += 1;
    }

    try {
      // 每页 20 条
      const limit = 20;
      const result: MessageListData = await ApiService.getMessages(this.messageType, this.currentPage);

      const newItems: MessageListItem[] = [];
      for (const apiMsg of result.items) {
        newItems.push(this.formatMessageItem(apiMsg));
      }

      if (isRefresh) {
        this.messageList = newItems;
      } else {
        const combined: MessageListItem[] = [];
        for (const msg of this.messageList) {
          combined.push(msg);
        }
        for (const msg of newItems) {
          combined.push(msg);
        }
        this.messageList = combined;
      }

      // 计算总页数
      this.totalPages = Math.ceil(result.total / limit);
      this.errorMessage = '';

    } catch (error) {
      const err = error as Error;
      this.errorMessage = err.message || '加载失败';
      console.error('[MessageList] 加载失败:', err.message);
    } finally {
      this.isLoading = false;
      this.isRefreshing = false;
      this.isLoadingMore = false;
    }
  }

  /**
   * 将 API 数据格式化为 UI 需要的结构，并截断文本
   */
  private formatMessageItem(apiMsg: ApiMessage): MessageListItem {
    const item = new MessageListItem();
    item.id = apiMsg.id;
    item.type = apiMsg.type;
    item.time = formatTime(apiMsg.createdAt);
    item.isRead = apiMsg.isRead;

    // 提取互动者信息
    if (apiMsg.relatedUser) {
      item.userId = apiMsg.relatedUser.id;
      item.userNickname = apiMsg.relatedUser.nickname;
      item.userAvatar = apiMsg.relatedUser.avatar;
    } else {
      item.userNickname = '未知用户';
    }

    // 提取帖子信息与截断
    let postContentPreview = '';
    if (apiMsg.relatedPost && apiMsg.relatedPost.content) {
      item.postId = apiMsg.relatedPost.id;
      postContentPreview = apiMsg.relatedPost.content;
      if (postContentPreview.length > 10) {
        postContentPreview = postContentPreview.substring(0, 10) + '...';
      }
    }

    // 格式化标题与副标题
    if (this.messageType === 'like') {
      item.title = `${item.userNickname} 赞了你`;
      item.subtitle = postContentPreview ? `内容：${postContentPreview}` : '';
    } else if (this.messageType === 'comment') {
      // 评论内容本身在 apiMsg.content 里
      let commentContent = apiMsg.content;
      if (commentContent.length > 15) {
        commentContent = commentContent.substring(0, 15) + '...';
      }
      item.title = `${item.userNickname} 评论了你：${commentContent}`;
      item.subtitle = postContentPreview ? `内容：${postContentPreview}` : '';
    } else if (this.messageType === 'follow') {
      item.title = `${item.userNickname} 关注了你`;
      item.subtitle = '';
    } else {
      // 兜底
      item.title = apiMsg.title;
      item.subtitle = apiMsg.content;
    }

    return item;
  }

  /**
   * 点击单条消息
   */
  private async handleItemClick(item: MessageListItem): Promise<void> {
    // 1. 标记已读 (乐观更新 UI)
    if (!item.isRead) {
      const idx = this.messageList.findIndex(m => m.id === item.id);
      if (idx !== -1) {
        const newList = [...this.messageList];
        const updated = new MessageListItem();

        updated.id = item.id;
        updated.type = item.type;
        updated.title = item.title;
        updated.subtitle = item.subtitle;
        updated.time = item.time;
        updated.userId = item.userId;
        updated.userNickname = item.userNickname;
        updated.userAvatar = item.userAvatar;
        updated.postId = item.postId;
        updated.isRead = true; // 设为已读

        newList[idx] = updated;
        this.messageList = newList;

        // 调用 API 设为已读
        try {
          await ApiService.markAsRead(item.id);
        } catch (e) {
          console.error('[MessageList] 标记已读失败');
        }
      }
    }

    // 2. 跳转逻辑
    if (this.messageType === 'follow') {
      // 关注 -> 跳个人主页
      if (item.userId) {
        router.pushUrl({ url: 'pages/community/UserProfilePage', params: { userId: item.userId } }).catch((error: Error) => {
          console.error(`[MessageList] 跳转用户主页失败: ${error.message}`);
        });
      }
    } else {
      // 点赞/评论 -> 跳帖子详情
      if (item.postId) {
        router.pushUrl({ url: 'pages/community/PostDetailPage', params: { postId: item.postId } }).catch((error: Error) => {
          console.error(`[MessageList] 跳转动态详情失败: ${error.message}`);
        });
      } else {
        promptAction.showToast({ message: '原内容已不存在' });
      }
    }
  }

  private goBack(): void {
    router.back();
  }

  build() {
    Column() {
      // ====== 顶部导航栏 ======
      Row() {
        Row() {
          Text('←')
            .fontSize(28)
            .fontColor('#1E293B')
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => this.goBack())

        Text(this.pageTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Column() {
          Text('全部已读')
            .fontSize(14)
            .fontColor('#38BDF8')
        }
        .width(80)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(async () => {
          try {
            await ApiService.markAllRead(this.messageType);
            promptAction.showToast({ message: '已全部标为已读' });
            this.loadMessages(true);
          } catch (e) {
            promptAction.showToast({ message: '操作失败' });
          }
        })
      }
      .width('100%')
      .padding({ left: 8, right: 8, top: 44, bottom: 12 }) // 适配状态栏
      .backgroundColor('#FFFFFF')
      .border({ width: { bottom: 0.5 }, color: '#F1F5F9' })

      // ====== 列表内容 ======
      Refresh({ refreshing: $$this.isRefreshing }) {
        List() {
          // 错误提示
          if (this.errorMessage) {
            ListItem() {
              Row() {
                Text('⚠️').fontSize(14)
                Text(this.errorMessage).fontSize(13).fontColor('#EF4444').margin({ left: 6 })
                Text(' 点击重试').fontSize(13).fontColor('#38BDF8')
              }
              .width('100%')
              .padding(16)
              .backgroundColor('#FEF2F2')
              .justifyContent(FlexAlign.Center)
              .onClick(() => this.loadMessages(true))
            }
          }

          // 空状态
          if (this.messageList.length === 0 && !this.isLoading && !this.isRefreshing) {
            ListItem() {
              Column() {
                Text('📭').fontSize(48)
                Text('暂无消息').fontSize(14).fontColor('#94A3B8').margin({ top: 12 })
              }
              .width('100%')
              .padding({ top: 100 })
              .alignItems(HorizontalAlign.Center)
            }
          }

          // 数据列表
          ForEach(this.messageList, (item: MessageListItem) => {
            ListItem() {
              this.MessageCard(item)
            }
          }, (item: MessageListItem) => `${item.id}_${item.isRead}`)

          // 底部加载状态
          if (this.isLoadingMore) {
            ListItem() {
              Row() {
                LoadingProgress().width(24).height(24).color('#38BDF8')
                Text('加载中...').fontSize(13).fontColor('#94A3B8').margin({ left: 8 })
              }
              .width('100%')
              .height(60)
              .justifyContent(FlexAlign.Center)
            }
          } else if (this.currentPage >= this.totalPages && this.messageList.length > 0) {
            ListItem() {
              Text('— 没有更多了 —')
                .fontSize(13)
                .fontColor('#CBD5E1')
                .width('100%')
                .height(60)
                .textAlign(TextAlign.Center)
            }
          }
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onReachEnd(() => {
          if (!this.isLoadingMore && this.currentPage < this.totalPages) {
            this.loadMessages(false);
          }
        })
      }
      .onRefreshing(() => this.loadMessages(true))
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  MessageCard(item: MessageListItem) {
    Row() {
      // 头像
      Stack() {
        if (item.userAvatar) {
          Image(item.userAvatar)
            .width(48)
            .height(48)
            .borderRadius(24)
            .objectFit(ImageFit.Cover)
        } else {
          Column() {
            Text(item.userNickname ? item.userNickname.charAt(0) : 'U')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
          }
          .width(48)
          .height(48)
          .borderRadius(24)
          .backgroundColor('#38BDF8')
          .justifyContent(FlexAlign.Center)
        }
      }
      .margin({ right: 12 })

      // 内容区
      Column() {
        Row() {
          Text(item.title)
            .fontSize(15)
            .fontWeight(item.isRead ? FontWeight.Medium : FontWeight.Bold)
            .fontColor(item.isRead ? '#475569' : '#1E293B')
            .layoutWeight(1)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          Text(item.time)
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ left: 8 })
        }
        .width('100%')

        if (item.subtitle) {
          Text(item.subtitle)
            .fontSize(13)
            .fontColor('#64748B')
            .margin({ top: 6 })
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F1F5F9')
            .borderRadius(6)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      // 未读红点
      if (!item.isRead) {
        Column()
          .width(8)
          .height(8)
          .backgroundColor('#EF4444')
          .borderRadius(4)
          .margin({ left: 12 })
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .border({ width: { bottom: 0.5 }, color: '#F1F5F9' })
    .onClick(() => this.handleItemClick(item))
  }
}