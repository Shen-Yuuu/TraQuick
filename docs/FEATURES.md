# TraQuick 功能模块文档

## 1. 概述

本文档详细描述 TraQuick 应用的各个功能模块，包括功能说明、交互流程和技术实现。

---

## 2. 地图探索功能

### 2.1 功能概述

地图探索是 TraQuick 的核心特色功能，采用"迷雾地图"的游戏化设计，用户通过实际到访城市来"解锁"地图区域。

### 2.2 功能特性

| 特性 | 说明 |
|------|------|
| 迷雾覆盖 | 未访问区域被迷雾遮盖 |
| 区域解锁 | 到达新城市自动解锁该区域 |
| 足迹统计 | 统计已访问城市、国家、大洲数量 |
| 城市标记 | 已访问城市显示特殊标记 |
| 成就系统 | 解锁区域获得对应成就 |

### 2.3 技术实现

#### 迷雾层渲染
```typescript
// GeoJSON 区域数据解析
const geoParser = new GeoJsonParser()
const regions = geoParser.parse(geoJsonData)

// 覆盖层管理
const overlayManager = new RegionOverlayManager()
overlayManager.setRevealedRegions(visitedCityCodes)

// 渲染迷雾
build() {
  MapComponent({
    overlays: overlayManager.getOverlays()
  })
}
```

#### 位置检测与解锁
```typescript
// 获取当前位置
const location = await LocationService.getCurrentLocation()

// 匹配城市
const city = await ApiService.matchCity(location.latitude, location.longitude)

if (city && !city.isVisited) {
  // 标记为已访问
  await ApiService.markCityVisited(city.id, location)

  // 更新本地状态
  this.visitedCities.push(city)

  // 显示解锁动画
  this.showUnlockAnimation(city)
}
```

### 2.4 用户交互流程

```
┌──────────────────────────────────────────────────────────────┐
│                        地图探索流程                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. 打开探索页 ──▶ 加载地图 ──▶ 显示迷雾覆盖                  │
│                                                              │
│  2. 定位当前位置 ──▶ 检测是否在新城市                        │
│         │                                                    │
│         ├── 是 ──▶ 解锁城市 ──▶ 播放解锁动画 ──▶ 更新统计    │
│         │                                                    │
│         └── 否 ──▶ 显示当前城市信息                          │
│                                                              │
│  3. 点击城市标记 ──▶ 显示城市卡片 ──▶ 可进入城市详情          │
│                                                              │
│  4. 地图缩放/拖动 ──▶ 浏览全球足迹                           │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 2.5 成就等级系统

| 等级 | 称号 | 解锁条件 | 徽章 |
|------|------|----------|------|
| Lv.1 | 旅行新手 | 注册 | 🌱 |
| Lv.2 | 城市探索者 | 5个城市 | 🏙️ |
| Lv.3 | 省际行者 | 3个省份 | 🚄 |
| Lv.4 | 国内达人 | 10个省份 | 🇨🇳 |
| Lv.5 | 环球旅人 | 3个国家 | ✈️ |
| Lv.6 | 世界探险家 | 10个国家 | 🌍 |
| Lv.7 | 大陆征服者 | 3个大洲 | 🏆 |
| Lv.8 | 环球使者 | 5个大洲 | 👑 |
| Lv.9 | 旅行大师 | 50个国家 | ⭐ |
| Lv.10 | 传奇旅者 | 全部大洲 | 💎 |

---

## 3. 社区动态功能

### 3.1 功能概述

社区动态是用户分享旅行经历、与其他旅行者互动的核心社交功能。

### 3.2 功能特性

| 特性 | 说明 |
|------|------|
| 多 Tab 内容流 | 推荐/关注/好友三种内容源 |
| 图文帖子 | 支持最多9张图片 |
| 位置标记 | 关联城市和具体地点 |
| 标签系统 | 最多5个标签分类 |
| 社交互动 | 点赞、收藏、评论、分享 |

### 3.3 内容流算法

```typescript
// 推荐 Tab - 热门 + 个性化推荐
async getRecommendedPosts(page: number) {
  return ApiService.getPosts({
    page,
    limit: 10,
    sort: 'hot',  // 热度排序
    // 后端会结合用户兴趣推荐
  })
}

