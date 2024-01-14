import * as colors from '../../theme/color';
import * as size from '../../theme/size';

@Entry
@Component
struct MovieLoginPage {

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @Styles rowStyle(){
    .border({
      width: {
        bottom: 1,
      },
      color: {
        bottom: colors.pageBackgroundColor
      },
      style: {
        bottom: BorderStyle.Solid
      }
    })
    .width('100%')
    .padding({ top: size.pagePadding, bottom: size.pagePadding })
  }

  build() {
    Column() {
      Column() {
        Image($r("app.media.icon_logo"))
          .width(size.bigIconSize * 3)
          .height(size.bigIconSize * 3)
          .margin({top:size.pagePadding * 2 ,bottom:size.pagePadding * 2 })
        Flex({direction:FlexDirection.Row,alignItems:ItemAlign.Center}){
          Image($r('app.media.icon_user_active'))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
            .margin({left:size.smallPadding,right:size.smallPadding})
          TextInput({placeholder:"请输入账号"})
            .flexGrow(1)
            .backgroundColor(Color.Transparent)
        }.padding(size.smallPadding).border({
          width:1,
          color:colors.pageBackgroundColor,
          style:BorderStyle.Solid
        }).borderRadius(size.blockBorderRaduis * 2)

        Flex({direction:FlexDirection.Row,alignItems:ItemAlign.Center}){
          Image($r('app.media.icon_password'))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
            .margin({left:size.smallPadding,right:size.smallPadding})
          TextInput({placeholder:"请输入密码"})
            .flexGrow(1)
            .backgroundColor(Color.Transparent)
        }.margin({top:size.pagePadding})
        .padding(size.smallPadding)
        .border({
          width:1,
          color:colors.pageBackgroundColor,
          style:BorderStyle.Solid
        })
        .borderRadius(size.blockBorderRaduis * 2)

        Text('登录')
          .width('100%')
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .backgroundColor(colors.warnColor)
          .margin({ top: size.pagePadding })
          .fontColor(Color.White)
          .borderRadius(size.blockBorderRaduis * 2)
          .onClick(()=>{

          })

        Text('注册')
          .padding(size.smallPadding)
          .border({
            width:1,
            color:colors.pageBackgroundColor,
            style:BorderStyle.Solid
          })
          .borderRadius(size.blockBorderRaduis * 2)
          .width('100%')
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .margin({ top: size.pagePadding })
          .onClick(()=>{

          })
      }
      .alignItems(HorizontalAlign.Center)
      .blockStyle()
      .padding({ top: 0, left: size.pagePadding, right: size.pagePadding })
      .flexGrow(1)
      Divider().height(size.pagePadding).color(Color.Transparent)
    }
    .width('100%')
    .height('100%')
    .padding({ left: size.pagePadding,right:size.pagePadding })
    .backgroundColor(colors.pageBackgroundColor)
  }
}
