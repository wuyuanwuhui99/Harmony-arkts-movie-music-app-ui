import * as colors from '../../theme/color';
import * as size from '../../theme/size';

@Entry
@Component
export default struct TVComponent{

  build() {
    Column() {
      Flex({ direction: FlexDirection.Column}){
        Text('电视剧').fontSize(15)
      }.width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
}