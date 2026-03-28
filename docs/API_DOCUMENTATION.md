# TraQuick API 接口文档

## 1. 概述

### 1.1 基础信息

| 项目 | 值 |
|------|-----|
| 基础 URL | `http://your-api-server.com/api` |
| 协议 | HTTP/HTTPS |
| 数据格式 | JSON |
| 字符编码 | UTF-8 |

### 1.2 认证方式

使用 JWT (JSON Web Token) 进行身份认证。

```
Authorization: Bearer <token>
```

### 1.3 通用响应格式

**成功响应:**
```json
{
  "code": 200,
  "message": "success",
  "data": { ... }
}
```

**错误响应:**
```json
{
  "code": 400,
  "message": "错误描述",
  "details": {
    "field": "具体错误信息"
  }
}
```

---

## 2. 认证接口

### 2.1 用户登录

**POST** `/auth/login`

**请求参数:**
```json
{
  "username": "string",
  "password": "string"
}
```

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "nickname": "旅行者",
      "avatar": "https://oss.example.com/avatar/1.jpg",
      "level": 3,
      "levelTitle": "省际行者"
    }
  }
}
```

### 2.2 用户注册

**POST** `/auth/register`

**请求参数:**
```json
{
  "username": "string",
  "password": "string",
  "nickname": "string",
  "email": "string (可选)",
  "phone": "string (可选)"
}
```

**响应数据:**
```json
{
  "code": 201,
  "message": "注册成功",
  "data": {
    "userId": 1
  }
}
```

### 2.3 获取当前用户信息

**GET** `/auth/profile`

**请求头:** 需要 Authorization

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "nickname": "旅行者",
    "avatar": "https://oss.example.com/avatar/1.jpg",
    "bio": "热爱旅行的人",
    "coverImage": "https://oss.example.com/cover/1.jpg",
    "level": 3,
    "levelTitle": "省际行者",
    "followingCount": 100,
    "followersCount": 200,
    "citiesCount": 15,
    "countriesCount": 3,
    "postsCount": 50
  }
}
```

### 2.4 更新用户资料

**PUT** `/auth/profile`

**请求头:** 需要 Authorization

**请求参数:**
```json
{
  "nickname": "string (可选)",
  "avatar": "string (可选)",
  "bio": "string (可选)",
  "coverImage": "string (可选)"
}
```

**响应数据:**
```json
{
  "code": 200,
  "message": "更新成功"
}
```

---

## 3. 用户接口

### 3.1 获取用户资料

**GET** `/users/{userId}`

**路径参数:**
- `userId`: 用户 ID

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "id": 2,
    "nickname": "探索者",
    "avatar": "https://oss.example.com/avatar/2.jpg",
    "bio": "世界那么大",
    "level": 5,
    "levelTitle": "环球旅人",
    "followingCount": 50,
    "followersCount": 300,
    "citiesCount": 30,
    "countriesCount": 10,
    "postsCount": 80,
    "isFollowing": false
  }
}
```

### 3.2 关注用户

**POST** `/users/{userId}/follow`

**路径参数:**
- `userId`: 要关注的用户 ID

**响应数据:**
```json
{
  "code": 200,
  "message": "关注成功"
}
```

### 3.3 取消关注

**DELETE** `/users/{userId}/follow`

**路径参数:**
- `userId`: 要取消关注的用户 ID

**响应数据:**
```json
{
  "code": 200,
  "message": "已取消关注"
}
```

### 3.4 获取关注列表

**GET** `/users/{userId}/following`

**路径参数:**
- `userId`: 用户 ID

**查询参数:**
- `page`: 页码 (默认 1)
- `limit`: 每页数量 (默认 20)

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "users": [
      {
        "id": 3,
        "nickname": "用户A",
        "avatar": "...",
        "bio": "...",
        "isFollowing": true
      }
    ],
    "total": 100,
    "hasMore": true
  }
}
```

### 3.5 获取粉丝列表

**GET** `/users/{userId}/followers`

**参数同关注列表**

---

## 4. 帖子接口

### 4.1 获取帖子列表

**GET** `/posts`

