# TraQuick 数据模型文档

## 1. 概述

本文档详细描述 TraQuick 应用中使用的所有数据模型和接口定义。

## 2. 用户模型 (User)

### 2.1 User 接口

```typescript
interface User {
  id: number                    // 用户唯一标识
  nickname: string              // 昵称
  avatar: string                // 头像 URL
  bio: string                   // 个人简介
  coverImage: string            // 封面图 URL
  level: number                 // 用户等级 (1-10)
  levelTitle: string            // 等级称号
  followingCount: number        // 关注数
  followersCount: number        // 粉丝数
  citiesCount: number           // 解锁城市数
  countriesCount: number        // 解锁国家数
  postsCount: number            // 发布帖子数
  isFollowing?: boolean         // 是否已关注 (查看他人时)
  createdAt?: string            // 注册时间
}
```

### 2.2 用户等级系统

| 等级 | 称号 | 要求 |
|------|------|------|
| 1 | 旅行新手 | 初始等级 |
| 2 | 城市探索者 | 解锁 5 个城市 |
| 3 | 省际行者 | 解锁 3 个省份 |
| 4 | 国内达人 | 解锁 10 个省份 |
| 5 | 环球旅人 | 解锁 3 个国家 |
| 6 | 世界探险家 | 解锁 10 个国家 |
| 7 | 大陆征服者 | 解锁 3 个大洲 |
| 8 | 环球使者 | 解锁 5 个大洲 |
| 9 | 旅行大师 | 解锁 50 个国家 |
| 10 | 传奇旅者 | 解锁全部大洲 |

### 2.3 相关接口

```typescript
// 登录请求
interface LoginRequest {
  username: string
  password: string
}

// 登录响应
interface LoginResponse {
  token: string
  user: User
}

// 注册请求
interface RegisterRequest {
  username: string
  password: string
  nickname: string
  email?: string
  phone?: string
}

// 更新资料请求
interface UpdateProfileRequest {
  nickname?: string
  avatar?: string
  bio?: string
  coverImage?: string
}
```

## 3. 帖子模型 (Post)

### 3.1 Post 接口

```typescript
interface Post {
  id: number                    // 帖子唯一标识
  author: User                  // 作者信息
  content: string               // 帖子内容
  images: string[]              // 图片 URL 数组
  location?: string             // 位置信息
  cityId?: number               // 关联城市 ID
  cityName?: string             // 城市名称
  tags: string[]                // 标签数组 (最多5个)
  likeCount: number             // 点赞数
  commentCount: number          // 评论数
  collectCount: number          // 收藏数
  shareCount: number            // 分享数
  isLiked: boolean              // 当前用户是否已点赞
  isCollected: boolean          // 当前用户是否已收藏
  createdAt: string             // 创建时间 (ISO 8601)
  updatedAt?: string            // 更新时间
}
```

### 3.2 PostComment 接口

```typescript
interface PostComment {
  id: number                    // 评论唯一标识
  postId: number                // 所属帖子 ID
  author: User                  // 评论作者
  content: string               // 评论内容
  replyTo?: User                // 回复的用户 (如果是回复)
  parentId?: number             // 父评论 ID (如果是回复)
  likeCount: number             // 点赞数
  isLiked: boolean              // 当前用户是否已点赞
  createdAt: string             // 创建时间
}
```

### 3.3 相关接口

```typescript
// 创建帖子请求
interface CreatePostRequest {
  content: string
  images?: string[]
  location?: string
  cityId?: number
  tags?: string[]
}

// 帖子列表查询参数
interface PostQueryParams {
  page?: number                 // 页码 (默认 1)
  limit?: number                // 每页数量 (默认 10)
  sort?: 'latest' | 'hot'       // 排序方式
  authorId?: number             // 按作者筛选
  cityId?: number               // 按城市筛选
  tag?: string                  // 按标签筛选
  likedBy?: number              // 用户点赞的帖子
  collectedBy?: number          // 用户收藏的帖子
}

// 帖子列表响应
interface PostListResponse {
  posts: Post[]
  total: number
  page: number
  limit: number
  hasMore: boolean
}

// 评论请求
interface CreateCommentRequest {
  postId: number
  content: string
  parentId?: number             // 回复的评论 ID
}
```

## 4. 消息模型 (Message)

### 4.1 Message 接口

