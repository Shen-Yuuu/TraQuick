# TraQuick 页面导航文档

## 1. 概述

本文档描述 TraQuick 应用的页面结构、导航流程和路由配置。

## 2. 页面目录结构

```
pages/
├── Index.ets                    # 主入口，底部 Tab 导航
├── auth/                        # 认证模块
│   ├── LoginPage.ets           # 登录页
│   └── RegisterPage.ets        # 注册页
├── explore/                     # 探索模块
│   ├── ExplorePage.ets         # 地图探索主页
│   ├── CityDetailPage.ets      # 城市详情页
│   ├── DriftBottlePage.ets     # 漂流瓶捡取页
│   ├── TimeCapsulePage.ets     # 时间胶囊列表页
│   └── BottleResultPage.ets    # 漂流瓶结果展示页
├── community/                   # 社区模块
│   ├── CommunityPage.ets       # 社区动态页
│   ├── PostDetailPage.ets      # 帖子详情页
│   ├── UserProfilePage.ets     # 用户主页
│   └── ImagePreviewPage.ets    # 图片预览页
├── message/                     # 消息模块
│   ├── MessagePage.ets         # 消息中心页
│   └── MessageListPage.ets     # 消息列表页
├── profile/                     # 个人中心模块
│   ├── ProfilePage.ets         # 个人主页
│   ├── EditProfilePage.ets     # 编辑资料页
│   └── SettingsPage.ets        # 设置页
└── publish/                     # 发布模块
    ├── PublishPostPage.ets     # 发布帖子页
    ├── DriftBottlePage.ets     # 发布漂流瓶页
    └── TimeCapsulePage.ets     # 发布时间胶囊页
```

## 3. 导航架构图

```
                              ┌─────────────┐
                              │  启动页      │
                              │ (Splash)    │
                              └──────┬──────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              │                      │                      │
              ▼                      ▼                      ▼
       ┌────────────┐         ┌────────────┐         ┌────────────┐
       │  未登录     │         │  已登录     │         │  引导页    │
       │  LoginPage │         │  Index     │         │  (首次)    │
       └──────┬─────┘         └──────┬─────┘         └────────────┘
              │                      │
              │                      │
              ▼                      ▼
       ┌────────────┐         ┌────────────────────────────────────┐
       │ RegisterPage│         │              Index.ets              │
       └────────────┘         │     (TabBar 底部导航容器)            │
                              ├────────┬────────┬────────┬─────────┤
                              │  探索  │  社区  │  消息  │  我的   │
                              │  Tab   │  Tab   │  Tab   │  Tab    │
                              └────┬───┴────┬───┴────┬───┴────┬────┘
                                   │        │        │        │
                                   ▼        ▼        ▼        ▼
                            ExplorePage Community MessagePage Profile
```

## 4. 主页面 (Index.ets)

### 4.1 Tab 结构

```typescript
@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  @Provide('pageStack') pageStack: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.pageStack) {
      Tabs({ barPosition: BarPosition.End }) {
        // Tab 0: 探索
        TabContent() {
          ExplorePage()
        }
        .tabBar(this.TabBuilder('探索', 0, $r('app.media.ic_explore')))

        // Tab 1: 社区
        TabContent() {
          CommunityPage()
        }
        .tabBar(this.TabBuilder('社区', 1, $r('app.media.ic_community')))

        // Tab 2: 发布 (中间按钮)
        TabContent() {
          // 空内容，点击触发发布弹窗
        }
        .tabBar(this.PublishTabBuilder())

        // Tab 3: 消息
        TabContent() {
          MessagePage()
        }
        .tabBar(this.TabBuilder('消息', 3, $r('app.media.ic_message')))

        // Tab 4: 我的
        TabContent() {
          ProfilePage()
        }
        .tabBar(this.TabBuilder('我的', 4, $r('app.media.ic_profile')))
      }
    }
  }
}
```

### 4.2 Tab 图标与选中状态

