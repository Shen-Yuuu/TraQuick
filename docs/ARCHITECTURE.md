# TraQuick 项目技术文档

> 更新时间：2026年1月23日  
> 版本：V1.0.0 (MVP)  
> 状态：开发中

---

## 1. 项目概述

### 1.1 项目定位
TraQuick (Travel + Quick) 是一款基于 HarmonyOS Next 的盲盒式旅行社交平台。核心理念是「足不出户，欣赏世界」，通过游戏化的交互体验，让用户在快节奏的生活中拥有一个纯净的社交平台去探索世界。

### 1.2 技术栈

| 层级 | 技术选型 | 说明 |
|------|----------|------|
| 前端框架 | ArkTS + ArkUI | HarmonyOS Next 原生开发 |
| 状态管理 | @State/@Prop/@Link | ArkUI 内置状态管理 |
| 网络请求 | @ohos.net.http | HarmonyOS 网络模块 |
| 数据存储 | @ohos.data.preferences | 本地持久化存储 |
| 地图服务 | 华为 Map Kit | 3D 地球、城市定位 |
| 后端服务 | Node.js + NestJS | RESTful API 服务 |
| 数据库 | PostgreSQL | 主数据存储 |
| 缓存 | Redis | 会话管理、热数据缓存 |

---

## 2. 项目架构

### 2.1 目录结构

```
entry/src/main/
├── ets/                          # ArkTS 源码目录
│   ├── components/               # 可复用组件
│   │   ├── common/               # 通用组件
│   │   │   ├── UserAvatar.ets    # 用户头像组件
│   │   │   ├── PostCard.ets      # 动态卡片组件
│   │   │   └── PublishSelectDialog.ets  # 发布选择弹窗
│   │   ├── explore/              # 探索模块组件
│   │   │   └── CityCardDialog.ets # 城市卡片弹窗
│   │   └── publish/              # 发布模块组件
│   │
│   ├── models/                   # 数据模型定义
│   │   ├── Index.ets             # 统一导出
│   │   ├── User.ets              # 用户模型
│   │   ├── Post.ets              # 动态/帖子模型
│   │   ├── City.ets              # 城市模型
│   │   └── Message.ets           # 消息模型
│   │
│   ├── services/                 # 服务层
│   │   ├── ApiService.ets        # HTTP 请求封装
│   │   ├── AuthService.ets       # 认证服务
│   │   └── MockData.ets          # Mock 数据服务
│   │
│   ├── pages/                    # 页面目录
│   │   ├── Index.ets             # 主页 Tab 容器
│   │   ├── auth/                 # 认证模块
│   │   │   ├── LoginPage.ets     # 登录页
│   │   │   └── RegisterPage.ets  # 注册页
│   │   ├── explore/              # 探索模块
│   │   │   ├── ExplorePage.ets   # 探索首页（地图）
│   │   │   ├── CityDetailPage.ets # 城市详情页
│   │   │   ├── DriftBottlePage.ets # 漂流瓶页
│   │   │   └── TimeCapsulePage.ets # 时空胶囊页
│   │   ├── community/            # 社区模块
│   │   │   ├── CommunityPage.ets # 社区首页
│   │   │   └── PostDetailPage.ets # 动态详情页
│   │   ├── publish/              # 发布模块
│   │   │   └── PublishPostPage.ets # 发布动态页
│   │   ├── message/              # 消息模块
│   │   │   └── MessagePage.ets   # 消息中心页
│   │   └── profile/              # 个人模块
│   │       ├── ProfilePage.ets   # 个人中心页
│   │       └── SettingsPage.ets  # 设置页
│   │
│   ├── utils/                    # 工具类
│   │   ├── Constants.ets         # 设计规范常量
│   │   └── Storage.ets           # 本地存储工具
│   │
│   └── entryability/             # 入口 Ability
│       └── EntryAbility.ets
│
└── resources/                    # 资源目录
    ├── base/                     # 基础资源
    │   ├── element/              # 元素资源
    │   ├── media/                # 媒体资源
    │   └── profile/              # 配置文件
    │       └── main_pages.json   # 页面路由配置
    └── dark/                     # 深色主题资源
```

### 2.2 页面路由配置

当前已注册页面（`main_pages.json`）：

| 页面路径 | 说明 | 入口类型 |
|----------|------|----------|
| pages/Index | 主 Tab 容器 | @Entry |
| pages/auth/LoginPage | 登录页 | @Entry |
| pages/auth/RegisterPage | 注册页 | @Entry |
| pages/explore/ExplorePage | 探索首页 | @Component |
| pages/explore/CityDetailPage | 城市详情 | @Entry |
| pages/explore/DriftBottlePage | 漂流瓶 | @Entry |
| pages/explore/TimeCapsulePage | 时空胶囊 | @Entry |
| pages/community/CommunityPage | 社区首页 | @Component |
| pages/community/PostDetailPage | 动态详情 | @Entry |
| pages/publish/PublishPostPage | 发布动态 | @Entry |
| pages/message/MessagePage | 消息中心 | @Component |
| pages/profile/ProfilePage | 个人中心 | @Component |
| pages/profile/SettingsPage | 设置页 | @Entry |

---

## 3. 设计系统

### 3.1 颜色规范