// 关注 Tab - 关注用户的内容
async getFollowingPosts(page: number) {
  return ApiService.getPosts({
    page,
    limit: 10,
    sort: 'latest',
    followingOnly: true
  })
}

// 好友 Tab - 互相关注的好友内容
async getFriendsPosts(page: number) {
  return ApiService.getPosts({
    page,
    limit: 10,
    sort: 'latest',
    friendsOnly: true
  })
}
```

### 3.4 交互操作

#### 点赞 (乐观更新)
```typescript
async handleLike(post: Post) {
  // 1. 立即更新 UI
  post.isLiked = !post.isLiked
  post.likeCount += post.isLiked ? 1 : -1

  try {
    // 2. 发送请求
    if (post.isLiked) {
      await ApiService.likePost(post.id)
    } else {
      await ApiService.unlikePost(post.id)
    }
  } catch (error) {
    // 3. 失败回滚
    post.isLiked = !post.isLiked
    post.likeCount += post.isLiked ? 1 : -1
    promptAction.showToast({ message: '操作失败' })
  }
}
```

#### 评论功能
```typescript
// 发送评论
async sendComment(postId: number, content: string, parentId?: number) {
  const comment = await ApiService.createComment({
    postId,
    content,
    parentId
  })

  // 更新本地评论列表
  this.comments.unshift(comment)
  this.post.commentCount++
}
```

### 3.5 分享功能

```
┌─────────────────────────────────────────────────────────────┐
│                        分享流程                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  点击分享按钮 ──▶ 打开分享面板                               │
│                       │                                     │
│                       ▼                                     │
│              加载关注列表                                    │
│                       │                                     │
│                       ▼                                     │
│              选择分享目标 (可多选)                           │
│                       │                                     │
│                       ▼                                     │
│              确认分享 ──▶ 发送分享请求                       │
│                       │                                     │
│                       ▼                                     │
│              显示分享成功提示                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. 漂流瓶功能

### 4.1 功能概述

漂流瓶是一个匿名社交功能，用户可以创建漂流瓶投入"大海"，也可以随机捡取他人的漂流瓶。

### 4.2 功能特性

| 特性 | 说明 |
|------|------|
| 创建漂流瓶 | 写下心情、愿望或问题 |
| 心情标记 | 选择当前心情状态 |
| 瓶子类型 | 心愿瓶/问题瓶/任务瓶/故事瓶 |
| 随机捡取 | 从"海洋"中捡取陌生人的瓶子 |
| 互动回复 | 对捡到的瓶子进行回复 |

### 4.3 漂流瓶类型

| 类型 | 说明 | 图标 |
|------|------|------|
| 心愿瓶 | 写下愿望，期待祝福 | 🌟 |
| 问题瓶 | 提出问题，寻求解答 | ❓ |
| 任务瓶 | 发起任务，邀请回复照片 | 📷 |
| 故事瓶 | 分享故事，传递感动 | 📖 |

### 4.4 心情系统

| 心情 | 显示 | 颜色 |
|------|------|------|
| 开心 | 😊 Happy | #FFD700 |
| 难过 | 😢 Sad | #4169E1 |
| 兴奋 | 🤩 Excited | #FF6347 |
| 平静 | 😌 Calm | #98FB98 |
| 好奇 | 🤔 Curious | #DDA0DD |
| 期待 | 🥰 Hopeful | #FFB6C1 |

### 4.5 交互流程

