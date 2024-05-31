import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface } from '../interface/Index';
import display from '@ohos.display';

@Entry
@Component
struct MusicPlayerPage {

  @State musicItem:MusicInterface = null;

  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicItem = params['musicItem'] as MusicInterface; // 获取info属性的值
  }

  build(){
    Column(){
      Text(this.musicItem.songName).margin({top:size.pagePadding * 2,bottom:size.pagePadding*2})
      Row(){

      }
      .backgroundColor(colors.playerOuterCircleColor)
      .width('80%')
      .borderRadius(px2vp(display.getDefaultDisplaySync().width * 0.8))
      .aspectRatio(1)
    }
    .height('100%')
    .width('100%')
  }
}