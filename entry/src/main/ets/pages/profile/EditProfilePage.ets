/**
 * 编辑资料页面 - 类似抖音风格
 */

import { Colors, FontSizes, Spacing, Radius } from '../../utils/Constants';
import { mockCurrentUser } from '../../services/MockData';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

// 性别选项
type GenderType = '男' | '女' | '保密';

@Entry
@Component
struct EditProfilePage {
  @State nickname: string = mockCurrentUser.nickname || '旅行者';
  @State bio: string = mockCurrentUser.bio || '走遍世界，一步一个脚印';
  @State gender: GenderType = '保密';
  @State birthday: string = '1995-06-15';
  @State location: string = '上海';
  @State traquickId: string = 'TraQuick_' + mockCurrentUser.id;
  
  // 编辑状态
  @State isEditingNickname: boolean = false;
  @State isEditingBio: boolean = false;
  @State tempNickname: string = '';
  @State tempBio: string = '';
  
  // 头像选择
  @State showAvatarPicker: boolean = false;

  build() {
    Column() {
      // 顶部导航栏
      this.NavigationBar()

      Scroll() {
        Column() {
          // 头像区域
          this.AvatarSection()

          // 编辑项列表
          this.EditItemsList()

          // 底部提示
          Text('个人信息仅用于展示，保护你的隐私安全')
            .fontSize(12)
            .fontColor('#94A3B8')
            .margin({ top: 32 })
        }
        .padding({ bottom: 50 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC')
  }

  @Builder
  NavigationBar() {
    Column() {
      // 状态栏占位
      Row()
        .width('100%')
        .height(48)

      // 导航内容
      Row() {
        // 返回按钮
        Row() {
          Text('←')
            .fontSize(28)
            .fontColor('#1E293B')
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          router.back();
        })

        Blank()

        Text('编辑资料')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        Blank()

        // 保存按钮
        Text('保存')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#38BDF8')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .onClick(() => {
            this.saveProfile();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 8, right: 16 })
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  @Builder
  AvatarSection() {
    Column() {
      Stack() {
        // 头像背景光晕
        Column()
          .width(108)
          .height(108)
          .borderRadius(54)
          .linearGradient({
            direction: GradientDirection.RightBottom,
            colors: [['#7DD3FC', 0], ['#0EA5E9', 1]]
          })

        // 头像
        Image($r('app.media.layered_image'))
          .width(100)
          .height(100)
          .borderRadius(50)
          .border({ width: 3, color: '#FFFFFF' })

        // 编辑图标
        Column() {
          Text('📷')
            .fontSize(14)
        }
        .width(32)
        .height(32)
        .backgroundColor('#38BDF8')
        .borderRadius(16)
        .border({ width: 2, color: '#FFFFFF' })
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .position({ x: 72, y: 72 })
      }
      .onClick(() => {
        this.showAvatarOptions();
      })

      Text('点击更换头像')
        .fontSize(13)
        .fontColor('#64748B')
        .margin({ top: 12 })
    }
    .width('100%')
    .padding({ top: 24, bottom: 24 })
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#FFFFFF')
  }

  @Builder
  EditItemsList() {
    Column() {
      // 基本信息分组
      this.SectionHeader('基本信息')
      
      Column() {
        this.EditItem('昵称', this.nickname, () => {
          this.startEditNickname();
        })
        this.Divider()
        this.EditItem('TraQuick ID', this.traquickId, undefined, false)
        this.Divider()
        this.EditItem('简介', this.bio || '填写简介，让大家认识你', () => {
          this.startEditBio();
        })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })

      // 个人信息分组
      this.SectionHeader('个人信息')

      Column() {
        this.EditItemWithValue('性别', this.gender, () => {
          this.showGenderPicker();
        })
        this.Divider()
        this.EditItemWithValue('生日', this.birthday, () => {
          this.showBirthdayPicker();
        })
        this.Divider()
        this.EditItemWithValue('地区', this.location, () => {
          this.showLocationPicker();
        })
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })

      // 社交账号分组
      this.SectionHeader('社交账号')

      Column() {
        this.EditItemWithIcon('🔗', '微信', '未绑定', () => {})
        this.Divider()
        this.EditItemWithIcon('📱', '手机号', '138****8888', () => {})
        this.Divider()
        this.EditItemWithIcon('📧', '邮箱', '未绑定', () => {})
      }
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .margin({ left: 16, right: 16 })
    }
  }

  @Builder
  SectionHeader(title: string) {
    Text(title)
      .fontSize(13)
      .fontColor('#64748B')
      .fontWeight(FontWeight.Medium)
      .padding({ left: 28, top: 20, bottom: 8 })
  }

  @Builder
  EditItem(label: string, value: string, onClick?: () => void, showArrow: boolean = true) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#1E293B')
        .width(80)

      Text(value)
        .fontSize(15)
        .fontColor(value.includes('填写') ? '#94A3B8' : '#64748B')
        .layoutWeight(1)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.End)

      if (showArrow) {
        Text('›')
          .fontSize(18)
          .fontColor('#CBD5E1')
          .margin({ left: 8 })
      }
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(() => {
      if (onClick) {
        onClick();
      }
    })
  }