**查询参数:**
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码，默认 1 |
| limit | number | 否 | 每页数量，默认 10 |
| sort | string | 否 | 排序: latest/hot |
| authorId | number | 否 | 按作者筛选 |
| cityId | number | 否 | 按城市筛选 |
| tag | string | 否 | 按标签筛选 |
| likedBy | number | 否 | 用户点赞的帖子 |
| collectedBy | number | 否 | 用户收藏的帖子 |

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "posts": [
      {
        "id": 1,
        "author": {
          "id": 1,
          "nickname": "旅行者",
          "avatar": "..."
        },
        "content": "今天天气真好！",
        "images": [
          "https://oss.example.com/post/1/1.jpg",
          "https://oss.example.com/post/1/2.jpg"
        ],
        "location": "北京市朝阳区",
        "cityId": 110,
        "cityName": "北京",
        "tags": ["风景", "旅行"],
        "likeCount": 100,
        "commentCount": 20,
        "collectCount": 50,
        "shareCount": 10,
        "isLiked": false,
        "isCollected": false,
        "createdAt": "2024-03-15T10:30:00Z"
      }
    ],
    "total": 500,
    "page": 1,
    "limit": 10,
    "hasMore": true
  }
}
```

### 4.2 获取帖子详情

**GET** `/posts/{postId}`

**路径参数:**
- `postId`: 帖子 ID

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "author": { ... },
    "content": "...",
    "images": [...],
    "location": "...",
    "tags": [...],
    "likeCount": 100,
    "commentCount": 20,
    "collectCount": 50,
    "shareCount": 10,
    "isLiked": true,
    "isCollected": false,
    "createdAt": "2024-03-15T10:30:00Z"
  }
}
```

### 4.3 创建帖子

**POST** `/posts`

**请求头:** 需要 Authorization

**请求参数:**
```json
{
  "content": "string",
  "images": ["string"],
  "location": "string (可选)",
  "cityId": "number (可选)",
  "tags": ["string"] // 最多5个
}
```

**响应数据:**
```json
{
  "code": 201,
  "data": {
    "postId": 123
  }
}
```

### 4.4 删除帖子

**DELETE** `/posts/{postId}`

**路径参数:**
- `postId`: 帖子 ID

**响应数据:**
```json
{
  "code": 200,
  "message": "删除成功"
}
```

### 4.5 点赞帖子

**POST** `/posts/{postId}/like`

**响应数据:**
```json
{
  "code": 200,
  "message": "点赞成功"
}
```

### 4.6 取消点赞

**DELETE** `/posts/{postId}/like`

**响应数据:**
```json
{
  "code": 200,
  "message": "已取消点赞"
}
```

### 4.7 收藏帖子

**POST** `/posts/{postId}/collect`

### 4.8 取消收藏

**DELETE** `/posts/{postId}/collect`

### 4.9 分享帖子

**POST** `/posts/{postId}/share`

**请求参数:**
```json
{
  "targetUserIds": [1, 2, 3]
}
```

**响应数据:**
```json
{
  "code": 200,
  "message": "分享成功"
}
```

---

## 5. 评论接口

### 5.1 获取评论列表

**GET** `/posts/{postId}/comments`

**查询参数:**
- `page`: 页码
- `limit`: 每页数量

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "comments": [
      {
        "id": 1,
        "postId": 123,
        "author": {
          "id": 2,
          "nickname": "用户A",
          "avatar": "..."
        },
        "content": "太美了！",
        "replyTo": null,
        "parentId": null,
        "likeCount": 10,
        "isLiked": false,
        "createdAt": "2024-03-15T11:00:00Z"
      }
    ],
    "total": 50,
    "hasMore": true
  }
}
```

### 5.2 创建评论

**POST** `/posts/{postId}/comments`

**请求参数:**
```json
{
  "content": "string",
  "parentId": "number (可选，回复时填写)"
}
```

**响应数据:**
```json
{
  "code": 201,
  "data": {
    "commentId": 456
  }
}
```

---

## 6. 城市接口

### 6.1 获取城市列表

**GET** `/cities`

**查询参数:**
- `country`: 国家代码筛选
- `province`: 省份筛选
- `search`: 搜索关键词

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "cities": [
      {
        "id": 110,
        "name": "北京",
        "nameEn": "Beijing",
        "province": "北京市",
        "country": "中国",
        "countryCode": "CN",
        "continent": "亚洲",
        "latitude": 39.9042,
        "longitude": 116.4074,
        "coverImage": "...",
        "visitCount": 10000,
        "postCount": 5000,
        "isVisited": true
      }
    ]
  }
}
```

### 6.2 获取城市详情

**GET** `/cities/{cityId}`

