import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import HomeComponent from '../components/HomeComponent'
import MovieComponent from '../components/MovieComponent'
import MyComponent from '../components/MyComponent'
import TVComponent from '../components/TVComponent'
import httpRequest from '../../utils/HttpUtil';
import { UserDataInterface } from '../interface/Index'
import preference from '../../utils/PreferenceModel';
import { USER_DATA } from '../../common/constant';
import { getUserDataService } from '../service/Index';

@Entry
@Component
struct Index {
  @State activeIndex: number = 0;
  @State isInitPage: Array<boolean> = [true, false, false, false];
  @State isInitIndex: boolean = false;

  build() {
    Column() {
      if (this.isInitIndex) {
        Tabs({
          index: this.activeIndex,
          barPosition: BarPosition.End
        }) {
          TabContent() {
            HomeComponent()
          }
          .tabBar(this.tabBuilder(0, '首页', $r('app.media.icon_home_active'), $r('app.media.icon_home')))

          TabContent() {
            if (this.isInitPage[1]) {
              MovieComponent()
            } else {
              Column()
            }
          }
          .tabBar(this.tabBuilder(1, '电影', $r('app.media.icon_movie_active'), $r('app.media.icon_movie')))

          TabContent() {
            if (this.isInitPage[2]) {
              TVComponent()
            } else {
              Column()
            }
          }
          .tabBar(this.tabBuilder(2, '电视剧', $r('app.media.icon_tv_active'), $r('app.media.icon_tv')))

          TabContent() {
            if (this.isInitPage[3]) {
              MyComponent()
            } else {
              Column()
            }
          }
          .tabBar(this.tabBuilder(3, '我的', $r('app.media.icon_user_active'), $r('app.media.icon_user')))

        }
        .barHeight(size.barHeight)
        .barMode(BarMode.Fixed)
        .onChange((index) => {
          this.isInitPage[index] = true;
          this.activeIndex = index
        })
      }

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

  async aboutToAppear() {
    const token: string = <string> await preference.getToken();
    getUserDataService(token).then((res) => {
      preference.setToke(res.token);
      httpRequest.setToken(res.token);
      AppStorage.SetOrCreate<UserDataInterface>(USER_DATA, res.data)
      this.isInitIndex = true;
    })
  }
}