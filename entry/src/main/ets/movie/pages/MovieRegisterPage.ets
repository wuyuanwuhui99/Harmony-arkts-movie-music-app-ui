import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { UserDataInterface } from '../interface';
import promptAction from '@ohos.promptAction'
import { registerService, verifyUserIdService } from '../service/Index';
import preference from '../../utils/PreferenceModel';
import display from '@ohos.display';
import OptionDialogComponent from '../components/OptionDialogComponent';
import { zerofull } from '../../utils/common';

@Entry
@Component
struct MovieRegisterPage {
  @State userData: UserDataInterface = {
    userId: '',
    username: '',
    telephone: '',
    email: '',
    avater: '',
    birthday: '',
    sex: '',
    role: '',
    password: '',
    sign: '',
    region: '',
  }
  loading: boolean = false;
  comfirmPassword: string = ''; // 确认密码
  sexController = new TextInputController()
  birthdayController = new TextInputController()

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @Styles inputStyle(){
    .border({
      width: {
        bottom: 1
      },
      color: {
        bottom: colors.borderColor
      },
      style: {
        bottom: BorderStyle.Solid
      }
    })
    .borderRadius(0)
    .backgroundColor(Color.Transparent)
    .width('80%')
  }

  dialogController: CustomDialogController = null; // 性别和姓名弹窗

  /**
   * @description: 校验必填字段
   * @date: 2024-01-14 21:47
   * @author wuwenqiang
   */
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

  build() {
    Column() {
      Column() {
        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("账号:")
          }.width('20%')

          TextInput({ placeholder: "请输入6-18位数的账号", text: this.userData.userId })
            .inputStyle()
            .maxLength(18)
            .onChange((value) => {
              this.userData.userId = value;
            }).onBlur(() => {
            if (this.verify(this.userData.userId, '账号')) {
              if (this.loading) return;
              this.loading = true;
              verifyUserIdService(this.userData.userId).then((res) => {
                if (res.data > 0) {
                  promptAction.showToast({
                    message: '该账号已经存在',
                    duration: 2000,
                    bottom: px2vp(display.getDefaultDisplaySync().height) / 2
                  });
                }
              }).finally(() => this.loading = false);
            }
          })
        }

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("密码:")
          }.width('20%')

          TextInput({ placeholder: "请输入6-18位数的密码", text: this.userData.password })
            .type(InputType.Password)
            .maxLength(18)
            .inputStyle()
            .onChange((value) => {
              this.userData.password = value;
            })
            .onBlur(() => {
              this.verify(this.userData.password, '密码')
            })
        }.margin({ top: size.pagePadding })

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("确认密码:")
          }.width('20%')

          TextInput({ placeholder: "请输入6-18位数的确认密码", text: this.comfirmPassword })
            .type(InputType.Password)
            .maxLength(18)
            .inputStyle()
            .onChange((value) => {
              this.comfirmPassword = value;
            })
            .onBlur(() => {
              this.verify(this.comfirmPassword, '确认密码');
            })
        }.margin({ top: size.pagePadding })

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("昵称:")
          }.width('20%')

          TextInput({ placeholder: "请输入6-18位数的确认昵称", text: this.userData.username })
            .inputStyle()
            .onChange((value) => {
              this.userData.username = value;
            }).onBlur(() => {
            this.verify(this.userData.username, '昵称');
          })
        }.margin({ top: size.pagePadding })

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("性别:")
          }.width('20%')

          TextInput({
            placeholder: "请选择性别",
            text: this.userData.sex,
            controller: this.birthdayController
          }).fontColor(colors.tabNormalColor).enabled(false).inputStyle()
        }.margin({ top: size.pagePadding }).onClick(() => {
          this.useShowDialog()
        })

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("出生日期:")
          }.width('20%')

          TextInput({
            placeholder: "请选择出生日期",
            text: this.userData.birthday,
            controller: this.birthdayController
          })
            .enabled(false)
            .inputStyle()
            .fontColor(colors.tabNormalColor)
            .onChange((value) => {
              this.userData.birthday = value;
            })
        }.margin({ top: size.pagePadding }).onClick(() => {
          DatePickerDialog.show({
            start: new Date("1970-1-1"),
            end: new Date("2100-12-31"),
            selected: new Date(this.userData.birthday || '1990-1-1'),
            onChange: (value: DatePickerResult) => {
              this.userData.birthday = `${value.year}-${zerofull(value.month + 1)}-${zerofull(value.day)}`;
            }
          })
        })

        Row() {
          Row() {
            Text("手机号码:")
          }.width('20%')

          TextInput({ placeholder: "请输入手机号码", text: this.userData.telephone })
            .inputStyle()
            .onChange((value) => {
              this.userData.telephone = value;
            })
        }.margin({ top: size.pagePadding })

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("邮箱:")
          }.width('20%')

          TextInput({ placeholder: "请输入邮箱", text: this.userData.email })
            .inputStyle()
            .onChange((value) => {
              this.userData.email = value;
            })
        }.margin({ top: size.pagePadding })

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("地区:")
          }.width('20%')

          TextInput({ placeholder: "请输入地区", text: this.userData.region })
            .inputStyle()
            .onChange((value) => {
              this.userData.region = value;
            })
        }.margin({ top: size.pagePadding })

        Row() {
          Row() {
            Text("*").fontColor(colors.warnColor)
            Text("个性签名:")
          }.width('20%')

          TextInput({ placeholder: "请输入个性签名", text: this.userData.sign })
            .inputStyle()
            .onChange((value) => {
              this.userData.sign = value;
            })
        }.margin({ top: size.pagePadding })

      }.blockStyle()

      Text('注册')
        .width('100%')
        .padding(size.pagePadding)
        .textAlign(TextAlign.Center)
        .backgroundColor(colors.warnColor)
        .margin({ top: size.pagePadding })
        .fontColor(Color.White)
        .borderRadius(size.blockBorderRaduis * 2)
        .onClick(() => {
          if (
            this.verify(this.userData.userId, '账号') &&
            this.verify(this.userData.userId, '密码') &&
            this.verify(this.userData.userId, '确认密码') &&
            this.verify(this.userData.userId, '昵称')
          ) {
            registerService(this.userData).then(async res => {
              preference.setPassword(this.userData.userId, this.userData.password)
              await preference.setToke(res.token)
              router.replaceUrl({
                url: 'movie/pages/Index', // 目标url
              }, router.RouterMode.Single, (err) => {
                if (err) {
                  console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
                }
              });
              router.clear()
            })
          }
        })
    }
    .width('100%')
    .height('100%')
    .padding({ left: size.pagePadding, right: size.pagePadding })
    .backgroundColor(colors.pageBackgroundColor)
  }

  useShowDialog() {
    this.dialogController = new CustomDialogController({
      customStyle: true,
      builder: OptionDialogComponent({
        cancel: () => this.onCancel(),
        confirm: (value) => this.onConfirm(value),
        options: ['男', '女'],
      }),
      alignment: DialogAlignment.Bottom,
    })
    this.dialogController.open()
  }

  onCancel() {
    this.dialogController.close()
  }

  /**
   * @description: 修改用户信息
   * @date: 2024-01-10 23:01
   * @author wuwenqiang
   */
  onConfirm(value) {
    this.userData.sex = value;
    this.dialogController.close();
  }
}
