# TraQuick 系统架构文档

## 1. 架构概述

TraQuick 采用分层架构设计，遵循 HarmonyOS 应用开发最佳实践，实现了清晰的关注点分离。

### 1.1 架构图

```
┌─────────────────────────────────────────────────────────────────┐
│                        表现层 (Presentation)                      │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│  │ 探索页  │ │ 社区页  │ │ 发布页  │ │ 消息页  │ │ 个人页  │    │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘    │
└───────┼──────────┼──────────┼──────────┼──────────┼────────────┘
        │          │          │          │          │
┌───────┴──────────┴──────────┴──────────┴──────────┴────────────┐
│                        组件层 (Components)                       │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐           │
│  │ PostCard │ │UserAvatar│ │SharePanel│ │MapExplore│           │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘           │
└─────────────────────────────┬───────────────────────────────────┘
                              │
┌─────────────────────────────┴───────────────────────────────────┐
│                        服务层 (Services)                         │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│  │  ApiService  │ │  AuthService │ │   MockData   │             │
│  └──────────────┘ └──────────────┘ └──────────────┘             │
└─────────────────────────────┬───────────────────────────────────┘
                              │
┌─────────────────────────────┴───────────────────────────────────┐
│                        工具层 (Utils)                            │
│  ┌────────┐ ┌────────┐ ┌─────────┐ ┌────────────┐ ┌──────────┐ │
│  │Storage │ │Formatter│ │ImageUtils│ │LocationSvc │ │PostMapper│ │
│  └────────┘ └────────┘ └─────────┘ └────────────┘ └──────────┘ │
└─────────────────────────────┬───────────────────────────────────┘
                              │
┌─────────────────────────────┴───────────────────────────────────┐
│                        数据层 (Models)                           │
│  ┌──────┐ ┌──────┐ ┌────────┐ ┌───────────┐ ┌───────────┐      │
│  │ User │ │ Post │ │ Message│ │TimeCapsule│ │DriftBottle│      │
│  └──────┘ └──────┘ └────────┘ └───────────┘ └───────────┘      │
└─────────────────────────────────────────────────────────────────┘
```

## 2. 分层详解

### 2.1 表现层 (Presentation Layer)

负责 UI 展示和用户交互，包含所有页面组件。

**职责:**
- 页面布局与渲染
- 用户输入处理
- 页面导航
- 状态绑定与更新

**目录:** `entry/src/main/ets/pages/`

```
pages/
├── Index.ets              # 主入口，TabBar 容器
├── auth/                  # 认证模块
│   ├── LoginPage.ets
│   └── RegisterPage.ets
├── explore/               # 探索模块
│   ├── ExplorePage.ets
│   ├── CityDetailPage.ets
│   ├── DriftBottlePage.ets
│   ├── TimeCapsulePage.ets
│   └── BottleResultPage.ets
├── community/             # 社区模块
│   ├── CommunityPage.ets
│   ├── PostDetailPage.ets
│   ├── UserProfilePage.ets
│   └── ImagePreviewPage.ets
├── message/               # 消息模块
│   ├── MessagePage.ets
│   └── MessageListPage.ets
├── profile/               # 个人中心模块
│   ├── ProfilePage.ets
│   ├── EditProfilePage.ets
│   └── SettingsPage.ets
└── publish/               # 发布模块
    ├── PublishPostPage.ets
    ├── DriftBottlePage.ets
    └── TimeCapsulePage.ets
```

### 2.2 组件层 (Component Layer)

可复用的 UI 组件，封装通用交互逻辑。

**目录:** `entry/src/main/ets/components/`

| 组件 | 说明 | 使用场景 |
|------|------|----------|
| PostCard | 帖子卡片 | 社区列表、个人主页 |
| UserAvatar | 用户头像 | 全局用户展示 |
| SharePanel | 分享面板 | 帖子分享 |
| MapExplore | 地图探索 | 探索页面 |
| CityCardDialog | 城市卡片弹窗 | 城市详情展示 |
| PublishSelectDialog | 发布选择弹窗 | 发布入口 |