| Tab | 图标 | 选中颜色 | 未选中颜色 |
|-----|------|----------|-----------|
| 探索 | ic_explore | #007AFF | #999999 |
| 社区 | ic_community | #007AFF | #999999 |
| 发布 | ic_publish | #FFFFFF (浮动按钮) | - |
| 消息 | ic_message | #007AFF | #999999 |
| 我的 | ic_profile | #007AFF | #999999 |

---

## 5. 页面详细说明

### 5.1 认证模块

#### LoginPage 登录页

**功能:**
- 用户名/密码登录
- 记住登录状态
- 跳转注册页
- 第三方登录入口

**路由参数:** 无

**跳转来源:**
- 应用启动时未登录
- 退出登录后
- 需要登录的操作触发

**跳转目标:**
- RegisterPage (注册)
- Index (登录成功)

---

#### RegisterPage 注册页

**功能:**
- 新用户注册
- 表单验证
- 注册成功自动登录

**路由参数:** 无

**跳转来源:**
- LoginPage

**跳转目标:**
- LoginPage (返回)
- Index (注册成功)

---

### 5.2 探索模块

#### ExplorePage 地图探索页

**功能:**
- 世界地图展示
- 迷雾探索效果
- 城市标记与点击
- 快捷入口 (漂流瓶/时间胶囊)

**路由参数:** 无

**跳转目标:**
- CityDetailPage
- DriftBottlePage
- TimeCapsulePage

---

#### CityDetailPage 城市详情页

**功能:**
- 城市信息展示
- 相关帖子列表
- 发布本地内容入口

**路由参数:**
```typescript
interface CityDetailParams {
  cityId: number
  cityName?: string
}
```

**跳转来源:**
- ExplorePage
- CityCardDialog
- PostCard (位置点击)

**跳转目标:**
- PostDetailPage
- PublishPostPage
- UserProfilePage

---

#### DriftBottlePage 漂流瓶页 (探索)

**功能:**
- 海洋主题动画
- 捡取漂流瓶
- 漂流瓶动画效果

**路由参数:** 无

**跳转来源:**
- ExplorePage

**跳转目标:**
- BottleResultPage

---

#### BottleResultPage 漂流瓶结果页

**功能:**
- 展示捡到的漂流瓶内容
- 沉浸式海洋风格
- 回复漂流瓶

**路由参数:**
```typescript
interface BottleResultParams {
  bottle: DriftBottle
}
```

**跳转来源:**
- DriftBottlePage

**跳转目标:**
- 返回 ExplorePage

---

#### TimeCapsulePage 时间胶囊页 (探索)

**功能:**
- 胶囊列表展示
- 状态分类 (未开启/可开启/已开启)
- 开启到期胶囊

**路由参数:** 无

**跳转来源:**
- ExplorePage

**跳转目标:**
- 胶囊详情弹窗

---

### 5.3 社区模块

#### CommunityPage 社区动态页

**功能:**
- 多 Tab 切换 (推荐/关注/好友)
- 帖子流展示
- 下拉刷新/上拉加载
- 点赞/收藏/评论/分享

**路由参数:** 无

**跳转目标:**
- PostDetailPage
- UserProfilePage
- ImagePreviewPage

---

#### PostDetailPage 帖子详情页

**功能:**
- 帖子完整内容
- 评论列表
- 评论功能
- 关注作者

**路由参数:**
```typescript
interface PostDetailParams {
  postId: number
  post?: Post  // 可选，用于预加载
}
```

**跳转来源:**
- CommunityPage
- ProfilePage
- UserProfilePage
- MessageListPage

**跳转目标:**
- UserProfilePage
- ImagePreviewPage

---

#### UserProfilePage 用户主页

**功能:**
- 用户资料展示
- 视差滚动效果
- 用户帖子列表
- 关注/私信

**路由参数:**
```typescript
interface UserProfileParams {
  userId: number
}
```

**跳转来源:**
- PostDetailPage
- CommunityPage
- MessageListPage

**跳转目标:**
- PostDetailPage
- MessagePage (私信)

---

#### ImagePreviewPage 图片预览页

**功能:**
- 全屏图片查看
- 手势缩放/平移
- 左右滑动切换
- 保存到相册

**路由参数:**
```typescript
interface ImagePreviewParams {
  images: string[]
  currentIndex: number
}
```

