import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { MusicStorageInterface, FavoriteDirectoryInterface, MusicInterface, MusicClassifyInterface } from '../interface';
import { MUSIC_STORAGE, PAGE_SIZE } from '../../common/constant';
import {  getMusicClassifyService, getMusicListByClassifyIdService } from '../service/Index';
import { useAppStorage, usePlayerRouter } from '../../utils/common';
import { MusicAuthorCategoryInterface } from '../interface/Index';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';
import MusicClassifyListComponent from '../components/MusicClassifyListComponent';

@Entry
@Component
export default struct MusicCategoryPage {

  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  @State favoriteDirectory:FavoriteDirectoryInterface = null;
  @State allCategoryList:Array<Array<MusicClassifyInterface>> = [];
  @State currentCategoryList:Array<Array<MusicClassifyInterface>> = [];
  @State musicList:Array<MusicInterface> = [];
  @State activeCategory:MusicClassifyInterface = null;
  @State pageNum:number = 1;
  @State total:number = 0;
  @State loading:boolean = false;
  @State expand:boolean = false;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  @Styles arrowIconStyle(){
    .width(size.smallIconSize)
    .height(size.smallIconSize)
  }

  aboutToAppear(){
    getMusicClassifyService().then((res)=>{
      for(let i = 0; i < Math.ceil(res.data.length/3) ; i++){
        const categoryList:Array<MusicClassifyInterface | null> = [];
        for(let j = 0; j < 3; j++){
          categoryList.push(res.data[i * 3 + j < res.data.length ? i * 3 + j : null])
        }
        this.allCategoryList.push(categoryList);
      }
      this.currentCategoryList.push(...this.allCategoryList.slice(0,3));
      this.activeCategory = this.currentCategoryList[0][0];
      this.useMusicList();
    });
  }

  /**
   * @description: 获取歌手列表
   * @date: 2024-08-20 00:15
   * @author wuwenqiang
   */
  useMusicList(){
    if(this.loading)return;
    this.loading = true;
    getMusicListByClassifyIdService(this.activeCategory.id,this.pageNum,PAGE_SIZE).then((res)=>{
      this.total = res.total;
      this.musicList.push(...res.data);
    }).finally(()=>{
      this.loading = false;
    });
  }

  /**
   * @description: 播放音乐分类
   * @date: 2024-07-17 22:23
   * @author wuwenqiang
   */
  async usePlayMusicList(musicModel:MusicInterface,index:number){
    let musicList:Array<MusicInterface> = [];
    if(this.musicStorage.classifyName !== this.activeCategory.classifyName){
      musicList = await getMusicListByClassifyIdService(this.activeCategory.id,1,500).then(res=>res.data)
    }
    usePlayerRouter(this.musicStorage,musicList,musicModel,this.activeCategory.classifyName,index)
  }

  build() {
    Column() {
      NavigatorTitleComponent({title:'歌手分类'})
      Scroll(){
        Column(){
          Column({space:size.smallPadding}){
            ForEach(this.currentCategoryList, (items: Array<MusicClassifyInterface>) => {
              Row({space:size.smallPadding}){
                ForEach(items,(item:MusicClassifyInterface)=>{
                  if(item){
                    Text(item.classifyName)
                      .border({
                        width: 1,
                        color: this.activeCategory?.id === item.id ? colors.tabSelectedColor :colors.borderColor,
                        style: BorderStyle.Solid
                      })
                      .onClick(()=>{
                        if(this.activeCategory?.id === item.id)return;
                        this.activeCategory = item;
                        this.musicList = [];
                        this.total = 0;
                        this.useMusicList();
                      })
                      .fontColor(this.activeCategory?.id === item.id ? colors.tabSelectedColor :colors.blackBackgroundColor)
                      .layoutWeight(1)
                      .textAlign(TextAlign.Center)
                      .height(size.inputHeight)
                      .borderRadius(size.smallBorderRaduis)
                  }else{
                    Text('').layoutWeight(1).visibility(Visibility.Hidden)
                  }
                })
              }
            })
            Row(){
              Text(this.expand ? '收起' : '展开更多').fontColor(colors.disableTextColor)
              Image($r('app.media.icon_arrow'))
                .opacity(size.opacity)
                .arrowIconStyle()
                .rotate({ angle: this.expand ? 90 : 0 })
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .onClick(()=>{
              this.expand = !this.expand;
              this.currentCategoryList.splice(0,this.currentCategoryList.length,...this.allCategoryList.slice(0,this.expand ? this.allCategoryList.length : 3));
            })
          }
          .blockStyle()
          MusicClassifyListComponent({
            musicList:$musicList,
            classifyName:this.activeCategory?.classifyName,
            onPlayMusicList:this.usePlayMusicList,
          })

          Row() {
            Text(this.pageNum * PAGE_SIZE < this.total || this.loading ? '正在加载更多...' : '已经到底了...')
          }.width('100%').justifyContent(FlexAlign.Center).padding({ top: size.pagePadding,bottom:size.pagePadding })
        }
        .justifyContent(FlexAlign.Start)
      }
      .onScrollEdge((side: Edge) => {
        if (this.pageNum * PAGE_SIZE < this.total) {
          this.pageNum++;
          this.useMusicList()
        }
      })
      .padding({left:size.pagePadding,right:size.pagePadding})
      .align(Alignment.Top)
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
  }
}