/**
 * API 服务基础配置
 */

import { User } from '../models/User';

// API 基础地址 - 开发环境
const BASE_URL = 'http://localhost:3000/api';

// 请求超时时间
const TIMEOUT = 30000;

/**
 * HTTP 请求封装
 */
class HttpClient {
  private token: string = '';

  setToken(token: string) {
    this.token = token;
  }

  clearToken() {
    this.token = '';
  }

  private getHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    return headers;
  }

  async get<T>(endpoint: string, params?: Record<string, string>): Promise<ApiResponse<T>> {
    let url = `${BASE_URL}${endpoint}`;
    if (params) {
      const queryString = Object.entries(params)
        .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(value)}`)
        .join('&');
      url += `?${queryString}`;
    }

    try {
      // TODO: 使用 HarmonyOS @ohos.net.http 模块
      // 这里先返回模拟数据结果
      return {
        success: true,
        data: {} as T,
        message: 'Success',
      };
    } catch (error) {
      return {
        success: false,
        data: {} as T,
        message: String(error),
      };
    }
  }

  async post<T>(endpoint: string, data?: object): Promise<ApiResponse<T>> {
    try {
      // TODO: 实现实际的 HTTP POST 请求
      return {
        success: true,
        data: {} as T,
        message: 'Success',
      };
    } catch (error) {
      return {
        success: false,
        data: {} as T,
        message: String(error),
      };
    }
  }

  async put<T>(endpoint: string, data?: object): Promise<ApiResponse<T>> {
    try {
      // TODO: 实现实际的 HTTP PUT 请求
      return {
        success: true,
        data: {} as T,
        message: 'Success',
      };
    } catch (error) {
      return {
        success: false,
        data: {} as T,
        message: String(error),
      };
    }
  }

  async delete<T>(endpoint: string): Promise<ApiResponse<T>> {
    try {
      // TODO: 实现实际的 HTTP DELETE 请求
      return {
        success: true,
        data: {} as T,
        message: 'Success',
      };
    } catch (error) {
      return {
        success: false,
        data: {} as T,
        message: String(error),
      };
    }
  }
}

// API 响应结构
export interface ApiResponse<T> {
  success: boolean;
  data: T;
  message: string;
  code?: number;
}

// 分页响应
export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  pageSize: number;
  hasMore: boolean;
}

// 导出单例
export const httpClient = new HttpClient();
