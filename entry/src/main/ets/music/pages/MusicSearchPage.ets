import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface, MusicStorageInterface } from '../interface';
import TitleComponent from '../../movie/components/TitleComponent';
import { HOST, MUSIC_SEARCH, MUSIC_STORAGE } from '../../common/constant';
import { LIKE_INNER_EVENT } from '../../common/config';
import { deleteMusicLikeService, insertMusicLikeService, searchMusicService } from '../service/Index';
import { useAppStorage, useUpdateStorage } from '../../utils/common';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';
import emitter from '@ohos.events.emitter';

@Entry
@Component
export default struct MusicSearchPage {
  @State searchKeyWord:string = '黄昏';
  @State loading:boolean = false;
  @State searching:boolean = false;
  @State musicItem:MusicInterface = null;
  @State searchRecordList:Array<string> = AppStorage.Get(MUSIC_SEARCH) || [];
  @State searchMusicList:Array<MusicInterface> = [];// 搜索结果
  @State total:number = 0;
  private pageNum:number = 1;
  private pageSize:number = 20;
  private loadingMore:boolean = false;
  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }


  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicItem = params['musicItem'] as MusicInterface; // 获取info属性的值
    this.useLikeEmitter();
  }

  useLikeEmitter(){
    emitter.on(LIKE_INNER_EVENT, (data:emitter.EventData)=>{
      const musicModel:MusicInterface = data.data as MusicInterface;
      const musicItem = this.searchMusicList.find(item => musicModel.id === item.id);
      musicItem.isLike = musicModel.isLike;
    });
  }

  /**
   * @description: 音乐搜索
   * @date: 2024-07-06 09:04
   * @author wuwenqiang
   */
  useSearch = () => {
    if (this.loading) return;
    this.loading = true;
    this.searching = true;
    if (!this.searchKeyWord) {
      this.searchKeyWord = this.musicItem.songName;
    }
    const index:number = this.searchRecordList.findIndex(item => item === this.searchKeyWord);
    index !== -1 && this.searchRecordList.splice(index,1);
    this.searchRecordList.unshift(this.searchKeyWord)
    this.pageNum = 1;
    // 搜索记录写入缓存
    PersistentStorage.PersistProp<Array<string>>(MUSIC_SEARCH, this.searchRecordList);
    // 搜索
    searchMusicService(encodeURIComponent(this.searchKeyWord), this.pageNum, this.pageSize).then((res) => {
      this.searchMusicList = res.data;
      this.total = res.total;
    }).finally(() => this.loading = false);
  }

  /**
   * @description: 加载更多
   * @date: 2024-07-06 09:04
   * @author wuwenqiang
   */
  useLoadMore = () => {
    if (this.total > this.pageNum * this.pageSize) {
      this.pageNum++;
      if(this.loadingMore)return;
      this.loadingMore = true;
      searchMusicService(encodeURIComponent(this.searchKeyWord), this.pageNum, this.pageSize).then((res) => {
        this.searchMusicList.push(...res.data);
      }).finally(() => this.loadingMore = false);
    }
  }

  /**
   * @description: 加载更多
   * @date: 2024-07-07 18:14
   * @author wuwenqiang
   */
  usePlay(musicModel:MusicInterface,index:number){
    const { musicList,playIndex,recordList,playList,musicItem } = this.musicStorage;
    if(musicList.length == 0){
      this.musicStorage.playIndex = index;
      musicList.push(...this.searchMusicList);
      playList.push(...this.searchMusicList);
      recordList.push(...playList.splice(index,1));
      this.musicStorage.musicItem = musicModel;
      useUpdateStorage(this.musicStorage);
    }else if(musicModel.id !== musicItem.id){
      musicList.splice(playIndex,0,musicModel)
      this.musicStorage.musicItem = musicModel;
      useUpdateStorage(this.musicStorage);
    }
    router.pushUrl({
      url: 'music/pages/MusicPlayerPage', // 目标url
    });
  }

  /**
   * @description: 添加点赞或取消点赞
   * @date: 2024-07-07 18:50
   * @author wuwenqiang
   */
  useLike = (musicModel:MusicInterface,index:number) => {
    if (this.loading) return;
    this.loading = true;
    if (musicModel.isLike === 1) {
      deleteMusicLikeService(musicModel.id).then((res) => {
        if (res.data > 0) {
          musicModel.isLike = 0;
          this.searchMusicList.splice(index,1,{...musicModel});
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
          musicModel.isLike = 1;
          this.searchMusicList.splice(index,1,{...musicModel});
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
   * @description: 点击搜索记录
   * @date: 2024-07-09 22:05
   * @author wuwenqiang
   */
  useLabelSearch(item:string){
    this.searchKeyWord = item;
    this.useSearch();
  }

  aboutToDisappear(){
    emitter.off(LIKE_INNER_EVENT.eventId);// 移除监听点赞事件
  }

  build() {
    Column() {
      Row({space:size.pagePadding}){
        Row() {
          TextInput({text:this.searchKeyWord,placeholder:this.musicItem ? `${this.musicItem.authorName} - ${this.musicItem.songName}` : '请输入歌曲名或者歌手'})
            .height(size.middleAvaterSize)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value) => {
              this.searchKeyWord = value.trim();
            })

          if (this.searchKeyWord) {
            Image($r('app.media.icon_clear'))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .onClick(() => {
                this.searchKeyWord = '';
              })
              .margin({right: size.pagePadding })
              .onClick(() => {
                this.searchKeyWord = '';
                this.searching = false;
              })
          }
        }
        .borderRadius(size.middleAvaterSize)
        .backgroundColor(colors.pageBackgroundColor)
        .layoutWeight(1)

        Button('搜索', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(colors.lineBackgroundColor)
          .width(size.btnWidth)
          .height(size.inputHeight)
          .onClick(this.useSearch)
      }.blockStyle()

      if(this.searching){
        if (!this.loading) {
          if (this.searchMusicList.length === 0) {
            Column() {
              Text("暂无搜索结果")
                .width('100%')
                .height(size.bigAvaterSize)
                .textAlign(TextAlign.Center)
            }.blockStyle()
          }else{
            Scroll(){
              Column({space:size.pagePadding}){
                ForEach(this.searchMusicList,(item:MusicInterface,index:number) => {
                  Row({space:size.pagePadding}){
                    Image(/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}', '480') : HOST + item.cover)
                      .width(size.middleAvaterSize)
                      .aspectRatio(1)
                      .borderRadius(size.middleAvaterSize)
                    Column({space:size.smallPadding}){
                      Text(item.songName)
                      Text(item.authorName).fontColor(colors.disableTextColor)
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                    Image(this.musicStorage.musicItem.id === item.id ? $r("app.media.icon_music_playing") : $r("app.media.icon_music_play"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                      .onClick(() => {})
                    Image(item.isLike ? $r("app.media.icon_like_active") : $r("app.media.icon_like"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                      .margin({ left: size.pagePadding })
                      .onClick(() => this.useLike(item,index))
                    Image($r("app.media.icon_music_menu"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                  }
                  .alignItems(VerticalAlign.Center)
                  .onClick(()=>this.usePlay(item,index))
                  if(index !== this.searchMusicList.length - 1)Divider().height(1).color(colors.borderColor)
                })
              }.blockStyle().margin({top:0,bottom:size.pagePadding}).justifyContent(FlexAlign.Start)
            }.layoutWeight(1).onScrollEdge(this.useLoadMore)
          }
        }
      }else{
        Column(){
          TitleComponent({ title: "历史搜索",showMarginBottom:false})
          Flex({wrap:FlexWrap.Wrap,direction:FlexDirection.Row,justifyContent: FlexAlign.SpaceBetween}){
            ForEach(this.searchRecordList,(item:string)=>{
              Button(item)
                .fontColor(colors.disableTextColor)
                .margin({top:size.pagePadding})
                .height(size.inputHeight)
                .backgroundColor(colors.pageBackgroundColor)
                .borderRadius(size.blockBorderRaduis * 2)
                .onClick(() => this.useLabelSearch(item))
                .padding({left:size.pagePadding * 2,right:size.pagePadding * 2})
            })
          }
        }.blockStyle()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}