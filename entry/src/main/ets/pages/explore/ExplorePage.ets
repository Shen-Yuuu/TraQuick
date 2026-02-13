/**
 * 探索页面 - 华为 Map Kit 3D地球 + 区域交互
 */

import { CityCardDialog } from '../../components/explore/CityCardDialog';
import { City } from '../../models/City';
import { getRandomCity } from '../../services/MockData';
import { router } from '@kit.ArkUI';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { RegionData } from '../../utils/GeoJsonParser';
import { RegionOverlayManager, RegionCallbacks } from '../../utils/RegionOverlayManager';
import { common } from '@kit.AbilityKit';

@Entry
@Component
export struct ExplorePage {
  // ==================== 页面UI状态 ====================
  @State showSearch: boolean = false;
  @State searchText: string = '';
  @State currentCity: City | null = null;
  @State showCityCard: boolean = false;

  // ==================== 区域交互状态 ====================
  @State selectedRegionName: string = '';
  @State showCityBubble: boolean = false;
  @State selectedCityRegion: RegionData | null = null;

  // ==================== 探索Tab双击触发 ====================
  @StorageLink('exploreShakeTrigger') @Watch('onShakeTrigger') exploreShakeTrigger: number = 0;
  private lastShakeTrigger: number = 0;

  // ==================== 地图相关 ====================
  private mapOptions?: mapCommon.MapOptions;
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private regionManager?: RegionOverlayManager;

  aboutToAppear(): void {
    this.initMap();
  }

  private initMap(): void {
    this.mapOptions = {
      position: {
        target: {
          latitude: 35.0,
          longitude: 105.0
        },
        zoom: 3
      },
      sphereEnabled: true,
      zoomControlsEnabled: false,
      compassControlsEnabled: false,
      scaleControlsEnabled: false,
      myLocationControlsEnabled: false
    };

    this.mapCallback = async (err, mapController) => {
      if (!err && mapController) {
        this.mapController = mapController;
        this.mapEventManager = this.mapController.getEventManager();

        // 地图加载完成
        this.mapEventManager.on("mapLoad", async () => {
          console.info("[ExplorePage] ✅ 地图加载完成");
          await this.initRegionOverlay();
        });

        // 地图点击
        this.mapEventManager.on("mapClick", (latLng: mapCommon.LatLng) => {
          if (this.regionManager) {
            this.regionManager.handleMapClick(latLng.latitude, latLng.longitude);
          }
        });

        // 相机停止移动 → 检查缩放级别
        this.mapEventManager.on("cameraIdle", () => {
          if (this.mapController && this.regionManager) {
            try {
              const position = this.mapController.getCameraPosition();
              this.regionManager.onZoomChanged(position.zoom);
            } catch (e) {
              // getCameraPosition 可能不存在，忽略
            }
          }
        });

      } else {
        console.error("[ExplorePage] ❌ 地图初始化失败", err);
      }
    };
  }

  private async initRegionOverlay(): Promise<void> {
    if (!this.mapController) return;

    const context = getContext(this) as common.UIAbilityContext;
    this.regionManager = new RegionOverlayManager(this.mapController, context);

    const callbacks: RegionCallbacks = {
      onProvinceSelected: (region: RegionData) => {
        this.selectedRegionName = region.name;
        this.showCityBubble = false;       // 第一次点击只显示标签
        this.selectedCityRegion = null;
        console.info(`[ExplorePage] 🏛️ 省份选中: ${region.name}（再次点击飞入）`);
      },
      onCountrySelected: (region: RegionData) => {
        // 判断是第一次选中还是飞入后
        if (this.selectedRegionName === region.name && this.selectedCityRegion !== null) {
          // 飞入后：弹气泡
          this.showCityBubble = true;
          console.info(`[ExplorePage] 🌍 国家飞入: ${region.name}`);
        } else {
          // 第一次选中：只显示标签
          this.selectedRegionName = region.name;
          this.selectedCityRegion = region;
          this.showCityBubble = false;
          console.info(`[ExplorePage] 🌍 国家选中: ${region.name}（再次点击飞入）`);
        }
      },
      onCitySelected: (region: RegionData) => {
        this.selectedRegionName = region.name;
        this.selectedCityRegion = region;
        this.showCityBubble = true;
        console.info(`[ExplorePage] 🏙️ 城市选中: ${region.name}`);
      },
      onSelectionCleared: () => {
        this.selectedRegionName = '';
        this.showCityBubble = false;
        this.selectedCityRegion = null;
      }
    };

    this.regionManager.setCallbacks(callbacks);
    await this.regionManager.init();
  }

