import * as colors from '../../theme/color';
import * as size from '../../theme/size';

@Entry
@Component
export default struct MovieComponent{

  build() {
    Row() {
      Text('电影').fontSize(15)
    }
    .width('100%')
    .height('100%')
  }
}