```typescript
// 主色调 - 天空蓝系列
primary: '#0EA5E9'        // Sky-500 主色
primaryLight: '#38BDF8'   // Sky-400 浅色
primaryLightest: '#E0F2FE' // Sky-100 最浅背景

// 背景色
bgPrimary: '#FFFFFF'      // 主背景
bgSecondary: '#F8FAFC'    // 次级背景

// 文字色
textPrimary: '#0F172A'    // 标题
textSecondary: '#475569'  // 正文
textTertiary: '#64748B'   // 描述
```

### 3.2 字体规范

```typescript
FontSizes = {
  h1: 32,      // 大标题
  h2: 28,      // 标题
  h3: 24,      // 小标题
  h4: 20,      // 次标题
  bodyLarge: 18,
  body: 16,    // 正文
  bodySmall: 14,
  small: 12,
  mini: 10,
  tiny: 8
}
```

### 3.3 间距规范

```typescript
Spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  pagePadding: 16,
  cardPadding: 16,
  cardMargin: 12
}
```

### 3.4 圆角规范

```typescript
Radius = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  card: 16,
  tag: 12,
  full: 999
}
```

---

## 4. 数据模型

### 4.1 User 用户模型

```typescript
interface User {
  id: string;
  phone?: string;
  email?: string;
  nickname?: string;
  avatar?: string;
  bio?: string;
  level: number;           // 1-5 等级
  levelTitle: string;      // 等级称号
  followingCount: number;
  followersCount: number;
  friendsCount: number;
  citiesCount: number;     // 点亮城市数
  countriesCount: number;  // 点亮国家数
  postsCount: number;
  createdAt: string;
  updatedAt: string;
}
```

### 4.2 Post 动态模型

```typescript
interface Post {
  id: string;
  author: PostAuthor;
  content: string;
  images: string[];
  video?: string;
  location?: PostLocation;
  tags: string[];
  likeCount: number;
  commentCount: number;
  shareCount: number;
  collectCount: number;
  isLiked: boolean;
  isCollected: boolean;
  createdAt: string;
  type: 'image' | 'video';
}
```

### 4.3 City 城市模型

```typescript
interface City {
  id: string;
  name: string;
  nameEn?: string;
  country: string;
  countryCode: string;
  province?: string;
  coverImage: string;
  latitude: number;
  longitude: number;
  description?: string;
  postsCount: number;
  visitorsCount: number;
  isUnlocked: boolean;
}
```

---

## 5. 组件说明

### 5.1 UserAvatar 用户头像

```typescript
@Component
export struct UserAvatar {
  @Prop src: string;         // 头像 URL
  @Prop size: number = 40;   // 尺寸
  @Prop level?: number;      // 等级
  @Prop showLevel: boolean = false; // 显示等级标签
}
```

### 5.2 PostCard 动态卡片

```typescript
@Component
export struct PostCard {
  @Prop post: Post;
  onLike: () => void;
  onComment: () => void;
  onShare: () => void;
  onCollect: () => void;
}
```

### 5.3 CityCardDialog 城市卡片弹窗

```typescript
@Component
export struct CityCardDialog {
  @Prop city: City;
  onClose: () => void;
  onExplore: (city: City) => void;
  onShuffle: () => void;
}
```

---

## 6. 游戏化等级体系

| 等级 | 称号 | 条件 | 颜色 |
|------|------|------|------|
| LV.1 | 迷雾行者 | 注册即得 | #94A3B8 (灰) |
| LV.2 | 城市猎人 | 点亮 5 城 | #10B981 (绿) |
| LV.3 | 洲际探险家 | 跨越 2 国 | #3B82F6 (蓝) |
| LV.4 | 环球领航员 | 攻略被收录 | #8B5CF6 (紫) |
| LV.5 | 星耀漫游者 | 顶级大V | #F59E0B (金) |

---

## 7. 开发规范

### 7.1 命名规范

- **文件命名**：PascalCase，如 `LoginPage.ets`
- **组件命名**：PascalCase，如 `UserAvatar`
- **变量命名**：camelCase，如 `isLoading`
- **常量命名**：UPPER_SNAKE_CASE 或 PascalCase 对象

### 7.2 代码规范

1. 组件使用 `@Component` 装饰器
2. 页面入口使用 `@Entry` 装饰器
3. 状态使用 `@State`，父子传递使用 `@Prop`
4. Builder 函数使用 `@Builder` 装饰器
5. 导入路径使用相对路径

### 7.3 注释规范

```typescript
/**
 * 组件/函数说明
 * @param xxx 参数说明
 * @returns 返回值说明
 */
```

---

## 8. 待开发功能

### Phase 2 - 地图集成
- [ ] 华为 Map Kit 3D 地球
- [ ] 城市标记点渲染
- [ ] 迷雾效果实现
- [ ] 摇一摇动画优化

### Phase 3 - 社交完善
- [ ] 关注/粉丝系统
- [ ] 私信功能
- [ ] @提及功能
- [ ] 评论回复嵌套

### Phase 4 - 后端对接
- [ ] 用户认证 API
- [ ] 动态 CRUD API
- [ ] 城市数据 API
- [ ] 文件上传服务

### Phase 5 - 鸿蒙特性
- [ ] 万能卡片
- [ ] 多端流转
- [ ] 手表联动

---

## 9. 版本记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v0.1.0 | 2026-01-22 | 项目初始化，基础架构搭建 |
| v0.2.0 | 2026-01-23 | 完成所有基础页面，组件库，Mock数据 |

---

*文档持续更新中...*
