import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { MusicInterface,MusicStorageInterface,LoopMode } from '../interface';
import { getMusicListByClassifyIdService } from '../service/Index';
import { HOST,MUSIC_STORAGE } from '../../config/constant';
import {useUpdateStorage} from '../../utils/common';

@Component
export default struct MusicClassifyComponent {
  @Prop classifyId: number;
  @Prop classifyName: string;
  @State musicList: Array<MusicInterface> = []
  @State musicStorage: MusicStorageInterface = AppStorage.Get<MusicStorageInterface>(MUSIC_STORAGE) || {
    musicItem: null,
    audio: null,
    isPlaying: true,
    isInitPlayer:false,
    musicList: [],
    classifyId: -1,
    total: 0,
    playIndex: -1,
    loop: LoopMode.ORDER,
    playList: [],// 还没有播放的音乐
    recordList:[]
  };

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
    })
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

            Image($r("app.media.icon_music_play"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .margin({ left: size.pagePadding })
              .onClick(()=>{
                if(this.musicStorage.musicItem?.id === item.id && this.musicStorage.musicList.length !== 0){
                  this.musicStorage.audio.play();
                  this.musicStorage.isPlaying = true;
                }else{
                  this.musicStorage.musicItem = item;
                  if(this.musicStorage.classifyId !== this.classifyId || this.musicStorage.musicList.length === 0){
                    getMusicListByClassifyIdService(this.classifyId,1,500).then((res)=>{
                      this.musicStorage.musicList = res.data;
                      this.musicStorage.playList = [...res.data];
                      this.musicStorage.playList.splice(index,1);
                      useUpdateStorage(this.musicStorage);
                    });
                    this.musicStorage.classifyId = this.classifyId;
                  }
                  useUpdateStorage(this.musicStorage);
                }
                router.pushUrl({url: 'music/pages/MusicPlayerPage'});
              })
            Image(item.isFavorite === 0 ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
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