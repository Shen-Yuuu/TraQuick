/**
 * 动态帖子数据模型
 */

export interface Post {
  id: string;
  author: PostAuthor;
  content: string;                 // 文字内容
  images: string[];                // 图片列表
  video?: string;                  // 视频URL(如果是视角
  location?: PostLocation;         // 位置信息
  tags: string[];                  // 标签 如#黄山
  likeCount: number;
  commentCount: number;
  shareCount: number;
  collectCount: number;
  isLiked: boolean;                // 当前用户是否点赞
  isCollected: boolean;            // 当前用户是否收藏
  createdAt: string;
  type: 'image' | 'video';         // 内容类型
  hotComments?: PostComment[];     // 热门评论(1-2条)
}

export interface PostAuthor {
  id: string;
  nickname: string;
  avatar: string;
  level: number;
  levelTitle: string;
}

export interface PostLocation {
  cityId: string;
  cityName: string;
  address?: string;                // 具体地址 如光明顶
  latitude?: number;
  longitude?: number;
}

export interface PostComment {
  id: string;
  postId: string;
  userId: string;
  userNickname: string;
  userAvatar?: string;
  content: string;
  likeCount: number;
  isLiked: boolean;
  replyTo?: CommentReply;          // 回复的评论
  createdAt: string;
}

export interface CommentReply {
  id: string;
  authorName: string;
}

export interface CreatePostLocation {
  cityId: string;
  address?: string;
  latitude?: number;
  longitude?: number;
}

// 发布动态的请求参数
export interface CreatePostRequest {
  content: string;
  images: string[];
  video?: string;
  location?: CreatePostLocation;
  tags: string[];
  type: 'image' | 'video';
}
