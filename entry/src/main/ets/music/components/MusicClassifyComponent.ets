import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import emitter from '@ohos.events.emitter'
import { MusicInterface,MusicStorageInterface } from '../interface';
import { getMusicListByClassifyIdService } from '../service/Index';
import { HOST,MUSIC_STORAGE,LIKE_INNER_EVENT } from '../../config/constant';
import {usePlayerRouter, useAppStorage} from '../../utils/common';

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
      musicItem.isLike = musicModel.isLike;
    });
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
          Row() {
            Image(/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}', '480') : HOST + item.cover)
              .width(size.middleAvaterSize)
              .height(size.middleAvaterSize)
              .borderRadius(size.middleAvaterSize)
              .margin({ right: size.pagePadding })
            Column() {
              Text(item.songName)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(item.authorName).margin({ top: size.smallPadding / 2 })
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .fontColor(colors.disableTextColor)
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)

            Image(this.musicStorage.musicItem.id === item.id ? $r("app.media.icon_music_playing") : $r("app.media.icon_music_play"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .margin({ left: size.pagePadding })
              .onClick(() => usePlayerRouter(this.musicStorage,item,this.classifyId,index))
            Image((this.musicStorage.musicItem?.id === item.id && this.musicStorage.musicItem?.isLike === 1 || item.isLike === 0) ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .margin({ left: size.pagePadding })
            Image($r("app.media.icon_music_menu"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .margin({ left: size.pagePadding })
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