# TraQuick 开发指南

## 1. 开发环境搭建

### 1.1 系统要求

| 项目 | 要求 |
|------|------|
| 操作系统 | Windows 10/11, macOS 10.15+, Ubuntu 18.04+ |
| 内存 | 8GB 以上 (推荐 16GB) |
| 硬盘 | 至少 10GB 可用空间 |
| Node.js | 16.0+ |

### 1.2 安装 DevEco Studio

1. 访问 [HarmonyOS 开发者官网](https://developer.harmonyos.com/)
2. 下载 DevEco Studio 5.0.0 或更高版本
3. 安装并完成初始化配置
4. 配置 HarmonyOS SDK (API 12+)

### 1.3 克隆项目

```bash
# 克隆仓库
git clone <repository-url>

# 进入项目目录
cd TraQuick

# 安装依赖
npm install
```

### 1.4 配置项目

1. 使用 DevEco Studio 打开项目
2. 等待项目同步完成
3. 配置签名信息 (用于真机调试)

---

## 2. 项目配置

### 2.1 应用配置 (AppScope/app.json5)

```json5
{
  "app": {
    "bundleName": "com.example.traquick",
    "vendor": "TraQuick",
    "versionCode": 1000000,
    "versionName": "1.0.0",
    "icon": "$media:app_icon",
    "label": "$string:app_name"
  }
}
```

### 2.2 模块配置 (entry/src/main/module.json5)

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": ["phone", "tablet"],
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET",
        "reason": "$string:permission_internet"
      },
      {
        "name": "ohos.permission.APPROXIMATELY_LOCATION",
        "reason": "$string:permission_location"
      },
      {
        "name": "ohos.permission.LOCATION",
        "reason": "$string:permission_location_precise"
      },
      {
        "name": "ohos.permission.READ_MEDIA",
        "reason": "$string:permission_media"
      },
      {
        "name": "ohos.permission.WRITE_MEDIA",
        "reason": "$string:permission_media_write"
      }
    ],
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:EntryAbility_desc",
        "icon": "$media:layered_image",
        "label": "$string:EntryAbility_label",
        "startWindowIcon": "$media:startIcon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": ["entity.system.home"],
            "actions": ["action.system.home"]
          }
        ]
      }
    ],
    "routerMap": "$profile:route_map"
  }
}
```

### 2.3 路由配置 (entry/src/main/resources/base/profile/route_map.json)

```json
{
  "routerMap": [
    {
      "name": "LoginPage",
      "pageSourceFile": "src/main/ets/pages/auth/LoginPage.ets",
      "buildFunction": "pageLoginPageBuilder"
    },
    {
      "name": "RegisterPage",
      "pageSourceFile": "src/main/ets/pages/auth/RegisterPage.ets",
      "buildFunction": "pageRegisterPageBuilder"
    }
    // ... 其他路由
  ]
}
```

---

## 3. 编码规范

### 3.1 文件命名

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| 页面文件 | PascalCase | `LoginPage.ets` |
| 组件文件 | PascalCase | `PostCard.ets` |
| 服务文件 | PascalCase | `ApiService.ets` |
| 工具文件 | PascalCase | `Formatter.ets` |
| 模型文件 | PascalCase | `User.ets` |
| 常量文件 | PascalCase | `Constants.ets` |

### 3.2 变量命名

```typescript
// 常量 - 全大写下划线分隔
const MAX_IMAGE_COUNT = 9
const API_BASE_URL = 'http://example.com/api'

// 变量 - 小驼峰
let currentPage = 1
let isLoading = false

// 私有属性 - 下划线前缀
private _internalState: number = 0

// 状态变量 - 小驼峰
@State postList: Post[] = []
@State isRefreshing: boolean = false
```

### 3.3 函数命名

```typescript
// 获取数据 - get 前缀
async getPostList(): Promise<Post[]>
async getUserProfile(userId: number): Promise<User>

// 设置数据 - set 前缀
setCurrentUser(user: User): void

