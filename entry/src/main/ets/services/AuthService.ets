/**
 * 认证服务
 */

import { httpClient, ApiResponse } from './ApiService';
import { User } from '../models/User';

interface LoginRequest {
  account: string;        // 手机号或邮箱
  password?: string;
  verifyCode?: string;
  loginType: 'password' | 'code' | 'huawei';
}

interface LoginResponse {
  token: string;
  user: User;
}

interface RegisterRequest {
  phone?: string;
  email?: string;
  password: string;
  verifyCode: string;
  nickname: string;
}

class AuthService {
  /**
   * 发送验证码
   */
  async sendVerifyCode(account: string, type: 'login' | 'register'): Promise<ApiResponse<boolean>> {
    return httpClient.post('/auth/send-code', { account, type });
  }

  /**
   * 账号密码登录
   */
  async loginWithPassword(account: string, password: string): Promise<ApiResponse<LoginResponse>> {
    const result = await httpClient.post<LoginResponse>('/auth/login', {
      account,
      password,
      loginType: 'password',
    });

    if (result.success && result.data.token) {
      httpClient.setToken(result.data.token);
      // TODO: 保存到本地存储
    }

    return result;
  }

  /**
   * 验证码登录
   */
  async loginWithCode(account: string, code: string): Promise<ApiResponse<LoginResponse>> {
    const result = await httpClient.post<LoginResponse>('/auth/login', {
      account,
      verifyCode: code,
      loginType: 'code',
    });

    if (result.success && result.data.token) {
      httpClient.setToken(result.data.token);
    }

    return result;
  }

  /**
   * 华为账号登录
   */
  async loginWithHuawei(huaweiToken: string): Promise<ApiResponse<LoginResponse>> {
    const result = await httpClient.post<LoginResponse>('/auth/login/huawei', {
      huaweiToken,
    });

    if (result.success && result.data.token) {
      httpClient.setToken(result.data.token);
    }

    return result;
  }

  /**
   * 注册
   */
  async register(data: RegisterRequest): Promise<ApiResponse<LoginResponse>> {
    const result = await httpClient.post<LoginResponse>('/auth/register', data);

    if (result.success && result.data.token) {
      httpClient.setToken(result.data.token);
    }

    return result;
  }

  /**
   * 退出登录
   */
  async logout(): Promise<void> {
    httpClient.clearToken();
    // TODO: 清除本地存储
  }

  /**
   * 获取当前用户信息
   */
  async getCurrentUser(): Promise<ApiResponse<User>> {
    return httpClient.get('/users/me');
  }

  /**
   * 检查登录状态
   */
  async checkLoginStatus(): Promise<boolean> {
    // TODO: 从本地存储读取 token，验证有效性
    return false;
  }
}

export const authService = new AuthService();
