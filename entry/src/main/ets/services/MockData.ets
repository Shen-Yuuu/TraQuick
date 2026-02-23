/**
 * Mock数据服务 - 提供测试数据
 */

import { Post, PostAuthor, PostLocation, PostComment } from '../models/Post';
import { City, CityMarker } from '../models/City';
import { User } from '../models/User';

// ==================== 用户Mock数据 ====================

export const mockCurrentUser: User = {
  id: 'user_001',
  phone: '138****8888',
  nickname: '探险家小七',
  avatar: '',
  bio: '用脚步丈量世界，用镜头记录美好',
  level: 3,
  levelTitle: '洲际探险家',
  followingCount: 128,
  followersCount: 4500,
  friendsCount: 56,
  citiesCount: 42,
  countriesCount: 8,
  postsCount: 23,
  createdAt: '2024-01-01T00:00:00Z',
  updatedAt: '2024-12-01T00:00:00Z',
};

export const mockUsers: User[] = [
  {
    id: 'user_002',
    nickname: '旅行达人',
    avatar: '',
    bio: '世界那么大，我想去看看',
    level: 4,
    levelTitle: '环球领航员',
    followingCount: 256,
    followersCount: 12000,
    friendsCount: 89,
    citiesCount: 86,
    countriesCount: 23,
    postsCount: 156,
    createdAt: '2023-06-01T00:00:00Z',
    updatedAt: '2024-12-01T00:00:00Z',
  },
  {
    id: 'user_003',
    nickname: '摄影师阿豪',
    avatar: '',
    bio: '用光影记录每一座城',
    level: 5,
    levelTitle: '星耀漫游者',
    followingCount: 89,
    followersCount: 58000,
    friendsCount: 34,
    citiesCount: 120,
    countriesCount: 35,
    postsCount: 432,
    createdAt: '2022-01-01T00:00:00Z',
    updatedAt: '2024-12-01T00:00:00Z',
  },
];
// ==================== 评论Mock数据 ====================

export function getMockComments(postId: string): PostComment[] {
  return [
    {
      id: 'comment_001', postId: postId, userId: 'user_002', userNickname: '旅行达人', userAvatar: '',
      content: '太美了！这个角度拍得真棒！', likeCount: 156, isLiked: false,
      createdAt: new Date(Date.now() - 3600000).toISOString(),
    },
    {
      id: 'comment_002', postId: postId, userId: 'user_003', userNickname: '摄影师阿豪', userAvatar: '',
      content: '用的什么设备拍的？求分享！📷', likeCount: 89, isLiked: false,
      createdAt: new Date(Date.now() - 7200000).toISOString(),
    },
    {
      id: 'comment_003', postId: postId, userId: 'user_004', userNickname: '背包客小凡', userAvatar: '',
      content: '已加入旅行清单 📝', likeCount: 45, isLiked: true,
      createdAt: new Date(Date.now() - 10800000).toISOString(),
    },
    {
      id: 'comment_004', postId: postId, userId: 'user_005', userNickname: '美食家大宝', userAvatar: '',
      content: '下次一起去呀，求组队！', likeCount: 34, isLiked: false,
      createdAt: new Date(Date.now() - 14400000).toISOString(),
    },
    {
      id: 'comment_005', postId: postId, userId: 'user_001', userNickname: '探险家小七', userAvatar: '',
      content: '这里的日落是我见过最美的 🌅', likeCount: 267, isLiked: false,
      replyTo: { id: 'comment_001', authorName: '旅行达人' },
      createdAt: new Date(Date.now() - 18000000).toISOString(),
    },
    {
      id: 'comment_006', postId: postId, userId: 'user_003', userNickname: '摄影师阿豪', userAvatar: '',
      content: '构图很有想法，学到了！', likeCount: 22, isLiked: false,
      createdAt: new Date(Date.now() - 21600000).toISOString(),
    },
    {
      id: 'comment_007', postId: postId, userId: 'user_002', userNickname: '旅行达人', userAvatar: '',
      content: '住的哪个酒店？推荐一下', likeCount: 18, isLiked: false,
      createdAt: new Date(Date.now() - 36000000).toISOString(),
    },
  ];
}

