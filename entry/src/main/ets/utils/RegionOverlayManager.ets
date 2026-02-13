/**
 * 区域覆盖物管理器 v2
 *
 * 交互流程：
 * 全国/全球视图 → 点击中国省份或其他国家 → 高亮
 * 再点中国省份 → 飞入显示市级边界
 * 再点其他国家 → 弹出气泡（无下钻）
 * 点击市 → 橙色高亮 + 气泡
 */
import { map, mapCommon } from '@kit.MapKit';
import { GeoJsonParser, RegionData, LatLng } from './GeoJsonParser';
import { common } from '@kit.AbilityKit';

// ==================== 交互状态 ====================

export enum InteractionState {
  IDLE = 'idle',
  PROVINCE_SELECTED = 'province_selected',   // 选中了中国省份或其他国家
  CITY_VIEW = 'city_view',                   // 飞入中国某省，显示市级（仅中国）
  CITY_SELECTED = 'city_selected'            // 选中了某市（仅中国）
}

// ==================== 回调类型 ====================

export interface RegionCallbacks {
  onProvinceSelected: (region: RegionData) => void;
  onCountrySelected: (region: RegionData) => void;
  onCitySelected: (region: RegionData) => void;
  onSelectionCleared: () => void;
}

// ==================== 管理器 ====================

export class RegionOverlayManager {
  private mapController: map.MapComponentController;
  private context: common.UIAbilityContext;

  // 当前状态
  private state: InteractionState = InteractionState.IDLE;

  // 数据缓存
  private provinceCache: RegionData[] = [];        // 中国省级
  private countryCache: RegionData[] = [];          // 全球国家（不含中国）
  private allTopLevel: RegionData[] = [];           // 省级 + 国家（合并，用于IDLE状态查找）
  private cityCache: Map<string, RegionData[]> = new Map();  // 市级缓存

  // 当前高亮的省份/国家
  private highlightedPolygons: map.MapPolygon[] = [];
  private highlightedRegion: RegionData | null = null;
  private highlightedIsChina: boolean = false;     // 当前高亮的是否是中国省份

  // 当前显示的市级边界
  private cityPolygons: map.MapPolygon[] = [];
  private cityRegions: RegionData[] = [];

  // 当前高亮的市
  private highlightedCityPolygons: map.MapPolygon[] = [];
  private highlightedCity: RegionData | null = null;

  // 当前飞入的省份 adcode
  private currentProvinceAdcode: string = '';

  // 回调
  private callbacks: RegionCallbacks | null = null;

  // 中国的adcode
  private readonly CHINA_ADCODE: string = '100000';
  private readonly CHINA_NAME: string = '中国';

  // 颜色
  private readonly COLOR_HIGHLIGHT_STROKE: number = 0xFF4488FF;
  private readonly COLOR_HIGHLIGHT_FILL: number = 0x334488FF;
  private readonly COLOR_CITY_BORDER_STROKE: number = 0xAA4488FF;
  private readonly COLOR_CITY_BORDER_FILL: number = 0x1A4488FF;
  private readonly COLOR_CITY_HIGHLIGHT_STROKE: number = 0xFFFFB400;
  private readonly COLOR_CITY_HIGHLIGHT_FILL: number = 0x55FFB400;
  private readonly COLOR_COUNTRY_HIGHLIGHT_STROKE: number = 0xFF4488FF;
  private readonly COLOR_COUNTRY_HIGHLIGHT_FILL: number = 0x334488FF;

  constructor(mapController: map.MapComponentController, context: common.UIAbilityContext) {
    this.mapController = mapController;
    this.context = context;
  }

  setCallbacks(callbacks: RegionCallbacks): void {
    this.callbacks = callbacks;
  }

  /**
   * 初始化：加载省级 + 全球国家数据
   */
  async init(): Promise<void> {
    console.info('[RegionOverlay] 🚀 初始化...');

    // 加载中国省级
    this.provinceCache = await GeoJsonParser.parseFromRawFile(this.context, 'geo/china_province.json');
    console.info(`[RegionOverlay] ✅ 中国省级: ${this.provinceCache.length} 个`);

    // 加载全球国家
    try {
      this.countryCache = await GeoJsonParser.parseFromRawFile(this.context, 'geo/world_countries.json');
      // 过滤掉中国（因为中国用省级数据）
      this.countryCache = this.countryCache.filter((c: RegionData) => {
        return c.name !== 'China' && c.name !== '中国' && c.name !== 'CN';
      });
      console.info(`[RegionOverlay] ✅ 全球国家: ${this.countryCache.length} 个`);
    } catch (e) {
      console.warn('[RegionOverlay] ⚠️ 全球国家数据加载失败，仅使用中国数据');
      this.countryCache = [];
    }

    // 合并：省级 + 国家
    this.allTopLevel = [...this.provinceCache, ...this.countryCache];
    console.info(`[RegionOverlay] ✅ 顶层区域总计: ${this.allTopLevel.length} 个`);
  }

