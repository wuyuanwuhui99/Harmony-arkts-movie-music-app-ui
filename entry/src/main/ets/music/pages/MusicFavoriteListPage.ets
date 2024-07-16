import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface, MusicStorageInterface,CircleInterface, FavoriteDirectoryInterface } from '../interface';
import { HOST, MUSIC_SEARCH, MUSIC_STORAGE } from '../../common/constant';
import { SocialEnum } from '../../common/enum';
import { LIKE_INNER_EVENT, PermissionValueMap } from '../../common/config';
import { getMusicListByFavoriteIdService } from '../service/Index';
import { getMusicCover, useAppStorage, useUpdateStorage } from '../../utils/common';

@Entry
@Component
export default struct MusicFavoriteListPage {

  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  @State favoriteDirectory:FavoriteDirectoryInterface = null;
  @State musicList:Array<MusicInterface> = [];
  @State pageNum:number = 1;
  @State total:number = 0;
  private pageSize:number = 20;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
  }

  aboutToAppear(){
    const params = router.getParams(); // 获取传递过来的参数对象
    this.favoriteDirectory = params['favoriteDirectory'] as FavoriteDirectoryInterface; // 获取info属性的值
    this.useMusicListByFavoriteId();
  }

  /**
   * @description: 根据收藏夹id查询音乐列表
   * @date: 2024-07-16 23:39
   * @author wuwenqiang
   */
  useMusicListByFavoriteId(){
    getMusicListByFavoriteIdService(this.favoriteDirectory.id,this.pageNum,this.pageSize).then((res) => {
      this.musicList.push(...res.data);
      this.total = res.total;
    })
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
        Text(this.favoriteDirectory?.name)
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
          Row({space:size.pagePadding}){
            Image(getMusicCover(this.favoriteDirectory?.cover))
              .width(size.bigAvaterSize)
              .aspectRatio(1)
              .borderRadius(size.blockBorderRaduis)
            Column({space:size.pagePadding}){
              Text(this.favoriteDirectory?.name)
              Text(`${this.favoriteDirectory?.total}首`).fontColor(colors.disableTextColor)
            }
            .alignItems(HorizontalAlign.Start)
          }.alignItems(VerticalAlign.Top).blockStyle()

          Column({space:size.pagePadding}){
            ForEach(this.musicList,(item:MusicInterface)=>{
              Row({space:size.pagePadding}){
                Image(getMusicCover(item.cover))
                  .width(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                  .aspectRatio(1)
                Text(`${item.authorName} - ${item.songName}`).layoutWeight(1)
                Image(this.musicStorage.musicItem?.id === item.id && this.musicStorage.isPlaying ? $r("app.media.icon_music_playing_grey") : $r("app.media.icon_music_play"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                Image((this.musicStorage.musicItem?.id === item.id && this.musicStorage.musicItem?.isLike === 1 || item.isLike === 0) ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              }.width('100%')
            })
          }.blockStyle()
        }.justifyContent(FlexAlign.Start)

      }
      .padding(size.pagePadding)
      .align(Alignment.Top)
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
  }
}