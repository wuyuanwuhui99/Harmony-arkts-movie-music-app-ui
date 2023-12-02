import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {UserDataInterface,Movieinterface} from '../interface/index'
import {HOST} from '../../config/constant';
import httpRequest from '../../utils/HttpUtil';
import api from '../api/index';
import {USER_DATA} from '../../config/constant';
@Entry
@Component
export default struct Home{
  @State searchKeyWord:string = '';
  @StorageLink(USER_DATA) userData:UserDataInterface = null;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }
  @Styles classifyItemStyle(){
    .width(size.largeIconSize)
    .height(size.largeIconSize)
    .margin({bottom:size.smallPadding})
  }

  aboutToAppear(){
    this.useSearchKeyWord()
  }


  useSearchKeyWord(){
    httpRequest.get<Movieinterface>(api.getKeyWord,{classify:"电影"}).then((res)=>{
      this.searchKeyWord = res.data.movieName;
    })
  }

  build() {
    Column() {
      Scroll(){
        Column(){
          Row(){
            Image(this.userData ? HOST + this.userData.avater : '')
              .height(size.middleavaterSize)
              .width(size.middleavaterSize)
              .borderRadius(size.middleavaterSize)
            Row(){
              Text(this.searchKeyWord)
                .fontSize(size.normalFontSize)
                .fontColor(colors.disableTextColor)
            }
            .height(size.middleavaterSize)
            .borderRadius(size.middleavaterSize)
            .backgroundColor(colors.pageBackgroundColor)
            .margin({left: size.pagePadding})
            .padding({left: size.pagePadding})
            .flexGrow(1)
          }.blockStyle()
          Row(){
            Column(){
              Image($r('app.media.icon_hot')).classifyItemStyle()
              Text('热门').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column(){
              Image($r('app.media.icon_play')).classifyItemStyle()
              Text('预告').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column(){
              Image($r('app.media.icon_top')).classifyItemStyle()
              Text('最新').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column(){
              Image($r('app.media.icon_classify')).classifyItemStyle()
              Text('分类').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }.blockStyle()
        }
      }
      .scrollable(ScrollDirection.Vertical)  // 滚动方向纵向
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({left:size.pagePadding,right:size.pagePadding,bottom:size.pagePadding})
  }
}