  /**
   * 处理地图点击（核心状态机）
   */
  handleMapClick(latitude: number, longitude: number): void {
    console.info(`[RegionOverlay] 📍 点击 (${latitude.toFixed(4)}, ${longitude.toFixed(4)}) 状态: ${this.state}`);

    switch (this.state) {
      case InteractionState.IDLE:
        this.handleClickInIdle(latitude, longitude);
        break;
      case InteractionState.PROVINCE_SELECTED:
        this.handleClickInProvinceSelected(latitude, longitude);
        break;
      case InteractionState.CITY_VIEW:
        this.handleClickInCityView(latitude, longitude);
        break;
      case InteractionState.CITY_SELECTED:
        this.handleClickInCitySelected(latitude, longitude);
        break;
    }
  }

  /**
   * 缩放变化
   */
  onZoomChanged(zoom: number): void {
    if (zoom < 5 && this.state !== InteractionState.IDLE && this.state !== InteractionState.PROVINCE_SELECTED) {
      console.info('[RegionOverlay] 🔙 缩小到全局视图，重置状态');
      this.resetToIdle();
    }
  }

  getState(): InteractionState {
    return this.state;
  }

  // ==================== 状态处理 ====================

  /**
   * 判断一个区域是否是中国省份
   */
  private isChinaProvince(region: RegionData): boolean {
    return region.parent === this.CHINA_ADCODE || region.level === 'province';
  }

  /**
   * IDLE：点击 → 找省份/国家 → 高亮
   */
  private handleClickInIdle(lat: number, lng: number): void {
    const region = this.findRegionByPoint(lat, lng, this.allTopLevel);

    if (region) {
      const isChina = this.isChinaProvince(region);
      console.info(`[RegionOverlay] 🎯 选中: ${region.name} (${isChina ? '中国省份' : '国家'})`);

      this.highlightRegion(region, isChina);
      this.state = InteractionState.PROVINCE_SELECTED;

      if (this.callbacks) {
        if (isChina) {
          this.callbacks.onProvinceSelected(region);
        } else {
          this.callbacks.onCountrySelected(region);
        }
      }
    }
  }

  /**
   * PROVINCE_SELECTED：
   * - 再次点击中国省份 → 飞入显示市级
   * - 再次点击其他国家 → 弹气泡（已在回调中处理）
   * - 点击其他区域 → 切换高亮
   * - 点击空白 → 取消
   */
  private handleClickInProvinceSelected(lat: number, lng: number): void {
    const region = this.findRegionByPoint(lat, lng, this.allTopLevel);

    if (!region) {
      this.resetToIdle();
      return;
    }

    const isChina = this.isChinaProvince(region);

    if (this.highlightedRegion && region.adcode === this.highlightedRegion.adcode) {
      // 再次点击同一区域
      if (isChina) {
        // 中国省份 → 飞入 + 加载市级
        console.info(`[RegionOverlay] ✈️ 飞入省份: ${region.name}`);
        this.flyToProvinceAndShowCities(region);
      } else {
        // 其他国家 → 飞入居中放大 + 弹气泡（不加载下级）
        console.info(`[RegionOverlay] ✈️ 飞入国家: ${region.name}`);
        this.flyToCountry(region);
      }
    } else {
      // 切换到其他区域
      console.info(`[RegionOverlay] 🔄 切换到: ${region.name}`);
      this.clearHighlight();
      this.highlightRegion(region, isChina);

      if (this.callbacks) {
        if (isChina) {
          this.callbacks.onProvinceSelected(region);
        } else {
          this.callbacks.onCountrySelected(region);
        }
      }
    }
  }

  /**
   * CITY_VIEW：
   * - 点击市 → 高亮
   * - 点击其他省/国家 → 切换
   */
  private handleClickInCityView(lat: number, lng: number): void {
    const city = this.findRegionByPoint(lat, lng, this.cityRegions);

    if (city) {
      console.info(`[RegionOverlay] 🏙️ 选中城市: ${city.name}`);
      this.highlightCity(city);
      this.state = InteractionState.CITY_SELECTED;

      if (this.callbacks) {
        this.callbacks.onCitySelected(city);
      }
      return;
    }

    // 没命中市 → 检查是否点了其他省/国家
    const region = this.findRegionByPoint(lat, lng, this.allTopLevel);

    if (region && region.adcode !== this.currentProvinceAdcode) {
      const isChina = this.isChinaProvince(region);
      console.info(`[RegionOverlay] 🔄 从市级视图切换到: ${region.name}`);
      this.clearCityHighlight();
      this.clearCityPolygons();
      this.cityRegions = [];
      this.currentProvinceAdcode = '';
      this.highlightRegion(region, isChina);
      this.state = InteractionState.PROVINCE_SELECTED;

      if (this.callbacks) {
        this.callbacks.onSelectionCleared();
        if (isChina) {
          this.callbacks.onProvinceSelected(region);
        } else {
          this.callbacks.onCountrySelected(region);
        }
      }
    }
  }