**跳转来源:**
- PostDetailPage
- CommunityPage
- UserProfilePage

---

### 5.4 消息模块

#### MessagePage 消息中心页

**功能:**
- 消息分类展示
- 未读数量显示
- 快捷入口 (点赞/评论/关注/系统)

**路由参数:** 无

**跳转目标:**
- MessageListPage

---

#### MessageListPage 消息列表页

**功能:**
- 分类消息列表
- 分页加载
- 标记已读
- 消息详情跳转

**路由参数:**
```typescript
interface MessageListParams {
  type: 'like' | 'comment' | 'follow' | 'system'
  title: string
}
```

**跳转来源:**
- MessagePage

**跳转目标:**
- PostDetailPage
- UserProfilePage

---

### 5.5 个人中心模块

#### ProfilePage 个人主页

**功能:**
- 个人资料展示
- 视差滚动效果
- 多 Tab (帖子/点赞/收藏)
- 徽章墙
- 足迹统计

**路由参数:** 无

**跳转目标:**
- EditProfilePage
- SettingsPage
- PostDetailPage

---

#### EditProfilePage 编辑资料页

**功能:**
- 修改头像 (含裁剪)
- 修改封面图
- 修改昵称/简介

**路由参数:** 无

**跳转来源:**
- ProfilePage

---

#### SettingsPage 设置页

**功能:**
- 主题切换 (深色/浅色)
- 缓存管理
- 关于应用
- 退出登录

**路由参数:** 无

**跳转来源:**
- ProfilePage

**跳转目标:**
- LoginPage (退出登录后)

---

### 5.6 发布模块

#### PublishPostPage 发布帖子页

**功能:**
- 图片选择 (最多9张)
- 内容编辑
- 位置选择
- 标签添加 (最多5个)

**路由参数:**
```typescript
interface PublishPostParams {
  cityId?: number   // 指定城市发布
  cityName?: string
}
```

**跳转来源:**
- PublishSelectDialog
- CityDetailPage

---

#### DriftBottlePage 发布漂流瓶页 (发布)

**功能:**
- 内容编辑
- 心情选择
- 类型选择 (心愿/问题/任务)
- 海洋主题 UI

**路由参数:** 无

**跳转来源:**
- PublishSelectDialog

---

#### TimeCapsulePage 发布时间胶囊页 (发布)

**功能:**
- 标题/内容编辑
- 图片添加
- 位置选择
- 开启日期设置
- 公开/私密选择

**路由参数:** 无

**跳转来源:**
- PublishSelectDialog

---

## 6. 路由配置

### 6.1 module.json5 路由配置

```json5
{
  "module": {
    "routerMap": [
      // 认证
      {
        "name": "LoginPage",
        "pageSourceFile": "src/main/ets/pages/auth/LoginPage.ets"
      },
      {
        "name": "RegisterPage",
        "pageSourceFile": "src/main/ets/pages/auth/RegisterPage.ets"
      },
      // 探索
      {
        "name": "CityDetailPage",
        "pageSourceFile": "src/main/ets/pages/explore/CityDetailPage.ets"
      },
      {
        "name": "DriftBottlePage",
        "pageSourceFile": "src/main/ets/pages/explore/DriftBottlePage.ets"
      },
      {
        "name": "TimeCapsulePage",
        "pageSourceFile": "src/main/ets/pages/explore/TimeCapsulePage.ets"
      },
      {
        "name": "BottleResultPage",
        "pageSourceFile": "src/main/ets/pages/explore/BottleResultPage.ets"
      },
      // 社区
      {
        "name": "PostDetailPage",
        "pageSourceFile": "src/main/ets/pages/community/PostDetailPage.ets"
      },
      {
        "name": "UserProfilePage",
        "pageSourceFile": "src/main/ets/pages/community/UserProfilePage.ets"
      },
      {
        "name": "ImagePreviewPage",
        "pageSourceFile": "src/main/ets/pages/community/ImagePreviewPage.ets"
      },
      // 消息
      {
        "name": "MessageListPage",
        "pageSourceFile": "src/main/ets/pages/message/MessageListPage.ets"
      },
      // 个人
      {
        "name": "EditProfilePage",
        "pageSourceFile": "src/main/ets/pages/profile/EditProfilePage.ets"
      },
      {
        "name": "SettingsPage",
        "pageSourceFile": "src/main/ets/pages/profile/SettingsPage.ets"
      },
      // 发布
      {
        "name": "PublishPostPage",
        "pageSourceFile": "src/main/ets/pages/publish/PublishPostPage.ets"
      },
      {
        "name": "PublishDriftBottlePage",
        "pageSourceFile": "src/main/ets/pages/publish/DriftBottlePage.ets"
      },
      {
        "name": "PublishTimeCapsulePage",
        "pageSourceFile": "src/main/ets/pages/publish/TimeCapsulePage.ets"
      }
    ]
  }
}
```

