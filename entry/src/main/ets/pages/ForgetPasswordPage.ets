import * as colors from '../theme/color';
import * as size from '../theme/size';
import { getBackPasswordService } from '../service/Index';
import { UserDataInterface } from '../interface/Index';
import { USER_DATA } from '../common/constant';
import promptAction from '@ohos.promptAction'
import display from '@ohos.display';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';
import prompt from '@system.prompt'
import router from '@ohos.router';

@Entry
@Component
struct LoginPage {
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  email: string = '';
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

  useSumbit=()=>{
    if(this.loading)return true;
    if (!this.email) {
      return promptAction.showToast({
        message: "邮箱不能为空",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      })
    } else {
      // prompt.showLoading({
      //   message: '',
      //   loadingColor: 'blue',
      //   mask: true
      // })
      this.loading = true;
      getBackPasswordService(this.email).then((res)=>{
        // prompt.hideLoading()
        promptAction.showToast({
          message: res.msg,
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        });
        router.pushUrl({
          url: 'pages/ResetPasswordPage', // 目标url
          params: {
            email: this.email
          }
        }, router.RouterMode.Single, (err) => {
          if (err) {
            console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      }).finally(()=>{
        // prompt.hideLoading()
        this.loading = false;
      })
    }
    this.loading = true;
  }

  build() {
    Column() {
      NavigatorTitleComponent({ title: "忘记密码" })
      Column() {
        Row() {
          Text("*").fontColor(colors.warnColor)
          TextInput({ placeholder: "请输入邮箱" })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value) => {
              this.email = value;
            })
        }
        .alignItems(VerticalAlign.Center)
        .blockStyle()

        Text('提交')
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
