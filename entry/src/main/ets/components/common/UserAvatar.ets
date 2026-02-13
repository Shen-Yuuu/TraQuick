/**
 * 用户头像组件
 */

import { Colors, Radius } from '../../utils/Constants';

@Component
export struct UserAvatar {
  @Prop src: string = '';
  @Prop avatarSize: number = 40;
  @Prop level?: number = 0;
  @Prop showLevel: boolean = false;
  @Prop avatarBorderWidth: number = 0;
  @Prop avatarBorderColor: string = Colors.bgPrimary;

  build() {
    Stack() {
      Image(this.src ? this.src : $r('app.media.layered_image'))
        .width(this.avatarSize)
        .height(this.avatarSize)
        .borderRadius(this.avatarSize / 2)
        .border({
          width: this.avatarBorderWidth,
          color: this.avatarBorderColor
        })
        .objectFit(ImageFit.Cover)

      // 等级标签
      if (this.showLevel && this.level && this.level > 0) {
        Text(`LV.${this.level}`)
          .fontSize(9)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textWhite)
          .backgroundColor(this.getLevelColor())
          .padding({ left: 5, right: 5, top: 2, bottom: 2 })
          .borderRadius(Radius.full)
          .position({ x: '50%', y: '100%' })
          .translate({ x: '-50%', y: '-60%' })
      }
    }
    .width(this.avatarSize)
    .height(this.showLevel ? this.avatarSize + 8 : this.avatarSize)
  }

  getLevelColor(): string {
    switch (this.level) {
      case 1: return '#94A3B8';
      case 2: return '#10B981';
      case 3: return '#7DD3FC';
      case 4: return '#8B5CF6';
      case 5: return '#F59E0B';
      default: return '#94A3B8';
    }
  }
}
