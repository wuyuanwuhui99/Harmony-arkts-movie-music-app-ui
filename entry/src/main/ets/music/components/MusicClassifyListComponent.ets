import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import emitter from '@ohos.events.emitter'
import { MusicInterface,MusicStorageInterface } from '../interface';
import { deleteMusicLikeService, insertMusicLikeService } from '../service/Index';
import { MUSIC_STORAGE } from '../../common/constant';
import { LIKE_INNER_EVENT } from '../../common/config';
import {useAppStorage, useUpdateStorage} from '../../utils/common';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';
import MusicAvaterComponent from './MusicAvaterComponent';

@Component
export default struct MusicClassifyListComponent {
  @Link musicList: Array<MusicInterface>;
  @Prop classifyName:string;
  onPlayMusicList: (musicModel:MusicInterface,index:number) => void
  @StorageLink(MUSIC_STORAGE) musicStorage: MusicStorageInterface = useAppStorage()
  private loading:boolean = false;
  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
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

  build() {
    Column() {
      ForEach(this.musicList, (item: MusicInterface, index: number) => {
        Row({space:size.pagePadding}) {
          MusicAvaterComponent({avater:item.cover?.toString(),title:item.songName[0],dimension:Number(size.middleAvaterSize),type:'music'})
          Column() {
            Text(item.songName)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Text(item.authorName).margin({ top: size.smallPadding / 2 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontColor(colors.disableTextColor)
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          Image(this.musicStorage.musicItem?.id === item.id && this.musicStorage.classifyName === this.classifyName && this.musicStorage.isPlaying ? $r("app.media.icon_music_playing_grey") : $r("app.media.icon_music_play"))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
          Image((this.musicStorage.musicItem?.id === item.id && this.musicStorage.musicItem?.isLike === 1 || item.isLike === 0) ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
            .onClick(()=>{
              this.useLike(item,index);
            })
          Image($r("app.media.icon_music_menu"))
            .width(size.smallIconSize)
            .height(size.smallIconSize)
        }
        .onClick(() => this.onPlayMusicList(item,index))
        .alignItems(VerticalAlign.Center)
        .margin({ top: index === 0 ? 0 : size.pagePadding })
        .padding({ bottom: index === this.musicList.length - 1 ? 0 : size.pagePadding })
        .border({
          width: {
            bottom: index === this.musicList.length - 1 ? 0 : 1,
          },
          color: {
            bottom: colors.pageBackgroundColor
          },
          style: {
            bottom: BorderStyle.Solid
          }
        })
      })
    }.blockStyle()
  }
}