### 6.2 导航 API

```typescript
// 获取导航栈
@Consume('pageStack') pageStack: NavPathStack

// 页面跳转
this.pageStack.pushPath({
  name: 'PostDetailPage',
  param: { postId: 123 }
})

// 带动画跳转
this.pageStack.pushPath({
  name: 'ImagePreviewPage',
  param: { images, currentIndex }
}, {
  animated: true
})

// 返回上一页
this.pageStack.pop()

// 返回到指定页面
this.pageStack.popToName('CommunityPage')

// 清空导航栈返回首页
this.pageStack.clear()

// 替换当前页面
this.pageStack.replacePath({ name: 'LoginPage' })
```

---

## 7. 导航流程图

### 7.1 发帖流程

```
Index
  │
  ▼ (点击发布按钮)
PublishSelectDialog
  │
  ├──▶ PublishPostPage ──▶ (发布成功) ──▶ 返回 Index
  │
  ├──▶ PublishDriftBottlePage ──▶ (投放成功) ──▶ 返回 Index
  │
  └──▶ PublishTimeCapsulePage ──▶ (埋藏成功) ──▶ 返回 Index
```

### 7.2 社交互动流程

```
CommunityPage
  │
  ├──▶ (点击帖子) ──▶ PostDetailPage
  │                        │
  │                        ├──▶ (点击作者) ──▶ UserProfilePage
  │                        │                        │
  │                        │                        └──▶ (点击帖子) ──▶ PostDetailPage
  │                        │
  │                        └──▶ (点击图片) ──▶ ImagePreviewPage
  │
  └──▶ (点击作者) ──▶ UserProfilePage
```

### 7.3 消息处理流程

```
MessagePage
  │
  ├──▶ (点击点赞) ──▶ MessageListPage (type: like)
  │                        │
  │                        └──▶ (点击消息) ──▶ PostDetailPage
  │
  ├──▶ (点击评论) ──▶ MessageListPage (type: comment)
  │                        │
  │                        └──▶ (点击消息) ──▶ PostDetailPage
  │
  └──▶ (点击关注) ──▶ MessageListPage (type: follow)
                           │
                           └──▶ (点击消息) ──▶ UserProfilePage
```

---

## 8. 页面生命周期

### 8.1 生命周期方法

```typescript
@Entry
@Component
struct ExamplePage {
  // 页面即将显示
  aboutToAppear() {
    console.log('页面即将显示')
    this.loadData()
  }

  // 页面即将消失
  aboutToDisappear() {
    console.log('页面即将消失')
    this.cleanup()
  }

  // 页面显示时 (每次)
  onPageShow() {
    console.log('页面显示')
    this.refreshData()
  }

  // 页面隐藏时 (每次)
  onPageHide() {
    console.log('页面隐藏')
  }

  // 返回按钮处理
  onBackPress() {
    // 返回 true 拦截返回，false 允许返回
    return false
  }
}
```

### 8.2 数据刷新策略

| 场景 | 刷新方式 |
|------|----------|
| 首次进入 | aboutToAppear 加载 |
| Tab 切换回来 | onPageShow 检查更新 |
| 下拉刷新 | 用户触发 |
| 发布/操作后 | AppStorage 触发器通知 |
| 返回页面 | 检查 refreshTrigger |
