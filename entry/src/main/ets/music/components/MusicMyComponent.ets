import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import AvaterComponent from '../../movie/components/AvaterComponent';
import { UserDataInterface } from '../../movie/interface/Index'
import { HOST,USER_DATA } from '../../config/constant';

@Component
export default struct MusicMyComponent{
  scroller: Scroller = new Scroller()

  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  @State dimensions:number = size.middleAvaterSize;// 导入的值不能直接传给组件

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  build(){
    Scroll(this.scroller) {
      Column(){
        Row(){
          AvaterComponent({dimensions:this.dimensions})
          Column(){
            Text(this.userData && this.userData.username).fontWeight(FontWeight.Bold)
            Text(this.userData && this.userData.sign).fontColor(colors.disableTextColor)
          }.alignItems(HorizontalAlign.Start).margin({left:size.pagePadding})
        }.blockStyle()

        Row(){
          Column(){
            Image($r("app.media.icon_menu_board"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("播放清单")
          }.width('25%')
          Column(){
            Image($r("app.media.icon_menu_like"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("喜欢")
          }.width('25%')
          Column(){
            Image($r("app.media.icon_menu_collect"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("收藏")
          }.width('25%')
          Column(){
            Image($r("app.media.icon_menu_history"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("历史播放")
          }.width('25%')
        }.blockStyle()

        Column(){
          Row(){
            Image($r("app.media.icon_down")).width(size.smallIconSize).height(size.smallIconSize)
            Text("我的歌单").margin({left:size.pagePadding})
            Blank()
            Image($r("app.media.icon_add")).width(size.smallIconSize).height(size.smallIconSize)
          }.width('100%')
        }.blockStyle()
      }

    }.scrollable(ScrollDirection.Vertical)
    .width("100%")
    .height("100%").align(Alignment.Top)
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}