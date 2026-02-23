/**
 * 统一 API 请求服务 - ArkTS 严格模式兼容版
 */
import { http } from '@kit.NetworkKit';

// ⚠️ 改成你电脑的局域网 IP
const BASE_URL: string = 'http://172.19.0.1:3000/api';

// ==================== 数据结构定义（全部用 class） ====================

export class ApiResponse {
  code: number = 0;
  message: string = '';
  data: object | null = null;
  timestamp: string = '';
}

export class AuthData {
  accessToken: string = '';
  user: ApiUser = new ApiUser();
}

export class ApiUser {
  id: string = '';
  email: string = '';
  nickname: string = '';
  avatar: string = '';
  bio: string = '';
  level: number = 1;
  levelTitle: string = '';
  followingCount: number = 0;
  followersCount: number = 0;
  friendsCount: number = 0;
  citiesCount: number = 0;
  countriesCount: number = 0;
  postsCount: number = 0;
  createdAt: string = '';
}

export class PostAuthorInfo {
  id: string = '';
  nickname: string = '';
  avatar: string = '';
  level: number = 1;
  levelTitle: string = '';
}

export class PostCityInfo {
  id: string = '';
  name: string = '';
}

export class ApiPost {
  id: string = '';
  content: string = '';
  images: string[] = [];
  video: string = '';
  type: string = 'image';
  tags: string[] = [];
  address: string = '';
  latitude: number = 0;
  longitude: number = 0;
  likeCount: number = 0;
  commentCount: number = 0;
  shareCount: number = 0;
  collectCount: number = 0;
  createdAt: string = '';
  author: PostAuthorInfo = new PostAuthorInfo();
  city: PostCityInfo | null = null;
  isLiked: boolean = false;
  isCollected: boolean = false;
}

export class PaginatedPosts {
  items: ApiPost[] = [];
  total: number = 0;
  page: number = 1;
  limit: number = 20;
  totalPages: number = 0;
}

export class CommentUserInfo {
  id: string = '';
  nickname: string = '';
  avatar: string = '';
  level: number = 1;
  levelTitle: string = '';
}

export class ReplyToUserInfo {
  id: string = '';
  nickname: string = '';
}

export class ApiComment {
  id: string = '';
  content: string = '';
  likeCount: number = 0;
  createdAt: string = '';
  user: CommentUserInfo = new CommentUserInfo();
  replyToUser: ReplyToUserInfo | null = null;
  children: ApiComment[] = [];
}

export class CommentListData {
  items: ApiComment[] = [];
  total: number = 0;
}

export class UserRelation {
  isFollowing: boolean = false;
  isFollowedBy: boolean = false;
  isFriend: boolean = false;
}

export class UserProfileData {
  profile: ApiUser = new ApiUser();
  relation: UserRelation | null = null;
}

export class LikeResult {
  likeCount: number = 0;
}

export class CollectResult {
  collectCount: number = 0;
}

export class FollowResult {
  isFollowing: boolean = false;
  isFriend: boolean = false;
}

export class MessageResult {
  message: string = '';
}

export class UserListData {
  items: ApiUser[] = [];
  total: number = 0;
}

// ==================== 请求参数类 ====================

export class LoginParams {
  email: string = '';
  password: string = '';
}

export class RegisterParams {
  email: string = '';
  password: string = '';
  nickname: string = '';
}

export class CreatePostParams {
  content: string = '';
  images: string[] = [];
  type: string = 'image';
  tags: string[] = [];
  address: string = '';
  latitude: number = 0;
  longitude: number = 0;
  cityId: string = '';
}

export class CreateCommentParams {
  postId: string = '';
  content: string = '';
  parentId: string = '';
  replyToUserId: string = '';
}

export class UpdateProfileParams {
  nickname: string = '';
  avatar: string = '';
  bio: string = '';
}

// ==================== API 请求类 ====================