```typescript
interface Message {
  id: number                    // 消息唯一标识
  type: MessageType             // 消息类型
  sender?: User                 // 发送者 (系统消息无)
  title?: string                // 消息标题
  content: string               // 消息内容
  relatedPost?: Post            // 关联帖子
  relatedComment?: PostComment  // 关联评论
  isRead: boolean               // 是否已读
  createdAt: string             // 创建时间
}
```

### 4.2 MessageType 枚举

```typescript
enum MessageType {
  LIKE = 'like'                 // 点赞通知
  COMMENT = 'comment'           // 评论通知
  FOLLOW = 'follow'             // 关注通知
  SYSTEM = 'system'             // 系统通知
  SHARE = 'share'               // 分享通知
  CAPSULE = 'capsule'           // 时间胶囊解锁
  BOTTLE = 'bottle'             // 漂流瓶回复
}
```

### 4.3 相关接口

```typescript
// 消息列表查询
interface MessageQueryParams {
  type?: MessageType            // 按类型筛选
  page?: number
  limit?: number
}

// 消息列表响应
interface MessageListResponse {
  messages: Message[]
  total: number
  hasMore: boolean
}

// 未读消息统计
interface UnreadCount {
  total: number
  like: number
  comment: number
  follow: number
  system: number
}
```

## 5. 城市模型 (City)

### 5.1 City 接口

```typescript
interface City {
  id: number                    // 城市唯一标识
  name: string                  // 城市名称
  nameEn?: string               // 英文名称
  province?: string             // 所属省份
  country: string               // 所属国家
  countryCode: string           // 国家代码 (ISO 3166-1)
  continent: string             // 所属大洲
  latitude: number              // 纬度
  longitude: number             // 经度
  coverImage?: string           // 封面图
  description?: string          // 城市简介
  visitCount: number            // 访问人数
  postCount: number             // 相关帖子数
  isVisited?: boolean           // 当前用户是否访问过
  visitedAt?: string            // 访问时间
}
```

### 5.2 地理区域接口

```typescript
// GeoJSON 区域数据
interface GeoRegion {
  type: 'Feature'
  properties: {
    name: string
    code: string
    level: 'province' | 'city' | 'country'
  }
  geometry: {
    type: 'Polygon' | 'MultiPolygon'
    coordinates: number[][][]
  }
}

// 区域覆盖层
interface RegionOverlay {
  regionCode: string
  isRevealed: boolean           // 是否已解锁 (揭开迷雾)
  polygonPath: Array<{ latitude: number, longitude: number }>
}
```

## 6. 漂流瓶模型 (DriftBottle)

### 6.1 DriftBottle 接口

```typescript
interface DriftBottle {
  id: number                    // 漂流瓶唯一标识
  author: User                  // 创建者
  content: string               // 瓶中内容
  mood: BottleMood              // 心情
  type: BottleType              // 类型
  images?: string[]             // 图片 (任务瓶回复时)
  location?: string             // 投放位置
  status: BottleStatus          // 状态
  pickedBy?: User               // 捡拾者
  pickedAt?: string             // 捡拾时间
  replyContent?: string         // 回复内容
  replyImages?: string[]        // 回复图片
  createdAt: string             // 创建时间
}
```

### 6.2 相关枚举

```typescript
enum BottleMood {
  HAPPY = 'happy'               // 开心
  SAD = 'sad'                   // 难过
  EXCITED = 'excited'           // 兴奋
  CALM = 'calm'                 // 平静
  CURIOUS = 'curious'           // 好奇
  HOPEFUL = 'hopeful'           // 期待
}

enum BottleType {
  WISH = 'wish'                 // 心愿瓶
  QUESTION = 'question'         // 问题瓶
  TASK = 'task'                 // 任务瓶 (需要回复照片)
  STORY = 'story'               // 故事瓶
}

enum BottleStatus {
  DRIFTING = 'drifting'         // 漂流中
  PICKED = 'picked'             // 已被捡起
  REPLIED = 'replied'           // 已回复
  EXPIRED = 'expired'           // 已过期
}
```

### 6.3 相关接口

```typescript
// 创建漂流瓶
interface CreateBottleRequest {
  content: string
  mood: BottleMood
  type: BottleType
  location?: string
}

// 回复漂流瓶
interface ReplyBottleRequest {
  bottleId: number
  content?: string
  images?: string[]
}
```

## 7. 时间胶囊模型 (TimeCapsule)

### 7.1 TimeCapsule 接口

