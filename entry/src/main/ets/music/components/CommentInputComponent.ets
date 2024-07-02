import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import promptAction from '@ohos.promptAction';

@CustomDialog
export default struct CommentInputComponent {
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
          .backgroundColor(colors.lineBackgroundColor)
          .width(size.btnWidth)
          .enabled(Boolean(this.text))
          .height(size.inputHeight)
          .margin({ left: size.pagePadding })
          .onClick(() => {
            this.onSend(this.text);
          })
      }.backgroundColor(colors.blockColor).padding(size.pagePadding)
    }
    .height('100%')
    .width('100%')
  }
}