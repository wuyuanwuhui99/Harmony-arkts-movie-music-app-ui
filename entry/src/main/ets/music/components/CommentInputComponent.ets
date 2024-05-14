import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import promptAction from '@ohos.promptAction';

@CustomDialog
export default struct InputComponent {
  @State text: string = '';
  placeholder: string = '评论';
  onSend: (value: string) => void
  controller: CustomDialogController;

  build() {
    Column() {
      Blank().layoutWeight(1).onClick(() => {
        this.controller.close()
      })
      Row() {
        TextInput({ placeholder: this.placeholder, })
          .layoutWeight(1)
          .height(size.inputHeight)
          .onChange((value) => {
            this.text = value;
          })
        Button('发送', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(this.text ? colors.lineBackgroundColor : colors.disableTextColor)
          .width(size.btnWidth)
          .height(size.inputHeight)
          .margin({ left: size.pagePadding })
          .onClick(() => {
            if (!this.text.trim()) {
              promptAction.showToast({
                message: '评论或回复内容不能为空',
                duration: 2000,
                bottom: '50%'
              });
              return
            }
            this.onSend(this.text);
          })
      }.backgroundColor(colors.blockColor).padding(size.pagePadding)
    }
    .height('100%')
    .width('100%')
  }
}