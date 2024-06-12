import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface,MusicStorageInterface,LoopMode} from '../interface/Index';
import display from '@ohos.display';
import {HOST,MUSIC_STORAGE} from '../../config/constant';
import Lyric,{LineInterface} from '../../utils/Lyric';
import media from '@ohos.multimedia.media';
import { formatSecond } from '../../utils/common';
import {getMusicListByClassifyIdService,getClassifyMusicByIndexService} from '../service';
@Entry
@Component
struct MusicPlayerPage {
  @State lyric:Lyric = null;
  @State currentLineNum:number = 0;
  @State angle:number = 0;
  @State duration:number = 0;
  @State currentTime:number = 0;
  @State progress:number = 0;
  private scroller: Scroller = new Scroller()
  private circleSize:number = px2vp(display.getDefaultDisplaySync().width * 0.8)
  @State musicStorage: MusicStorageInterface = AppStorage.Get<MusicStorageInterface>(MUSIC_STORAGE) || {
    musicItem: null,
    audio: null,
    isPlaying: true,
    musicList: [],
    classifyId: -1,
    playIndex: -1,
    total: 0,
    loop: LoopMode.ORDER,
    playList: [],// 还没有播放的音乐
  };

  async aboutToAppear() {
    const params:any = router.getParams(); // 获取传递过来的参数对象
    const musicItem:MusicInterface = params.musicItem as MusicInterface; // 获取info属性的值
    const classifyId:number =  params.classifyId as number;
    if(this.musicStorage.classifyId !== classifyId || this.musicStorage.musicList.length === 0){
      this.musicStorage.classifyId = classifyId;
      getMusicListByClassifyIdService(this.musicStorage.classifyId, 1, 500).then(res => {
        this.musicStorage.total = res.total;
        this.musicStorage.musicList = res.data;
        this.musicStorage.playList = [...res.data];
        this.removeMusic();
        this.useUpdateStorage();
      });
    }

    if(this.musicStorage.audio == null || this.musicStorage.musicItem.id !== musicItem.id){
      this.musicStorage.musicItem = musicItem;
      this.musicStorage.audio = await media.createAVPlayer();
      this.setAVPlayerCallback();
      this.musicStorage.audio.url = HOST + musicItem.localPlayUrl;
      this.useUpdateStorage();
    }else{
      this.setAVPlayerCallback();
    }
    this.useLyric();
  }

  /**
   * @description: 从待播放列表中移除一首歌
   * @date: 2024-06-05 22:18
   * @author wuwenqiang
   */
  removeMusic(){
    const index = this.musicStorage.playList.findIndex(item => item.id === this.musicStorage.musicItem.id);
    this.musicStorage.playList.splice(index,1);
  }

  /**
   * @description: 更新缓存和状态管理器
   * @date: 2024-06-05 22:18
   * @author wuwenqiang
   */
  useUpdateStorage(){
    AppStorage.SetOrCreate<MusicStorageInterface>(MUSIC_STORAGE,this.musicStorage);
    const musicStorage:MusicStorageInterface =  {...this.musicStorage};
    // 列表数据不用存缓存，避免缓存过大，或者下次进来缓存没更新
    musicStorage.musicList = [];// 所有音乐
    musicStorage.playList = [];// 还没有播放的音乐
    PersistentStorage.PersistProp<MusicStorageInterface>(MUSIC_STORAGE, musicStorage);
  }

  useLyric(){
    if (!this.musicStorage.musicItem.lyrics) return;// 如果有歌词
    this.lyric = new Lyric(this.musicStorage.musicItem.lyrics, ({ lineNum = 0 }) => {
      // 滚动到相对应的歌词
      this.scroller.scrollToIndex(lineNum);
      // 当前播放的歌词下标
      this.currentLineNum = lineNum;
    })
  }

  // 注册avplayer回调函数
  setAVPlayerCallback() {
    // seek操作结果回调函数
    this.musicStorage.audio.off('seekDone');
    this.musicStorage.audio.off('stateChange');
    this.musicStorage.audio.off('timeUpdate');
    this.musicStorage.audio.off('durationUpdate');

    this.musicStorage.audio.on('seekDone', (seekDoneTime) => {
      console.info(`AVPlayer seek succeeded, seek time is ${seekDoneTime}`);
    })
    // 状态机变化回调函数
    this.musicStorage.audio.on('stateChange', async (state:string) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          this.musicStorage.audio.release(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          this.musicStorage.audio.prepare().then(() => {
          }, (err) => {
            console.error(`Invoke prepare failed, code is ${err.code}, message is ${err.message}`);
          });
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          this.musicStorage.audio.play(); // 调用播放接口开始播放
          break;
        case 'playing': // play成功调用后触发该状态机上报
          this.musicStorage.isPlaying = true;
          console.log('playing')
          break
        case 'paused': // pause成功调用后触发该状态机上报
          this.musicStorage.isPlaying = false;
          break;
        case 'completed': // 播放结束后触发该状态机上报
          this.useTabNextMusic();
          break;
        case 'stopped': // stop接口成功调用后触发该状态机上报
          this.musicStorage.isPlaying = false;
          break;
        case 'released':
          this.musicStorage.isPlaying = false;
          break;
      }
    });