### 2.3 服务层 (Service Layer)

封装业务逻辑和数据获取，提供统一的 API 调用接口。

**目录:** `entry/src/main/ets/services/`

#### ApiService.ets
核心 API 服务，封装所有 HTTP 请求。

```typescript
// 主要方法分类
class ApiService {
  // 认证相关
  login(username: string, password: string): Promise<LoginResponse>
  register(data: RegisterData): Promise<void>
  getProfile(): Promise<User>

  // 帖子相关
  getPosts(params: PostQueryParams): Promise<PostListResponse>
  createPost(data: CreatePostData): Promise<void>
  likePost(postId: number): Promise<void>

  // 社交相关
  followUser(userId: number): Promise<void>
  getFollowing(userId: number): Promise<User[]>

  // 特色功能
  pickBottle(): Promise<DriftBottle>
  createCapsule(data: CapsuleData): Promise<void>

  // 媒体上传
  uploadImage(filePath: string): Promise<string>
}
```

#### AuthService.ets
认证状态管理服务。

```typescript
class AuthService {
  static isLoggedIn(): boolean
  static getToken(): string
  static saveToken(token: string): void
  static clearToken(): void
}
```

### 2.4 工具层 (Utils Layer)

通用工具函数和辅助类。

**目录:** `entry/src/main/ets/utils/`

| 工具 | 说明 |
|------|------|
| Constants.ets | 应用常量 (颜色、字体、间距等) |
| Storage.ets | 本地存储封装 |
| Formatter.ets | 格式化工具 (时间、数字) |
| ImageUtils.ets | 图片处理 (压缩、URL格式化) |
| LocationService.ets | 位置服务封装 |
| PostMapper.ets | 数据转换工具 |
| GeoJsonParser.ets | GeoJSON 解析 |
| RegionOverlayManager.ets | 地图区域覆盖管理 |

### 2.5 数据层 (Model Layer)

定义数据结构和接口类型。

**目录:** `entry/src/main/ets/models/`

| 模型 | 说明 |
|------|------|
| User.ets | 用户数据模型 |
| Post.ets | 帖子数据模型 |
| Message.ets | 消息数据模型 |
| City.ets | 城市数据模型 |
| TimeCapsule.ets | 时间胶囊模型 |
| DriftBottle.ets | 漂流瓶模型 |

## 3. 状态管理

### 3.1 AppStorage 全局状态

使用 HarmonyOS 提供的 AppStorage 进行全局状态管理。

```typescript
// 全局状态定义
AppStorage.setOrCreate('isLoggedIn', false)
AppStorage.setOrCreate('currentUserId', 0)
AppStorage.setOrCreate('communityRefreshTrigger', 0)
AppStorage.setOrCreate('profileRefreshTrigger', 0)
```

### 3.2 状态绑定装饰器

| 装饰器 | 说明 | 使用场景 |
|--------|------|----------|
| @State | 组件内部状态 | 局部状态管理 |
| @Prop | 父组件单向传递 | 只读属性传递 |
| @Link | 父子双向绑定 | 需要同步更新 |
| @StorageLink | 绑定 AppStorage | 全局状态同步 |
| @StorageProp | 只读绑定 AppStorage | 全局状态读取 |
| @Watch | 状态监听 | 状态变化响应 |

### 3.3 状态同步模式

```typescript
// 1. 触发器模式 - 通知组件刷新
@StorageLink('communityRefreshTrigger') refreshTrigger: number = 0

// 触发刷新
this.refreshTrigger++

// 监听刷新
@Watch('onRefreshTriggerChange')
onRefreshTriggerChange() {
  this.loadData()
}

// 2. 事件发射器模式 - 跨组件通信
import { emitter } from '@kit.BasicServicesKit'

// 发送事件
emitter.emit({ eventId: 1001 }, { data: { refresh: true } })

// 监听事件
emitter.on({ eventId: 1001 }, (data) => {
  this.handleRefresh()
})
```

## 4. 路由架构

### 4.1 路由配置

路由在 `module.json5` 中配置，使用 NavPathStack 进行导航管理。