  // ==================== 探索Tab双击 ====================

  onShakeTrigger(): void {
    if (this.exploreShakeTrigger > 0 && this.exploreShakeTrigger !== this.lastShakeTrigger) {
      this.lastShakeTrigger = this.exploreShakeTrigger;
      this.currentCity = getRandomCity();
      this.showCityCard = true;
    }
  }

  // ==================== 页面布局 ====================

  build() {
    Stack() {
      // ① 全屏地图
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback })
        .width('100%')
        .height('100%')

      // ② 顶部状态提示（选中省/市时显示）
      if (this.selectedRegionName !== '') {
        Row() {
          Text(`📍 ${this.selectedRegionName}`)
            .fontSize(14)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Medium)
        }
        .backgroundColor('rgba(0,0,0,0.6)')
        .padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .borderRadius(20)
        .position({ x: '50%', y: 90 })
        .translate({ x: '-50%' })
      }

      // ③ 城市气泡卡片
      if (this.showCityBubble && this.selectedCityRegion !== null) {
        this.CityBubble()
      }

      // ④ 顶部搜索栏
      this.TopSearchBar()

      // ⑤ 底部功能按钮
      this.BottomButtons()

      // ⑥ 搜索面板
      if (this.showSearch) {
        this.SearchPanel()
      }

      // ⑦ 随机城市卡片
      if (this.showCityCard && this.currentCity !== null) {
        CityCardDialog({
          city: this.currentCity as City,
          isShow: this.showCityCard,
          onClose: () => { this.showCityCard = false; },
          onExplore: () => { this.navigateToCityDetail(this.currentCity as City); },
          onShuffle: () => { this.shuffleCity(); }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // ==================== 城市气泡 ====================

  @Builder
  CityBubble() {
    Column() {
      // 城市名
      Text(this.selectedCityRegion?.name || '')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')

      // 区划代码
      Text(`区划代码: ${this.selectedCityRegion?.adcode || ''}`)
        .fontSize(12)
        .fontColor('rgba(255,255,255,0.6)')
        .margin({ top: 4 })

      // 探索按钮
      Row() {
        Text('探索该城市')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .linearGradient({
        direction: GradientDirection.Right,
        colors: [['#4488FF', 0], ['#38BDF8', 1]]
      })
      .borderRadius(20)
      .margin({ top: 12 })
      .onClick(() => {
        // 点击探索：可以跳转到城市详情页
        if (this.selectedCityRegion) {
          console.info(`[ExplorePage] 🚀 探索城市: ${this.selectedCityRegion.name}`);
          router.pushUrl({
            url: 'pages/explore/CityDetailPage',
            params: {
              cityId: this.selectedCityRegion.adcode,
              cityName: this.selectedCityRegion.name
            }
          }).catch(() => {});
        }
      })
    }
    .width('70%')
    .padding(20)
    .backgroundColor('rgba(15, 23, 42, 0.9)')
    .borderRadius(16)
    .border({ width: 1, color: 'rgba(68, 136, 255, 0.3)' })
    .shadow({ radius: 20, color: 'rgba(0,0,0,0.3)', offsetY: 8 })
    .position({ x: '15%', y: '60%' })
    .transition(TransitionEffect.OPACITY.animation({ duration: 250 }))
  }

  // ==================== UI组件 ====================

  @Builder
  TopSearchBar() {
    Row() {
      Row() {
        Text('🔍')
          .fontSize(15)
        Text('搜索城市、景点...')
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.45)')
          .margin({ left: 8 })
      }
      .layoutWeight(1)
      .height(38)
      .padding({ left: 14, right: 14 })
      .backgroundBlurStyle(BlurStyle.Thin)
      .backgroundColor('rgba(255,255,255,0.08)')
      .borderRadius(19)
      .border({ width: 0.5, color: 'rgba(255,255,255,0.12)' })
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.showSearch = true;
      })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 38 })
    .position({ x: 0, y: 0 })
  }

  @Builder
  SearchPanel() {
    Column() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showSearch = false;
        })

      Column() {
        Row() {
          Text('🔍')
            .fontSize(16)
          TextInput({ placeholder: '搜索城市、景点、国家...', text: this.searchText })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('transparent')
            .fontSize(15)
            .fontColor('#1E293B')
            .margin({ left: 8 })
            .onChange((value: string) => {
              this.searchText = value;
            })
          Text('取消')
            .fontSize(14)
            .fontColor('#38BDF8')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })
            .onClick(() => {
              this.showSearch = false;
              this.searchText = '';
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)

        Column() {
          Text('热门城市')
            .fontSize(13)
            .fontColor('#94A3B8')
            .margin({ bottom: 12 })

          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['巴黎', '东京', '纽约', '成都', '伦敦', '悉尼', '迪拜', '罗马'],
              (city: string) => {
                Text(city)
                  .fontSize(13)
                  .fontColor('#475569')
                  .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                  .backgroundColor('#F1F5F9')
                  .borderRadius(16)
                  .margin({ right: 8, bottom: 8 })
              })
          }
          .width('100%')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16 })
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ top: 36, bottom: 24 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ bottomLeft: 20, bottomRight: 20 })
      .position({ x: 0, y: 0 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  BottomButtons() {
    Stack() {
      // 左下角 - 漂流瓶
      Column() {
        Column() {
          Text('🍾')
            .fontSize(20)
        }
        .width(50)
        .height(50)
        .backgroundBlurStyle(BlurStyle.Regular)
        .backgroundColor('rgba(255,255,255,0.1)')
        .borderRadius(25)
        .border({ width: 0.5, color: 'rgba(255,255,255,0.18)' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.12)', offsetY: 4 })

        Text('漂流瓶')
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)
      .position({ x: 20, y: '100%' })
      .translate({ y: -120 })
      .onClick(() => { this.onDriftBottleClick(); })

      // 右下角 - 时空胶囊
      Column() {
        Column() {
          Text('⏳')
            .fontSize(20)
        }
        .width(50)
        .height(50)
        .backgroundBlurStyle(BlurStyle.Regular)
        .backgroundColor('rgba(255,255,255,0.1)')
        .borderRadius(25)
        .border({ width: 0.5, color: 'rgba(255,255,255,0.18)' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.12)', offsetY: 4 })

        Text('胶囊')
          .fontSize(10)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)
      .position({ x: '100%', y: '100%' })
      .translate({ x: -70, y: -120 })
      .onClick(() => { this.onTimeCapsuleClick(); })
    }
    .width('100%')
    .height('100%')
    .hitTestBehavior(HitTestMode.Transparent)  // 让不在按钮上的点击穿透到地图
  }

  // ==================== 业务方法 ====================

  shuffleCity(): void {
    this.currentCity = getRandomCity();
  }

  navigateToCityDetail(city: City): void {
    router.pushUrl({
      url: 'pages/explore/CityDetailPage',
      params: { cityId: city.id, cityName: city.name }
    }).catch(() => {});
  }

  onDriftBottleClick(): void {
    router.pushUrl({ url: 'pages/explore/DriftBottlePage' }).catch(() => {});
  }

  onTimeCapsuleClick(): void {
    router.pushUrl({ url: 'pages/explore/TimeCapsulePage' }).catch(() => {});
  }
}