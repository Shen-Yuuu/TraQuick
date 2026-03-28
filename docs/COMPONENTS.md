# TraQuick 组件文档

## 1. 概述

本文档详细描述 TraQuick 应用中所有可复用的 UI 组件，包括组件的功能、属性、事件和使用示例。

## 2. 组件目录

```
components/
├── common/
│   ├── PostCard.ets        # 帖子卡片组件
│   ├── UserAvatar.ets      # 用户头像组件
│   └── SharePanel.ets      # 分享面板组件
├── explore/
│   ├── MapExplore.ets      # 地图探索组件
│   └── CityCardDialog.ets  # 城市卡片弹窗
└── publish/
    └── PublishSelectDialog.ets  # 发布选择弹窗
```

---

## 3. PostCard 帖子卡片

### 3.1 功能描述

帖子卡片是社区模块的核心组件，用于展示用户发布的帖子内容，支持点赞、收藏、评论、分享等交互。

### 3.2 组件属性

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| post | Post | 是 | 帖子数据对象 |
| onPostUpdated | (post: Post) => void | 否 | 帖子更新回调 |
| showAuthor | boolean | 否 | 是否显示作者信息，默认 true |
| enableNavigation | boolean | 否 | 是否启用详情页导航，默认 true |

### 3.3 组件结构

```
┌────────────────────────────────────────┐
│ ┌──────┐ 用户昵称        关注按钮      │
│ │头像  │ @用户名 · 2小时前             │
│ └──────┘                               │
├────────────────────────────────────────┤
│                                        │
│  帖子内容文本...                        │
│                                        │
├────────────────────────────────────────┤
│ ┌────────┐ ┌────────┐ ┌────────┐      │
│ │  图片1  │ │  图片2  │ │  图片3  │      │
│ └────────┘ └────────┘ └────────┘      │
├────────────────────────────────────────┤
│ 📍 北京市朝阳区                        │
│ #标签1  #标签2  #标签3                 │
├────────────────────────────────────────┤
│ ❤️ 128    💬 32    ⭐ 56    📤 分享   │
└────────────────────────────────────────┘
```

### 3.4 使用示例

```typescript
import { PostCard } from '../components/common/PostCard'

@Entry
@Component
struct PostListPage {
  @State posts: Post[] = []

  build() {
    List() {
      ForEach(this.posts, (post: Post) => {
        ListItem() {
          PostCard({
            post: post,
            onPostUpdated: (updatedPost) => {
              // 处理帖子更新
              const index = this.posts.findIndex(p => p.id === updatedPost.id)
              if (index >= 0) {
                this.posts[index] = updatedPost
              }
            }
          })
        }
      })
    }
  }
}
```

### 3.5 内部功能

#### 点赞功能
```typescript
private async handleLike() {
  // 乐观更新 UI
  this.post.isLiked = !this.post.isLiked
  this.post.likeCount += this.post.isLiked ? 1 : -1

  try {
    if (this.post.isLiked) {
      await ApiService.likePost(this.post.id)
    } else {
      await ApiService.unlikePost(this.post.id)
    }
  } catch (error) {
    // 失败时回滚
    this.post.isLiked = !this.post.isLiked
    this.post.likeCount += this.post.isLiked ? 1 : -1
  }
}
```

#### 图片展示网格
根据图片数量自动调整布局:
- 1张图片: 宽度占满，高度自适应
- 2张图片: 横向排列，各占50%
- 3张图片: 左侧大图，右侧两张小图
- 4张及以上: 3列网格布局

---

## 4. UserAvatar 用户头像

### 4.1 功能描述

用户头像组件，支持显示用户头像图片和等级徽章。

### 4.2 组件属性

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| avatarUrl | string | 是 | 头像 URL |
| size | number | 否 | 头像尺寸，默认 40 |
| level | number | 否 | 用户等级 (1-10) |
| showBadge | boolean | 否 | 是否显示等级徽章，默认 true |
| onClick | () => void | 否 | 点击回调 |

### 4.3 等级徽章样式

| 等级 | 颜色 | 图标 |
|------|------|------|
| 1-2 | 灰色 | 铜星 |
| 3-4 | 绿色 | 银星 |
| 5-6 | 蓝色 | 金星 |
| 7-8 | 紫色 | 钻石 |
| 9-10 | 金色 | 皇冠 |

### 4.4 使用示例

```typescript
import { UserAvatar } from '../components/common/UserAvatar'

@Component
struct UserInfo {
  @Prop user: User

  build() {
    Row() {
      UserAvatar({
        avatarUrl: this.user.avatar,
        size: 48,
        level: this.user.level,
        showBadge: true,
        onClick: () => {
          // 跳转到用户主页
          this.pageStack.pushPath({
            name: 'UserProfilePage',
            param: { userId: this.user.id }
          })
        }
      })

      Column() {
        Text(this.user.nickname)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
        Text(this.user.levelTitle)
          .fontSize(12)
          .fontColor('#999')
      }
      .margin({ left: 12 })
    }
  }
}
```

---

## 5. SharePanel 分享面板

