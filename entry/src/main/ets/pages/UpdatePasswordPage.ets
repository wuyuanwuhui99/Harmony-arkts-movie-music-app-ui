import * as colors from '../theme/color';
import * as size from '../theme/size';
import { updatePasswordService } from '../service/Index';
import { UserDataInterface } from '../interface/Index';
import { USER_DATA } from '../common/constant';
import promptAction from '@ohos.promptAction'
import display from '@ohos.display';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';
import router from '@ohos.router';
import preference from '../utils/PreferenceModel';
import httpRequest from '../utils/HttpUtil';

@Entry
@Component
struct UpdatePasswordPage {
  oldPassword: string = '';
  newPassword:string = "";
  newComfirmPassword:string = ""
  loading:boolean = false;

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

  verify(value: string, title: string) {
    if (value.length > 18 || value.length < 6) {
      promptAction.showToast({
        message: `请输入6-18的${title}`,
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      });
      return false;
    } else if (!value.trim()) {
      promptAction.showToast({
        message: `${title}不能为空`,
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      });
      return false;
    }
    return true;
  }

  useSumbit=()=>{
    if(this.newPassword && this.newComfirmPassword && this.newPassword !== this.newComfirmPassword){
      promptAction.showToast({
        message: "密码和确认密码不一致",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      });
    } else if (
      this.verify(this.oldPassword,'旧密码') &&
      this.verify(this.newPassword,'新密码') &&
      this.verify(this.newPassword,'确认新密码')
    ) {
      if(this.loading)return;
      this.loading = true;
      updatePasswordService(this.oldPassword,this.newPassword).then((res)=>{
        promptAction.showToast({
          message: `修改密码成功`,
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        });
        router.back();
      }).finally(()=>{
        this.loading = false;
      })
    }
  }

  build() {
    Column() {
      NavigatorTitleComponent({ title: "修改密码" })
      Column() {
        Column(){
          Row() {
            Text("*").fontColor(colors.warnColor)
            TextInput({ placeholder: "请输入旧密码" })
              .layoutWeight(1)
              .type(InputType.Password)
              .backgroundColor(Color.Transparent)
              .onChange((value) => {
                this.oldPassword = value;
              })
          }
          Divider().height(size.pagePadding).color(colors.borderColor)
          Row() {
            Text("*").fontColor(colors.warnColor)
            TextInput({ placeholder: "请输入新密码" })
              .layoutWeight(1)
              .type(InputType.Password)
              .backgroundColor(Color.Transparent)
              .onChange((value) => {
                this.newPassword = value;
              })
          }.margin({top:size.pagePadding})
          Divider().height(size.pagePadding).color(colors.borderColor)
          Row() {
            Text("*").fontColor(colors.warnColor)
            TextInput({ placeholder: "请输入新确认密码" })
              .layoutWeight(1)
              .type(InputType.Password)
              .backgroundColor(Color.Transparent)
              .onChange((value) => {
                this.newComfirmPassword = value;
              })
          }.margin({top:size.pagePadding})
        }
        .blockStyle()

        Text('确定')
          .width('100%')
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .backgroundColor(colors.warnColor)
          .margin({ top: size.pagePadding })
          .fontColor(Color.White)
          .borderRadius(size.blockBorderRaduis * 2)
          .onClick(this.useSumbit)

      }
      .width('100%')
      .height('100%')
      .padding({left:size.pagePadding,right:size.pagePadding})
      .backgroundColor(colors.pageBackgroundColor)
    }
  }
}