**路径参数:**
- `cityId`: 城市 ID

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "id": 110,
    "name": "北京",
    "description": "中华人民共和国首都...",
    "coverImage": "...",
    "visitCount": 10000,
    "postCount": 5000,
    "isVisited": true,
    "visitedAt": "2024-01-15T08:00:00Z"
  }
}
```

### 6.3 标记城市已访问

**POST** `/cities/{cityId}/visit`

**请求参数:**
```json
{
  "latitude": 39.9042,
  "longitude": 116.4074
}
```

---

## 7. 漂流瓶接口

### 7.1 获取漂流瓶列表

**GET** `/bottles`

**查询参数:**
- `status`: 状态筛选 (drifting/picked/replied)
- `type`: 类型筛选 (wish/question/task/story)

### 7.2 创建漂流瓶

**POST** `/bottles`

**请求参数:**
```json
{
  "content": "string",
  "mood": "happy|sad|excited|calm|curious|hopeful",
  "type": "wish|question|task|story",
  "location": "string (可选)"
}
```

### 7.3 捡起漂流瓶

**POST** `/bottles/pick`

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "id": 789,
    "author": {
      "id": 5,
      "nickname": "匿名用户",
      "avatar": "..."
    },
    "content": "希望捡到这个瓶子的人...",
    "mood": "hopeful",
    "type": "wish",
    "createdAt": "2024-03-10T15:00:00Z"
  }
}
```

### 7.4 回复漂流瓶

**POST** `/bottles/{bottleId}/reply`

**请求参数:**
```json
{
  "content": "string (可选)",
  "images": ["string"] // 任务瓶需要
}
```

---

## 8. 时间胶囊接口

### 8.1 获取胶囊列表

**GET** `/capsules`

**查询参数:**
- `status`: sealed/ready/opened

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "capsules": [...],
    "total": 10,
    "sealed": 5,
    "ready": 2,
    "opened": 3
  }
}
```

### 8.2 创建时间胶囊

**POST** `/capsules`

**请求参数:**
```json
{
  "title": "string",
  "content": "string",
  "images": ["string"],
  "location": "string (可选)",
  "targetDate": "2025-03-15T00:00:00Z",
  "isPublic": false
}
```

### 8.3 获取胶囊详情

**GET** `/capsules/{capsuleId}`

### 8.4 开启时间胶囊

**POST** `/capsules/{capsuleId}/open`

**注意:** 只有到达 targetDate 的胶囊才能开启

---

## 9. 消息接口

### 9.1 获取消息列表

**GET** `/messages`

**查询参数:**
- `type`: like/comment/follow/system
- `page`: 页码
- `limit`: 每页数量

### 9.2 标记消息已读

**PUT** `/messages/{messageId}/read`

### 9.3 标记全部已读

**PUT** `/messages/read-all`

**请求参数:**
```json
{
  "type": "like|comment|follow|system (可选)"
}
```

### 9.4 获取未读消息数

**GET** `/messages/unread-count`

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "total": 15,
    "like": 5,
    "comment": 3,
    "follow": 2,
    "system": 5
  }
}
```

---

## 10. 媒体上传接口

### 10.1 上传图片

**POST** `/upload/image`

**请求头:**
```
Content-Type: multipart/form-data
Authorization: Bearer <token>
```

**请求体:**
- `file`: 图片文件 (支持 jpg, png, gif, webp)

**响应数据:**
```json
{
  "code": 200,
  "data": {
    "url": "https://oss.example.com/images/abc123.jpg",
    "width": 1920,
    "height": 1080,
    "size": 102400
  }
}
```

### 10.2 图片处理参数

OSS 图片支持 URL 参数进行实时处理:

| 后缀 | 说明 | 尺寸 |
|------|------|------|
| `_avatar` | 头像 | 200x200 |
| `_thumb` | 缩略图 | 400x400 |
| `_large` | 大图 | 1200xAuto |
| `_origin` | 原图 | 原始尺寸 |

**示例:**
```
https://oss.example.com/images/abc123_avatar.jpg
https://oss.example.com/images/abc123_thumb.jpg
```

---

## 11. 错误码参考

| 错误码 | HTTP 状态码 | 说明 |
|--------|------------|------|
| 10001 | 400 | 参数缺失 |
| 10002 | 400 | 参数格式错误 |
| 20001 | 401 | Token 无效 |
| 20002 | 401 | Token 过期 |
| 20003 | 403 | 无权限访问 |
| 30001 | 404 | 用户不存在 |
| 30002 | 404 | 帖子不存在 |
| 30003 | 404 | 评论不存在 |
| 40001 | 409 | 已关注该用户 |
| 40002 | 409 | 已点赞该帖子 |
| 50001 | 500 | 服务器内部错误 |
| 50002 | 503 | 服务暂时不可用 |

---

## 12. 请求限流

| 接口类型 | 限流规则 |
|----------|----------|
| 登录/注册 | 5次/分钟 |
| 发帖 | 10次/小时 |
| 评论 | 30次/小时 |
| 点赞/收藏 | 100次/小时 |
| 图片上传 | 50次/小时 |
| 其他接口 | 60次/分钟 |

超出限流返回:
```json
{
  "code": 429,
  "message": "请求过于频繁，请稍后再试"
}
```
