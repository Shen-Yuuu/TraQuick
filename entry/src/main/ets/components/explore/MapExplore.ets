/**
 * 地图探索组件 - 使用华为 Map Kit
 */

import { map, mapCommon, site, MapComponent } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';

// 热门城市坐标
interface CityLocation {
  name: string;
  emoji: string;
  latitude: number;
  longitude: number;
  count: number;
}

@Component
export struct MapExplore {
  // 地图控制器
  private mapController?: map.MapComponentController;
  // 地图回调
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  // 地图选项
  private mapOptions?: mapCommon.MapOptions;

  @State isMapReady: boolean = false;
  @State currentZoom: number = 3;
  @State selectedCity: CityLocation | null = null;

  // 热门城市位置
  private hotCities: CityLocation[] = [
    { name: '巴黎', emoji: '🗼', latitude: 48.8566, longitude: 2.3522, count: 12580 },
    { name: '纽约', emoji: '🗽', latitude: 40.7128, longitude: -74.0060, count: 10234 },
    { name: '东京', emoji: '🏯', latitude: 35.6762, longitude: 139.6503, count: 9876 },
    { name: '成都', emoji: '🐼', latitude: 30.5728, longitude: 104.0668, count: 8654 },
    { name: '伦敦', emoji: '🎡', latitude: 51.5074, longitude: -0.1278, count: 7832 },
    { name: '悉尼', emoji: '🦘', latitude: -33.8688, longitude: 151.2093, count: 6543 },
    { name: '迪拜', emoji: '🏜️', latitude: 25.2048, longitude: 55.2708, count: 5432 },
    { name: '新加坡', emoji: '🦁', latitude: 1.3521, longitude: 103.8198, count: 4321 },
  ];

  aboutToAppear(): void {
    // 初始化地图选项 - 以中国为中心的世界视角
    this.mapOptions = {
      position: {
        target: {
          latitude: 30.0,
          longitude: 110.0
        },
        zoom: this.currentZoom
      },
      mapType: mapCommon.MapType.STANDARD,
      myLocationControlsEnabled: false,
      compassControlsEnabled: false,
      zoomControlsEnabled: false,
      scaleControlsEnabled: false
    };

    // 地图回调
    this.mapCallback = async (err, controller) => {
      if (!err) {
        this.mapController = controller;
        this.isMapReady = true;
        // 添加城市标记
        this.addCityMarkers();
      }
    };
  }

  // 添加城市标记点
  private async addCityMarkers(): Promise<void> {
    if (!this.mapController) return;

    for (const city of this.hotCities) {
      try {
        const markerOptions: mapCommon.MarkerOptions = {
          position: {
            latitude: city.latitude,
            longitude: city.longitude
          },
          title: city.name,
          snippet: `${city.emoji} ${(city.count / 1000).toFixed(1)}k 人打卡`,
          clickable: true
        };

        const marker = await this.mapController.addMarker(markerOptions);
        if (marker) {
          marker.setClickable(true);
        }
      } catch (e) {
        console.error(`添加标记失败: ${city.name}`, e);
      }
    }

    // 监听标记点击
    this.mapController.on('markerClick', (marker) => {
      const position = marker.getPosition();
      const city = this.hotCities.find(c => 
        Math.abs(c.latitude - position.latitude) < 0.01 && 
        Math.abs(c.longitude - position.longitude) < 0.01
      );
      if (city) {
        this.selectedCity = city;
      }
      return true;
    });

    // 监听地图点击关闭选中
    this.mapController.on('mapClick', () => {
      this.selectedCity = null;
    });
  }

  // 飞到指定城市
  flyToCity(city: CityLocation): void {
    if (!this.mapController) return;

    const cameraUpdate = map.newCameraPosition({
      target: {
        latitude: city.latitude,
        longitude: city.longitude
      },
      zoom: 10
    });

    this.mapController.animateCamera(cameraUpdate, 1000);
    this.selectedCity = city;
  }

  // 缩放控制
  zoomIn(): void {
    if (!this.mapController || this.currentZoom >= 20) return;
    this.currentZoom += 1;
    const cameraUpdate = map.newCameraPosition({
      target: { latitude: 30.0, longitude: 110.0 },
      zoom: this.currentZoom
    });
    this.mapController.animateCamera(cameraUpdate, 300);
  }

  zoomOut(): void {
    if (!this.mapController || this.currentZoom <= 1) return;
    this.currentZoom -= 1;
    const cameraUpdate = map.newCameraPosition({
      target: { latitude: 30.0, longitude: 110.0 },
      zoom: this.currentZoom
    });
    this.mapController.animateCamera(cameraUpdate, 300);
  }

