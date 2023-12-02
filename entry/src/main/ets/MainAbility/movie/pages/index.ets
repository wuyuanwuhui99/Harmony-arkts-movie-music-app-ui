import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import Home from './home'
import Movie from './movie'
import My from './my'
import TV from './tv'
import httpRequest from '../../utils/HttpUtil';
import {UserDataInterface} from '../interface/index'
import api from '../api/index';

@Entry
@Component
struct Index{
  @State activeIndex:number = 0;
  @State isInitPage:Array<boolean> = [true,false,false,false];

  build() {
    Column() {
      Tabs({
        index: this.activeIndex,
        barPosition: BarPosition.End
      }){
        //微信
        TabContent() {
          Home()
        }
        .tabBar(this.tabBuilder(0, '首页', $r('app.media.icon_home_active'), $r('app.media.icon_home')))

        //通讯录
        TabContent() {
          if(this.isInitPage[1]){
             Movie()
          }else{
            Column()
          }
        }
        .tabBar(this.tabBuilder(1, '电影', $r('app.media.icon_movie_active'), $r('app.media.icon_movie')))

        //发现
        TabContent() {
          if(this.isInitPage[2]){
            TV()
          }else{
            Column()
          }
        }
        .tabBar(this.tabBuilder(2, '电视剧', $r('app.media.icon_tv_active'), $r('app.media.icon_tv')))

        //我
        TabContent() {
          if(this.isInitPage[3]){
            My()
          }else{
            Column()
          }
        }
        .tabBar(this.tabBuilder(3, '我得', $r('app.media.icon_user_active'), $r('app.media.icon_user')))

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
        .width(30)
        .height(30)
        .margin({bottom:size.smallPadding})
      Text(title)
        .fontColor(this.activeIndex == index ? colors.tabSelectedColor : colors.tabNormalColor)
        .fontSize(size.normalFontSize)
        .padding({bottom:size.pagePadding})
    }
    .width(50)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  aboutToAppear(){
    httpRequest.get<UserDataInterface>(api.getUserData).then((res)=>{
      console.info(JSON.stringify(res))
    }).catch((err)=>{
      console.info(err)
    })
  }
}