class ApiServiceClass {
  /**
   * 获取 Token
   */
  private getToken(): string {
    return AppStorage.get<string>('userToken') || '';
  }

  /**
   * 通用 GET 请求
   */
  private async get<T>(path: string, needAuth: boolean = false): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      const url = `${BASE_URL}${path}`;

      const header: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (needAuth) {
        const token = this.getToken();
        if (token) {
          header['Authorization'] = `Bearer ${token}`;
        }
      }

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: header,
        connectTimeout: 10000,
        readTimeout: 15000,
      });

      const result: ApiResponse = JSON.parse(response.result as string) as ApiResponse;

      if (result.code >= 200 && result.code < 300) {
        return result.data as T;
      } else {
        throw new Error(result.message || '请求失败');
      }
    } catch (error) {
      const err = error as Error;
      console.error(`[ApiService] GET ${path} 失败: ${err.message}`);
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 通用 POST 请求
   */
  private async post<T>(path: string, data?: object, needAuth: boolean = false): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      const url = `${BASE_URL}${path}`;

      const header: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (needAuth) {
        const token = this.getToken();
        if (token) {
          header['Authorization'] = `Bearer ${token}`;
        }
      }

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.POST,
        header: header,
        extraData: data ? JSON.stringify(data) : undefined,
        connectTimeout: 10000,
        readTimeout: 15000,
      });

      const result: ApiResponse = JSON.parse(response.result as string) as ApiResponse;

      if (result.code >= 200 && result.code < 300) {
        return result.data as T;
      } else {
        throw new Error(result.message || '请求失败');
      }
    } catch (error) {
      const err = error as Error;
      console.error(`[ApiService] POST ${path} 失败: ${err.message}`);
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 通用 PUT 请求
   */
  private async put<T>(path: string, data?: object, needAuth: boolean = false): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      const url = `${BASE_URL}${path}`;

      const header: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (needAuth) {
        const token = this.getToken();
        if (token) {
          header['Authorization'] = `Bearer ${token}`;
        }
      }

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.PUT,
        header: header,
        extraData: data ? JSON.stringify(data) : undefined,
        connectTimeout: 10000,
        readTimeout: 15000,
      });

      const result: ApiResponse = JSON.parse(response.result as string) as ApiResponse;

      if (result.code >= 200 && result.code < 300) {
        return result.data as T;
      } else {
        throw new Error(result.message || '请求失败');
      }
    } catch (error) {
      const err = error as Error;
      console.error(`[ApiService] PUT ${path} 失败: ${err.message}`);
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }

  /**
   * 通用 DELETE 请求
   */
  private async del<T>(path: string, needAuth: boolean = false): Promise<T> {
    const httpRequest = http.createHttp();

    try {
      const url = `${BASE_URL}${path}`;

      const header: Record<string, string> = {
        'Content-Type': 'application/json',
      };

      if (needAuth) {
        const token = this.getToken();
        if (token) {
          header['Authorization'] = `Bearer ${token}`;
        }
      }

      const response = await httpRequest.request(url, {
        method: http.RequestMethod.DELETE,
        header: header,
        connectTimeout: 10000,
        readTimeout: 15000,
      });

      const result: ApiResponse = JSON.parse(response.result as string) as ApiResponse;

      if (result.code >= 200 && result.code < 300) {
        return result.data as T;
      } else {
        throw new Error(result.message || '请求失败');
      }
    } catch (error) {
      const err = error as Error;
      console.error(`[ApiService] DELETE ${path} 失败: ${err.message}`);
      throw err;
    } finally {
      httpRequest.destroy();
    }
  }

  // ============================================================
  // Auth 接口
  // ============================================================

  async register(params: RegisterParams): Promise<AuthData> {
    return await this.post<AuthData>('/auth/register', params);
  }

  async login(params: LoginParams): Promise<AuthData> {
    return await this.post<AuthData>('/auth/login', params);
  }

  async getProfile(): Promise<ApiUser> {
    return await this.get<ApiUser>('/auth/profile', true);
  }

  // ============================================================
  // Post 接口
  // ============================================================

  async createPost(params: CreatePostParams): Promise<ApiPost> {
    return await this.post<ApiPost>('/posts', params, true);
  }

  async getPosts(page: number = 1, limit: number = 20, orderBy: string = 'latest',
    authorId: string = '', cityId: string = '', tag: string = ''): Promise<PaginatedPosts> {
    let query = `?page=${page}&limit=${limit}&orderBy=${orderBy}`;
    if (authorId) query += `&authorId=${authorId}`;
    if (cityId) query += `&cityId=${cityId}`;
    if (tag) query += `&tag=${tag}`;

    return await this.get<PaginatedPosts>(`/posts${query}`, true);
  }

  async getPostDetail(postId: string): Promise<ApiPost> {
    return await this.get<ApiPost>(`/posts/${postId}`, true);
  }

  async deletePost(postId: string): Promise<MessageResult> {
    return await this.del<MessageResult>(`/posts/${postId}`, true);
  }

  async likePost(postId: string): Promise<LikeResult> {
    return await this.post<LikeResult>(`/posts/${postId}/like`, undefined, true);
  }

  async unlikePost(postId: string): Promise<LikeResult> {
    return await this.del<LikeResult>(`/posts/${postId}/like`, true);
  }

  async collectPost(postId: string): Promise<CollectResult> {
    return await this.post<CollectResult>(`/posts/${postId}/collect`, undefined, true);
  }

  async uncollectPost(postId: string): Promise<CollectResult> {
    return await this.del<CollectResult>(`/posts/${postId}/collect`, true);
  }

  // ============================================================
  // Comment 接口
  // ============================================================

  async createComment(params: CreateCommentParams): Promise<ApiComment> {
    // 构建请求体，只发送非空字段
    const body: Record<string, string> = {};
    body['postId'] = params.postId;
    body['content'] = params.content;

    // 只有非空时才添加
    if (params.parentId.length > 0) {
      body['parentId'] = params.parentId;
    }

    if (params.replyToUserId.length > 0) {
      body['replyToUserId'] = params.replyToUserId;
    }

    return await this.post<ApiComment>('/comments', body, true);
  }

  async getComments(postId: string, page: number = 1, limit: number = 20): Promise<CommentListData> {
    return await this.get<CommentListData>(`/comments/post/${postId}?page=${page}&limit=${limit}`);
  }

  // ============================================================
  // User 接口
  // ============================================================

  async getUserProfile(userId: string): Promise<UserProfileData> {
    return await this.get<UserProfileData>(`/users/${userId}`, true);
  }

  async updateProfile(params: UpdateProfileParams): Promise<ApiUser> {
    return await this.put<ApiUser>('/users/me', params, true);
  }

  async followUser(userId: string): Promise<FollowResult> {
    return await this.post<FollowResult>(`/users/${userId}/follow`, undefined, true);
  }

  async unfollowUser(userId: string): Promise<FollowResult> {
    return await this.del<FollowResult>(`/users/${userId}/follow`, true);
  }

  async getFollowingList(userId: string, page: number = 1): Promise<UserListData> {
    return await this.get<UserListData>(`/users/${userId}/following?page=${page}`);
  }

  async getFollowersList(userId: string, page: number = 1): Promise<UserListData> {
    return await this.get<UserListData>(`/users/${userId}/followers?page=${page}`);
  }

  // ============================================================
  // City 接口
  // ============================================================

  async checkInCity(cityId: string): Promise<MessageResult> {
    return await this.post<MessageResult>(`/cities/${cityId}/check-in`, undefined, true);
  }

  // ============================================================
  // Message 接口
  // ============================================================

  async markAllRead(type: string = ''): Promise<object> {
    const query = type ? `?type=${type}` : '';
    return await this.put<object>(`/messages/read-all${query}`, undefined, true);
  }
}

// 导出单例
export const ApiService = new ApiServiceClass();