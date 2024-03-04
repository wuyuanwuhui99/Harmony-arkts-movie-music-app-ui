import * as colors from '../../theme/color';
import * as size from '../../theme/size';

@Component
export default struct MusicCircleComponent{
  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  build(){
    Row(){
      Column(){

      }
      Column(){}
      Column(){}
      Column(){}
    }
  }
}