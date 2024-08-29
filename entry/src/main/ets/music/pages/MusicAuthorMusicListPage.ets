import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface, MusicStorageInterface, MusicAuthorInterface } from '../interface';
import { MAX_PAGE_SIZE, MUSIC_STORAGE, PAGE_SIZE } from '../../common/constant';
import { LIKE_INNER_EVENT } from '../../common/config';
import { getMusicListByAuthorIdService} from '../service/Index';
import { useAppStorage, usePlayerRouter } from '../../utils/common';
import emitter from '@ohos.events.emitter';
import MusicClassifyListComponent from '../components/MusicClassifyListComponent';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';

@Entry
@Component
export default struct MusicAuthorMusicListPage {

  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  @State musicList:Array<MusicInterface> = [];
  @State pageNum:number = 1;
  @State total:number = 0;
  @State musicAuthor:MusicAuthorInterface | null = null;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
  }

  aboutToAppear(){
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicAuthor = params['musicAuthor'] as MusicAuthorInterface; // 获取info属性的值
    this.useMusicListByAuthorId();
  }

  /**
   * @description: 根据收藏夹id查询音乐列表
   * @date: 2024-07-16 23:39
   * @author wuwenqiang
   */
  useMusicListByAuthorId(){
    getMusicListByAuthorIdService(this.musicAuthor!.authorId,this.pageNum,PAGE_SIZE).then((res) => {
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
    if(this.musicStorage.classifyName !== this.musicAuthor.authorName){
      musicList = await getMusicListByAuthorIdService(this.musicAuthor!.id,1,MAX_PAGE_SIZE).then(res=>res.data)
    }
    usePlayerRouter(this.musicStorage,musicList,musicModel,this.musicAuthor.authorName,index)
  }

  aboutToDisappear(){
    emitter.off(LIKE_INNER_EVENT.eventId);
  }

  build() {
    Column() {
      NavigatorTitleComponent({title:this.musicAuthor?.authorName || ''})
      Scroll(){
        MusicClassifyListComponent({
          musicList:$musicList,
          classifyName:this.musicAuthor.authorName,
          onPlayMusicList:this.usePlayMusicList,
        })
      }
      .onScrollEdge((side: Edge) => {
        if (this.pageNum * PAGE_SIZE < this.total) {
          this.pageNum++;
          this.useMusicListByAuthorId()
        }
      }) // 滚动方向纵向
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