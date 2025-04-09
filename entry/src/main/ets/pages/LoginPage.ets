import router from '@ohos.router';
import * as colors from '../theme/color';
import * as size from '../theme/size';
import { loginByEmailService, loginService, sendEmailVertifyCodeService } from '../service/Index';
import { UserDataInterface } from '../interface/Index';
import { USER_DATA } from '../common/constant';
import promptAction from '@ohos.promptAction'
import display from '@ohos.display';
import preference from '../utils/PreferenceModel';
import httpRequest from '../utils/HttpUtil';
import { strictEmailRegex } from '../utils/common';
import GlobalLoading from "../components/GlobalLoading";
import LoadingController from '../controller/LoadingController';
@Entry
@Component
struct LoginPage {
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  userAccount: string = '';
  password: string = '';
  loading: boolean = false;
  email: string = "";// 邮箱
  code: string = "";// 验证码
  @State activeIndex:number = 0
  private loadingController:LoadingController = new LoadingController()

  async aboutToAppear(){
    this.userAccount = this.userData?.userAccount;
    this.password = <string> await preference.getPassword(this.userData?.userAccount);
  }

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

  useLogin=()=>{
    this.loadingController.showLoading();
    if(this.activeIndex === 0){
      if (!this.userAccount) {
        return promptAction.showToast({
          message: "账号不能为空",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
      } else if (!this.password) {
        return promptAction.showToast({
          message: "密码不能为空",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
      }
      this.loading = true;
      loginService(this.userAccount, this.password).then(async res => {
        promptAction.showToast({
          message: "登录成功",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
        await preference.setToke(res.token);
        httpRequest.setToken(res.token);
        AppStorage.SetOrCreate<UserDataInterface>(USER_DATA, res.data)
        router.replaceUrl({
          url: 'pages/MusicIndexPage', // 目标url
        });
      }).catch((e) => {
        promptAction.showToast({
          message: "账号或密码错误，请重登录",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
      }).finally(() => {
        this.loadingController.showLoading();
      })
    }else{
      if(!strictEmailRegex.test(this.email)){
        return  promptAction.showToast({
          message: "请输入正确的邮箱格式",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
      }else if(this.code.length !== 4){
        return  promptAction.showToast({
          message: "请输入4位数的验证码",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
      }
      loginByEmailService(this.email,this.code).then(async (res)=>{
        promptAction.showToast({
          message: "登录成功",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
        await preference.setToke(res.token);
        httpRequest.setToken(res.token);
        AppStorage.SetOrCreate<UserDataInterface>(USER_DATA, res.data)
        router.replaceUrl({
          url: 'pages/MusicIndexPage', // 目标url
        });
      }).catch(()=>{
        promptAction.showToast({
          message: "邮箱或者验证码错误",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
      }).finally(()=>{
        this.loadingController.hideLoading();
      })
    }

  }

  build() {
    Column() {
      GlobalLoading({controller:this.loadingController})
      Column() {
        Image($r("app.media.logo"))
          .width(size.bigIconSize * 3)
          .height(size.bigIconSize * 3)
          .margin({ top: size.pagePadding * 2, bottom: size.pagePadding * 2 })
        Row() {
          Row(){
            Text("账号密码登录").border({
              width: {
                bottom: 2,
              },
              color: {
                bottom: this.activeIndex === 0 ? colors.tabSelectedColor :colors.pageBackgroundColor
              },
              style: {
                bottom: BorderStyle.Solid
              }
            })
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .onClick(()=>{
            this.activeIndex = 0
          })
          Row(){
            Text("邮箱验证码登录").border({
              width: {
                bottom: 2,
              },
              color: {
                bottom: this.activeIndex === 1 ? colors.tabSelectedColor :colors.blockColor
              },
              style: {
                bottom: BorderStyle.Solid
              }
            })
          }.layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .onClick(()=>{
            this.activeIndex = 1
          })
        }.margin({bottom:size.pagePadding})
        if(this.activeIndex === 0){
          Column(){
            Row() {
              Image($r('app.media.icon_user_active'))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.smallPadding, right: size.smallPadding })
              TextInput({ placeholder: "请输入账号或邮箱", text: this.userAccount })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((value) => {
                  this.userAccount = value;
                })
            }
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .padding(size.smallPadding).border({
              width: 1,
              color: colors.pageBackgroundColor,
              style: BorderStyle.Solid
            }).borderRadius(size.blockBorderRaduis * 2)

            Row() {
              Image($r('app.media.icon_password'))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.smallPadding, right: size.smallPadding })
              TextInput({ placeholder: "请输入密码", text: this.password })
                .type(InputType.Password)
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((value) => {
                  this.password = value;
                })
            }
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .margin({ top: size.pagePadding })
            .padding(size.smallPadding)
            .border({
              width: 1,
              color: colors.pageBackgroundColor,
              style: BorderStyle.Solid
            })
            .borderRadius(size.blockBorderRaduis * 2)
          }
        }else{
          Column(){
            Row() {
              Image($r('app.media.icon_user_active'))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.smallPadding, right: size.smallPadding })
              TextInput({ placeholder: "请输入邮箱地址", text: this.email })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((value) => {
                  this.email = value;
                })
              Image($r('app.media.icon_send'))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.smallPadding, right: size.smallPadding })
                .onClick(()=>{
                  if(strictEmailRegex.test(this.email)){
                    sendEmailVertifyCodeService(this.email).then((res)=>{
                      promptAction.showToast({
                        message: res.msg,
                        duration: 2000,
                        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
                      })
                    })
                  }else{
                    promptAction.showToast({
                      message: "请输入正确的邮箱格式",
                      duration: 2000,
                      bottom: px2vp(display.getDefaultDisplaySync().height) / 2
                    })
                  }
                })
            }
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .padding(size.smallPadding).border({
              width: 1,
              color: colors.pageBackgroundColor,
              style: BorderStyle.Solid
            }).borderRadius(size.blockBorderRaduis * 2)

            Row() {
              Image($r('app.media.icon_password'))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.smallPadding, right: size.smallPadding })
              TextInput({ placeholder: "请输入验证码", text: '' })
                .layoutWeight(1)
                .backgroundColor(Color.Transparent)
                .onChange((value) => {
                  this.code = value;
                })
            }
            .alignItems(VerticalAlign.Center)
            .width('100%')
            .margin({ top: size.pagePadding })
            .padding(size.smallPadding)
            .border({
              width: 1,
              color: colors.pageBackgroundColor,
              style: BorderStyle.Solid
            })
            .borderRadius(size.blockBorderRaduis * 2)
          }
        }



        Text('登录')
          .width('100%')
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .backgroundColor(colors.warnColor)
          .margin({ top: size.pagePadding })
          .fontColor(Color.White)
          .borderRadius(size.blockBorderRaduis * 2)
          .onClick(this.useLogin)

        Text('注册')
          .padding(size.smallPadding)
          .border({
            width: 1,
            color: colors.borderColor,
            style: BorderStyle.Solid
          })
          .borderRadius(size.blockBorderRaduis * 2)
          .width('100%')
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .margin({ top: size.pagePadding })
          .onClick(() => {
            router.replaceUrl({
              url: 'pages/RegisterPage', // 目标url
            }, router.RouterMode.Single, (err) => {
              if (err) {
                console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
              }
            });
            router.clear();// 清除历史页面
          })

        Text('忘记密码')
          .padding(size.smallPadding)
          .border({
            width: 1,
            color: colors.borderColor,
            style: BorderStyle.Solid
          })
          .borderRadius(size.blockBorderRaduis * 2)
          .width('100%')
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .margin({ top: size.pagePadding })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ForgetPasswordPage', // 目标url
            }, router.RouterMode.Single, (err) => {
              if (err) {
                console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
              }
            });
            router.clear();// 清除历史页面
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
    .padding({ left: size.pagePadding, right: size.pagePadding })
    .backgroundColor(colors.pageBackgroundColor)
  }
}
