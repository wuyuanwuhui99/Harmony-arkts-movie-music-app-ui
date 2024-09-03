import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface, MusicStorageInterface, FavoriteDirectoryInterface } from '../interface';
import { FAVORITE_MUSIC, MUSIC_STORAGE } from '../../common/constant';
import { LIKE_INNER_EVENT } from '../../common/config';
import {  getMusicListByFavoriteIdService } from '../service/Index';
import { getMusicCover, useAppStorage, usePlayerRouter } from '../../utils/common';
import emitter from '@ohos.events.emitter';
import MusicClassifyListComponent from '../components/MusicClassifyListComponent';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';

@Entry
@Component
export default struct MusicFavoriteListPage {

  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  @State favoriteDirectory:FavoriteDirectoryInterface = null;
  @State musicList:Array<MusicInterface> = [];
  @State pageNum:number = 1;
  @State total:number = 0;
  private loading:boolean = false;
  private pageSize:number = 20;
  private classifyName:string = "";

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
    this.classifyName = FAVORITE_MUSIC + this.favoriteDirectory.name;
    emitter.on(LIKE_INNER_EVENT, (data:emitter.EventData)=>{
      const musicModel:MusicInterface = data.data as MusicInterface;
      const musicItem = this.musicList.find(item => musicModel.id === item.id);
      musicItem && (musicItem.isLike = musicModel.isLike);
    });
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

  /**
   * @description: 播放音乐分类
   * @date: 2024-07-17 22:23
   * @author wuwenqiang
   */
  usePlayMusicList = async (musicModel:MusicInterface,index:number)=>{
    let musicList:Array<MusicInterface> = [];
    if(this.musicStorage.classifyName !== this.classifyName){
      musicList = await getMusicListByFavoriteIdService(this.favoriteDirectory.id,1,500).then(res=>res.data)
    }
    usePlayerRouter(this.musicStorage,musicList,musicModel,this.classifyName,index)
  }

  aboutToDisappear(){
    emitter.off(LIKE_INNER_EVENT.eventId);
  }

  build() {
    Column() {
      NavigatorTitleComponent({title:this.favoriteDirectory?.name || ''})
      Scroll(){
        Column(){
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

          MusicClassifyListComponent({musicList:$musicList,
            onPlayMusicList:this.usePlayMusicList,
            classifyName:this.classifyName.toString()// 使用toString防止把@State装饰的响应式变量传递到组件中，避免编辑器抛出警告
          })
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