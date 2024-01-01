import {UserDataInterface} from "../interface";
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {HOST} from '../../config/constant';
import {USER_DATA} from '../../config/constant';

@Entry
@Component
struct MovieUserPage {
  @StorageLink(USER_DATA) userData:UserDataInterface = null;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @Styles rowStyle(){
    .border({
      width:{
        bottom:1,
      },
      color:{
        bottom:colors.disableTextColor
      },
      style:{
        bottom:BorderStyle.Solid
      }
    })
    .width('100%')
    .padding(size.lineHeight)
  }

  build() {
    Column(){
      Column(){
        Row(){
          Text('头像').flexGrow(1)
          Image(this.userData ? HOST + this.userData.avater : '')
            .height(size.bigAvaterSize)
            .width(size.bigAvaterSize)
            .borderRadius(size.bigAvaterSize)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('昵称').flexGrow(1)
          Text(this.userData.username)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('性别').flexGrow(1)
          Text(this.userData.birthday)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('电话').flexGrow(1)
          Text(this.userData.telephone)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('邮箱').flexGrow(1)
          Text(this.userData.email)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('生日').flexGrow(1)
          Text(this.userData.birthday)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('个性签名').flexGrow(1)
          Text(this.userData.sign)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('区域').flexGrow(1)
          Text(this.userData.region)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().border({width:0}).justifyContent(FlexAlign.Center)
      }.blockStyle().padding({top:0})
      Text('退出登录')
        .width('100%')
        .padding(size.pagePadding)
        .textAlign(TextAlign.Center)
        .backgroundColor(colors.warnColor)
        .margin({top:size.pagePadding})
        .fontColor(Color.White)
        .borderRadius(size.blockBorderRaduis)
    }.width('100%')
    .padding({left:size.pagePadding,right:size.pagePadding})
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(colors.pageBackgroundColor)
  }
}