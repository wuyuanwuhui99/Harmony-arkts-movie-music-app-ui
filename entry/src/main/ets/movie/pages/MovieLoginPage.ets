import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { loginService } from '../service/Index';
import { UserDataInterface } from '../interface';
import { USER_DATA } from '../../common/constant';
import promptAction from '@ohos.promptAction'
import display from '@ohos.display';
import preference from '../../utils/PreferenceModel';
import httpRequest from '../../utils/HttpUtil';

@Entry
@Component
struct MovieLoginPage {
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  userId: string = '';
  password: string = '';
  loading: boolean = false;

  async aboutToAppear(){
    this.userId = this.userData?.userId || '吴时吴刻';
    this.password = <string> await preference.getPassword(this.userData?.userId) || '123456';
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
    if (!this.userId) {
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
    loginService(this.userId, this.password).then(async res => {
      promptAction.showToast({
        message: "登录成功",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      })
      await preference.setToke(res.token);
      httpRequest.setToken(res.token);
      AppStorage.SetOrCreate<UserDataInterface>(USER_DATA, res.data)
      router.replaceUrl({
        url: 'movie/pages/IndexPage', // 目标url
      });
    }).catch((e) => {
      promptAction.showToast({
        message: "账号或密码错误，请重登录",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      })
    }).finally(() => {
      this.loading = false;
    })
  }

  build() {
    Column() {
      Column() {
        Image($r("app.media.icon_logo"))
          .width(size.bigIconSize * 3)
          .height(size.bigIconSize * 3)
          .margin({ top: size.pagePadding * 2, bottom: size.pagePadding * 2 })
        Row() {
          Image($r('app.media.icon_user_active'))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
            .margin({ left: size.smallPadding, right: size.smallPadding })
          TextInput({ placeholder: "请输入账号", text: this.userId })
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value) => {
              this.userId = value;
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
          TextInput({ placeholder: "请输入密码", text: '123456' })
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
              url: 'movie/pages/MovieRegisterPage', // 目标url
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
