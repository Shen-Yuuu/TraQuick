/**
 * 城市数据模型
 */

export interface City {
  id: string;
  name: string;                    // 城市名
  nameEn?: string;                 // 英文名
  country: string;                 // 国家
  countryCode: string;             // 国家代码
  province?: string;               // 省份
  coverImage: string;              // 封面图
  latitude: number;
  longitude: number;
  description?: string;            // 城市简介
  postsCount: number;              // 相关动态数
  visitorsCount: number;           // 打卡人数
  isUnlocked: boolean;             // 当前用户是否已点亮
}

export interface CityDetail extends City {
  images: string[];                // 城市图片集
  weather?: CityWeather;           // 天气信息
  distance?: number;               // 距离当前位置(km)
  friendsVisited?: CityFriend[];   // 去过的好友
}

export interface CityWeather {
  temperature: number;
  condition: string;               // 多云/雨等
  icon: string;
}

export interface CityFriend {
  id: string;
  nickname: string;
  avatar: string;
}

// 城市标记点用于地图展示)
export interface CityMarker {
  id: string;
  name: string;
  latitude: number;
  longitude: number;
  isUnlocked: boolean;
  hasContent: boolean;             // 是否有内容
  type: 'normal' | 'hot' | 'fog';  // 普通/热门/重度迷雾
}
