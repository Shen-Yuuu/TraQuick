/**
 * 探索页面 - 真实 API 对接版 + 华为 Map Kit
 */

import { CityCardDialog } from '../../components/explore/CityCardDialog';
import { City } from '../../models/City';
import { router, promptAction } from '@kit.ArkUI';
import { MapComponent, mapCommon, map } from '@kit.MapKit';
import { AsyncCallback } from '@kit.BasicServicesKit';
import { RegionData } from '../../utils/GeoJsonParser';
import { RegionOverlayManager, RegionCallbacks } from '../../utils/RegionOverlayManager';
import { common } from '@kit.AbilityKit';
import { ApiService, ApiCity } from '../../services/ApiService';

@Entry
@Component
export struct ExplorePage {
  @State showSearch: boolean = false;
  @State searchText: string = '';
  @State currentCity: City | null = null;
  @State showCityCard: boolean = false;

  @State selectedRegionName: string = '';
  @State showCityBubble: boolean = false;
  @State selectedCityRegion: RegionData | null = null;
  
  // 缓存从后端拉取的全部城市
  @State allCitiesCache: City[] = [];

  @StorageLink('exploreShakeTrigger') @Watch('onShakeTrigger') exploreShakeTrigger: number = 0;
  private lastShakeTrigger: number = 0;

  private mapOptions?: mapCommon.MapOptions;
  private mapCallback?: AsyncCallback<map.MapComponentController>;
  private mapController?: map.MapComponentController;
  private mapEventManager?: map.MapEventManager;
  private regionManager?: RegionOverlayManager;

  aboutToAppear(): void {
    this.initMap();
    this.loadAllCities();
  }

  private async loadAllCities(): Promise<void> {
    try {
      const apiCities = await ApiService.getCities();
      const converted: City[] = [];
      for (const ac of apiCities) {
        converted.push(this.convertApiCity(ac));
      }
      this.allCitiesCache = converted;
    } catch (error) {
      console.error('[ExplorePage] 加载城市数据失败:', (error as Error).message);
    }
  }

  private convertApiCity(ac: ApiCity): City {
    return {
      id: ac.id,
      name: ac.name,
      nameEn: ac.nameEn || undefined,
      country: ac.country,
      countryCode: ac.countryCode,
      province: ac.province || undefined,
      coverImage: ac.coverImage,
      latitude: Number(ac.latitude),
      longitude: Number(ac.longitude),
      description: ac.description || undefined,
      postsCount: ac.postsCount,
      visitorsCount: ac.visitorsCount,
      isUnlocked: ac.isUnlocked
    };
  }