  @Builder
  EditItemWithValue(label: string, value: string, onClick: () => void) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontColor('#1E293B')
        .width(80)

      Text(value)
        .fontSize(15)
        .fontColor('#64748B')
        .layoutWeight(1)
        .textAlign(TextAlign.End)

      Text('›')
        .fontSize(18)
        .fontColor('#CBD5E1')
        .margin({ left: 8 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(() => onClick())
  }

  @Builder
  EditItemWithIcon(icon: string, label: string, value: string, onClick: () => void) {
    Row() {
      Text(icon)
        .fontSize(20)
        .margin({ right: 12 })

      Text(label)
        .fontSize(15)
        .fontColor('#1E293B')
        .layoutWeight(1)

      Text(value)
        .fontSize(14)
        .fontColor(value === '未绑定' ? '#94A3B8' : '#64748B')

      Text('›')
        .fontSize(18)
        .fontColor('#CBD5E1')
        .margin({ left: 8 })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .onClick(() => onClick())
  }

  @Builder
  Divider() {
    Column()
      .width('100%')
      .height(1)
      .backgroundColor('#F1F5F9')
      .margin({ left: 16 })
  }

  // 开始编辑昵称
  private startEditNickname(): void {
    promptAction.showDialog({
      title: '修改昵称',
      message: '请输入新昵称（最多12个字符）',
      buttons: [
        { text: '取消', color: '#64748B' },
        { text: '确定', color: '#38BDF8' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 用户点击确定，这里可以弹出输入框
        // 由于ArkUI限制，使用TextPickerDialog模拟
      }
    }).catch(() => {});
  }

  // 开始编辑简介
  private startEditBio(): void {
    promptAction.showDialog({
      title: '修改简介',
      message: '请输入个人简介（最多70个字符）',
      buttons: [
        { text: '取消', color: '#64748B' },
        { text: '确定', color: '#38BDF8' }
      ]
    }).then((result) => {
      if (result.index === 1) {
        // 用户点击确定
      }
    }).catch(() => {});
  }

  // 显示头像选项
  private showAvatarOptions(): void {
    promptAction.showActionMenu({
      title: '更换头像',
      buttons: [
        { text: '拍照', color: '#1E293B' },
        { text: '从相册选择', color: '#1E293B' },
        { text: '取消', color: '#64748B' }
      ]
    }).then((result) => {
      if (result.index === 0) {
        // 拍照
        this.showToast('打开相机...');
      } else if (result.index === 1) {
        // 从相册选择
        this.showToast('打开相册...');
      }
    }).catch(() => {});
  }

  // 显示性别选择器
  private showGenderPicker(): void {
    promptAction.showActionMenu({
      title: '选择性别',
      buttons: [
        { text: '男', color: '#1E293B' },
        { text: '女', color: '#1E293B' },
        { text: '保密', color: '#1E293B' }
      ]
    }).then((result) => {
      const options: GenderType[] = ['男', '女', '保密'];
      if (result.index >= 0 && result.index < options.length) {
        this.gender = options[result.index];
      }
    }).catch(() => {});
  }

  // 显示生日选择器
  private showBirthdayPicker(): void {
    // 由于DatePickerDialog需要特殊处理，这里使用简化的方式
    this.showToast('日期选择器开发中...');
  }

  // 显示地区选择器
  private showLocationPicker(): void {
    promptAction.showActionMenu({
      title: '选择地区',
      buttons: [
        { text: '北京', color: '#1E293B' },
        { text: '上海', color: '#1E293B' },
        { text: '广州', color: '#1E293B' },
        { text: '深圳', color: '#1E293B' },
        { text: '杭州', color: '#1E293B' },
        { text: '成都', color: '#1E293B' }
      ]
    }).then((result) => {
      const cities = ['北京', '上海', '广州', '深圳', '杭州', '成都'];
      if (result.index >= 0 && result.index < cities.length) {
        this.location = cities[result.index];
      }
    }).catch(() => {});
  }

  // 保存资料
  private saveProfile(): void {
    this.showToast('保存成功');
    setTimeout(() => {
      router.back();
    }, 500);
  }

  // 显示Toast
  private showToast(message: string): void {
    promptAction.showToast({
      message: message,
      duration: 2000
    });
  }
}