```typescript
interface TimeCapsule {
  id: number                    // 胶囊唯一标识
  author: User                  // 创建者
  title: string                 // 胶囊标题
  content: string               // 胶囊内容
  images?: string[]             // 图片数组
  location?: string             // 埋藏位置
  targetDate: string            // 目标开启日期
  status: CapsuleStatus         // 状态
  isPublic: boolean             // 是否公开
  viewCount?: number            // 查看次数 (公开胶囊)
  createdAt: string             // 创建时间
  openedAt?: string             // 开启时间
}
```

### 7.2 相关枚举

```typescript
enum CapsuleStatus {
  SEALED = 'sealed'             // 已封存
  READY = 'ready'               // 可开启
  OPENED = 'opened'             // 已开启
}

// 预设时间选项
enum CapsuleDuration {
  SIX_MONTHS = '6m'             // 6个月
  ONE_YEAR = '1y'               // 1年
  THREE_YEARS = '3y'            // 3年
  FIVE_YEARS = '5y'             // 5年
  CUSTOM = 'custom'             // 自定义
}
```

### 7.3 相关接口

```typescript
// 创建时间胶囊
interface CreateCapsuleRequest {
  title: string
  content: string
  images?: string[]
  location?: string
  targetDate: string            // ISO 8601 格式
  isPublic: boolean
}

// 胶囊列表响应
interface CapsuleListResponse {
  capsules: TimeCapsule[]
  total: number
  sealed: number                // 未开启数量
  ready: number                 // 可开启数量
  opened: number                // 已开启数量
}
```

## 8. API 通用接口

### 8.1 分页参数

```typescript
interface PaginationParams {
  page: number                  // 页码，从 1 开始
  limit: number                 // 每页数量
}

interface PaginationResponse {
  total: number                 // 总数量
  page: number                  // 当前页码
  limit: number                 // 每页数量
  totalPages: number            // 总页数
  hasMore: boolean              // 是否有下一页
}
```

### 8.2 通用响应格式

```typescript
interface ApiResponse<T> {
  code: number                  // 状态码 (200 成功)
  message: string               // 消息
  data: T                       // 数据
}

interface ApiError {
  code: number                  // 错误码
  message: string               // 错误消息
  details?: Record<string, string>  // 详细错误信息
}
```

### 8.3 常用状态码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 201 | 创建成功 |
| 400 | 请求参数错误 |
| 401 | 未授权 (Token 无效/过期) |
| 403 | 禁止访问 |
| 404 | 资源不存在 |
| 409 | 资源冲突 (如重复关注) |
| 500 | 服务器错误 |

## 9. 数据关系图

```
┌─────────┐     1:N     ┌─────────┐
│  User   │ ──────────▶ │  Post   │
└─────────┘             └─────────┘
     │                       │
     │ 1:N                   │ 1:N
     ▼                       ▼
┌─────────┐           ┌───────────┐
│ Message │           │PostComment│
└─────────┘           └───────────┘

┌─────────┐     N:M     ┌─────────┐
│  User   │ ◀────────▶ │  City   │
└─────────┘  (visited)  └─────────┘

┌─────────┐     1:N     ┌───────────┐
│  User   │ ──────────▶ │DriftBottle│
└─────────┘             └───────────┘

┌─────────┐     1:N     ┌───────────┐
│  User   │ ──────────▶ │TimeCapsule│
└─────────┘             └───────────┘

┌─────────┐     N:M     ┌─────────┐
│  User   │ ◀────────▶ │  User   │
└─────────┘  (follow)   └─────────┘
```

## 10. 本地存储数据

### 10.1 Preferences 存储

| Key | 类型 | 说明 |
|-----|------|------|
| `auth_token` | string | 用户认证 Token |
| `current_user` | User (JSON) | 当前登录用户信息 |
| `theme_mode` | 'light' \| 'dark' | 主题模式 |
| `visited_cities` | number[] | 已访问城市 ID 缓存 |
| `draft_post` | Post (JSON) | 帖子草稿 |

### 10.2 AppStorage 全局状态

| Key | 类型 | 说明 |
|-----|------|------|
| `isLoggedIn` | boolean | 登录状态 |
| `currentUserId` | number | 当前用户 ID |
| `communityRefreshTrigger` | number | 社区刷新触发器 |
| `profileRefreshTrigger` | number | 个人页刷新触发器 |
| `unreadMessageCount` | number | 未读消息数 |