### 5.1 功能描述

分享面板组件，以底部弹出的方式展示可分享的目标用户列表（关注列表），支持选择多个用户进行分享。

### 5.2 组件属性

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| visible | boolean | 是 | 是否显示面板 |
| postId | number | 是 | 要分享的帖子 ID |
| onClose | () => void | 是 | 关闭面板回调 |
| onShareComplete | (success: boolean) => void | 否 | 分享完成回调 |

### 5.3 组件结构

```
┌────────────────────────────────────────┐
│                 分享给                  │
├────────────────────────────────────────┤
│  搜索关注的人...                        │
├────────────────────────────────────────┤
│ ┌──────┐ 用户A            ☑️          │
│ │ 头像 │ @user_a                       │
│ └──────┘                               │
│ ┌──────┐ 用户B            ☐           │
│ │ 头像 │ @user_b                       │
│ └──────┘                               │
│ ┌──────┐ 用户C            ☑️          │
│ │ 头像 │ @user_c                       │
│ └──────┘                               │
├────────────────────────────────────────┤
│         [ 分享给 2 人 ]                 │
└────────────────────────────────────────┘
```

### 5.4 使用示例

```typescript
import { SharePanel } from '../components/common/SharePanel'

@Component
struct PostActions {
  @State showSharePanel: boolean = false
  @Prop postId: number

  build() {
    Column() {
      Button('分享')
        .onClick(() => {
          this.showSharePanel = true
        })

      if (this.showSharePanel) {
        SharePanel({
          visible: this.showSharePanel,
          postId: this.postId,
          onClose: () => {
            this.showSharePanel = false
          },
          onShareComplete: (success) => {
            if (success) {
              promptAction.showToast({ message: '分享成功' })
            }
          }
        })
      }
    }
  }
}
```

---

## 6. MapExplore 地图探索

### 6.1 功能描述

地图探索组件，用于展示世界地图并实现"迷雾探索"效果。用户访问过的区域会被揭开，未访问的区域保持迷雾覆盖。

### 6.2 组件属性

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| visitedCities | City[] | 是 | 已访问的城市列表 |
| onCityClick | (city: City) => void | 否 | 城市点击回调 |
| onMapReady | () => void | 否 | 地图加载完成回调 |
| centerLatitude | number | 否 | 地图中心纬度 |
| centerLongitude | number | 否 | 地图中心经度 |
| zoomLevel | number | 否 | 缩放级别，默认 5 |

### 6.3 核心功能

#### 迷雾覆盖层
```typescript
// 使用 RegionOverlayManager 管理区域覆盖
@State regionOverlays: RegionOverlay[] = []

private updateFogOfWar() {
  const visitedCodes = this.visitedCities.map(c => c.cityCode)

  this.regionOverlays = this.allRegions.map(region => ({
    regionCode: region.code,
    isRevealed: visitedCodes.includes(region.code),
    polygonPath: region.geometry.coordinates
  }))
}
```

#### 地图交互
- 缩放: 支持双指缩放
- 拖动: 支持地图拖动
- 点击: 点击城市显示详情

### 6.4 使用示例

```typescript
import { MapExplore } from '../components/explore/MapExplore'

@Entry
@Component
struct ExplorePage {
  @State visitedCities: City[] = []

  aboutToAppear() {
    this.loadVisitedCities()
  }

  build() {
    Stack() {
      MapExplore({
        visitedCities: this.visitedCities,
        onCityClick: (city) => {
          // 显示城市详情弹窗
          this.selectedCity = city
          this.showCityDialog = true
        },
        centerLatitude: 35.0,
        centerLongitude: 105.0,
        zoomLevel: 4
      })
    }
  }
}
```

---

## 7. CityCardDialog 城市卡片弹窗

### 7.1 功能描述

城市信息卡片弹窗，展示城市的详细信息、统计数据，并提供查看详情和发布内容的入口。

### 7.2 组件属性

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| city | City | 是 | 城市数据 |
| visible | boolean | 是 | 是否显示弹窗 |
| onClose | () => void | 是 | 关闭弹窗回调 |
| onViewDetail | (cityId: number) => void | 否 | 查看详情回调 |
| onPublish | (cityId: number) => void | 否 | 发布内容回调 |

### 7.3 组件结构

```
┌────────────────────────────────────────┐
│  ┌────────────────────────────────┐   │
│  │                                │   │
│  │         城市封面图              │   │
│  │                                │   │
│  └────────────────────────────────┘   │
│                                        │
│  北京市                                │
│  Beijing · 中国                        │
│                                        │
│  ┌──────────┐ ┌──────────┐            │
│  │ 访问人数  │ │ 相关帖子  │            │
│  │  10,234  │ │  5,678   │            │
│  └──────────┘ └──────────┘            │
│                                        │
│  ┌──────────────────────────────┐     │
│  │        查看城市详情            │     │
│  └──────────────────────────────┘     │
│                                        │
│  ┌──────────────────────────────┐     │
│  │        在此地发布内容          │     │
│  └──────────────────────────────┘     │
└────────────────────────────────────────┘
```

