import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface } from '../interface/Index';
import display from '@ohos.display';
import {HOST,MUSIC_STORAGE} from '../../config/constant';
import Lyric,{LineInterface} from '../../utils/Lyric';
import media from '@ohos.multimedia.media';
import { formatSecond } from '../../utils/common';

@Entry
@Component
struct MusicPlayerPage {
  @State lyric:Lyric = null;
  @State musicItem:MusicInterface = null;
  @State currentLineNum:number = 0;
  @State angle:number = 0;
  @State duration:number = 0;
  @State currentTime:number = 0;
  @State progress:number = 0;

  @StorageLink(MUSIC_STORAGE) avPlayer:media.AVPlayer | null  = null;

  private circleSize:number = px2vp(display.getDefaultDisplaySync().width * 0.8)

  async aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicItem = params['musicItem'] as MusicInterface; // 获取info属性的值

    if(this.avPlayer == null){
      this.avPlayer = await media.createAVPlayer();
      AppStorage.SetOrCreate<media.AVPlayer>(MUSIC_STORAGE, this.avPlayer);
      this.setAVPlayerCallback()
      this.avPlayer.url = HOST + this.musicItem.localPlayUrl;
    }

    if (!this.musicItem.lyrics) return;
    this.lyric = new Lyric(this.musicItem.lyrics, ({ lineNum = 0 }) => {
      this.currentLineNum = lineNum;
    })
  }

  // 注册avplayer回调函数
  setAVPlayerCallback() {
    // seek操作结果回调函数
    this.avPlayer.on('seekDone', (seekDoneTime) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // error回调监听函数,当avPlayer在操作过程中出现错误时调用reset接口触发重置流程
    this.avPlayer.on('error', (err) => {
      this.avPlayer.reset(); // 调用reset重置资源，触发idle状态
    })
    // 状态机变化回调函数
    this.avPlayer.on('stateChange', async (state:string) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          this.avPlayer.release(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          this.avPlayer.prepare().then(() => {
          }, (err) => {
            console.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          this.avPlayer.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
        case 'paused': // pause成功调用后触发该状态机上报
          this.avPlayer.play(); // 再次播放接口开始播放
          break;
        case 'completed': // 播放结束后触发该状态机上报
          this.avPlayer.stop(); //调用播放结束接口
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          this.avPlayer.reset(); // 调用reset接口初始化avplayer状态
          break;
        case 'released':
          break;
        default:
          break;
      }
    });

    // 当前播放时长
    this.avPlayer.on('timeUpdate',(millisecond:number)=>{
      this.currentTime = millisecond
      this.angle += 5;
      if(this.angle === 360)this.angle = 0;
      if(this.duration){
        this.progress = Math.ceil((this.currentTime / this.duration) * 100)
      }
    })

    // 总时长
    this.avPlayer.on('durationUpdate',(millisecond:number)=>{
      this.duration = millisecond
    })
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
        .rotate({ angle: this.angle })
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

      // 歌词
      Scroll(){
        Column(){
          if(this.lyric?.lines.length > 0){
            ForEach(this.lyric?.lines,(item:LineInterface,index:number)=>{
              Text(item.txt).fontColor(colors.blockColor).opacity(this.currentLineNum === index ? 1 : 0.5)
            })
          }else{
            Text("暂无歌词").fontColor(colors.blockColor).opacity(0.5)
          }
        }.alignItems(HorizontalAlign.Center).justifyContent(FlexAlign.Center)
      }.scrollable(ScrollDirection.Vertical).layoutWeight(1)

      Text(this.musicItem.authorName).width('80%').fontColor(colors.blockColor)
      Row(){
        Image($r('app.media.icon_music_collect')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_down')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_comments')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_white_menu')).width(size.middlIconSize).aspectRatio(1)
      }.width('80%').justifyContent(FlexAlign.SpaceBetween)
      Row({space:size.smallPadding}){
        Text(this.currentTime ? formatSecond(this.currentTime/1000) : '00:00').fontColor(colors.blockColor)
        Slider({value:this.progress})
          .selectedColor(colors.blockColor)
          .layoutWeight(1)
        Text(this.duration ? formatSecond(this.duration/1000) : '00:00').fontColor(colors.blockColor)
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
          width: 2,
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