/**
 * 用户数据模型
 */

export interface User {
  id: string;
  phone?: string;
  email?: string;
  nickname: string;
  avatar: string;
  bio?: string;                    // 个人简介
  level: number;                   // 用户等级 1-5
  levelTitle: string;              // 等级称号
  followingCount: number;          // 关注数
  followersCount: number;          // 粉丝数
  friendsCount: number;            // 互关好友数
  citiesCount: number;             // 点亮城市名
  countriesCount: number;          // 点亮国家数
  postsCount: number;              // 作品数
  createdAt: string;
  updatedAt: string;
}

export interface UserBasic {
  id: string;
  nickname: string;
  avatar: string;
  level: number;
  levelTitle: string;
}

export interface UserRelation {
  isFollowing: boolean;            // 我是否关注了ta
  isFollowedBy: boolean;           // ta是否关注了我
  isFriend: boolean;               // 是否互相关注(朋友)
}
