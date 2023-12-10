import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import AvaterComponent from './AvaterComponent';
import {UserDataInterface,UserMsgInterface} from '../interface/Index';
import {USER_DATA} from '../../config/constant';
import {getUserMsgService} from '../service/Index'
@Entry
@Component
export default struct MyComponent{
  scroller: Scroller = new Scroller()
  @State bigAvaterSize:number = size.bigAvaterSize;
  @State userMsg:UserMsgInterface = null;
  @StorageLink(USER_DATA) userData:UserDataInterface = null;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  aboutToAppear() {
    this.useUserMsgService()
  }

  /**
   * @description: 获取用户使用天数、访问记录数量等
   * @date: 2023-12-10 10:20
   * @author wuwenqiang
   */
  useUserMsgService(){
    getUserMsgService().then(res=>{
      this.userMsg = res.data
    })
  }

  build() {
    Column() {
      Scroll(this.scroller){
        Column(){
          Flex({alignItems:ItemAlign.Center}){
            AvaterComponent({dimensions:this.bigAvaterSize})
            Flex({direction:FlexDirection.Column}){
              Text(this.userData?.username || '')
                .fontSize(size.bigFontSize)
                .fontWeight(FontWeight.Bolder)
                .margin({bottom: size.smallPadding})
              Text(this.userData?.sign || '').fontColor(colors.disableTextColor)
            }
            .margin({left: size.pagePadding})
            .flexGrow(1)
            Image($r('app.media.icon_edit')).height(size.bigIconSize).width(size.bigIconSize)
          }.blockStyle().width('100%').align(Alignment.Center)
          Row(){
            Column(){
              Text(this.userMsg?.userAge.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('使用天数').fontColor(colors.disableTextColor).margin({top:size.smallPadding})
            }.flexGrow(1)
            Column(){
              Text(this.userMsg?.favoriteCount.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('收藏').fontColor(colors.disableTextColor).margin({top:size.smallPadding})
            }.flexGrow(1)
            Column(){
              Text(this.userMsg?.playRecordCount.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('观看记录').fontColor(colors.disableTextColor).margin({top:size.smallPadding})
            }.flexGrow(1)
            Column(){
              Text(this.userMsg?.viewRecordCount.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('浏览记录').fontColor(colors.disableTextColor).margin({top:size.smallPadding})
            }.flexGrow(1)
          }.blockStyle().width('100%')
        }
      }.scrollable(ScrollDirection.Vertical)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding, bottom: size.pagePadding })
  }
}