```json5
{
  "routerMap": [
    { "name": "LoginPage", "pageSourceFile": "src/main/ets/pages/auth/LoginPage.ets" },
    { "name": "RegisterPage", "pageSourceFile": "src/main/ets/pages/auth/RegisterPage.ets" },
    { "name": "CityDetailPage", "pageSourceFile": "src/main/ets/pages/explore/CityDetailPage.ets" },
    // ... 更多路由
  ]
}
```

### 4.2 导航模式

```typescript
// 创建导航栈
@Provide('pageStack') pageStack: NavPathStack = new NavPathStack()

// 页面跳转
this.pageStack.pushPath({ name: 'PostDetailPage', param: { postId: 123 } })

// 返回上一页
this.pageStack.pop()

// 返回到根页面
this.pageStack.clear()

// 替换当前页面
this.pageStack.replacePath({ name: 'ProfilePage' })
```

## 5. 网络架构

### 5.1 HTTP 请求封装

```typescript
// 基础请求配置
const BASE_URL = 'http://your-api-server.com/api'

// 请求拦截 - 添加 Token
const headers: Record<string, string> = {
  'Content-Type': 'application/json'
}
const token = AuthService.getToken()
if (token) {
  headers['Authorization'] = `Bearer ${token}`
}

// 响应处理
const response = await http.request(url, {
  method: http.RequestMethod.POST,
  header: headers,
  extraData: JSON.stringify(data)
})
```

### 5.2 错误处理

```typescript
try {
  const result = await ApiService.getPosts()
  // 处理成功响应
} catch (error) {
  // 统一错误处理
  if (error.code === 401) {
    // Token 过期，跳转登录
    router.pushUrl({ url: 'pages/auth/LoginPage' })
  } else {
    // 显示错误提示
    promptAction.showToast({ message: '网络请求失败' })
  }
}
```

## 6. 数据流

### 6.1 单向数据流

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   用户操作    │ ──▶ │  调用 Service │ ──▶ │  更新 State  │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                                                 ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   UI 更新    │ ◀── │  State 变化   │ ◀── │  触发渲染    │
└──────────────┘     └──────────────┘     └──────────────┘
```

### 6.2 乐观更新模式

```typescript
// 1. 先更新本地状态
this.post.likeCount++
this.post.isLiked = true

// 2. 发起 API 请求
try {
  await ApiService.likePost(this.post.id)
} catch (error) {
  // 3. 失败时回滚
  this.post.likeCount--
  this.post.isLiked = false
  promptAction.showToast({ message: '操作失败' })
}
```

## 7. 安全架构

### 7.1 认证机制

- 使用 JWT Token 进行身份认证
- Token 存储在本地安全存储中
- 请求自动携带 Authorization 头

### 7.2 权限管理

```json5
// module.json5 中声明所需权限
{
  "requestPermissions": [
    {
      "name": "ohos.permission.INTERNET",
      "reason": "网络访问"
    },
    {
      "name": "ohos.permission.APPROXIMATELY_LOCATION",
      "reason": "获取位置信息"
    },
    {
      "name": "ohos.permission.READ_MEDIA",
      "reason": "读取媒体文件"
    }
  ]
}
```

## 8. 性能优化

### 8.1 图片优化

- 上传前压缩图片
- 使用 OSS 图片处理参数按需获取不同尺寸
- 列表使用缩略图，详情使用大图

### 8.2 列表优化

- 使用 `LazyForEach` 懒加载列表项
- 分页加载数据
- 滚动时暂停非关键请求

### 8.3 状态优化

- 避免不必要的状态更新
- 使用 `@Watch` 精确监听变化
- 合理拆分组件减少重渲染范围

## 9. 扩展性设计

### 9.1 模块化设计

每个功能模块独立封装，便于:
- 独立开发与测试
- 功能复用
- 按需加载

### 9.2 配置外置

- 服务器地址配置化
- 主题颜色可配置
- 功能开关可配置

### 9.3 插件化架构

为未来功能扩展预留接口:
- 第三方登录扩展
- 支付功能集成
- 推送服务集成