// 获取转发用户列表
export function getShareUsers(): User[] {
  return [mockCurrentUser, ...mockUsers];
}
// ==================== 动态Mock数据 ====================

const mockAuthors: PostAuthor[] = [
  { id: 'user_001', nickname: '探险家小七', avatar: '', level: 3, levelTitle: '洲际探险家' },
  { id: 'user_002', nickname: '旅行达人', avatar: '', level: 4, levelTitle: '环球领航员' },
  { id: 'user_003', nickname: '摄影师阿豪', avatar: '', level: 5, levelTitle: '星耀漫游者' },
  { id: 'user_004', nickname: '背包客小凡', avatar: '', level: 2, levelTitle: '城市猎人' },
  { id: 'user_005', nickname: '美食家大宝', avatar: '', level: 3, levelTitle: '洲际探险家' },
];

export const mockPosts: Post[] = [
  {
    id: 'post_001',
    author: mockAuthors[0],
    content: '黄山归来不看岳，真的是太美了！云海翻腾，奇松怪石，仿佛置身仙境。这次特意起了个大早看日出，值回票价！📸✨',
    images: [
      'https://example.com/huangshan1.jpg',
      'https://example.com/huangshan2.jpg',
      'https://example.com/huangshan3.jpg',
      'https://example.com/huangshan4.jpg',
      'https://example.com/huangshan5.jpg',
      'https://example.com/huangshan6.jpg',
      'https://example.com/huangshan7.jpg',
      'https://example.com/huangshan8.jpg',
      'https://example.com/huangshan9.jpg',
    ],
    location: { cityId: 'city_huangshan', cityName: '黄山', address: '光明顶' },
    tags: ['黄山', '旅行', '摄影'],
    likeCount: 1286,
    commentCount: 89,
    shareCount: 45,
    collectCount: 234,
    isLiked: false,
    isCollected: true,
    createdAt: new Date(Date.now() - 2 * 3600000).toISOString(),
    type: 'image',
    hotComments: [
      { id: 'hc_001', postId: 'post_001', userId: 'user_002', userNickname: '旅行达人', userAvatar: '', content: '太美了！云海简直绝了 🤩', likeCount: 156, isLiked: false, createdAt: new Date(Date.now() - 3600000).toISOString() },
      { id: 'hc_002', postId: 'post_001', userId: 'user_003', userNickname: '摄影师阿豪', userAvatar: '', content: '请问这是什么时间段拍的？光线太棒了', likeCount: 89, isLiked: false, createdAt: new Date(Date.now() - 5400000).toISOString() },
    ],
  },
  {
    id: 'post_002',
    author: mockAuthors[1],
    content: '巴黎的夜晚，埃菲尔铁塔闪烁的灯光真的太浪漫了！站在塞纳河边，听着街头艺人的手风琴，感觉整个世界都慢下来了。',
    images: [
      'https://example.com/paris1.jpg',
      'https://example.com/paris2.jpg',
      'https://example.com/paris3.jpg',
    ],
    location: { cityId: 'city_paris', cityName: '巴黎', address: '埃菲尔铁塔' },
    tags: ['巴黎', '法国', '夜景'],
    likeCount: 3456,
    commentCount: 178,
    shareCount: 89,
    collectCount: 567,
    isLiked: true,
    isCollected: false,
    createdAt: new Date(Date.now() - 5 * 3600000).toISOString(),
    type: 'image',
    hotComments: [
      { id: 'hc_003', postId: 'post_002', userId: 'user_004', userNickname: '背包客小凡', userAvatar: '', content: '巴黎是我的梦想之地，好缡慕！', likeCount: 234, isLiked: false, createdAt: new Date(Date.now() - 14400000).toISOString() },
    ],
  },
  {
    id: 'post_003',
    author: mockAuthors[2],
    content: '东京的涩谷十字路口，人潮涌动却井然有序。这座城市的节奏让人着迷，每个角落都有故事。',
    images: [
      'https://example.com/tokyo1.jpg',
    ],
    location: { cityId: 'city_tokyo', cityName: '东京', address: '涩谷' },
    tags: ['东京', '日本', '城市'],
    likeCount: 2134,
    commentCount: 67,
    shareCount: 34,
    collectCount: 189,
    isLiked: false,
    isCollected: false,
    createdAt: new Date(Date.now() - 24 * 3600000).toISOString(),
    type: 'image',
    hotComments: [
      { id: 'hc_004', postId: 'post_003', userId: 'user_005', userNickname: '美食家大宝', userAvatar: '', content: '涩谷的拉面必须安排！“', likeCount: 67, isLiked: false, createdAt: new Date(Date.now() - 43200000).toISOString() },
      { id: 'hc_005', postId: 'post_003', userId: 'user_001', userNickname: '探险家小七', userAvatar: '', content: '下次去东京约吧！', likeCount: 45, isLiked: true, createdAt: new Date(Date.now() - 50000000).toISOString() },
    ],
  },
  {
    id: 'post_004',
    author: mockAuthors[3],
    content: '成都的春熙路，太古里走一走，感受这座城市的悠闲与时尚的完美融合。晚上必须来一顿正宗火锅！🌶️',
    images: [
      'https://example.com/chengdu1.jpg',
      'https://example.com/chengdu2.jpg',
    ],
    location: { cityId: 'city_chengdu', cityName: '成都', address: '太古里' },
    tags: ['成都', '美食', '火锅'],
    likeCount: 876,
    commentCount: 45,
    shareCount: 23,
    collectCount: 156,
    isLiked: false,
    isCollected: false,
    createdAt: new Date(Date.now() - 48 * 3600000).toISOString(),
    type: 'image',
    hotComments: [
      { id: 'hc_006', postId: 'post_004', userId: 'user_002', userNickname: '旅行达人', userAvatar: '', content: '太古里的小熊猫咖啡很不错，推荐！', likeCount: 112, isLiked: false, createdAt: new Date(Date.now() - 100000000).toISOString() },
    ],
  },
  {
    id: 'post_005',
    author: mockAuthors[4],
    content: '西安的兵马俑，两千年前的奇迹。每一个陶俑都栩栩如生，站在坑边，仿佛能听到当年的战马嘶鸣。历史的厚重感扑面而来。',
    images: [
      'https://example.com/xian1.jpg',
      'https://example.com/xian2.jpg',
      'https://example.com/xian3.jpg',
      'https://example.com/xian4.jpg',
    ],
    location: { cityId: 'city_xian', cityName: '西安', address: '秦始皇兵马俑博物馆' },
    tags: ['西安', '历史', '兵马俑'],
    likeCount: 1567,
    commentCount: 78,
    shareCount: 56,
    collectCount: 345,
    isLiked: true,
    isCollected: true,
    createdAt: new Date(Date.now() - 72 * 3600000).toISOString(),
    type: 'image',
    hotComments: [
      { id: 'hc_007', postId: 'post_005', userId: 'user_003', userNickname: '摄影师阿豪', userAvatar: '', content: '兵马俑的规模真的震撼人心，强烈推荐实地感受！', likeCount: 198, isLiked: false, createdAt: new Date(Date.now() - 200000000).toISOString() },
      { id: 'hc_008', postId: 'post_005', userId: 'user_004', userNickname: '背包客小凡', userAvatar: '', content: '我上次去的时候赶上还在修复，没看全 😢', likeCount: 76, isLiked: false, createdAt: new Date(Date.now() - 220000000).toISOString() },
    ],
  },
];

