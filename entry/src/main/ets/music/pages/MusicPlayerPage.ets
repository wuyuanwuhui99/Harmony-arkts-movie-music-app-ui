import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface } from '../interface/Index';
import display from '@ohos.display';
import {HOST} from '../../config/constant';

@Entry
@Component
struct MusicPlayerPage {

  @State musicItem:MusicInterface = null;
  private circleSize:number = px2vp(display.getDefaultDisplaySync().width * 0.8)
  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicItem = params['musicItem'] as MusicInterface; // 获取info属性的值
  }

  build(){
    Column({space:size.pagePadding}){
      Text(this.musicItem.songName)
        .margin({top:size.pagePadding,bottom:size.pagePadding})
        .fontColor(colors.blockColor)
        .fontSize(size.bigFontSize)
      Row(){
        Row(){
          Image(HOST + this.musicItem.cover)
            .width('100%')
            .aspectRatio(1)
            .borderRadius(this.circleSize - size.smallPadding * 12)
        }.linearGradient({
          direction: GradientDirection.Top, // 渐变方向
          repeating: true, // 渐变颜色是否重复
          colors: [[0x000000, 0.0], [0x333333, 0.5], [0x000000, 1]] // 数组末尾元素占比小于1时满足重复着色效果
        })
        .width(this.circleSize - size.smallPadding * 2)
        .aspectRatio(1)
        .padding(size.smallPadding * 5)
        .borderRadius(this.circleSize - size.smallPadding * 2)

      }
      .border({
        width: size.smallPadding,
        color: colors.playerOuterCircleColor,
        style: BorderStyle.Solid
      })
      .borderRadius(this.circleSize)
      .width('80%')
      .aspectRatio(1)
      Column().layoutWeight(1)
      Text(this.musicItem.authorName).width('80%').fontColor(colors.blockColor)
      Row(){
        Image($r('app.media.icon_music_collect')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_down')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_comments')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_white_menu')).width(size.middlIconSize).aspectRatio(1)
      }.width('80%').justifyContent(FlexAlign.SpaceBetween)
      Row({space:size.smallPadding}){
        Text("00:00").fontColor(colors.blockColor)
        Slider({value:0})
          .selectedColor(colors.blockColor)
          .layoutWeight(1)
        Text("30:00").fontColor(colors.blockColor)
      }.width('80%').alignItems(VerticalAlign.Center)

      Row(){
        Image($r('app.media.icon_music_order')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_prev')).width(size.middlIconSize).aspectRatio(1)
        Row(){
          Image($r('app.media.icon_music_play_white')).width(size.middlIconSize).aspectRatio(1)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .width(size.bigAvaterSize)
        .aspectRatio(1)
        .borderRadius(size.bigAvaterSize)
        .border({
          width: 1,
          color: colors.blockColor,
          style: BorderStyle.Solid
        })
        Image($r('app.media.icon_music_next')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_play_menu')).width(size.middlIconSize).aspectRatio(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({bottom:size.pagePadding})
    }
    .backgroundImage(HOST + this.musicItem.cover,ImageRepeat.NoRepeat)
    .backgroundImagePosition({x:0,y:0})
    .backgroundImageSize({width:'100%',height:'100%'})
    .backdropBlur(200)
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}