  // 重置视图
  resetView(): void {
    if (!this.mapController) return;
    const cameraUpdate = map.newCameraPosition({
      target: { latitude: 30.0, longitude: 110.0 },
      zoom: 3
    });
    this.mapController.animateCamera(cameraUpdate, 800);
    this.currentZoom = 3;
    this.selectedCity = null;
  }

  build() {
    Stack() {
      // 华为地图组件
      if (this.mapOptions) {
        MapComponent({
          mapOptions: this.mapOptions,
          mapCallback: this.mapCallback
        })
          .width('100%')
          .height('100%')
      }

      // 地图加载中提示
      if (!this.isMapReady) {
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color(Colors.primary)
          Text('地图加载中...')
            .fontSize(FontSizes.body)
            .fontColor(Colors.textSecondary)
            .margin({ top: 12 })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .backgroundColor('rgba(255,255,255,0.9)')
      }

      // 缩放控制按钮
      Column() {
        this.ZoomButton('+', () => this.zoomIn())
        Divider().width(36).color('#E5E5E5')
        this.ZoomButton('-', () => this.zoomOut())
      }
      .backgroundColor(Colors.bgPrimary)
      .borderRadius(Radius.md)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
      .position({ x: '85%', y: '40%' })

      // 重置视图按钮
      Column() {
        Text('🌍')
          .fontSize(24)
      }
      .width(44)
      .height(44)
      .backgroundColor(Colors.bgPrimary)
      .borderRadius(22)
      .justifyContent(FlexAlign.Center)
      .shadow({ radius: 8, color: 'rgba(0,0,0,0.1)', offsetY: 2 })
      .position({ x: '85%', y: '55%' })
      .onClick(() => this.resetView())

      // 选中城市卡片
      if (this.selectedCity) {
        this.CityInfoCard(this.selectedCity)
      }

      // 底部热门城市滚动
      this.HotCitiesBar()
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ZoomButton(label: string, onClick: () => void) {
    Text(label)
      .fontSize(24)
      .fontWeight(FontWeight.Medium)
      .fontColor(Colors.textPrimary)
      .width(44)
      .height(44)
      .textAlign(TextAlign.Center)
      .onClick(onClick)
  }

  @Builder
  CityInfoCard(city: CityLocation) {
    Column() {
      Row() {
        Text(city.emoji)
          .fontSize(40)
        
        Column() {
          Text(city.name)
            .fontSize(FontSizes.h4)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
          Text(`${(city.count / 1000).toFixed(1)}k 人打卡`)
            .fontSize(FontSizes.small)
            .fontColor(Colors.textTertiary)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12 })
        
        Blank()
        
        Button('探索')
          .fontSize(FontSizes.bodySmall)
          .fontColor(Colors.textWhite)
          .backgroundColor(Colors.primary)
          .borderRadius(Radius.full)
          .height(32)
          .onClick(() => {
            // TODO: 跳转到城市详情
          })
      }
      .width('100%')
      .padding(16)
    }
    .width('90%')
    .backgroundColor(Colors.bgPrimary)
    .borderRadius(Radius.card)
    .shadow({ radius: 16, color: 'rgba(0,0,0,0.15)', offsetY: 4 })
    .position({ x: '5%', y: '70%' })
  }

  @Builder
  HotCitiesBar() {
    Column() {
      Row() {
        Text('🔥')
          .fontSize(16)
          Text('热门目的地')
          .fontSize(FontSizes.bodySmall)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .margin({ left: 4 })
      }
      .width('100%')
      .padding({ left: Spacing.pagePadding, bottom: 8 })

      Scroll() {
        Row() {
          ForEach(this.hotCities, (city: CityLocation) => {
            Column() {
              Text(city.emoji)
                .fontSize(28)
              Text(city.name)
                .fontSize(FontSizes.small)
                .fontWeight(FontWeight.Medium)
                .fontColor(Colors.textPrimary)
                .margin({ top: 4 })
            }
            .width(70)
            .padding({ top: 10, bottom: 10 })
            .margin({ right: 8 })
            .backgroundColor(this.selectedCity?.name === city.name ? Colors.primaryLightest : Colors.bgPrimary)
            .borderRadius(Radius.card)
            .alignItems(HorizontalAlign.Center)
            .shadow({ radius: 4, color: 'rgba(0,0,0,0.05)', offsetY: 2 })
            .onClick(() => this.flyToCity(city))
          })
        }
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .padding({ top: 12, bottom: 20 })
    .backgroundColor('rgba(255,255,255,0.95)')
    .position({ x: 0, y: '85%' })
  }
}
