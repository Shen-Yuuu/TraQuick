/**
 * 设置页面 - 符合设计数
 */

import { Colors, FontSizes, Spacing, Radius, Sizes } from '../../utils/Constants';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State fogDensity: number = 65;
  @State renderQuality: number = 2; // 0: 低耗能, 1: 平衡, 2: 高画质
  @State cacheSize: string = '256 MB';

  build() {
    Column() {
      // 顶部导航
      Row() {
        Column() {
            Text('←')
            .fontSize(28)
            .fontColor('#38BDF8')
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.back();
        })

        Text('设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)

        Column().width(40)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 52, bottom: 16 })
      .backgroundColor('#FFFFFF')

      // 设置列表
      Scroll() {
        Column() {
          // 账号设置分组
          Column() {
              this.SettingItemRow('🔐', '账号与安全', '', true)
            Divider().color('#F1F5F9').margin({ left: 56 })
            this.SettingItemRow('🔒', '隐私设置', '', true)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 24 })

          // 应用偏好分组
          Text('应用偏好')
            .fontSize(13)
            .fontColor('#94A3B8')
            .width('100%')
            .margin({ bottom: 12, left: 4 })

          Column() {
            this.SettingItemRow('🔔', '通知设置', '', true)

            Divider().color('#F1F5F9').margin({ left: 56 })

            // 地球引擎设置
            Column() {
              Row() {
                Column() {
                  Text('🌍')
                    .fontSize(20)
                }
                .width(40)
                .height(40)
                .backgroundColor('#E0F2FE')
                .borderRadius(20)
                .justifyContent(FlexAlign.Center)

                Column() {
                  Text('地球引擎设置')
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#1E293B')
                  Text('Earth Engine v2.1')
                    .fontSize(12)
                    .fontColor('#94A3B8')
                    .margin({ top: 2 })
                }
                .alignItems(HorizontalAlign.Start)
                .margin({ left: 12 })
              }
              .width('100%')
              .margin({ bottom: 20 })

              // 迷雾密度滑块
              Column() {
                Row() {
                  Text('迷雾密度')
                    .fontSize(14)
                    .fontColor('#64748B')
                  Blank()
                  Text(`${this.fogDensity}%`)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#38BDF8')
                }
                .width('100%')
                .margin({ bottom: 12 })

                Slider({
                  value: this.fogDensity,
                  min: 0,
                  max: 100,
                  step: 1,
                  style: SliderStyle.OutSet
                })
                  .width('100%')
                  .blockColor('#FFFFFF')
                  .trackColor('#E2E8F0')
                  .selectedColor('#38BDF8')
                  .showSteps(false)
                  .showTips(false)
                  .onChange((value: number) => {
                    this.fogDensity = Math.round(value);
                  })
              }
              .width('100%')
              .margin({ bottom: 20 })

              // 渲染质量
              Column() {
                Text('渲染质量')
                  .fontSize(14)
                  .fontColor('#64748B')
                  .width('100%')
                  .margin({ bottom: 12 })

                Row() {
                    ForEach(['低耗能', '平衡', '高画质'], (item: string, index: number) => {
                    Text(item)
                      .fontSize(13)
                      .fontWeight(this.renderQuality === index ? FontWeight.Bold : FontWeight.Normal)
                      .fontColor(this.renderQuality === index ? '#38BDF8' : '#64748B')
                      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
                      .backgroundColor(this.renderQuality === index ? '#E0F2FE' : '#F8FAFC')
                      .borderRadius(8)
                      .border({
                        width: this.renderQuality === index ? 1 : 0,
                        color: '#BAE6FD'
                      })
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .margin({ right: index < 2 ? 8 : 0 })
                      .onClick(() => {
                        this.renderQuality = index;
                      })
                  })
                }
                .width('100%')
              }
            }
            .width('100%')
            .padding(16)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 24 })

          // 系统分组
          Text('系统')
            .fontSize(13)
            .fontColor('#94A3B8')
            .width('100%')
            .margin({ bottom: 12, left: 4 })

          Column() {
              this.SettingItemRow('🗑️', '清除缓存', this.cacheSize, true)
            Divider().color('#F1F5F9').margin({ left: 56 })
            this.SettingItemRow('ℹ️', '关于 TraQuick', '', true)
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 12, bottom: 12 })
          .backgroundColor('#FFFFFF')
          .borderRadius(16)
          .margin({ bottom: 32 })

          // 退出登录按钮
          Button() {
            Row() {
                Text('⇦')
                .fontSize(18)
                .fontColor('#EF4444')
                Text('退出登录')
                .fontSize(15)
                .fontColor('#EF4444')
                .margin({ left: 8 })
            }
          }
          .width('100%')
          .height(52)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#FEE2E2' })
          .borderRadius(26)
          .margin({ bottom: 24 })
          .onClick(() => {
            this.handleLogout();
          })

          // 版本信息
          Column() {
            Text('🌍')
              .fontSize(24)
              .opacity(0.5)
            Text('TRAQUICK IOS V2.4.1')
              .fontSize(11)
              .fontColor('#CBD5E1')
              .letterSpacing(1)
              .margin({ top: 8 })
          }
          .width('100%')
          .alignItems(HorizontalAlign.Center)
          .margin({ bottom: 48 })
        }
        .padding({ left: Spacing.pagePadding, right: Spacing.pagePadding, top: 16 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  SettingItemRow(icon: string, title: string, value: string, showArrow: boolean) {
    Row() {
      Column() {
        Text(icon)
          .fontSize(20)
      }
      .width(40)
      .height(40)
      .backgroundColor('#E0F2FE')
      .borderRadius(20)
      .justifyContent(FlexAlign.Center)

      Text(title)
        .fontSize(15)
        .fontColor('#1E293B')
        .margin({ left: 12 })
        .layoutWeight(1)

      if (value) {
        Text(value)
          .fontSize(13)
          .fontColor('#94A3B8')
          .margin({ right: 8 })
      }

      if (showArrow) {
          Text('›')
          .fontSize(20)
          .fontColor('#CBD5E1')
      }
    }
    .width('100%')
    .height(56)
  }

  handleLogout() {
    router.replaceUrl({ url: 'pages/auth/LoginPage' });
  }
}