#### 创建漂流瓶
```
┌─────────────────────────────────────────────────────────────┐
│                     创建漂流瓶流程                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  选择发布漂流瓶 ──▶ 进入创建页面                             │
│                         │                                   │
│                         ▼                                   │
│                    选择瓶子类型                              │
│                         │                                   │
│                         ▼                                   │
│                    选择当前心情                              │
│                         │                                   │
│                         ▼                                   │
│                    编写瓶中内容                              │
│                         │                                   │
│                         ▼                                   │
│              点击"投入大海" ──▶ 播放投瓶动画                 │
│                         │                                   │
│                         ▼                                   │
│                    投放成功提示                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 捡取漂流瓶
```
┌─────────────────────────────────────────────────────────────┐
│                     捡取漂流瓶流程                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  进入漂流瓶页面 ──▶ 显示海洋动画                             │
│                         │                                   │
│                         ▼                                   │
│              点击"捡瓶子" ──▶ 发送捡取请求                   │
│                         │                                   │
│                         ▼                                   │
│                    播放捡瓶动画                              │
│                         │                                   │
│                ┌───────┴───────┐                           │
│                ▼               ▼                            │
│           有瓶子可捡       没有瓶子                          │
│                │               │                            │
│                ▼               ▼                            │
│         进入结果页面      显示提示                           │
│                │                                            │
│                ▼                                            │
│         显示瓶中内容                                         │
│                │                                            │
│                ▼                                            │
│         可选择回复或放回                                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 4.6 技术实现

```typescript
// 创建漂流瓶
async createBottle(data: CreateBottleRequest) {
  return ApiService.createBottle({
    content: data.content,
    mood: data.mood,
    type: data.type,
    location: await LocationService.getCurrentCity()
  })
}

// 捡取漂流瓶
async pickBottle() {
  try {
    const bottle = await ApiService.pickBottle()
    this.currentBottle = bottle
    this.pageStack.pushPath({
      name: 'BottleResultPage',
      param: { bottle }
    })
  } catch (error) {
    if (error.code === 404) {
      promptAction.showToast({ message: '海上没有漂流瓶了，晚点再来试试吧' })
    }
  }
}

// 回复漂流瓶
async replyBottle(bottleId: number, reply: ReplyBottleRequest) {
  await ApiService.replyBottle(bottleId, {
    content: reply.content,
    images: reply.images  // 任务瓶需要图片
  })
}
```

---

## 5. 时间胶囊功能

### 5.1 功能概述

时间胶囊让用户可以给未来的自己或他人留下信息，设定未来某个日期才能开启。

### 5.2 功能特性

| 特性 | 说明 |
|------|------|
| 创建胶囊 | 写下给未来的话 |
| 添加图片 | 最多添加9张图片 |
| 设定日期 | 选择胶囊开启日期 |
| 位置埋藏 | 记录埋藏位置 |
| 公开选项 | 可选择公开或私密 |
| 到期提醒 | 胶囊到期时发送通知 |

### 5.3 预设时间选项

| 选项 | 时长 | 说明 |
|------|------|------|
| 6个月后 | 6m | 半年后开启 |
| 1年后 | 1y | 一年后开启 |
| 3年后 | 3y | 三年后开启 |
| 5年后 | 5y | 五年后开启 |
| 自定义 | custom | 自选日期 |

### 5.4 胶囊状态

| 状态 | 说明 | 图标 |
|------|------|------|
| SEALED | 已封存，未到开启时间 | 🔒 |
| READY | 已到期，可以开启 | 🔓 |
| OPENED | 已开启 | 📬 |

### 5.5 交互流程

#### 创建时间胶囊
```
┌─────────────────────────────────────────────────────────────┐
│                    创建时间胶囊流程                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  选择发布时间胶囊 ──▶ 进入创建页面                           │
│                           │                                 │
│                           ▼                                 │
│                      编写胶囊标题                            │
│                           │                                 │
│                           ▼                                 │
│                      编写胶囊内容                            │
│                           │                                 │
│                           ▼                                 │
│                   添加图片 (可选)                            │
│                           │                                 │
│                           ▼                                 │
│                   选择开启日期                               │
│                           │                                 │
│                           ▼                                 │
│                   选择公开/私密                              │
│                           │                                 │
│                           ▼                                 │
│                   获取当前位置                               │
│                           │                                 │
│                           ▼                                 │
│              点击"埋藏胶囊" ──▶ 播放埋藏动画                 │
│                           │                                 │
│                           ▼                                 │
│                      埋藏成功                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

#### 开启时间胶囊
```
┌─────────────────────────────────────────────────────────────┐
│                    开启时间胶囊流程                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  收到胶囊到期通知 ──▶ 进入胶囊列表                           │
│                           │                                 │
│                           ▼                                 │
│                   查看"可开启"胶囊                           │
│                           │                                 │
│                           ▼                                 │
│                   点击要开启的胶囊                           │
│                           │                                 │
│                           ▼                                 │
│                   播放开启动画                               │
│                           │                                 │
│                           ▼                                 │
│                   展示胶囊内容                               │
│                           │                                 │
│                           ▼                                 │
│                   显示埋藏时的位置                           │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 5.6 技术实现

