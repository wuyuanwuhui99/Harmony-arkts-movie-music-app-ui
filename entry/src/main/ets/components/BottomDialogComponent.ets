import * as colors from '../theme/color';
import * as size from '../theme/size';

@CustomDialog
export default struct BottomDialogComponent {
  @Prop dialogHeight: string;
  @BuilderParam builder : () => void;
  // 使用父组件@Builder装饰的方法初始化子组件@BuilderParam
  controller: CustomDialogController

  // 弹窗中的内容描述
  build() {
    Column(){
      this.builder()
    }
    .borderRadius({topLeft:size.blockBorderRaduis,topRight:size.blockBorderRaduis})
    .height(this.dialogHeight)
    .width('100%')
    .backgroundColor(colors.blockColor)
  }
}