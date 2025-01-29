import * as colors from '../theme/color';
import * as size from '../theme/size';
import { resetPasswordService } from '../service/Index';
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
struct ResetPasswordPage {
  code: string = '';
  password:string = "";
  comfirmPassword:string = ""
  email:string =  router.getParams()['email']; // 获取传递过来的参数对象
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
    if(this.loading)return true;
    if(!this.code){
      promptAction.showToast({
        message: "验证码不能为空",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      });
    }else if(this.code.length < 4){
      promptAction.showToast({
        message: "请输入四位数的验证码",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      });
    }else if(this.password !== this.comfirmPassword){
      promptAction.showToast({
        message: "密码和确认密码不一致",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      });
    } else if (this.verify(this.password,'密码') &&
      this.verify(this.password,'确认密码')) {
      this.loading = true;
      resetPasswordService(this.email,this.password,this.code).then(async (res)=>{
        // prompt.hideLoading()
        promptAction.showToast({
          message: res.msg,
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        });
        await preference.setToke(res.token);
        httpRequest.setToken(res.token);
        AppStorage.SetOrCreate<UserDataInterface>(USER_DATA, res.data)
        router.replaceUrl({
          url: 'pages/IndexPage', // 目标url
        });
        router.clear(); // 清除历史页面
      }).finally(()=>{
        // prompt.hideLoading()
        this.loading = false;
      })
    }
    this.loading = true;
  }

  build() {
    Column() {
      NavigatorTitleComponent({ title: "重置密码" })
      Column() {
        Column({space:size.pagePadding}){
          Row() {
            Text("*").fontColor(colors.warnColor)
            TextInput({ placeholder: "请输入验证码" })
              .layoutWeight(1)
              .backgroundColor(Color.Transparent)
              .onChange((value) => {
                this.code = value;
              })
          }
          Divider().height(size.pagePadding).color(colors.borderColor)
          Row() {
            Text("*").fontColor(colors.warnColor)
            TextInput({ placeholder: "请输入密码" })
              .layoutWeight(1)
              .type(InputType.Password)
              .backgroundColor(Color.Transparent)
              .onChange((value) => {
                this.password = value;
              })
          }
          Divider().height(size.pagePadding).color(colors.borderColor)
          Row() {
            Text("*").fontColor(colors.warnColor)
            TextInput({ placeholder: "请输入确认密码" })
              .layoutWeight(1)
              .type(InputType.Password)
              .backgroundColor(Color.Transparent)
              .onChange((value) => {
                this.comfirmPassword = value;
              })
          }
        }
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