// ==================== 城市Mock数据 ====================

export const mockCities: City[] = [
  {
    id: 'city_paris',
    name: '巴黎',
    nameEn: 'Paris',
    country: '法国',
    countryCode: 'FR',
    province: '法兰西岛',
    coverImage: 'https://example.com/paris_cover.jpg',
    latitude: 48.8566,
    longitude: 2.3522,
    description: '浪漫之都，艺术与时尚的交汇点。埃菲尔铁塔、卢浮宫、塞纳河畔，每一处都散发着独特的魅力。',
    postsCount: 12456,
    visitorsCount: 8934,
    isUnlocked: false,
  },
  {
    id: 'city_tokyo',
    name: '东京',
    nameEn: 'Tokyo',
    country: '日本',
    countryCode: 'JP',
    coverImage: 'https://example.com/tokyo_cover.jpg',
    latitude: 35.6762,
    longitude: 139.6503,
    description: '传统与现代的完美融合，从古老的浅草寺到繁华的涩谷，每一刻都是惊喜。',
    postsCount: 15678,
    visitorsCount: 11234,
    isUnlocked: true,
  },
  {
    id: 'city_newyork',
    name: '纽约',
    nameEn: 'New York',
    country: '美国',
    countryCode: 'US',
    province: '纽约州',
    coverImage: 'https://example.com/newyork_cover.jpg',
    latitude: 40.7128,
    longitude: -74.0060,
    description: '永不眠息的城市，自由女神像见证着无数梦想的起航。',
    postsCount: 23456,
    visitorsCount: 15678,
    isUnlocked: false,
  },
  {
    id: 'city_chengdu',
    name: '成都',
    nameEn: 'Chengdu',
    country: '中国',
    countryCode: 'CN',
    province: '四川省',
    coverImage: 'https://example.com/chengdu_cover.jpg',
    latitude: 30.5728,
    longitude: 104.0668,
    description: '天府之国，熊猫的故乡。悠闲的生活节奏，让人流连忘返的美食。',
    postsCount: 8765,
    visitorsCount: 6543,
    isUnlocked: true,
  },
  {
    id: 'city_huangshan',
    name: '黄山',
    nameEn: 'Huangshan',
    country: '中国',
    countryCode: 'CN',
    province: '安徽省',
    coverImage: 'https://example.com/huangshan_cover.jpg',
    latitude: 30.1375,
    longitude: 118.1694,
    description: '五岳归来不看山，黄山归来不看岳。云海、奇松、怪石、温泉，四绝闻名天下。',
    postsCount: 5678,
    visitorsCount: 4321,
    isUnlocked: true,
  },
  {
    id: 'city_xian',
    name: '西安',
    nameEn: "Xi'an",
    country: '中国',
    countryCode: 'CN',
    province: '陕西省',
    coverImage: 'https://example.com/xian_cover.jpg',
    latitude: 34.3416,
    longitude: 108.9398,
    description: '十三朝古都，历史的沉淀让这座城市厚重而迷人。兵马俑、大雁塔、回民街...',
    postsCount: 7890,
    visitorsCount: 5678,
    isUnlocked: true,
  },
  {
    id: 'city_london',
    name: '伦敦',
    nameEn: 'London',
    country: '英国',
    countryCode: 'GB',
    coverImage: 'https://example.com/london_cover.jpg',
    latitude: 51.5074,
    longitude: -0.1278,
    description: '雾都伦敦，大本钟的钟声穿越时空，泰晤士河见证了帝国的兴衰。',
    postsCount: 11234,
    visitorsCount: 8765,
    isUnlocked: false,
  },
];

