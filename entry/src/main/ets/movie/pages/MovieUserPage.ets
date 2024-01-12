import { UserDataInterface } from "../interface";
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { HOST } from '../../config/constant';
import { USER_DATA } from '../../config/constant';
import { updateUserDataService } from '../service';

@Entry
@Component
struct MovieUserPage {
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  title: string = '';
  @State field: string = '';

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

  useShowDialog(title: string, field: string) {
    this.title = title;
    this.field = field;
    if(field === 'sex'){
      this.dialogController =  new CustomDialogController({
        customStyle: true,
        builder: OptionDialogComponent({
          cancel: ()=>this.onCancel(),
          confirm: (value)=>this.onConfirm(value),
          options: ['男', '女'],
        }),
        alignment: DialogAlignment.Bottom,
      })
    }else{
      this.dialogController = new CustomDialogController({
        customStyle: true,
        builder: CustomDialogComponent({
          cancel: ()=>this.onCancel(),
          confirm: (value)=>this.onConfirm(value),
          title: this.title,
          text: this.userData[this.field]
        }),
        alignment: DialogAlignment.Center,
      })
    }
    this.dialogController.open()
  }

  dialogController: CustomDialogController  = null

  onCancel() {
    this.dialogController.close()
  }

  /**
   * @description: 修改用户信息
   * @date: 2024-01-10 23:01
   * @author wuwenqiang
   */
  onConfirm(value) {
    const userData: UserDataInterface = { ...this.userData }
    userData[this.field] = value
    updateUserDataService(userData).then(() => {
      this.userData[this.field] = value;
      this.dialogController.close()
    })
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text('头像').flexGrow(1)
          Image(this.userData ? HOST + this.userData.avater : '')
            .height(size.bigAvaterSize)
            .width(size.bigAvaterSize)
            .borderRadius(size.bigAvaterSize)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center)

        Row() {
          Text('昵称').flexGrow(1)
          Text(this.userData.username)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(() => {
          this.useShowDialog('昵称', 'username')
        })

        Row() {
          Text('性别').flexGrow(1)
          Text(this.userData.sex)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(() => {
          this.useShowDialog('性别', 'sex')
        })

        Row() {
          Text('电话').flexGrow(1)
          Text(this.userData.telephone)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(() => {
          this.useShowDialog('电话', 'telephone')
        })

        Row() {
          Text('邮箱').flexGrow(1)
          Text(this.userData.email)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(() => {
          this.useShowDialog('邮箱', 'email')
        })

        Row() {
          Text('生日').flexGrow(1)
          Text(this.userData.birthday)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(() => {
          this.useShowDialog('生日', 'birthday')
        })

        Row() {
          Text('个性签名').flexGrow(1)
          Text(this.userData.sign)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().justifyContent(FlexAlign.Center).onClick(() => {
          this.useShowDialog('个性签名', 'sign')
        })

        Row() {
          Text('区域').flexGrow(1)
          Text(this.userData.region)
          Image($r('app.media.icon_arrow'))
            .margin({ left: size.smallPadding })
            .height(size.smallIconSize)
            .width(size.smallIconSize)
        }.rowStyle().border({ width: 0 }).justifyContent(FlexAlign.Center).onClick(() => {
          this.useShowDialog('区域', 'region')
        })

      }.blockStyle().padding({ top: 0, left: size.pagePadding, right: size.pagePadding })

      Text('退出登录')
        .width('100%')
        .padding(size.pagePadding)
        .textAlign(TextAlign.Center)
        .backgroundColor(colors.warnColor)
        .margin({ top: size.pagePadding })
        .fontColor(Color.White)
        .borderRadius(size.blockBorderRaduis)
    }
    .width('100%')
    .padding({ left: size.pagePadding, right: size.pagePadding })
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(colors.pageBackgroundColor)
  }
}

@CustomDialog
struct CustomDialogComponent {
  controller: CustomDialogController
  cancel: () => void
  confirm: (value: string) => void
  title: string
  text: string
  value: string

  aboutToAppear() {
    this.value = this.text
  }

  build() {
    Column() {
      Text("请输入")
        .margin({ top: size.pagePadding, bottom: size.pagePadding })
      Flex({alignItems:ItemAlign.Center}) {
        Text(this.title)
          .flexShrink(0)
          .margin({ right: size.smallIconSize })
        TextInput({ placeholder: '请输入', text: this.text })
          .flexGrow(1)
          .backgroundColor(colors.pageBackgroundColor)
          .height(size.lineHeight * 2)
          .onChange((value: string) => {
            this.value = value
          })
      }.margin(size.pagePadding)

      Flex({ justifyContent: FlexAlign.SpaceAround }) {
        Text('取消')
          .onClick(() => {
            this.controller.close()
            this.cancel()
          }).flexGrow(1)
          .textAlign(TextAlign.Center)
          .backgroundColor(colors.blockColor)
          .fontColor(Color.Black)
        Text('确定')
          .onClick(() => {
            this.confirm(this.value)
          })
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          .border({
            width: {
              left: 1,
            },
            color: {
              top: colors.pageBackgroundColor
            },
            style: {
              top: BorderStyle.Solid
            }
          })
          .backgroundColor(colors.blockColor)
          .fontColor(Color.Red)
      }.border({
        width: {
          top: 1,
        },
        color: {
          top: colors.pageBackgroundColor
        },
        style: {
          top: BorderStyle.Solid
        }
      }).padding({ top: size.pagePadding * 2, bottom: size.pagePadding * 2 })
    }
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .margin({ left: size.pagePadding, right: size.pagePadding })
  }
}


@CustomDialog
struct OptionDialogComponent {
  controller: CustomDialogController
  cancel: () => void
  confirm: (value: string) => void
  options: Array<string>

  build() {
    Column() {
      Column() {
        Text('男')
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding(size.pagePadding)
          .backgroundColor(colors.blockColor)
          .borderRadius(size.blockBorderRaduis)
          .onClick(()=>{
            this.confirm('男')
          })
        Divider()
          .height(1)
          .backgroundColor(colors.pageBackgroundColor)
        Text('女')
          .textAlign(TextAlign.Center)
          .width('100%')
          .padding(size.pagePadding)
          .onClick(()=>{
            this.confirm('女')
          })
      }.backgroundColor(colors.blockColor)
      .borderRadius(size.blockBorderRaduis)
      .padding({ left: size.pagePadding, right: size.pagePadding })

      Divider()
        .height(size.pagePadding)
        .backgroundColor(Color.Transparent)
      Text('取消')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding(size.pagePadding)
        .backgroundColor(colors.blockColor)
        .borderRadius(size.blockBorderRaduis)
        .onClick(() => {
          this.cancel()
        })
      Divider()
        .height(size.pagePadding)
        .backgroundColor(Color.Transparent)
    }.width('100%').backgroundColor(Color.Transparent).padding({ left: size.pagePadding, right: size.pagePadding })
  }
}