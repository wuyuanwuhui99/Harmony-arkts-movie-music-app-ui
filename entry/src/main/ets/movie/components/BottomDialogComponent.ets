import * as colors from '../../theme/color';
import * as size from '../../theme/size';

@CustomDialog
export default struct BottomDialogComponent {
  @BuilderParam builder:()=>{};

  controller: CustomDialogController

  // 弹窗中的内容描述
  build() {
    Column(){
      this.builder()
    }
    .borderRadius({topLeft:size.blockBorderRaduis,topRight:size.blockBorderRaduis})
    .height('80%')
    .width('100%')
    .backgroundColor(colors.blockColor)
  }
}