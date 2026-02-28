/**
 * 本地存储工具
 */

import preferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

const PREFERENCES_NAME = 'TraQuickPreferences';

class StorageUtil {
  private preferences: preferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  /**
   * 初始化存储
   */
  async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    try {
      this.preferences = await preferences.getPreferences(context, PREFERENCES_NAME);
    } catch (error) {
      console.error('StorageUtil init error:', error);
    }
  }

  /**
   * 存储字符串
   */
  async setString(key: string, value: string): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(key, value);
      await this.preferences.flush();
    } catch (error) {
      console.error('StorageUtil setString error:', error);
    }
  }

  /**
   * 获取字符串
   */
  async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (!this.preferences) return defaultValue;
    try {
      const value = await this.preferences.get(key, defaultValue);
      return value as string;
    } catch (error) {
      console.error('StorageUtil getString error:', error);
      return defaultValue;
    }
  }

  /**
   * 存储对象
   */
  async setObject<T>(key: string, value: T): Promise<void> {
    await this.setString(key, JSON.stringify(value));
  }

  /**
   * 获取对象
   */
  async getObject<T>(key: string): Promise<T | null> {
    const str = await this.getString(key);
    if (!str) return null;
    try {
      return JSON.parse(str) as T;
    } catch {
      return null;
    }
  }

  /**
   * 存储布尔值
   */
  async setBoolean(key: string, value: boolean): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.put(key, value);
      await this.preferences.flush();
    } catch (error) {
      console.error('StorageUtil setBoolean error:', error);
    }
  }

  /**
   * 获取布尔值
   */
  async getBoolean(key: string, defaultValue: boolean = false): Promise<boolean> {
    if (!this.preferences) return defaultValue;
    try {
      const value = await this.preferences.get(key, defaultValue);
      return value as boolean;
    } catch (error) {
      console.error('StorageUtil getBoolean error:', error);
      return defaultValue;
    }
  }

  /**
   * 删除指定key
   */
  async remove(key: string): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.delete(key);
      await this.preferences.flush();
    } catch (error) {
      console.error('StorageUtil remove error:', error);
    }
  }

  /**
   * 清空所有数量
   */
  async clear(): Promise<void> {
    if (!this.preferences) return;
    try {
      await this.preferences.clear();
      await this.preferences.flush();
    } catch (error) {
      console.error('StorageUtil clear error:', error);
    }
  }
}

// 存储 Key 常量
interface StorageKeysType {
  TOKEN: string;
  USER_INFO: string;
  IS_LOGGED_IN: string;
  FIRST_LAUNCH: string;
  THEME_MODE: string;
}

export const StorageKeys: StorageKeysType = {
  TOKEN: 'user_token',
  USER_INFO: 'user_info',
  IS_LOGGED_IN: 'is_logged_in',
  FIRST_LAUNCH: 'first_launch',
  THEME_MODE: 'theme_mode',
};

export const storage = new StorageUtil();
