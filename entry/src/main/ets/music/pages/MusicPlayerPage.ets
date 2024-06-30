import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { MusicStorageInterface,LoopMode,SwitchEnum, MusicInterface} from '../interface/Index';
import display from '@ohos.display';
import {HOST,MUSIC_STORAGE,LIKE_INNER_EVENT, SocialEnum} from '../../config/constant';
import Lyric,{LineInterface} from '../../utils/Lyric';
import media from '@ohos.multimedia.media';
import { formatSecond,useUpdateStorage, useAppStorage} from '../../utils/common';
import { deleteMusicLikeService, insertMusicLikeService, insertMusicRecordService } from '../service/Index';
import promptAction from '@ohos.promptAction';
import emitter from '@ohos.events.emitter'
import BottomDialogComponent from '../../movie/components/BottomDialogComponent';
import CommentComponent from '../../movie/components/CommentComponent';

@Entry
@Component
struct MusicPlayerPage {
  @State lyric:Lyric = null;
  @State currentLineNum:number = 0;
  @State angle:number = 0;
  @State duration:number = 0;
  @State currentTime:number = 0;
  @State progress:number = 0;
  @State showPopupLoopMode:boolean = false;
  @State @Watch("onMusicChange") musicModel:MusicInterface | null = null;
  private scroller: Scroller = new Scroller()
  private circleSize:number = px2vp(display.getDefaultDisplaySync().width * 0.8)
  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  private loopMode:object = {
    [LoopMode.ORDER]:$r('app.media.icon_music_order'),
    [LoopMode.REPEAT]:$r('app.media.icon_music_loop'),
    [LoopMode.RANDOM]:$r('app.media.icon_music_random')
  }
  private switchMode:SwitchEnum | null = null
  private loading:boolean = false;
  private customDialogController: CustomDialogController;

  async aboutToAppear() {
    if(this.musicStorage.audio == null){
      this.musicStorage.audio = await media.createAVPlayer();
      this.setAVPlayerCallback();
      this.musicStorage.audio.url = HOST + this.musicStorage.musicItem.localPlayUrl;
      this.musicStorage.recordList.push(this.musicStorage.musicItem)
      useUpdateStorage(this.musicStorage);
    }else{
      this.setAVPlayerCallback();
    }
    this.musicModel = this.musicStorage.musicItem;
  }

  onMusicChange(){
    this.useLyric();
  }