```typescript
// 创建时间胶囊
async createCapsule(data: CreateCapsuleRequest) {
  const location = await LocationService.getCurrentLocation()

  return ApiService.createCapsule({
    title: data.title,
    content: data.content,
    images: data.images,
    location: `${location.city}, ${location.address}`,
    targetDate: data.targetDate,  // ISO 8601 格式
    isPublic: data.isPublic
  })
}

// 获取胶囊列表
async getCapsules() {
  const response = await ApiService.getCapsules()

  this.sealedCapsules = response.capsules.filter(c => c.status === 'sealed')
  this.readyCapsules = response.capsules.filter(c => c.status === 'ready')
  this.openedCapsules = response.capsules.filter(c => c.status === 'opened')
}

// 开启胶囊
async openCapsule(capsuleId: number) {
  const capsule = await ApiService.openCapsule(capsuleId)

  // 播放开启动画
  await this.playOpenAnimation()

  // 显示胶囊内容
  this.showCapsuleContent(capsule)
}
```

---

## 6. 消息通知功能

### 6.1 功能概述

消息通知功能用于接收和管理各类互动消息和系统通知。

### 6.2 消息类型

| 类型 | 说明 | 图标 |
|------|------|------|
| 点赞 | 有人点赞了你的内容 | ❤️ |
| 评论 | 有人评论了你的内容 | 💬 |
| 关注 | 有人关注了你 | 👤 |
| 系统 | 系统通知和公告 | 📢 |
| 分享 | 有人分享内容给你 | 📤 |
| 胶囊 | 时间胶囊到期 | ⏰ |

### 6.3 消息中心结构

```
┌─────────────────────────────────────────────────────────────┐
│                        消息中心                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  ❤️ 点赞                              未读: 5       │    │
│  │  有 5 条新的点赞消息                                │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  💬 评论                              未读: 3       │    │
│  │  有 3 条新的评论消息                                │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  👤 关注                              未读: 2       │    │
│  │  有 2 位新粉丝                                      │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  📢 系统通知                          未读: 1       │    │
│  │  有 1 条系统消息                                    │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 6.4 技术实现

```typescript
// 获取未读消息数
async getUnreadCount() {
  const counts = await ApiService.getUnreadCount()

  // 更新全局状态
  AppStorage.setOrCreate('unreadMessageCount', counts.total)

  return counts
}

// 标记消息已读
async markAsRead(messageId: number) {
  await ApiService.markAsRead(messageId)
  this.updateUnreadCount()
}

// 一键已读
async markAllAsRead(type?: MessageType) {
  await ApiService.markAllRead(type)
  this.updateUnreadCount()
}

