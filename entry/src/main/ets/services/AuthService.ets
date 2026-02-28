/**
 * 认证服务 - 基于 ApiService 单例
 * 提供登录、注册、登出、登录状态检查等高层认证逻辑
 */

import { ApiService, ApiUser, LoginParams, RegisterParams } from './ApiService';
import { storage, StorageKeys } from '../utils/Storage';

/**
 * 登录结果
 */
export interface AuthResult {
  success: boolean;
  message: string;
  user?: ApiUser;
}

class AuthServiceClass {
  /**
   * 账号密码登录
   */
  async loginWithPassword(email: string, password: string): Promise<AuthResult> {
    try {
      const params = new LoginParams();
      params.email = email;
      params.password = password;

      const loginData = await ApiService.login(params);

      // 保存到 AppStorage（供 UI 即时响应）
      AppStorage.setOrCreate('userToken', loginData.accessToken);
      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('currentUserId', loginData.user.id);
      AppStorage.setOrCreate('currentUserNickname', loginData.user.nickname);
      AppStorage.setOrCreate('currentUserAvatar', loginData.user.avatar);

      // 持久化到本地存储
      await storage.setString(StorageKeys.TOKEN, loginData.accessToken);
      await storage.setObject(StorageKeys.USER_INFO, loginData.user);
      await storage.setBoolean(StorageKeys.IS_LOGGED_IN, true);

      return { success: true, message: '登录成功', user: loginData.user };
    } catch (error) {
      const err = error as Error;
      console.error('[AuthService] 登录失败:', err.message);
      return { success: false, message: err.message || '登录失败，请重试' };
    }
  }

  /**
   * 注册新用户
   */
  async register(email: string, password: string, nickname: string): Promise<AuthResult> {
    try {
      const params = new RegisterParams();
      params.email = email;
      params.password = password;
      params.nickname = nickname;

      const registerData = await ApiService.register(params);

      // 注册成功后自动登录
      AppStorage.setOrCreate('userToken', registerData.accessToken);
      AppStorage.setOrCreate('isLoggedIn', true);
      AppStorage.setOrCreate('currentUserId', registerData.user.id);
      AppStorage.setOrCreate('currentUserNickname', registerData.user.nickname);
      AppStorage.setOrCreate('currentUserAvatar', registerData.user.avatar);

      await storage.setString(StorageKeys.TOKEN, registerData.accessToken);
      await storage.setObject(StorageKeys.USER_INFO, registerData.user);
      await storage.setBoolean(StorageKeys.IS_LOGGED_IN, true);

      return { success: true, message: '注册成功', user: registerData.user };
    } catch (error) {
      const err = error as Error;
      console.error('[AuthService] 注册失败:', err.message);
      return { success: false, message: err.message || '注册失败，请重试' };
    }
  }

  /**
   * 退出登录 - 清除所有本地状态
   */
  async logout(): Promise<void> {
    try {
      // 清除 AppStorage
      AppStorage.delete('userToken');
      AppStorage.delete('isLoggedIn');
      AppStorage.delete('currentUserId');
      AppStorage.delete('currentUserNickname');
      AppStorage.delete('currentUserAvatar');

      // 清除持久化存储
      await storage.remove(StorageKeys.TOKEN);
      await storage.remove(StorageKeys.USER_INFO);
      await storage.remove(StorageKeys.IS_LOGGED_IN);
    } catch (error) {
      console.error('[AuthService] 退出登录异常:', error);
    }
  }

  /**
   * 获取当前用户信息
   */
  async getCurrentUser(): Promise<ApiUser | null> {
    try {
      return await ApiService.getProfile();
    } catch (error) {
      console.error('[AuthService] 获取用户信息失败:', error);
      return null;
    }
  }

  /**
   * 检查登录状态 - 从本地存储恢复 Session
   * 应在 App 启动时调用
   */
  async checkAndRestoreSession(): Promise<boolean> {
    try {
      const token = await storage.getString(StorageKeys.TOKEN);
      const isLoggedIn = await storage.getBoolean(StorageKeys.IS_LOGGED_IN, false);

      if (!token || !isLoggedIn) {
        return false;
      }

      // 恢复 AppStorage
      AppStorage.setOrCreate('userToken', token);
      AppStorage.setOrCreate('isLoggedIn', true);

      // 尝试用 token 拉取最新用户信息验证有效性
      const user = await this.getCurrentUser();
      if (user) {
        AppStorage.setOrCreate('currentUserId', user.id);
        AppStorage.setOrCreate('currentUserNickname', user.nickname);
        AppStorage.setOrCreate('currentUserAvatar', user.avatar);
        return true;
      } else {
        // token 已失效，清除登录态
        await this.logout();
        return false;
      }
    } catch (error) {
      console.error('[AuthService] 恢复会话失败:', error);
      await this.logout();
      return false;
    }
    }
}

export const authService = new AuthServiceClass();
