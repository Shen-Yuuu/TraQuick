# TraQuick 项目文档

## 项目概述

**TraQuick** 是一款基于 HarmonyOS/OpenHarmony 的社交旅行应用，允许用户探索城市、分享旅行经历、与其他用户互动，并体验漂流瓶和时间胶囊等独特功能。

## 技术栈

| 技术 | 说明 |
|------|------|
| **ArkTS/ArkUI** | HarmonyOS 声明式 UI 框架 |
| **REST API** | 后端通信 |
| **AppStorage** | 全局状态管理 |
| **geoLocationManager** | GPS/位置服务 |
| **photoAccessHelper** | 图片处理 |
| **OSS** | 对象存储服务 |

## 文档目录

| 文档 | 说明 |
|------|------|
| [项目架构](./ARCHITECTURE.md) | 系统架构设计与技术选型 |
| [数据模型](./DATA_MODELS.md) | 数据结构与接口定义 |
| [API 接口](./API_DOCUMENTATION.md) | 后端 API 接口文档 |
| [组件文档](./COMPONENTS.md) | 可复用组件说明 |
| [页面导航](./PAGES_NAVIGATION.md) | 页面结构与导航流程 |
| [功能模块](./FEATURES.md) | 核心功能详细说明 |
| [开发指南](./DEVELOPMENT_GUIDE.md) | 开发环境搭建与规范 |

## 快速开始

### 环境要求

- DevEco Studio 5.0.0 或更高版本
- HarmonyOS SDK API 12+
- Node.js 16+

### 安装运行

```bash
# 克隆项目
git clone <repository-url>

# 进入项目目录
cd TraQuick

# 安装依赖
npm install

# 在 DevEco Studio 中打开项目
# 连接设备或模拟器后点击运行
```

## 项目结构

```
TraQuick/
├── AppScope/                    # 应用级配置
│   ├── app.json5               # 应用配置文件
│   └── resources/              # 应用级资源
├── entry/                       # 主模块
│   └── src/main/
│       ├── module.json5        # 模块配置
│       ├── resources/          # 模块资源
│       └── ets/                # 源代码目录
│           ├── entryability/   # 入口能力
│           ├── models/         # 数据模型
│           ├── services/       # 服务层
│           ├── utils/          # 工具类
│           ├── components/     # 可复用组件
│           └── pages/          # 页面
├── oh-package.json5            # 包配置
├── build-profile.json5         # 构建配置
└── docs/                       # 项目文档
```

## 主要功能

### 🗺️ 地图探索
- 迷雾地图探索效果
- 城市发现与解锁
- 足迹追踪

### 👥 社区互动
- 发布图文动态
- 点赞、收藏、评论
- 关注与分享

### 🌊 漂流瓶
- 创建并投掷漂流瓶
- 随机捡拾他人漂流瓶
- 任务瓶互动

### ⏳ 时间胶囊
- 创建给未来的自己的信息
- 设定解锁日期
- 基于位置的埋藏

### 💬 消息通知
- 点赞/评论/关注通知
- 系统消息
- 未读消息管理

### 👤 个人中心
- 个人资料编辑
- 足迹统计
- 设置管理

## 版本信息

- **当前版本**: 1.0.0
- **最低支持 API**: 12
- **目标 API**: 12

## 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](../LICENSE) 文件
