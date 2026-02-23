# TraQuick 项目技术文档

> **最后更新**：2026年2月12日  
> **版本**：V1.2.0 (Alpha)  
> **开发状态**：核心功能开发完成，UI/UX 优化阶段，地图交互打磨中  
> **平台**：HarmonyOS NEXT (API 12+)

---

## 1. 项目概述

### 1.1 项目定位
**TraQuick (Travel + Quick)** 是一款基于 **HarmonyOS NEXT** 原生开发的沉浸式旅行社交平台。核心理念是「足不出户，探索世界」。通过 **华为 Map Kit 3D 地球引擎**，结合盲盒社交（漂流瓶、时空胶囊）、游戏化探索（迷雾解锁）和社区互动，为用户提供一个纯净、高效且充满惊喜的虚拟旅行体验。

### 1.2 核心价值
- **沉浸感**：全屏 3D 地球交互，无缝缩放，从全球视角平滑过渡到城市街区。
- **游戏化**：通过“点亮地图”、“迷雾消散”、“等级晋升”激励用户探索。
- **情感连接**：通过漂流瓶和时空胶囊，建立跨越时空的情感共鸣。

### 1.3 技术栈

| 层级 | 技术选型 | 说明 |
| :--- | :--- | :--- |
| **前端框架** | **ArkTS + ArkUI** | HarmonyOS Next 原生声明式 UI 开发 |
| **地图服务** | **@kit.MapKit** | 华为原生地图服务（3D地球、瓦片渲染、覆盖物） |
| **地理数据** | **GeoJSON** | 处理全球国家/中国省市区县的边界数据 |
| **网络请求** | **@kit.NetworkKit** | 原生 HTTP 通信模块 |
| **状态管理** | **AppStorage + @State/@Prop** | 全局与组件级状态管理 |
| **本地存储** | **@ohos.data.preferences** | 用户偏好设置、简单的本地缓存 |
| **动画效果** | **Explicit Animation** | 属性动画、转场动画、手势交互 |

---

## 2. 核心功能模块

### 2.1 🌏 探索 (Explore) - 核心引擎
- **3D 地球交互**：
    - 全球视角查看 3D 球体，支持旋转、缩放。
    - 智能缩放分级：全球 → 国家/省份 → 城市 → 街区。
- **区域覆盖系统 (RegionOverlay)**：
    - 基于 GeoJSON 解析的动态多边形覆盖物。
    - **交互逻辑**：
        - 点击国家/省份：高亮显示边界 + 显示标签。
        - 再次点击：镜头平滑飞入居中，若是中国省份则下钻显示市级边界。
        - 点击城市：高亮并弹出城市信息气泡。
- **盲盒探索**：
    - 随机摇一摇：随机飞向一个城市，弹出精美的城市介绍卡片。

### 2.2 🏙️ 社区 (Community) - 动态广场
- **双流设计**：支持“视频”流和“图文”流切换。
- **沉浸式卡片**：仿抖音/小红书风格的沉浸式动态卡片。
- **互动体系**：点赞（双击）、评论（支持回复）、收藏、转发。
- **图片浏览**：仿微信朋友圈的九宫格图片布局，支持点击全屏预览、双击点赞。

### 2.3 💊 盲盒社交 (Social Box)
- **漂流瓶 (Drift Bottle)**：
    - 海洋主题沉浸式 UI。
    - 捡瓶子：随机获取陌生人的愿望或故事。
    - 投瓶子：发送文字/心情，丢入大海。
- **时空胶囊 (Time Capsule)**：
    - 星空主题沉浸式 UI。
    - 埋下胶囊：设定解封时间（如1年后），封存文字/图片。
    - 挖掘胶囊：查看已到期的胶囊，回顾过去。

### 2.4 👤 个人中心 (Profile)
- **抽屉式背景**：顶部背景图支持下拉放大、上滑收起的视差效果。
- **迷雾地球**：个人专属的 3D 记录地球，展示已点亮区域。
- **勋章墙**：展示根据探索成就解锁的徽章。

---

## 3. 项目架构与目录结构