// 消息跳转处理
handleMessageTap(message: Message) {
  switch (message.type) {
    case 'like':
    case 'comment':
      // 跳转到帖子详情
      this.pageStack.pushPath({
        name: 'PostDetailPage',
        param: { postId: message.relatedPost.id }
      })
      break
    case 'follow':
      // 跳转到用户主页
      this.pageStack.pushPath({
        name: 'UserProfilePage',
        param: { userId: message.sender.id }
      })
      break
    case 'capsule':
      // 跳转到时间胶囊
      this.pageStack.pushPath({
        name: 'TimeCapsulePage'
      })
      break
  }
}
```

---

## 7. 个人中心功能

### 7.1 功能概述

个人中心是用户管理个人信息、查看统计数据和设置应用的中心。

### 7.2 功能特性

| 特性 | 说明 |
|------|------|
| 资料展示 | 头像、昵称、简介、等级 |
| 足迹统计 | 城市、国家、大洲数量 |
| 内容管理 | 我的帖子、点赞、收藏 |
| 徽章墙 | 展示获得的成就徽章 |
| 资料编辑 | 修改个人信息 |
| 应用设置 | 主题、缓存、退出 |

### 7.3 页面结构

```
┌─────────────────────────────────────────────────────────────┐
│                       个人中心                               │
├─────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────┐    │
│  │                    封面图                           │    │
│  │                                                    │    │
│  │  ┌──────┐                                          │    │
│  │  │ 头像 │  昵称          [编辑] [设置]             │    │
│  │  └──────┘  Lv.5 环球旅人                           │    │
│  │                                                    │    │
│  │  个人简介...                                       │    │
│  │                                                    │    │
│  │  关注 120  |  粉丝 350  |  获赞 1.2K               │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  🌍 足迹统计                                        │    │
│  │                                                    │    │
│  │  城市: 25    国家: 8    大洲: 4                    │    │
│  │                                                    │    │
│  │  [展开查看详细足迹]                                 │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌────────────────────────────────────────────────────┐    │
│  │  🏆 徽章墙                                          │    │
│  │                                                    │    │
│  │  [徽章1] [徽章2] [徽章3] [徽章4]                   │    │
│  └────────────────────────────────────────────────────┘    │
│                                                             │
│  ┌───────────┬───────────┬───────────┐                    │
│  │   帖子    │   点赞    │   收藏    │                    │
│  │    50     │   128     │    36     │                    │
│  ├───────────┴───────────┴───────────┤                    │
│  │                                   │                    │
│  │         内容列表区域               │                    │
│  │                                   │                    │
│  └───────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────┘
```

### 7.4 视差滚动效果

```typescript
@Component
struct ProfilePage {
  @State scrollY: number = 0
  private coverHeight: number = 200

  build() {
    Scroll() {
      Column() {
        // 封面图 - 视差效果
        Image(this.coverImage)
          .height(this.coverHeight)
          .translate({ y: this.scrollY * 0.5 })  // 视差滚动

        // 头像 - 缩放效果
        Image(this.avatar)
          .scale({ x: this.avatarScale, y: this.avatarScale })

        // 其他内容...
      }
    }
    .onScroll((xOffset, yOffset) => {
      this.scrollY = yOffset
      this.updateParallaxEffect()
    })
  }
}
```

### 7.5 资料编辑功能

```typescript
// 编辑头像
async editAvatar() {
  // 1. 打开相册选择图片
  const photo = await this.selectPhoto()

  // 2. 打开裁剪弹窗
  const croppedImage = await this.cropImage(photo, { ratio: 1, circle: true })

  // 3. 压缩图片
  const compressed = await ImageUtils.compressImage(croppedImage)

  // 4. 上传图片
  const url = await ApiService.uploadImage(compressed)

  // 5. 更新资料
  await ApiService.updateProfile({ avatar: url })

  // 6. 刷新页面
  this.loadProfile()
}
```

---

## 8. 图片处理功能

### 8.1 功能概述

图片处理功能涵盖图片选择、压缩、上传和展示的完整流程。

### 8.2 图片压缩

```typescript
// ImageUtils.ets
class ImageUtils {
  // 压缩图片
  static async compressImage(filePath: string, quality: number = 80): Promise<string> {
    const imageSource = image.createImageSource(filePath)
    const pixelMap = await imageSource.createPixelMap()

    // 计算压缩尺寸
    const { width, height } = pixelMap.getImageInfo()
    const maxSize = 1920
    const scale = Math.min(maxSize / width, maxSize / height, 1)

    // 创建压缩后的图片
    const packer = image.createImagePacker()
    const packed = await packer.packing(pixelMap, {
      format: 'image/jpeg',
      quality: quality,
      width: width * scale,
      height: height * scale
    })

    return packed
  }