  /**
   * @description: 从待播放列表中移除一首歌
   * @date: 2024-06-05 22:18
   * @author wuwenqiang
   */
  removeMusic(){
    if(this.switchMode === SwitchEnum.PREV)return;
    const index = this.musicStorage.playList.findIndex(item => item.id === this.musicStorage.musicItem.id);
    if(index !== -1)this.musicStorage.playList.splice(index,1);
    const recordIndex =  this.musicStorage.recordList.findIndex(item => item.id === this.musicStorage.musicItem.id);
    if(recordIndex !== -1){
      this.musicStorage.recordList.splice(recordIndex,1);
    }
    this.musicStorage.recordList.push(this.musicStorage.musicItem);// 新播放的歌曲永远都置于栈底
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
    this.musicStorage.audio.off('timeUpdate');
    this.musicStorage.audio.off('durationUpdate');

    // 状态机变化回调函数
    if(!this.musicStorage.isInitPlayer){
      this.musicStorage.isInitPlayer = true;
      this.musicStorage.audio.on('stateChange', async (state:string) => {
        switch (state) {
          case 'idle': // 成功调用reset接口后触发该状态机上报
            this.musicStorage.audio.url = HOST + this.musicStorage.musicItem.localPlayUrl;
            this.musicStorage.audio.prepare(); // 调用release接口销毁实例对象
            break;
          case 'initialized': // avplayer 设置播放源后触发该状态上报
            this.musicStorage.audio.prepare();
            break;
          case 'prepared': // prepare调用成功后上报该状态机
            this.musicStorage.audio.play().then(() => insertMusicRecordService(this.musicStorage.musicItem)); // 调用播放接口开始播放
            break;
          case 'playing': // play成功调用后触发该状态机上报
            this.musicStorage.isPlaying = true;
            break;
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
    }

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
    this.musicStorage.musicItem = this.musicStorage.musicList[this.musicStorage.playIndex];
    this.musicStorage.audio.reset();
    this.removeMusic();
    this.musicModel = this.musicStorage.musicItem;
    useUpdateStorage(this.musicStorage);
  }

  /**
   * @description: 切换上一首音乐
   * @date: 2024-06-15 16:11
   * @author wuwenqiang
   */
  useTabPrevMusic = async () => {
    this.switchMode = SwitchEnum.PREV;
    if(this.musicStorage.loop === LoopMode.RANDOM && this.musicStorage.recordList.length > 1){
      // 随机播放切换到上一曲播放的音乐
      this.musicStorage.playIndex = this.musicStorage.musicList.findIndex(item => item.id === this.musicStorage.recordList[this.musicStorage.recordList.length - 2].id)
      this.musicStorage.recordList.pop();
    }else if(this.musicStorage.playIndex === 0){
      this.musicStorage.playIndex = this.musicStorage.musicList.length - 1;
    }else{
      this.musicStorage.playIndex--;
    }
    this.useTabMusic();
  }

  /**
   * @description: 切下一首音乐
   * @date: 2024-06-15 16:11
   * @author wuwenqiang
   */
  useTabNextMusic = async () => {
    if(this.musicStorage.loop === LoopMode.RANDOM){
      const randomIndex = Math.floor(Math.random() * this.musicStorage.playList.length);
      this.musicStorage.playIndex = this.musicStorage.musicList.findIndex(item => item.id === this.musicStorage.playList[randomIndex].id);
    } if(this.musicStorage.playIndex === this.musicStorage.musicList.length - 1){
      this.musicStorage.playIndex = 0;
    }else{
      this.musicStorage.playIndex++;
    }
    this.useTabMusic();
  }

  /**
   * @description: 切下一首音乐
   * @date: 2024-06-15 16:11
   * @author wuwenqiang
   */
  async useRandomMusic(){
    const randomIndex = Math.floor(Math.random() * this.musicStorage.playList.length);
    this.musicStorage.playIndex = this.musicStorage.musicList.findIndex(item => item.id === this.musicStorage.playList[randomIndex].id);
    this.useTabMusic();
  }

  /**
   * @description: 弹出循环模式选择
   * @date: 2024-06-15 16:11
   * @author wuwenqiang
   */
  @Builder popupBuilder(){
    Column(){
      Row(){
        Image($r('app.media.icon_music_order'))
          .width(size.smallIconSize)
          .aspectRatio(1)
        Text('顺序播放').margin({left:size.smallPadding}).fontColor(colors.blockColor)
      }.padding(size.pagePadding).onClick(()=>{
        this.showPopupLoopMode = false;
        this.musicStorage.loop = LoopMode.ORDER;
        useUpdateStorage(this.musicStorage);
      })
      Row(){
        Image($r('app.media.icon_music_loop'))
          .width(size.smallIconSize)
          .aspectRatio(1)
        Text('单曲循环').margin({left:size.smallPadding}).fontColor(colors.blockColor)
      }.padding(size.pagePadding).onClick(()=>{
        this.showPopupLoopMode = false;
        this.musicStorage.loop = LoopMode.REPEAT;
        useUpdateStorage(this.musicStorage);
      })
      Row(){
        Image($r('app.media.icon_music_random'))
          .width(size.smallIconSize)
          .aspectRatio(1)
        Text('随机播放').margin({left:size.smallPadding}).fontColor(colors.blockColor)
      }.padding(size.pagePadding).onClick(()=>{
        this.showPopupLoopMode = false;
        this.musicStorage.loop = LoopMode.RANDOM;
        useUpdateStorage(this.musicStorage);
      })
    }
  }

  /**
   * @description: 添加收藏或取消收藏
   * @date: 2024-05-12 11:45
   * @author wuwenqiang
   */
  useFavorite = () => {
    if (this.loading) return;
    this.loading = true;
    if (this.musicModel.isLike === 1) {
      deleteMusicLikeService(this.musicStorage.musicItem.id).then((res) => {
        if (res.data > 0) {
          this.musicModel.isLike = 0;
          useUpdateStorage(this.musicStorage);
          promptAction.showToast({
            message: "取消收藏成功",
            duration: 2000,
            bottom: px2vp(display.getDefaultDisplaySync().height) / 2
          });
          emitter.emit(LIKE_INNER_EVENT,{data:this.musicModel})
        }

      }).finally(() => this.loading = false)
    } else {
      insertMusicLikeService(this.musicStorage.musicItem.id).then(res => {
        if (res.data > 0) {
          this.musicModel.isLike = 1;
          useUpdateStorage(this.musicStorage);
          promptAction.showToast({
            message: "添加收藏成功",
            duration: 2000,
            bottom: px2vp(display.getDefaultDisplaySync().height) / 2
          });
          emitter.emit(LIKE_INNER_EVENT,{data:this.musicModel});
        }
      }).finally(() => this.loading = false)
    }
  }

  /**
   * @description: 评论弹窗
   * @date: 2024-06-30 14:36
   * @author wuwenqiang
   */
  useComment = () => {
    if (!this.customDialogController) {
      this.customDialogController = new CustomDialogController({
        customStyle: true,
        builder: BottomDialogComponent({
          dialogHeight: '80%',
          builder: this.commentBuilder.bind(this)
        }),
        alignment: DialogAlignment.Bottom,
      })
    }
    this.customDialogController.open();
  }

  /**
   * @author: wuwenqiang
   * @description: 创建评论
   * @date: 2024-05-25 16:30
   */
  @Builder commentBuilder() {
    CommentComponent({commentListStr:'' ,relationId: this.musicModel.id, type: SocialEnum.MUSIC.toString() })
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
        Image(this.musicModel?.isLike ? $r('app.media.icon_collection_active') : $r('app.media.icon_music_collect'))
          .width(size.middlIconSize)
          .aspectRatio(1)
          .onClick(this.useFavorite)
        Image($r('app.media.icon_music_down')).width(size.middlIconSize).aspectRatio(1)
        Image($r('app.media.icon_music_comments'))
          .width(size.middlIconSize)
          .aspectRatio(1)
          .onClick(this.useComment)
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
        Image(this.loopMode[this.musicStorage.loop])
          .width(size.middlIconSize)
          .aspectRatio(1)
          .onClick(()=>{
            this.showPopupLoopMode = true;
          }).bindPopup(this.showPopupLoopMode, {
          builder: this.popupBuilder,
          placement: Placement.Top,
          popupColor: colors.blackBackgroundColor,
          enableArrow: true,
          showInSubWindow: false,
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.showPopupLoopMode = false
            }
          }
        })
        Image($r('app.media.icon_music_prev'))
          .width(size.middlIconSize)
          .aspectRatio(1)
          .onClick(this.useTabPrevMusic)
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