/**
 * 消息数据模型
 */

export interface Message {
  id: string;
  type: MessageType;
  title: string;
  content: string;
  isRead: boolean;
  createdAt: string;
  relatedUser?: MessageUser;       // 相关用户(点赞/评论/关注)
  relatedPost?: MessagePost;       // 相关动态
}

export type MessageType = 
  | 'like'          // 点赞
  | 'comment'       // 评论
  | 'follow'        // 关注
  | 'system'        // 系统通知
  | 'capsule'       // 时空胶囊
  | 'bottle';       // 漂流瓶

export interface MessageUser {
  id: string;
  nickname: string;
  avatar: string;
}

export interface MessagePost {
  id: string;
  coverImage?: string;
  content?: string;
}

// 消息分组
export interface MessageGroup {
  type: MessageType;
  title: string;
  icon: string;
  unreadCount: number;
  latestMessage?: Message;
}
