import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface, MusicStorageInterface, FavoriteDirectoryInterface, MusicClassifyInterface } from '../interface';
import { FAVORITE_MUSIC, MAX_PAGE_SIZE, MUSIC_STORAGE, PAGE_SIZE } from '../../common/constant';
import { LIKE_INNER_EVENT } from '../../common/config';
import { deleteMusicLikeService, getMusicListByClassifyIdService, getMusicListByFavoriteIdService, insertMusicLikeService } from '../service/Index';
import { getMusicCover, useAppStorage, usePlayerRouter, useUpdateStorage } from '../../utils/common';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';
import emitter from '@ohos.events.emitter';

@Entry
@Component
export default struct MusicFavoriteListPage {

  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  @State musicList:Array<MusicInterface> = [];
  @State pageNum:number = 1;
  @State total:number = 0;
  private loading:boolean = false;
  private musicClassify:MusicClassifyInterface;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
  }

  aboutToAppear(){
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicClassify = params['musicClassify'] as MusicClassifyInterface; // 获取info属性的值
    this.useMusicListByClassifyId();
    emitter.on(LIKE_INNER_EVENT, (data:emitter.EventData)=>{
      const musicModel:MusicInterface = data.data as MusicInterface;
      const musicItem = this.musicList.find(item => musicModel.id === item.id);
      musicItem && (musicItem.isLike = musicModel.isLike);
    });
  }

  /**
   * @description: 根据分类id查询音乐列表
   * @date: 2024-07-25 23:18
   * @author wuwenqiang
   */
  useMusicListByClassifyId(){
    getMusicListByClassifyIdService(this.musicClassify.id,this.pageNum,PAGE_SIZE).then((res) => {
      this.musicList.push(...res.data);
      this.total = res.total;
    })
  }

  /**
   * @description: 添加点赞或取消点赞
   * @date: 2024-05-12 11:45
   * @author wuwenqiang
   */
  useLike(musicModel:MusicInterface,index:number){
    if (this.loading) return;
    this.loading = true;
    if (musicModel.isLike === 1) {
      deleteMusicLikeService(musicModel.id).then((res) => {
        if (res.data > 0) {
          musicModel.isLike = 0;// 取消点赞标志
          // 对象解构之后，形成新的内存地址，相当于对象的浅拷贝,再把旧的对象替换掉
          this.musicList.splice(index,1,{...musicModel})
          useUpdateStorage(this.musicStorage);
          promptAction.showToast({
            message: "取消点赞成功",
            duration: 2000,
            bottom: px2vp(display.getDefaultDisplaySync().height) / 2
          });
          emitter.emit(LIKE_INNER_EVENT,{data:musicModel})
        }
      }).finally(() => this.loading = false)
    } else {
      insertMusicLikeService(musicModel.id).then(res => {
        if (res.data > 0) {
          musicModel.isLike = 1;// 添加点赞标志
          // 对象解构之后，形成新的内存地址，相当于对象的浅拷贝，再把旧的对象替换掉
          this.musicList.splice(index,1,{...musicModel})
          useUpdateStorage(this.musicStorage);
          promptAction.showToast({
            message: "添加收藏成功",
            duration: 2000,
            bottom: px2vp(display.getDefaultDisplaySync().height) / 2
          });
          emitter.emit(LIKE_INNER_EVENT,{data:musicModel})
        }
      }).finally(() => this.loading = false)
    }
  }

  /**
   * @description: 播放音乐分类
   * @date: 2024-07-17 22:23
   * @author wuwenqiang
   */
  async usePlayMusicList(musicModel:MusicInterface,index:number){
    let musicList:Array<MusicInterface> = [];
    if(this.musicStorage.classifyName !== this.musicClassify.classifyName){
      musicList = await getMusicListByFavoriteIdService(this.musicClassify.id,1,MAX_PAGE_SIZE).then(res=>res.data)
    }
    usePlayerRouter(this.musicStorage,musicList,musicModel,this.musicClassify.classifyName,index)
  }

  aboutToDisappear(){
    emitter.off(LIKE_INNER_EVENT.eventId);
  }

  build() {
    Column() {
      Row(){
        Image($r('app.media.icon_back'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
          .opacity(size.opacity)
          .onClick(()=>{
            router.back()
          })
        Text(this.musicClassify?.classifyName)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        Image($r('app.media.icon_back'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
          .visibility(Visibility.Hidden)
      }
      .width('100%')
      .padding(size.pagePadding)
      .backgroundColor(colors.blockColor)
      Scroll(){
        Column({space:size.pagePadding}){
          ForEach(this.musicList,(item:MusicInterface,index:number)=>{
            Row({space:size.pagePadding}){
              Image(getMusicCover(item.cover))
                .width(size.middleAvaterSize)
                .borderRadius(size.middleAvaterSize)
                .aspectRatio(1)
              Text(`${item.authorName} - ${item.songName}`).layoutWeight(1)
              Image(this.musicStorage.musicItem?.id === item.id && this.musicStorage.classifyName === this.musicClassify.classifyName && this.musicStorage.isPlaying ? $r("app.media.icon_music_playing_grey") : $r("app.media.icon_music_play"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .onClick(()=>this.usePlayMusicList(item,index))
              Image(item.isLike === 0 ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .onClick((()=>this.useLike(item,index)))
              Image($r("app.media.icon_music_menu"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
            }.width('100%')
            if(index !== this.musicList.length - 1){
              Divider().height(1).color(colors.pageBackgroundColor)
            }
          })
        }.blockStyle()
        Row() {
          Text(this.pageNum * PAGE_SIZE < this.total ? '正在加载更多...' : '已经到底了...')
        }.width('100%').padding({ top: size.pagePadding,bottom:size.pagePadding })
      }
      .padding(size.pagePadding)
      .align(Alignment.Top)
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      .onScrollEdge((side: Edge) => {
        if (this.pageNum * PAGE_SIZE < this.total) {
          this.pageNum++;
          this.useMusicListByClassifyId()
        }
      }) // 滚动方向纵向
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
  }
}