// 地图标记
export const mockCityMarkers: CityMarker[] = mockCities.map((city: City): CityMarker => ({
  id: city.id,
  name: city.name,
  latitude: city.latitude,
  longitude: city.longitude,
  isUnlocked: city.isUnlocked,
  hasContent: city.postsCount > 0,
  type: city.postsCount > 10000 ? 'hot' : (city.isUnlocked ? 'normal' : 'fog'),
}));

// ==================== 工具函数 ====================

/**
 * 获取随机城市（盲盒摇一摇）
 */
export function getRandomCity(): City {
  const index = Math.floor(Math.random() * mockCities.length);
  return mockCities[index];
}

/**
 * 根据城市ID获取城市信息
 */
export function getCityById(cityId: string): City | undefined {
  return mockCities.find(city => city.id === cityId);
}

/**
 * 获取城市相关的动态
 */
export function getPostsByCityId(cityId: string): Post[] {
  return mockPosts.filter(post => post.location?.cityId === cityId);
}

/**
 * 获取推荐动态（模拟分页）
 */
export function getRecommendPosts(page: number = 1, pageSize: number = 10): Post[] {
  const start = (page - 1) * pageSize;
  const end = start + pageSize;
  // 循环返回数据模拟无限滚动
  const result: Post[] = [];
  for (let i = start; i < end; i++) {
    result.push(mockPosts[i % mockPosts.length]);
  }
  return result;
}

/**
 * 将新发布的动态插入到列表头部
 */
export function addMockPost(newPost: Post): void {
  mockPosts.unshift(newPost);
}