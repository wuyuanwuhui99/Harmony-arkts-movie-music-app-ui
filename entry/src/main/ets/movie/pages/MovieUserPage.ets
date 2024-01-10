import {UserDataInterface} from "../interface";
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {HOST} from '../../config/constant';
import {USER_DATA} from '../../config/constant';
import {updateUserDataService} from '../service';

@Entry
@Component
struct MovieUserPage {
  @StorageLink(USER_DATA) userData:UserDataInterface = null;
  title:string = '';
  @State field:string = '';

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
        bottom:colors.pageBackgroundColor
      },
      style:{
        bottom:BorderStyle.Solid
      }
    })
    .width('100%')
    .padding({top:size.pagePadding,bottom:size.pagePadding})
  }

  useShowDialog(title:string,field:string){
    this.title = title;
    this.field = field;
    this.dialogController.open()
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: CustomDialogComponent({
      cancel: this.onCancel,
      confirm: this.onConfirm,
      title: this.title,
      text: this.userData[this.field]
    }),
    alignment: DialogAlignment.Default,
  })

  onCancel(){
    this.dialogController.close()
  }

  /**
   * @description: 修改用户信息
   * @date: 2024-01-10 23:01
   * @author wuwenqiang
   */
  onConfirm(value){
    const userData:UserDataInterface = {...this.userData}
    userData[this.field] = value
    updateUserDataService(userData).then(()=>{
      this.userData[this.field] = value;
      this.dialogController.close()
    })
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
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(()=>{
          this.useShowDialog('昵称','username')
        })

        Row(){
          Text('性别').flexGrow(1)
          Text(this.userData.birthday)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row(){
          Text('电话').flexGrow(1)
          Text(this.userData.telephone)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(()=>{
          this.useShowDialog('电话','telephone')
        })

        Row(){
          Text('邮箱').flexGrow(1)
          Text(this.userData.email)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(()=>{
          this.useShowDialog('邮箱','email')
        })

        Row(){
          Text('生日').flexGrow(1)
          Text(this.userData.birthday)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(()=>{
          this.useShowDialog('生日','birthday')
        })

        Row(){
          Text('个性签名').flexGrow(1)
          Text(this.userData.sign)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(()=>{
          this.useShowDialog('个性签名','sign')
        })

        Row(){
          Text('区域').flexGrow(1)
          Text(this.userData.region)
          Image($r('app.media.icon_arrow')).margin({left:size.smallPadding}).height(size.smallIconSize).width(size.smallIconSize)
        }.rowStyle().border({width:0}).justifyContent(FlexAlign.Center).onClick(()=>{
          this.useShowDialog('区域','region')
        })

      }.blockStyle().padding({top:0,left:size.pagePadding,right:size.pagePadding})
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

@CustomDialog
struct CustomDialogComponent {
  controller: CustomDialogController
  cancel: () => void
  confirm: (value:string) => void
  title: string
  text: string
  value:string

  aboutToAppear(){
    this.value = this.text
  }

  build() {
    Column() {
      Text("请输入").margin({top:size.pagePadding,bottom:size.pagePadding})
      Row(){
        Text(this.title).margin({right:size.smallIconSize})
        TextInput({placeholder:'请输入',text:this.text})
          .flexGrow(1)
          .backgroundColor(colors.pageBackgroundColor)
          .height(size.lineHeight*2)
          .onChange((value: string)=>{
            this.value = value
          })
      }.margin({left:size.pagePadding,right:size.pagePadding})
      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Button('取消')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).backgroundColor(colors.blockColor).fontColor(Color.Black)
        Button('确定')
          .onClick(() => {
            this.confirm(this.value)
          })
          .border({
            width:{
              left:1,
            },
            color:{
              top:colors.pageBackgroundColor
            },
            style:{
              top:BorderStyle.Solid
            }
          }).backgroundColor(colors.blockColor).fontColor(Color.Red)
      }.border({
        width:{
          top:1,
        },
        color:{
          top:colors.pageBackgroundColor
        },
        style:{
          top:BorderStyle.Solid
        }
      }).padding({top:size.pagePadding,bottom:size.pagePadding})
    }.borderRadius(size.blockBorderRaduis)
  }
}