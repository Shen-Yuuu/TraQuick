/**
 * 统一 API 请求服务 - ArkTS 严格模式兼容版
 */
import { http } from '@kit.NetworkKit';

const BASE_URL: string = 'http://192.168.137.1:3000/api';

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
  updatedAt: string = '';
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

// ------ Message 相关 ------
export class MessageRelatedUser {
  id: string = '';
  nickname: string = '';
  avatar: string = '';
}

export class MessageRelatedPost {
  id: string = '';
  content: string = '';
}

export class ApiMessage {
  id: string = '';
  type: string = 'system';
  title: string = '';
  content: string = '';
  isRead: boolean = false;
  createdAt: string = '';
  relatedUser: MessageRelatedUser | null = null;
  relatedPost: MessageRelatedPost | null = null;
}

export class MessageListData {
  items: ApiMessage[] = [];
  total: number = 0;
  unreadTotal: number = 0;
}

export class ApiMessageGroup {
  type: string = '';
  unreadCount: number = 0;
  latestMessage: ApiMessage | null = null;
}

export class MarkReadResult {
  count: number = 0;
}

// ------ City 相关 ------
export class ApiCity {
  id: string = '';
  name: string = '';
  nameEn: string | null = null;
  country: string = '';
  countryCode: string = '';
  province: string | null = null;
  coverImage: string = '';
  latitude: number = 0;
  longitude: number = 0;
  description: string | null = null;
  postsCount: number = 0;
  visitorsCount: number = 0;
  isUnlocked: boolean = false;
}

export class ApiCityMarker {
  id: string = '';
  name: string = '';
  latitude: number = 0;
  longitude: number = 0;
  isUnlocked: boolean = false;
  hasContent: boolean = false;
  type: string = 'normal';
}

// ------ DriftBottle (漂流瓶) 相关 ------
export class ApiDriftBottle {
  id: string = '';
  content: string = '';
  type: string = 'wish'; // 'wish' | 'story' | 'question'
  senderNickname: string = '';
  senderCity: string | null = null;
  createdAt: string = '';
}

export class CreateBottleParams {
  content: string = '';
  type: string = 'wish';
  cityId?: string = '';
}

// ------ TimeCapsule (时空胶囊) 相关 ------
export class ApiTimeCapsule {
  id: string = '';
  content: string = '';
  images: string[] = [];
  targetDate: string = '';
  cityName: string | null = null;
  address: string | null = null;
  status: string = 'locked'; // 'locked' | 'unlocked'
  createdAt: string = '';
}

export class CreateCapsuleParams {
  content: string = '';
  images?: string[] = [];
  targetDate: string = '';
  cityName?: string = '';
  address?: string = '';
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

  async getPosts(
    page: number = 1,
    limit: number = 20,
    orderBy: string = 'latest',
    authorId: string = '',
    cityId: string = '',
    tag: string = '',
    likedBy: string = '',
    collectedBy: string = '',
    feedType: string = ''
  ): Promise<PaginatedPosts> {
    let query = `?page=${page}&limit=${limit}&orderBy=${orderBy}`;
    if (authorId) query += `&authorId=${authorId}`;
    if (cityId) query += `&cityId=${cityId}`;
    if (tag) query += `&tag=${tag}`;
    if (likedBy) query += `&likedBy=${likedBy}`;
    if (collectedBy) query += `&collectedBy=${collectedBy}`;
    if (feedType) query += `&feedType=${feedType}`;

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

  /**
   * 获取所有城市列表（探索页随机抽选用）或根据关键字搜索
   */
  async getCities(keyword: string = ''): Promise<ApiCity[]> {
    const query = keyword ? `?keyword=${keyword}` : '';
    return await this.get<ApiCity[]>(`/cities${query}`, true);
  }

  /**
   * 获取地图标记点数据
   */
  async getCityMarkers(): Promise<ApiCityMarker[]> {
    return await this.get<ApiCityMarker[]>('/cities/markers', true);
  }

  /**
   * 获取当前用户已点亮的城市
   */
  async getMyCities(): Promise<ApiCity[]> {
    return await this.get<ApiCity[]>('/cities/my', true);
  }

  /**
   * 获取城市详情
   */
  async getCityDetail(cityId: string): Promise<ApiCity> {
    return await this.get<ApiCity>(`/cities/${cityId}`, true);
  }

  /**
   * 签到打卡（点亮城市）
   */
  async checkInCity(cityId: string): Promise<MessageResult> {
    return await this.post<MessageResult>(`/cities/${cityId}/check-in`, undefined, true);
  }

  // ============================================================
  // Message 接口
  // ============================================================

  /**
   * 获取我的消息列表
   */
  async getMessages(type: string = '', page: number = 1): Promise<MessageListData> {
    let query = `?page=${page}`;
    if (type) query += `&type=${type}`;
    return await this.get<MessageListData>(`/messages${query}`, true);
  }

  /**
   * 获取消息分组概览
   */
  async getMessageGroups(): Promise<ApiMessageGroup[]> {
    return await this.get<ApiMessageGroup[]>('/messages/groups', true);
  }

  /**
   * 标记单条消息为已读
   */
  async markAsRead(messageId: string): Promise<MessageResult> {
    return await this.put<MessageResult>(`/messages/${messageId}/read`, undefined, true);
  }

  /**
   * 全部标记为已读
   */
  async markAllRead(type: string = ''): Promise<MarkReadResult> {
    const query = type ? `?type=${type}` : '';
    return await this.put<MarkReadResult>(`/messages/read-all${query}`, undefined, true);
  }

  // ============================================================
  // DriftBottle 接口
  // ============================================================

  /**
   * 投放漂流瓶
   */
  async createBottle(params: CreateBottleParams): Promise<ApiDriftBottle> {

    const body: Record<string, string> = {};
    body['content'] = params.content;
    body['type'] = params.type;

    if (params.cityId && params.cityId.length > 0) {
      body['cityId'] = params.cityId;
    }

    return await this.post<ApiDriftBottle>('/bottles', body, true);
  }
  /**
   * 随机捡一个瓶子
   */
  async pickBottle(): Promise<ApiDriftBottle> {
    return await this.post<ApiDriftBottle>('/bottles/pick', undefined, true);
  }

  /**
   * 获取我投放的瓶子
   */
  async getMySentBottles(): Promise<ApiDriftBottle[]> {
    return await this.get<ApiDriftBottle[]>('/bottles/sent', true);
  }

  /**
   * 获取我捡到的瓶子
   */
  async getMyPickedBottles(): Promise<ApiDriftBottle[]> {
    return await this.get<ApiDriftBottle[]>('/bottles/picked', true);
  }

  // ============================================================
  // TimeCapsule 接口
  // ============================================================

  /**
   * 创建时空胶囊
   */
  async createCapsule(params: CreateCapsuleParams): Promise<ApiTimeCapsule> {
    return await this.post<ApiTimeCapsule>('/capsules', params, true);
  }

  /**
   * 获取我的所有胶囊
   */
  async getMyCapsules(): Promise<ApiTimeCapsule[]> {
    return await this.get<ApiTimeCapsule[]>('/capsules', true);
  }

  /**
   * 删除胶囊
   */
  async deleteCapsule(capsuleId: string): Promise<MessageResult> {
    return await this.del<MessageResult>(`/capsules/${capsuleId}`, true);
  }

}

// 导出单例
export const ApiService = new ApiServiceClass();