```text
entry/src/main/
├── ets/
│   ├── entryability/             # 应用入口 Ability
│   │   └── EntryAbility.ets
│   ├── models/                   # 数据模型 (Interfaces)
│   │   ├── City.ets              # 城市、地标数据结构
│   │   ├── Post.ets              # 社区动态、评论结构
│   │   └── User.ets              # 用户信息结构
│   ├── services/                 # 数据服务层
│   │   └── MockData.ets          # 模拟数据生成器 (当前阶段替代后端)
│   ├── utils/                    # 工具类
│   │   ├── Constants.ets         # 全局常量 (颜色、字体、间距)
│   │   ├── GeoJsonParser.ets     # GeoJSON 解析器 (核心)
│   │   └── RegionOverlayManager.ets # 地图覆盖物管理器 (核心逻辑)
│   ├── components/               # UI 组件库
│   │   ├── common/               # 通用组件
│   │   │   ├── PostCard.ets      # 社区动态卡片
│   │   │   └── SharePanel.ets    # 分享弹窗
│   │   ├── explore/              # 探索页专用组件
│   │   │   └── CityCardDialog.ets # 随机城市弹窗
│   │   └── publish/              # 发布页专用组件
│   │       └── PublishSelectDialog.ets # 发布类型选择器
│   └── pages/                    # 页面视图 (View)
│       ├── Index.ets             # 主页 (Tab容器 + 底部导航)
│       ├── auth/                 # 认证模块
│       │   ├── LoginPage.ets
│       │   └── RegisterPage.ets
│       ├── explore/              # 探索模块
│       │   ├── ExplorePage.ets   # 地图主页 (MapKit集成)
│       │   ├── CityDetailPage.ets # 城市详情 (抽屉式背景)
│       │   ├── DriftBottlePage.ets # 漂流瓶
│       │   └── TimeCapsulePage.ets # 时空胶囊
│       ├── community/            # 社区模块
│       │   ├── CommunityPage.ets # 社区主页
│       │   ├── PostDetailPage.ets # 动态详情
│       │   ├── ImagePreviewPage.ets # 图片全屏预览
│       │   └── UserProfilePage.ets # 用户主页
│       ├── message/              # 消息模块
│       │   └── MessagePage.ets
│       ├── publish/              # 发布模块
│       │   └── PublishPostPage.ets
│       └── profile/              # 个人模块
│           ├── ProfilePage.ets
│           └── SettingsPage.ets
└── resources/                    # 资源文件
    ├── base/media/               # 图片资源
    └── rawfile/                  # 原始文件
        └── geo/                  # 地图边界数据 (GeoJSON)
            ├── china_province.json
            └── world_countries.json
```

---

## 4. 关键技术实现细节

### 4.1 动态地图覆盖物系统
- **数据源**：使用 `GeoJsonParser` 解析本地 `rawfile` 中的 GeoJSON 数据。
- **渲染优化**：
    - **分级加载**：缩放级别小加载省级/国家级边界；缩放级别大加载市级边界。
    - **视口剔除**：仅渲染当前屏幕可见区域内的多边形，提升性能。
- **交互状态机**：
    - `IDLE` (静止) → `PROVINCE_SELECTED` (选中省/国家) → `CITY_VIEW` (下钻市级) → `CITY_SELECTED` (选中城市)。
    - 使用 `RegionOverlayManager` 统一管理点击事件、相机飞行和高亮样式。

### 4.2 沉浸式 UI 交互
- **抽屉式背景图** (`CityDetailPage`)：
    - 监听 `Scroll` 组件的 `yOffset`。
    - **下拉**：`scale` > 1.0，图片中心放大，产生逼近感。
    - **上滑**：`scale` 回归 1.0，内容层覆盖图片，产生视差滚动效果。
- **发布选择器** (`PublishSelectDialog`)：
    - 使用 `Stack` 实现全屏毛玻璃遮罩。
    - 列表项采用错峰入场动画 (`delay + Curve.FastOutSlowIn`)。
    - 底部取消按钮添加旋转退出动画，增强仪式感。

### 4.3 社区图片网格
- 实现了一套**自适应图片网格布局算法**：
    - 1张图：大尺寸 (180vp)。
    - 2/4张图：2列布局。
    - 3/5-9张图：3列布局（微信朋友圈风格）。
    - 结合 `ImageFit.Cover` 保证图片裁切美观。

---

## 5. 待办事项与规划 (Roadmap)

### Phase 1: 基础构建 (已完成 ✅)
- [x] 项目脚手架与路由搭建
- [x] 华为 Map Kit 基础集成与 3D 地球显示
- [x] 核心 UI 页面高保真还原 (社区、个人中心、详情页)
- [x] GeoJSON 解析与区域高亮交互
- [x] 漂流瓶与时空胶囊的 UI 与基础逻辑

### Phase 2: 数据与服务对接 (进行中 🚧)
- [ ] **API 对接**：替换 MockData，接入 NestJS 后端 API。
- [ ] **图片上传**：实现发布动态时的多图/视频上传功能。
- [ ] **用户认证**：完善登录/注册流程，对接 JWT Token 鉴权。

### Phase 3: 地图深度优化 (待开始 📅)
- [ ] **迷雾系统 (Fog of War)**：实现基于 GL Shader 的动态迷雾，仅点亮去过的区域。
- [ ] **3D 模型加载**：在热门城市（如巴黎、北京）加载简易的 3D 地标模型 (.gltf)。
- [ ] **性能调优**：优化大量 Polygon 渲染时的帧率。

---