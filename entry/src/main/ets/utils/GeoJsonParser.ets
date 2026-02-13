/**
 * GeoJSON 解析工具类
 * 支持本地rawfile和网络在线加载
 */
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { http } from '@kit.NetworkKit';

// ==================== 数据结构定义 ====================

export interface RegionData {
  adcode: string;
  name: string;
  center: number[];
  level: string;
  parent: string;
  boundaries: LatLng[][];
  boundingBox: BoundingBox;
}

export interface LatLng {
  latitude: number;
  longitude: number;
}

export interface BoundingBox {
  minLat: number;
  maxLat: number;
  minLng: number;
  maxLng: number;
}

// ==================== GeoJSON 原始类型 ====================

interface GeoJsonFeatureCollection {
  type: string;
  features: GeoJsonFeature[];
}

interface GeoJsonFeature {
  type: string;
  properties: GeoJsonProperties;
  geometry: GeoJsonGeometry;
}

interface GeoJsonProperties {
  adcode: number | null;
  name: string;
  center: number[] | null;
  centroid: number[] | null;
  level: string | null;
  parent: GeoJsonParent | null;
  childrenNum: number | null;
  subFeatureIndex: number | null;
  acroutes: number[] | null;
}

interface GeoJsonParent {
  adcode: number;
}

interface GeoJsonGeometry {
  type: string;
  coordinates: number[][][] | number[][][][];
}

// ==================== 解析器 ====================

export class GeoJsonParser {

  /**
   * 从 rawfile 读取并解析 GeoJSON（本地文件）
   */
  static async parseFromRawFile(context: common.UIAbilityContext, filePath: string): Promise<RegionData[]> {
    try {
      const resourceManager = context.resourceManager;
      const fileData: Uint8Array = await resourceManager.getRawFileContent(filePath);

      console.info(`[GeoJsonParser] 📁 文件大小: ${fileData.length} 字节`);

      const textDecoder = util.TextDecoder.create('utf-8');
      const jsonString = textDecoder.decodeWithStream(fileData);

      return GeoJsonParser.parseJsonString(jsonString, filePath);

    } catch (error) {
      console.error(`[GeoJsonParser] ❌ 本地解析失败: ${filePath}`, JSON.stringify(error));
      return [];
    }
  }

  /**
   * 从网络加载并解析 GeoJSON（动态加载下级区域）
   * @param adcode 行政区划代码，如 "440000"（广东省）
   */
  static async parseFromNetwork(adcode: string): Promise<RegionData[]> {
    const url = `https://geo.datav.aliyun.com/areas_v3/bound/${adcode}_full.json`;

    try {
      console.info(`[GeoJsonParser] 🌐 请求: ${url}`);

      const httpRequest = http.createHttp();
      const response = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        connectTimeout: 10000,
        readTimeout: 15000
      });

      if (response.responseCode !== 200) {
        console.error(`[GeoJsonParser] ❌ HTTP ${response.responseCode}`);
        httpRequest.destroy();
        return [];
      }

      const jsonString = response.result as string;
      httpRequest.destroy();

      return GeoJsonParser.parseJsonString(jsonString, adcode);

    } catch (error) {
      console.error(`[GeoJsonParser] ❌ 网络请求失败: ${adcode}`, JSON.stringify(error));
      return [];
    }
  }

  /**
   * 解析 JSON 字符串为 RegionData 数组（共用逻辑）
   */
  private static parseJsonString(jsonString: string, source: string): RegionData[] {
    const geoJson: GeoJsonFeatureCollection = JSON.parse(jsonString) as GeoJsonFeatureCollection;

    console.info(`[GeoJsonParser] 📊 ${source} features数量: ${geoJson.features ? geoJson.features.length : 0}`);

    const regions: RegionData[] = [];
    for (let i = 0; i < geoJson.features.length; i++) {
      const region = GeoJsonParser.parseFeature(geoJson.features[i]);
      if (region !== null) {
        regions.push(region);
      }
    }

    console.info(`[GeoJsonParser] ✅ 解析完成: ${source}, 共 ${regions.length} 个区域`);
    return regions;
  }

  private static parseFeature(feature: GeoJsonFeature): RegionData | null {
    try {
      const props = feature.properties;
      const geometry = feature.geometry;

      const boundaries: LatLng[][] = GeoJsonParser.parseGeometry(geometry);

      if (boundaries.length === 0) {
        return null;
      }

      const boundingBox = GeoJsonParser.calculateBoundingBox(boundaries);

      // 兼容不同数据源的字段
      const adcode = (props.adcode !== null && props.adcode !== undefined)
        ? props.adcode.toString()
        : (props.name || '');

      const center = props.center || props.centroid || GeoJsonParser.calculateCenter(boundaries);

      const region: RegionData = {
        adcode: adcode,
        name: props.name || '',
        center: center,
        level: props.level || 'country',
        parent: (props.parent !== null && props.parent !== undefined &&
          props.parent.adcode !== null && props.parent.adcode !== undefined)
          ? props.parent.adcode.toString() : '',
        boundaries: boundaries,
        boundingBox: boundingBox
      };

      return region;

    } catch (error) {
      console.error(`[GeoJsonParser] 解析Feature失败`, error);
      return null;
    }
  }

  /**
   * 根据边界计算中心点
   */
  private static calculateCenter(boundaries: LatLng[][]): number[] {
    let totalLat = 0;
    let totalLng = 0;
    let count = 0;

    for (let i = 0; i < boundaries.length; i++) {
      for (let j = 0; j < boundaries[i].length; j++) {
        totalLng += boundaries[i][j].longitude;
        totalLat += boundaries[i][j].latitude;
        count++;
      }
    }

    if (count === 0) return [0, 0];
    return [totalLng / count, totalLat / count];  // [经度, 纬度]
  }

  private static parseGeometry(geometry: GeoJsonGeometry): LatLng[][] {
    const result: LatLng[][] = [];

    if (geometry.type === 'Polygon') {
      const coords = geometry.coordinates as number[][][];
      for (let ring = 0; ring < coords.length; ring++) {
        const points: LatLng[] = [];
        for (let i = 0; i < coords[ring].length; i++) {
          points.push({
            longitude: coords[ring][i][0],
            latitude: coords[ring][i][1]
          });
        }
        result.push(points);
      }

    } else if (geometry.type === 'MultiPolygon') {
      const multiCoords = geometry.coordinates as number[][][][];
      for (let p = 0; p < multiCoords.length; p++) {
        for (let ring = 0; ring < multiCoords[p].length; ring++) {
          const points: LatLng[] = [];
          for (let i = 0; i < multiCoords[p][ring].length; i++) {
            points.push({
              longitude: multiCoords[p][ring][i][0],
              latitude: multiCoords[p][ring][i][1]
            });
          }
          result.push(points);
        }
      }
    }

    return result;
  }

  private static calculateBoundingBox(boundaries: LatLng[][]): BoundingBox {
    let minLat = 90;
    let maxLat = -90;
    let minLng = 180;
    let maxLng = -180;

    for (let i = 0; i < boundaries.length; i++) {
      for (let j = 0; j < boundaries[i].length; j++) {
        const point = boundaries[i][j];
        if (point.latitude < minLat) minLat = point.latitude;
        if (point.latitude > maxLat) maxLat = point.latitude;
        if (point.longitude < minLng) minLng = point.longitude;
        if (point.longitude > maxLng) maxLng = point.longitude;
      }
    }

    return { minLat, maxLat, minLng, maxLng };
  }
}