// 判断条件 - is/has/can 前缀
isLoggedIn(): boolean
hasPermission(permission: string): boolean
canEdit(): boolean

// 事件处理 - handle/on 前缀
handleLikeClick(): void
onScrollEnd(): void

// 私有方法 - 下划线前缀 (可选)
private _validateInput(): boolean
```

### 3.4 组件结构规范

```typescript
import { ... } from '...'

// 接口定义
interface ComponentProps {
  title: string
  onClose: () => void
}

@Component
export struct ExampleComponent {
  // 1. 属性定义
  @Prop title: string = ''
  @State isVisible: boolean = true
  @Link externalState: number
  @Consume('pageStack') pageStack: NavPathStack

  // 2. 回调属性
  onClose: () => void = () => {}

  // 3. 私有属性
  private scroller: Scroller = new Scroller()

  // 4. 生命周期方法
  aboutToAppear() {
    this.loadData()
  }

  aboutToDisappear() {
    this.cleanup()
  }

  // 5. 私有方法
  private async loadData() {
    // ...
  }

  private handleAction() {
    // ...
  }

  // 6. Builder 方法
  @Builder
  private HeaderBuilder() {
    Row() {
      Text(this.title)
    }
  }

  // 7. build 方法 (最后)
  build() {
    Column() {
      this.HeaderBuilder()
      // ...
    }
  }
}
```

---

## 4. 状态管理最佳实践

### 4.1 局部状态

```typescript
@Component
struct LocalStateExample {
  // 组件内部状态
  @State count: number = 0
  @State items: string[] = []

  build() {
    Column() {
      Text(`Count: ${this.count}`)
      Button('Add')
        .onClick(() => this.count++)
    }
  }
}
```

### 4.2 父子通信

```typescript
// 父组件
@Component
struct ParentComponent {
  @State value: string = ''

  build() {
    Column() {
      // 单向传递 (只读)
      ChildComponent({ title: this.value })

      // 双向绑定
      InputComponent({ value: $value })
    }
  }
}

// 子组件 - Prop (只读)
@Component
struct ChildComponent {
  @Prop title: string = ''

  build() {
    Text(this.title)
  }
}

// 子组件 - Link (双向)
@Component
struct InputComponent {
  @Link value: string

  build() {
    TextInput({ text: this.value })
      .onChange((newValue) => {
        this.value = newValue
      })
  }
}
```

### 4.3 全局状态

```typescript
// 初始化全局状态
AppStorage.setOrCreate('isLoggedIn', false)
AppStorage.setOrCreate('currentUserId', 0)
AppStorage.setOrCreate('refreshTrigger', 0)

// 组件中使用
@Component
struct GlobalStateExample {
  // 双向绑定
  @StorageLink('isLoggedIn') isLoggedIn: boolean = false

  // 只读绑定
  @StorageProp('currentUserId') userId: number = 0

  // 监听变化
  @Watch('onLoginStateChange')
  @StorageLink('isLoggedIn') loginState: boolean = false

  onLoginStateChange() {
    if (this.loginState) {
      this.loadUserData()
    }
  }
}
```

### 4.4 跨组件通信

```typescript
// 使用 EventEmitter
import { emitter } from '@kit.BasicServicesKit'

// 定义事件 ID
const EVENT_REFRESH_PROFILE = 1001
const EVENT_POST_CREATED = 1002

// 发送事件
emitter.emit({ eventId: EVENT_REFRESH_PROFILE }, { data: { userId: 123 } })

// 监听事件
emitter.on({ eventId: EVENT_REFRESH_PROFILE }, (eventData) => {
  const userId = eventData.data.userId
  this.loadProfile(userId)
})

// 取消监听 (在 aboutToDisappear 中)
emitter.off(EVENT_REFRESH_PROFILE)
```

---

## 5. API 调用规范

### 5.1 基础请求封装

```typescript
// services/ApiService.ets
import http from '@ohos.net.http'

class ApiService {
  private static BASE_URL = 'http://your-api-server.com/api'

  private static async request<T>(
    method: http.RequestMethod,
    path: string,
    data?: object
  ): Promise<T> {
    const httpRequest = http.createHttp()

    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    }