  // OSS 图片 URL 格式化
  static formatImageUrl(url: string, size: 'avatar' | 'thumb' | 'large' | 'origin'): string {
    if (!url) return ''

    const sizeMap = {
      avatar: '_avatar',   // 200x200
      thumb: '_thumb',     // 400x400
      large: '_large',     // 1200xAuto
      origin: ''           // 原图
    }

    const ext = url.substring(url.lastIndexOf('.'))
    const base = url.substring(0, url.lastIndexOf('.'))

    return `${base}${sizeMap[size]}${ext}`
  }
}
```

### 8.3 图片预览

```typescript
// 全屏图片预览
@Component
struct ImagePreviewPage {
  @State images: string[] = []
  @State currentIndex: number = 0
  @State scale: number = 1
  @State offsetX: number = 0
  @State offsetY: number = 0

  build() {
    Stack() {
      Swiper() {
        ForEach(this.images, (image: string, index: number) => {
          Image(image)
            .objectFit(ImageFit.Contain)
            .scale({ x: this.scale, y: this.scale })
            .translate({ x: this.offsetX, y: this.offsetY })
            .gesture(
              GestureGroup(GestureMode.Parallel,
                // 双击缩放
                TapGesture({ count: 2 })
                  .onAction(() => {
                    this.scale = this.scale === 1 ? 2 : 1
                  }),
                // 捏合缩放
                PinchGesture()
                  .onActionUpdate((event) => {
                    this.scale = event.scale
                  }),
                // 拖动
                PanGesture()
                  .onActionUpdate((event) => {
                    this.offsetX = event.offsetX
                    this.offsetY = event.offsetY
                  })
              )
            )
        })
      }
      .index(this.currentIndex)

      // 保存按钮
      SaveButton()
        .onClick(() => this.saveToAlbum())
    }
  }
}
```

---

## 9. 位置服务功能

### 9.1 功能概述

位置服务为应用提供定位、城市识别和地理编码功能。

### 9.2 核心功能

```typescript
// LocationService.ets
class LocationService {
  // 获取当前位置
  static async getCurrentLocation(): Promise<Location> {
    // 检查权限
    const hasPermission = await this.checkLocationPermission()
    if (!hasPermission) {
      await this.requestLocationPermission()
    }

    // 获取位置
    const location = await geoLocationManager.getCurrentLocation({
      priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
      scenario: geoLocationManager.LocationRequestScenario.UNSET
    })

    return {
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy
    }
  }

  // 逆地理编码 - 坐标转地址
  static async reverseGeocode(lat: number, lng: number): Promise<Address> {
    const request = {
      latitude: lat,
      longitude: lng,
      maxItems: 1
    }

    const addresses = await geoLocationManager.getAddressesFromLocation(request)

    if (addresses && addresses.length > 0) {
      return {
        country: addresses[0].country,
        province: addresses[0].administrativeArea,
        city: addresses[0].locality,
        district: addresses[0].subLocality,
        address: addresses[0].placeName
      }
    }

    throw new Error('无法获取地址信息')
  }

  // 匹配城市
  static async matchCity(lat: number, lng: number): Promise<City | null> {
    const address = await this.reverseGeocode(lat, lng)
    return ApiService.matchCity(address.city)
  }
}
```

### 9.3 权限处理

```typescript
// 检查定位权限
static async checkLocationPermission(): Promise<boolean> {
  const status = await abilityAccessCtrl.createAtManager()
    .checkAccessToken(
      bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT).appInfo.accessTokenId,
      'ohos.permission.APPROXIMATELY_LOCATION'
    )

  return status === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED
}

// 请求定位权限
static async requestLocationPermission(): Promise<boolean> {
  const context = getContext(this) as common.UIAbilityContext

  const result = await abilityAccessCtrl.createAtManager()
    .requestPermissionsFromUser(context, [
      'ohos.permission.APPROXIMATELY_LOCATION',
      'ohos.permission.LOCATION'
    ])

  return result.authResults.every(r => r === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
}
```
