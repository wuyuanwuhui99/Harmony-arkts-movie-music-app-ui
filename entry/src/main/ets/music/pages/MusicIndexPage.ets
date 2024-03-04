import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import MusicCircleComponent from '../components/MusicCircleComponent'
import MusicHomeComponent from '../components/MusicHomeComponent'
import MusicMyComponent from '../components/MusicMyComponent'
import MusicRecommendComponent from '../components/MusicRecommendComponent'

@Entry
@Component
struct MusicIndexPage {
  @State activeIndex: number = 0;
  @State isInitPage: Array<boolean> = [true, false, false, false];

  build() {
    Column() {
      Tabs({
        index: this.activeIndex,
        barPosition: BarPosition.End
      }) {
        TabContent() {
          MusicHomeComponent()
        }
        .tabBar(this.tabBuilder(0, '首页', $r('app.media.icon_home_active'), $r('app.media.icon_home')))

        TabContent() {
          if (this.isInitPage[1]) {
            MusicRecommendComponent()
          } else {
            Column()
          }
        }
        .tabBar(this.tabBuilder(1, '推荐', $r('app.media.icon_recomment_active'), $r('app.media.icon_recomment')))

        TabContent() {
          if (this.isInitPage[2]) {
            MusicCircleComponent()
          } else {
            Column()
          }
        }
        .tabBar(this.tabBuilder(2, '音乐圈', $r('app.media.icon_music_circle_active'), $r('app.media.icon_music_circle')))

        TabContent() {
          if (this.isInitPage[3]) {
            MusicMyComponent()
          } else {
            Column()
          }
        }
        .tabBar(this.tabBuilder(3, '我的', $r('app.media.icon_user_active'), $r('app.media.icon_user')))

      }
      .barHeight(70)
      .barMode(BarMode.Fixed)
      .onChange((index) => {
        this.isInitPage[index] = true;
        this.activeIndex = index
      })
    }
    .width('100%')
    .height('100%')

  }

  @Builder tabBuilder(index: number, title: string, selectedImage: Resource, normalImage: Resource) {
    Column() {
      Image(this.activeIndex == index ? selectedImage : normalImage)
        .width(size.middlIconSize)
        .height(size.middlIconSize)
        .margin({ top: size.smallPadding, bottom: size.smallPadding })
      Text(title)
        .fontColor(this.activeIndex == index ? colors.tabSelectedColor : colors.tabNormalColor)
        .fontSize(size.normalFontSize)
        .padding({ bottom: size.pagePadding })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .border({
      width: { top: 1 },
      color: { top: colors.disableTextColor },
      style: { top: BorderStyle.Solid }
    })
  }
}