### 7.4 使用示例

```typescript
import { CityCardDialog } from '../components/explore/CityCardDialog'

@Component
struct MapPage {
  @State selectedCity: City | null = null
  @State showCityDialog: boolean = false

  build() {
    Stack() {
      // 地图组件
      MapExplore({ ... })

      // 城市详情弹窗
      if (this.showCityDialog && this.selectedCity) {
        CityCardDialog({
          city: this.selectedCity,
          visible: this.showCityDialog,
          onClose: () => {
            this.showCityDialog = false
          },
          onViewDetail: (cityId) => {
            this.pageStack.pushPath({
              name: 'CityDetailPage',
              param: { cityId }
            })
          },
          onPublish: (cityId) => {
            this.pageStack.pushPath({
              name: 'PublishPostPage',
              param: { cityId }
            })
          }
        })
      }
    }
  }
}
```

---

## 8. PublishSelectDialog 发布选择弹窗

### 8.1 功能描述

发布类型选择弹窗，让用户选择要发布的内容类型：普通帖子、漂流瓶或时间胶囊。

### 8.2 组件属性

| 属性 | 类型 | 必填 | 说明 |
|------|------|------|------|
| visible | boolean | 是 | 是否显示弹窗 |
| onClose | () => void | 是 | 关闭弹窗回调 |
| onSelect | (type: PublishType) => void | 是 | 选择类型回调 |

### 8.3 发布类型

```typescript
enum PublishType {
  POST = 'post',           // 普通帖子
  DRIFT_BOTTLE = 'bottle', // 漂流瓶
  TIME_CAPSULE = 'capsule' // 时间胶囊
}
```

### 8.4 组件结构

```
┌────────────────────────────────────────┐
│              创建内容                   │
├────────────────────────────────────────┤
│                                        │
│  ┌────────────────────────────────┐   │
│  │  📝  发布帖子                   │   │
│  │      分享你的旅行故事           │   │
│  └────────────────────────────────┘   │
│                                        │
│  ┌────────────────────────────────┐   │
│  │  🌊  漂流瓶                    │   │
│  │      投放一个神秘的漂流瓶       │   │
│  └────────────────────────────────┘   │
│                                        │
│  ┌────────────────────────────────┐   │
│  │  ⏳  时间胶囊                   │   │
│  │      给未来的自己留言           │   │
│  └────────────────────────────────┘   │
│                                        │
└────────────────────────────────────────┘
```

### 8.5 使用示例

```typescript
import { PublishSelectDialog } from '../components/publish/PublishSelectDialog'

@Entry
@Component
struct MainPage {
  @State showPublishDialog: boolean = false

  build() {
    Stack() {
      // 主内容
      TabContent() { ... }

      // 发布按钮
      Button('+')
        .onClick(() => {
          this.showPublishDialog = true
        })

      // 发布选择弹窗
      if (this.showPublishDialog) {
        PublishSelectDialog({
          visible: this.showPublishDialog,
          onClose: () => {
            this.showPublishDialog = false
          },
          onSelect: (type) => {
            this.showPublishDialog = false
            switch (type) {
              case 'post':
                this.pageStack.pushPath({ name: 'PublishPostPage' })
                break
              case 'bottle':
                this.pageStack.pushPath({ name: 'PublishDriftBottlePage' })
                break
              case 'capsule':
                this.pageStack.pushPath({ name: 'PublishTimeCapsulePage' })
                break
            }
          }
        })
      }
    }
  }
}
```

---

## 9. 组件设计规范

### 9.1 命名规范

- 组件文件名使用 PascalCase: `PostCard.ets`
- 组件名与文件名一致
- 属性使用 camelCase

### 9.2 属性设计

- 必填属性放在前面
- 提供合理的默认值
- 回调函数以 `on` 开头

### 9.3 样式规范

- 使用 Constants.ets 中的常量
- 颜色使用语义化命名
- 间距使用 4 的倍数

### 9.4 性能优化

- 使用 `@Prop` 传递简单类型
- 复杂对象使用 `@ObjectLink`
- 避免不必要的重渲染

---

## 10. 组件最佳实践

### 10.1 状态管理

```typescript
// 推荐: 父组件管理状态，通过回调通知
@Component
struct ChildComponent {
  @Prop value: string
  onValueChange: (newValue: string) => void = () => {}

  build() {
    TextInput({ text: this.value })
      .onChange((value) => {
        this.onValueChange(value)
      })
  }
}
```

### 10.2 事件处理

```typescript
// 推荐: 事件向上冒泡，让父组件处理
@Component
struct ActionButton {
  onClick: () => void = () => {}

  build() {
    Button('点击')
      .onClick(() => {
        this.onClick()
      })
  }
}
```

### 10.3 条件渲染

```typescript
// 推荐: 使用条件语句控制渲染
build() {
  Column() {
    if (this.isLoading) {
      LoadingIndicator()
    } else if (this.error) {
      ErrorView({ message: this.error })
    } else {
      ContentView({ data: this.data })
    }
  }
}
```