  private initMap(): void {
    this.mapOptions = {
      position: { 
        target: { latitude: 35.0, longitude: 105.0 }, 
        zoom: 3,
        bearing: 0, // 强制正北朝上
        tilt: 0     // 垂直俯视
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

        this.mapEventManager.on("mapLoad", async () => {
          await this.initRegionOverlay();
        });

        this.mapEventManager.on("mapClick", (latLng: mapCommon.LatLng) => {
          if (this.regionManager) {
            this.regionManager.handleMapClick(latLng.latitude, latLng.longitude);
          }
        });

        this.mapEventManager.on("cameraIdle", () => {
          if (this.mapController && this.regionManager) {
            try {
              const position = this.mapController.getCameraPosition();
              this.regionManager.onZoomChanged(position.zoom);
            } catch (e) {}
          }
        });
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
        this.showCityBubble = false;
        this.selectedCityRegion = null;
      },
      onCountrySelected: (region: RegionData) => {
        if (this.selectedRegionName === region.name && this.selectedCityRegion !== null) {
          this.showCityBubble = true;
        } else {
          this.selectedRegionName = region.name;
          this.selectedCityRegion = region;
          this.showCityBubble = false;
        }
      },
      onCitySelected: (region: RegionData) => {
        this.selectedRegionName = region.name;
        this.selectedCityRegion = region;
        this.showCityBubble = true;
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

  onShakeTrigger(): void {
    if (this.exploreShakeTrigger > 0 && this.exploreShakeTrigger !== this.lastShakeTrigger) {
      this.lastShakeTrigger = this.exploreShakeTrigger;
      this.shuffleCity();
    }
  }

  shuffleCity(): void {
    if (this.allCitiesCache.length > 0) {
      const index = Math.floor(Math.random() * this.allCitiesCache.length);
      this.currentCity = this.allCitiesCache[index];
      this.showCityCard = true;
    } else {
      promptAction.showToast({ message: '正在加载地球数据，请稍后再试' });
      this.loadAllCities(); // 重试加载
    }
  }

  navigateToCityDetail(city: City): void {
    if (!city.id) {
      promptAction.showToast({ message: '城市数据异常' });
      return;
    }
    router.pushUrl({
      url: 'pages/explore/CityDetailPage',
      params: { cityId: city.id, cityName: city.name }
    }).catch(() => {});
  }

  build() {
    Stack() {
      // 若地球依旧是倒着的，可以解开下面这行的 .rotate 注释强制翻转
      MapComponent({ mapOptions: this.mapOptions, mapCallback: this.mapCallback })
        .width('100%')
        .height('100%')
        // .rotate({ angle: 180 })

      if (this.selectedRegionName !== '') {
        Row() { Text(`📍 ${this.selectedRegionName}`).fontSize(14).fontColor('#FFFFFF').fontWeight(FontWeight.Medium) }
        .backgroundColor('rgba(0,0,0,0.6)').padding({ left: 16, right: 16, top: 8, bottom: 8 })
        .borderRadius(20).position({ x: '50%', y: 90 }).translate({ x: '-50%' })
      }

      if (this.showCityBubble && this.selectedCityRegion !== null) {
        this.CityBubble()
      }

      this.TopSearchBar()
      this.BottomButtons()

      if (this.showSearch) {
        this.SearchPanel()
      }

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
    .width('100%').height('100%')
  }

  @Builder
  CityBubble() {
    Column() {
      Text(this.selectedCityRegion?.name || '').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
      Text(`区划代码: ${this.selectedCityRegion?.adcode || ''}`).fontSize(12).fontColor('rgba(255,255,255,0.6)').margin({ top: 4 })
      Row() { Text('探索该城市').fontSize(14).fontColor('#FFFFFF').fontWeight(FontWeight.Medium) }
      .width('100%').height(40).justifyContent(FlexAlign.Center)
      .linearGradient({ direction: GradientDirection.Right, colors: [['#4488FF', 0], ['#38BDF8', 1]] })
      .borderRadius(20).margin({ top: 12 })
      .onClick(() => {
        if (this.selectedCityRegion) {
          // 模糊匹配：地图点的是"成都市"，后端可能是"成都"
          const matchedCity = this.allCitiesCache.find(c => this.selectedCityRegion!.name.includes(c.name) || c.name.includes(this.selectedCityRegion!.name));
          if (matchedCity) {
            this.navigateToCityDetail(matchedCity);
          } else {
            promptAction.showToast({ message: '暂未开放该城市的详细数据' });
          }
        }
      })
    }
    .width('70%').padding(20).backgroundColor('rgba(15, 23, 42, 0.9)').borderRadius(16)
    .border({ width: 1, color: 'rgba(68, 136, 255, 0.3)' }).shadow({ radius: 20, color: 'rgba(0,0,0,0.3)', offsetY: 8 })
    .position({ x: '15%', y: '60%' })
  }

  @Builder TopSearchBar() { 
    Row() {
      Row() {
        Text('🔍').fontSize(15)
        Text('搜索城市、景点...').fontSize(14).fontColor('rgba(255,255,255,0.45)').margin({ left: 8 })
      }
      .layoutWeight(1).height(38).padding({ left: 14, right: 14 }).backgroundBlurStyle(BlurStyle.Thin)
      .backgroundColor('rgba(255,255,255,0.08)').borderRadius(19).border({ width: 0.5, color: 'rgba(255,255,255,0.12)' })
      .alignItems(VerticalAlign.Center)
      .onClick(() => { this.showSearch = true; })
    }
    .width('100%').padding({ left: 20, right: 20, top: 38 }).position({ x: 0, y: 0 })
  }

  @Builder
  SearchPanel() {
    Column() {
      // 半透明遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.5)')
        .onClick(() => {
          this.showSearch = false;
        })

      // 搜索面板主体
      Column() {
        Row() {
          Text('🔍').fontSize(16)
          TextInput({ placeholder: '搜索城市、景点、国家...', text: this.searchText })
            .layoutWeight(1)
            .height(40)
            .backgroundColor('transparent')
            .fontSize(15)
            .fontColor('#1E293B')
            .margin({ left: 8 })
            .enterKeyType(EnterKeyType.Search) // 键盘显示搜索键
            .onChange((value: string) => {
              this.searchText = value;
            })
            .onSubmit(() => {
              this.executeSearch();
            })

          Text('搜索')
            .fontSize(14)
            .fontColor('#38BDF8')
            .fontWeight(FontWeight.Medium)
            .margin({ left: 12 })
            .onClick(() => {
              this.executeSearch();
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)

        Column() {
          Text('热门城市').fontSize(13).fontColor('#94A3B8').margin({ bottom: 12 })
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(['巴黎', '东京', '纽约', '成都', '伦敦', '悉尼', '迪拜', '罗马'], (city: string) => {
              Text(city)
                .fontSize(13)
                .fontColor('#475569')
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .backgroundColor('#F1F5F9')
                .borderRadius(16)
                .margin({ right: 8, bottom: 8 })
                .onClick(() => {
                  this.searchText = city;
                  this.executeSearch();
                })
            })
          }.width('100%')
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

  // 新增的搜索执行逻辑
  private executeSearch(): void {
    const keyword = this.searchText.trim();
    if (!keyword) return;

    // 在已缓存的后端真实城市中查找匹配项
    const matchedCity = this.allCitiesCache.find(c =>
    c.name.includes(keyword) ||
      (c.nameEn && c.nameEn.toLowerCase().includes(keyword.toLowerCase())) ||
      (c.country && c.country.includes(keyword))
    );

    if (matchedCity) {
      // 找到了，显示城市卡片
      this.currentCity = matchedCity;
      this.showSearch = false; // 关闭搜索面板
      this.showCityCard = true; // 弹出城市盲盒卡片
      this.searchText = ''; // 清空搜索框
    } else {
      promptAction.showToast({ message: '抱歉，暂未收录该城市信息' });
    }
  }

  @Builder BottomButtons() { 
    Stack() {
      Column() {
        Column() { Text('🍾').fontSize(20) }
        .width(50).height(50).backgroundBlurStyle(BlurStyle.Regular).backgroundColor('rgba(255,255,255,0.1)')
        .borderRadius(25).border({ width: 0.5, color: 'rgba(255,255,255,0.18)' }).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).shadow({ radius: 12, color: 'rgba(0,0,0,0.12)', offsetY: 4 })
        Text('漂流瓶').fontSize(10).fontColor('rgba(255,255,255,0.6)').margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center).position({ x: 20, y: '100%' }).translate({ y: -120 })
      .onClick(() => { this.onDriftBottleClick(); })

      Column() {
        Column() { Text('⏳').fontSize(20) }
        .width(50).height(50).backgroundBlurStyle(BlurStyle.Regular).backgroundColor('rgba(255,255,255,0.1)')
        .borderRadius(25).border({ width: 0.5, color: 'rgba(255,255,255,0.18)' }).justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center).shadow({ radius: 12, color: 'rgba(0,0,0,0.12)', offsetY: 4 })
        Text('胶囊').fontSize(10).fontColor('rgba(255,255,255,0.6)').margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center).position({ x: '100%', y: '100%' }).translate({ x: -70, y: -120 })
      .onClick(() => { this.onTimeCapsuleClick(); })
    }
    .width('100%').height('100%').hitTestBehavior(HitTestMode.Transparent)
  }

  onDriftBottleClick(): void { router.pushUrl({ url: 'pages/explore/DriftBottlePage' }).catch(() => {}); }
  onTimeCapsuleClick(): void { router.pushUrl({ url: 'pages/explore/TimeCapsulePage' }).catch(() => {}); }
}