  /**
   * CITY_SELECTED：
   * - 点击其他市 → 切换
   * - 点击其他省/国家 → 切换
   * - 点击空白 → 取消市高亮
   */
  private handleClickInCitySelected(lat: number, lng: number): void {
    const city = this.findRegionByPoint(lat, lng, this.cityRegions);

    if (city) {
      if (this.highlightedCity && city.adcode === this.highlightedCity.adcode) {
        return;
      }
      console.info(`[RegionOverlay] 🔄 切换到城市: ${city.name}`);
      this.clearCityHighlight();
      this.highlightCity(city);

      if (this.callbacks) {
        this.callbacks.onCitySelected(city);
      }
      return;
    }

    const region = this.findRegionByPoint(lat, lng, this.allTopLevel);

    if (region && region.adcode !== this.currentProvinceAdcode) {
      const isChina = this.isChinaProvince(region);
      console.info(`[RegionOverlay] 🔄 从城市视图切换到: ${region.name}`);
      this.clearCityHighlight();
      this.clearCityPolygons();
      this.cityRegions = [];
      this.currentProvinceAdcode = '';
      this.highlightRegion(region, isChina);
      this.state = InteractionState.PROVINCE_SELECTED;

      if (this.callbacks) {
        this.callbacks.onSelectionCleared();
        if (isChina) {
          this.callbacks.onProvinceSelected(region);
        } else {
          this.callbacks.onCountrySelected(region);
        }
      }
    } else if (!region) {
      console.info('[RegionOverlay] 取消城市选中');
      this.clearCityHighlight();
      this.state = InteractionState.CITY_VIEW;

      if (this.callbacks) {
        this.callbacks.onSelectionCleared();
      }
    }
  }

  // ==================== 绘制方法 ====================

  private async highlightRegion(region: RegionData, isChina: boolean): Promise<void> {
    this.highlightedRegion = region;
    this.highlightedIsChina = isChina;

    const strokeColor = isChina ? this.COLOR_HIGHLIGHT_STROKE : this.COLOR_COUNTRY_HIGHLIGHT_STROKE;
    const fillColor = isChina ? this.COLOR_HIGHLIGHT_FILL : this.COLOR_COUNTRY_HIGHLIGHT_FILL;
    const strokeWidth = isChina ? 3 : 4.5;

    this.highlightedPolygons = await this.drawRegionPolygons(region, strokeColor, fillColor, strokeWidth);
  }

  private clearHighlight(): void {
    this.removePolygons(this.highlightedPolygons);
    this.highlightedPolygons = [];
    this.highlightedRegion = null;
    this.highlightedIsChina = false;
  }

  private async flyToProvinceAndShowCities(province: RegionData): Promise<void> {
    this.clearHighlight();

    const targetZoom = 7;
    try {
      const cameraUpdate = map.newCameraPosition({
        target: {
          latitude: province.center[1],
          longitude: province.center[0]
        },
        zoom: targetZoom
      });
      this.mapController.animateCamera(cameraUpdate, 800);
    } catch (e) {
      console.error('[RegionOverlay] ❌ 相机动画失败', e);
      try {
        this.mapController.moveCamera(map.newCameraPosition({
          target: {
            latitude: province.center[1],
            longitude: province.center[0]
          },
          zoom: targetZoom
        }));
      } catch (e2) {
        console.error('[RegionOverlay] ❌ 相机移动也失败', e2);
      }
    }

    this.currentProvinceAdcode = province.adcode;
    let cities = this.cityCache.get(province.adcode);

    if (!cities) {
      console.info(`[RegionOverlay] 🌐 加载 ${province.name} 市级数据...`);
      cities = await GeoJsonParser.parseFromNetwork(province.adcode);
      if (cities.length > 0) {
        this.cityCache.set(province.adcode, cities);
      }
    }

    if (cities && cities.length > 0) {
      this.cityRegions = cities;
      await this.drawCityBorders(cities);
      this.state = InteractionState.CITY_VIEW;
      console.info(`[RegionOverlay] ✅ 显示 ${cities.length} 个市级边界`);
    }
  }

