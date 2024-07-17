import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import emitter from '@ohos.events.emitter'
import { MusicInterface,MusicStorageInterface } from '../interface';
import { getMusicListByClassifyIdService } from '../service/Index';
import { MUSIC_STORAGE } from '../../common/constant';
import { LIKE_INNER_EVENT } from '../../common/config';
import {usePlayerRouter, useAppStorage, getMusicCover} from '../../utils/common';

@Component
export default struct MusicClassifyComponent {
  @Prop classifyId: number;
  @Prop classifyName: string;
  @State musicList: Array<MusicInterface> = []
  @StorageLink(MUSIC_STORAGE) musicStorage: MusicStorageInterface = useAppStorage()

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  aboutToAppear() {
    getMusicListByClassifyIdService(this.classifyId, 1, 4).then((res) => {
      this.musicList = res.data;
    });
   this.useLikeEmitter();
  }

  /**
   * @description: 监听音乐是否收藏
   * @date: 2024-07-07 18:54
   * @author wuwenqiang
   */
  useLikeEmitter(){
    emitter.on(LIKE_INNER_EVENT, (data:emitter.EventData)=>{
      const musicModel:MusicInterface = data.data as MusicInterface;
      const musicItem = this.musicList.find(item => musicModel.id === item.id);
      musicItem && (musicItem.isLike = musicModel.isLike);
    });
  }

  /**
   * @description: 播放音乐分类
   * @date: 2024-07-17 22:23
   * @author wuwenqiang
   */
  async usePlayMusicList(musicModel:MusicInterface,index:number){
    let musicList:Array<MusicInterface> = [];
    if(this.musicStorage.classifyName !== this.classifyName){
      musicList = await getMusicListByClassifyIdService(this.classifyId,1,500).then(res=>res.data)
    }
    usePlayerRouter(this.musicStorage,musicList,musicModel,this.classifyName,index)
  }

  aboutToDisappear(){
    emitter.off(LIKE_INNER_EVENT.eventId);
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_down'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
        Text(this.classifyName).margin({ left: size.pagePadding }).layoutWeight(1)
        Text("更多")
      }.alignItems(VerticalAlign.Center)

      Column() {
        ForEach(this.musicList, (item: MusicInterface, index: number) => {
          Row({space:size.pagePadding}) {
            Image(getMusicCover(item.cover))
              .width(size.middleAvaterSize)
              .height(size.middleAvaterSize)
              .borderRadius(size.middleAvaterSize)
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
              .onClick(() => this.usePlayMusicList(item,index))
            Image((this.musicStorage.musicItem?.id === item.id && this.musicStorage.musicItem?.isLike === 1 || item.isLike === 0) ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
            Image($r("app.media.icon_music_menu"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
          }
          .alignItems(VerticalAlign.Center)
          .margin({ top: size.pagePadding })
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

      }
    }.blockStyle()
  }
}