    // 添加认证头
    const token = AuthService.getToken()
    if (token) {
      headers['Authorization'] = `Bearer ${token}`
    }

    try {
      const response = await httpRequest.request(
        `${this.BASE_URL}${path}`,
        {
          method,
          header: headers,
          extraData: data ? JSON.stringify(data) : undefined
        }
      )

      if (response.responseCode === 200 || response.responseCode === 201) {
        const result = JSON.parse(response.result as string)
        return result.data as T
      } else if (response.responseCode === 401) {
        // Token 过期，跳转登录
        AuthService.clearToken()
        throw new Error('认证已过期')
      } else {
        throw new Error(`请求失败: ${response.responseCode}`)
      }
    } finally {
      httpRequest.destroy()
    }
  }

  // GET 请求
  static async get<T>(path: string): Promise<T> {
    return this.request<T>(http.RequestMethod.GET, path)
  }

  // POST 请求
  static async post<T>(path: string, data?: object): Promise<T> {
    return this.request<T>(http.RequestMethod.POST, path, data)
  }

  // PUT 请求
  static async put<T>(path: string, data?: object): Promise<T> {
    return this.request<T>(http.RequestMethod.PUT, path, data)
  }

  // DELETE 请求
  static async delete<T>(path: string): Promise<T> {
    return this.request<T>(http.RequestMethod.DELETE, path)
  }
}
```

### 5.2 错误处理

```typescript
// 统一错误处理
async function safeApiCall<T>(
  apiCall: () => Promise<T>,
  options?: {
    showError?: boolean
    errorMessage?: string
  }
): Promise<T | null> {
  try {
    return await apiCall()
  } catch (error) {
    console.error('API Error:', error)

    if (options?.showError !== false) {
      promptAction.showToast({
        message: options?.errorMessage || '操作失败，请重试'
      })
    }

    return null
  }
}

// 使用示例
const posts = await safeApiCall(
  () => ApiService.getPosts({ page: 1 }),
  { errorMessage: '加载帖子失败' }
)
```

---

## 6. 常用 UI 模式

### 6.1 列表加载

```typescript
@Component
struct ListPage {
  @State items: Item[] = []
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State hasMore: boolean = true
  private page: number = 1

  async loadData(refresh: boolean = false) {
    if (this.isLoading) return

    this.isLoading = true
    if (refresh) {
      this.page = 1
      this.isRefreshing = true
    }

    try {
      const response = await ApiService.getItems({ page: this.page })

      if (refresh) {
        this.items = response.items
      } else {
        this.items = this.items.concat(response.items)
      }

      this.hasMore = response.hasMore
      this.page++
    } finally {
      this.isLoading = false
      this.isRefreshing = false
    }
  }

  build() {
    Refresh({ refreshing: this.isRefreshing }) {
      List() {
        ForEach(this.items, (item: Item) => {
          ListItem() {
            ItemCard({ item })
          }
        })

        // 加载更多
        if (this.hasMore) {
          ListItem() {
            LoadingIndicator()
          }
          .onAppear(() => this.loadData())
        }
      }
    }
    .onRefreshing(() => this.loadData(true))
  }
}
```

### 6.2 空状态处理

```typescript
@Component
struct EmptyState {
  @Prop icon: Resource
  @Prop message: string
  @Prop actionText?: string
  onAction?: () => void

  build() {
    Column() {
      Image(this.icon)
        .width(120)
        .height(120)
        .opacity(0.6)

      Text(this.message)
        .fontSize(16)
        .fontColor('#999')
        .margin({ top: 16 })

      if (this.actionText) {
        Button(this.actionText)
          .margin({ top: 24 })
          .onClick(() => this.onAction?.())
      }
    }
    .width('100%')
    .padding(32)
  }
}

