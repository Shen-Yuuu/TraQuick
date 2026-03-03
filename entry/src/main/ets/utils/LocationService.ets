/**
 * 位置服务工具类 (LocationService)
 * 封装权限申请、GPS 定位获取和反向地理编码
 */
import { geoLocationManager } from '@kit.LocationKit';
import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';

export interface LocationInfo {
  latitude: number;
  longitude: number;
  cityName: string;
  address: string;
}

export class LocationService {
  /**
   * 检查并动态申请定位权限
   */
  public static async requestLocationPermission(context: common.UIAbilityContext): Promise<boolean> {
    const atManager = abilityAccessCtrl.createAtManager();
    const permissions: Permissions[] = [
      'ohos.permission.LOCATION',
      'ohos.permission.APPROXIMATELY_LOCATION'
    ];

    try {
      const authResults = await atManager.requestPermissionsFromUser(context, permissions);
      // 只要这两个权限有一个被允许 (0 表示 granted)，就认为有定位权限
      const isGranted = authResults.authResults.some(result => result === 0);
      return isGranted;
    } catch (err) {
      console.error('[LocationService] 申请定位权限失败:', err);
      return false;
    }
  }

  /**
   * 获取当前详细位置信息 (包含坐标和中文地址)
   */
  public static async getCurrentLocation(): Promise<LocationInfo> {
    try {
      // 1. 获取当前坐标
      const location = await geoLocationManager.getCurrentLocation({
        priority: geoLocationManager.LocationRequestPriority.FIRST_FIX,
        scenario: geoLocationManager.LocationRequestScenario.DAILY_LIFE_SERVICE,
        maxAccuracy: 0,
        timeoutMs: 5000 // 5秒超时
      });

      const lat = location.latitude;
      const lon = location.longitude;

      // 2. 初始化默认返回值
      const result: LocationInfo = {
        latitude: lat,
        longitude: lon,
        cityName: '探索中',
        address: '未知街区'
      };

      // 3. 反向地理编码 (将经纬度转换为文字地址)
      try {
        if (geoLocationManager.isGeocoderAvailable()) {
          const geoAddresses = await geoLocationManager.getAddressesFromLocation({
            latitude: lat,
            longitude: lon,
            maxItems: 1
          });

          if (geoAddresses && geoAddresses.length > 0) {
            const addr = geoAddresses[0];
            // 提取城市名，优先用 locality(市)
            result.cityName = addr.locality || addr.administrativeArea  || '未知城市';

            // 提取具体街道地址
            const poi = addr.placeName || addr.subLocality || addr.roadName || '';
            result.address = poi ? poi : addr.descriptions?.[0] || '未知街区';
          }
        }
      } catch (geoErr) {
        console.warn('[LocationService] 反向地理编码失败，使用坐标兜底:', geoErr);
      }

      return result;

    } catch (error) {
      console.error('[LocationService] 获取定位失败:', error);
      throw new Error('无法获取您的位置信息');
    }
  }
}