    // 当前播放时长
    this.musicStorage.audio.on('timeUpdate',(millisecond:number)=>{
      this.currentTime = millisecond;
      this.angle += 5;
      if(this.angle === 360)this.angle = 0;
      if(this.duration){
        this.progress = Math.ceil((this.currentTime / this.duration) * 100)
      }
      this.lyric?.seek(Math.floor(millisecond));// 歌词跳转到对应的时间线
    })

    // 总时长
    this.musicStorage.audio.on('durationUpdate',(millisecond:number)=>{
      this.duration = millisecond
    });
  }

  /**
   * @description: 切换音乐
   * @date: 2024-06-05 23:38
   * @author wuwenqiang
   */
  async useTabMusic(){
    this.musicStorage.audio.release();
    this.musicStorage.musicItem = this.musicStorage.musicList[this.musicStorage.playIndex];
    this.musicStorage.audio = await media.createAVPlayer();
    this.setAVPlayerCallback();// 先设置音乐播放器，在赋值url，两行语句不能颠倒
    this.musicStorage.audio.url = HOST + this.musicStorage.musicItem.localPlayUrl;
    this.removeMusic();
    this.useLyric();
    this.useUpdateStorage();
  }

  async useTabNextMusic(){
    if(this.musicStorage.playIndex === this.musicStorage.musicList.length - 1){
      this.musicStorage.playIndex = 0;
    }else{
      this.musicStorage.playIndex++;
    }
    this.useTabMusic();
  }

  build(){
    Column({space:size.pagePadding}){
      Text(this.musicStorage.musicItem.songName)
        .margin({top:size.pagePadding,bottom:size.pagePadding})
        .fontColor(colors.blockColor)
        .fontSize(size.bigFontSize)
      Row(){
        Row(){
          Image(HOST + this.musicStorage.musicItem.cover)
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
      if(this.lyric?.lines.length > 0){
        // 歌词列表
        List({space:size.miniPadding,scroller:this.scroller}) {
          ForEach(this.lyric?.lines, (item: LineInterface, index: number) => {
            ListItem(){
              Text(item.txt)
                .fontColor(colors.blockColor)
                .opacity(this.currentLineNum === index ? 1 : 0.5)
                .alignSelf(ItemAlign.Center)
            }.width('100%')
          })
        }
        .width('100%')
        .layoutWeight(1)
      }else{
        Row(){
          Text("暂无歌词").fontColor(colors.blockColor).opacity(0.5)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }

      Text(this.musicStorage.musicItem.authorName).width('80%').fontColor(colors.blockColor)
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
        Image($r('app.media.icon_music_prev'))
          .width(size.middlIconSize)
          .aspectRatio(1)
          .onClick(async ()=>{
            if(this.musicStorage.playIndex === 0){
              this.musicStorage.playIndex = this.musicStorage.musicList.length - 1;
            }else{
              this.musicStorage.playIndex--;
            }
            this.useTabMusic();
          })
        Row(){
          Image(this.musicStorage.isPlaying ? $r('app.media.icon_music_playing') : $r('app.media.icon_music_play_white')).width(size.middlIconSize).aspectRatio(1)
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
        }).onClick(()=>{
          this.musicStorage.isPlaying = !this.musicStorage.isPlaying;
          this.musicStorage.audio[this.musicStorage.isPlaying ? 'play' : 'pause']()
        })
        Image($r('app.media.icon_music_next'))
          .width(size.middlIconSize)
          .aspectRatio(1)
          .onClick(this.useTabNextMusic)
        Image($r('app.media.icon_music_play_menu')).width(size.middlIconSize).aspectRatio(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({bottom:size.pagePadding})
    }
    .backgroundImage(HOST + this.musicStorage.musicItem.cover,ImageRepeat.NoRepeat)
    .backgroundImagePosition({x:0,y:0})
    .backgroundImageSize({width:'100%',height:'100%'})
    .backdropBlur(200)
    .alignItems(HorizontalAlign.Center)
    .height('100%')
    .width('100%')
  }
}