  /**
   * 飞入国家：居中放大 + 弹气泡（不加载下级边界）
   */
  private async flyToCountry(country: RegionData): Promise<void> {
    const box = country.boundingBox;
    const latSpan = box.maxLat - box.minLat;
    const lngSpan = box.maxLng - box.minLng;
    const maxSpan = Math.max(latSpan, lngSpan);

    // 缩放级别调小，不需要放太大
    let targetZoom = 4;
    if (maxSpan > 20) {
      targetZoom = 5;
    } else {
      targetZoom = 6;
    }

    try {
      const cameraUpdate = map.newCameraPosition({
        target: {
          latitude: country.center[1],
          longitude: country.center[0]
        },
        zoom: targetZoom
      });
      this.mapController.animateCamera(cameraUpdate, 800);
    } catch (e) {
      console.error('[RegionOverlay] ❌ 相机动画失败', e);
      try {
        this.mapController.moveCamera(map.newCameraPosition({
          target: {
            latitude: country.center[1],
            longitude: country.center[0]
          },
          zoom: targetZoom
        }));
      } catch (e2) {
        console.error('[RegionOverlay] ❌ 相机移动也失败', e2);
      }
    }

    if (this.callbacks) {
      this.callbacks.onCountrySelected(country);
    }
  }

  private async drawCityBorders(cities: RegionData[]): Promise<void> {
    this.clearCityPolygons();

    for (let i = 0; i < cities.length; i++) {
      const polygons = await this.drawRegionPolygons(
        cities[i],
        this.COLOR_CITY_BORDER_STROKE,
        this.COLOR_CITY_BORDER_FILL,
        2
      );
      for (let j = 0; j < polygons.length; j++) {
        this.cityPolygons.push(polygons[j]);
      }
    }
  }

  private async highlightCity(city: RegionData): Promise<void> {
    this.highlightedCity = city;
    this.highlightedCityPolygons = await this.drawRegionPolygons(
      city,
      this.COLOR_CITY_HIGHLIGHT_STROKE,
      this.COLOR_CITY_HIGHLIGHT_FILL,
      4
    );
  }

  private clearCityHighlight(): void {
    this.removePolygons(this.highlightedCityPolygons);
    this.highlightedCityPolygons = [];
    this.highlightedCity = null;
  }

  private clearCityPolygons(): void {
    this.removePolygons(this.cityPolygons);
    this.cityPolygons = [];
  }

  private resetToIdle(): void {
    this.clearCityHighlight();
    this.clearCityPolygons();
    this.clearHighlight();
    this.cityRegions = [];
    this.currentProvinceAdcode = '';
    this.state = InteractionState.IDLE;

    if (this.callbacks) {
      this.callbacks.onSelectionCleared();
    }
    console.info('[RegionOverlay] 🔄 重置到IDLE状态');
  }

  // ==================== 底层工具 ====================

  private async drawRegionPolygons(
    region: RegionData,
    strokeColor: number,
    fillColor: number,
    strokeWidth: number
  ): Promise<map.MapPolygon[]> {

    const polygons: map.MapPolygon[] = [];

    for (let j = 0; j < region.boundaries.length; j++) {
      const boundary = region.boundaries[j];
      if (boundary.length < 3) continue;

      const points: mapCommon.LatLng[] = [];
      for (let k = 0; k < boundary.length; k++) {
        points.push({
          latitude: boundary[k].latitude,
          longitude: boundary[k].longitude
        });
      }

      try {
        const polygonOptions: mapCommon.MapPolygonOptions = {
          points: points,
          clickable: false,
          strokeColor: strokeColor,
          fillColor: fillColor,
          strokeWidth: strokeWidth
        };

        const polygon: map.MapPolygon = await this.mapController.addPolygon(polygonOptions);
        polygons.push(polygon);
      } catch (error) {
        console.error(`[RegionOverlay] ❌ 绘制Polygon失败: ${region.name}`, error);
      }
    }

    return polygons;
  }

  private removePolygons(polygons: map.MapPolygon[]): void {
    for (let i = 0; i < polygons.length; i++) {
      try {
        polygons[i].remove();
      } catch (e) {
        // 忽略
      }
    }
  }

  private findRegionByPoint(lat: number, lng: number, regions: RegionData[]): RegionData | null {
    for (let i = 0; i < regions.length; i++) {
      const region = regions[i];
      const box = region.boundingBox;

      if (lat < box.minLat || lat > box.maxLat || lng < box.minLng || lng > box.maxLng) {
        continue;
      }

      for (let j = 0; j < region.boundaries.length; j++) {
        if (this.isPointInPolygon(lat, lng, region.boundaries[j])) {
          return region;
        }
      }
    }
    return null;
  }

  private isPointInPolygon(lat: number, lng: number, polygon: LatLng[]): boolean {
    let inside = false;
    const n = polygon.length;
    let j = n - 1;

    for (let i = 0; i < n; i++) {
      const yi = polygon[i].latitude;
      const xi = polygon[i].longitude;
      const yj = polygon[j].latitude;
      const xj = polygon[j].longitude;

      if (((yi > lat) !== (yj > lat)) &&
        (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }
    return inside;
  }
}