// 使用
build() {
  if (this.items.length === 0 && !this.isLoading) {
    EmptyState({
      icon: $r('app.media.ic_empty'),
      message: '暂无内容',
      actionText: '去发布',
      onAction: () => this.goToPublish()
    })
  } else {
    // 列表内容
  }
}
```

### 6.3 Loading 状态

```typescript
@Component
struct LoadingState {
  build() {
    Column() {
      LoadingProgress()
        .width(48)
        .height(48)
        .color('#007AFF')

      Text('加载中...')
        .fontSize(14)
        .fontColor('#999')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}

// 使用
build() {
  Stack() {
    // 主内容
    Column() { ... }

    // Loading 覆盖层
    if (this.isLoading) {
      LoadingState()
        .backgroundColor('#FFFFFF')
    }
  }
}
```

---

## 7. 调试技巧

### 7.1 日志输出

```typescript
// 开发环境日志
const isDev = true

function log(tag: string, message: string, data?: any) {
  if (isDev) {
    console.log(`[${tag}] ${message}`, data ? JSON.stringify(data) : '')
  }
}

// 使用
log('PostCard', 'Like clicked', { postId: 123 })
log('ApiService', 'Request failed', error)
```

### 7.2 断点调试

1. 在代码中设置断点
2. 使用 DevEco Studio 的调试模式运行
3. 查看变量值和调用栈

### 7.3 性能分析

```typescript
// 性能计时
const startTime = Date.now()
await this.loadData()
console.log(`Data loaded in ${Date.now() - startTime}ms`)

// 使用 HiLog
import hilog from '@ohos.hilog'

hilog.info(0x0000, 'TraQuick', 'Performance: %{public}d ms', elapsedTime)
```

---

## 8. 测试指南

### 8.1 单元测试

```typescript
// entry/src/test/ExampleTest.ets
import { describe, it, expect } from '@ohos/hypium'
import { Formatter } from '../main/ets/utils/Formatter'

describe('Formatter', () => {
  it('should format time correctly', () => {
    const result = Formatter.formatTime('2024-03-15T10:30:00Z')
    expect(result).assertEqual('5分钟前')
  })

  it('should format count correctly', () => {
    expect(Formatter.formatCount(999)).assertEqual('999')
    expect(Formatter.formatCount(1234)).assertEqual('1.2K')
    expect(Formatter.formatCount(1234567)).assertEqual('123.5W')
  })
})
```

### 8.2 运行测试

```bash
# 在 DevEco Studio 中
# 右键点击测试文件 -> Run Tests
```

---

## 9. 构建与发布

### 9.1 开发构建

```bash
# 同步项目
npm install

# 构建 Debug 版本
# 在 DevEco Studio 中: Build -> Build Hap(s)/APP(s) -> Build Hap(s)
```

### 9.2 发布构建

1. 配置签名证书
2. 修改 `build-profile.json5` 中的签名配置
3. Build -> Build Hap(s)/APP(s) -> Build APP(s)
4. 生成的 .app 文件用于发布

### 9.3 版本管理

```json5
// AppScope/app.json5
{
  "app": {
    "versionCode": 1000001,  // 每次发布递增
    "versionName": "1.0.1"   // 语义化版本
  }
}
```

---

## 10. 常见问题

### 10.1 编译错误

**问题:** `Cannot find module '@ohos.xxx'`
**解决:** 检查 SDK 版本，确保 API Level 匹配

**问题:** `Type 'xxx' is not assignable to type 'yyy'`
**解决:** 检查类型定义，确保类型匹配

### 10.2 运行时错误

**问题:** 网络请求失败
**解决:**
1. 检查 `ohos.permission.INTERNET` 权限
2. 确认服务器地址正确
3. 检查网络连接

**问题:** 定位失败
**解决:**
1. 检查定位权限配置
2. 确认设备定位服务已开启
3. 模拟器可能不支持某些定位功能

### 10.3 性能问题

**问题:** 列表滚动卡顿
**解决:**
1. 使用 `LazyForEach` 替代 `ForEach`
2. 减少列表项复杂度
3. 图片使用缩略图

**问题:** 内存占用高
**解决:**
1. 及时释放资源
2. 图片使用适当尺寸
3. 避免内存泄漏
