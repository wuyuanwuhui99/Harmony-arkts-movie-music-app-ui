import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { MusicStorageInterface, FavoriteDirectoryInterface } from '../interface';
import { MUSIC_STORAGE, PAGE_SIZE } from '../../common/constant';
import { getMusicAuthorCategoryService, getMusicAuthorListService } from '../service/Index';
import { getMusicCover, useAppStorage } from '../../utils/common';
import { MusicAuthorInterface, SingerCategoryInterface } from '../interface/Index';
import NavigatorTitleComponent from '../components/NavigatorTitleComponent';

@Entry
@Component
export default struct MusicSingerPage {

  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  @State favoriteDirectory:FavoriteDirectoryInterface = null;
  @State categoryList:Array<Array<SingerCategoryInterface>> = [];
  @State musicAuthorList:Array<MusicAuthorInterface> = [];
  @State activeCategoryItem:SingerCategoryInterface = null;
  @State pageNum:number = 1;
  @State total:number = 0;
  @State loading:boolean = false;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  aboutToAppear(){
    getMusicAuthorCategoryService().then((res)=>{
      for(let i = 0; i < Math.ceil(res.data.length / 4); i++){
        const items:Array<SingerCategoryInterface> = res.data.slice(i*4,(i+1) * 4)
        const length = items.length;
        if(length < 4){
          for(let j = 0; j < 4 - length; j++){
            items.push({
              id:0,// 分类id
              categoryName:'',// 歌手分类名称
              rank:0,// 排名
              disabled:0,// 是否禁用
              createTime:'',// 创建时间
              updateTime:''// 更新时间
            })
          }
        }
        this.categoryList.push(items);
      }
      this.useMusicAuthorList();
    });
  }

  /**
   * @description: 获取歌手列表
   * @date: 2024-08-20 00:15
   * @author wuwenqiang
   */
  useMusicAuthorList(){
    if(this.loading)return;
    this.loading = true;
    getMusicAuthorListService(this.activeCategoryItem?.id || 0,this.pageNum,PAGE_SIZE).then((res)=>{
      this.total = res.total;
      this.musicAuthorList.push(...res.data);
    }).finally(()=>{
      this.loading = false;
    });
  }

  build() {
    Column() {
      NavigatorTitleComponent({title:'歌手分类'})
      Scroll(){
        Column(){
          Column({space:size.smallPadding}){
            ForEach(this.categoryList, (items: Array<SingerCategoryInterface>) => {
              Row({space:size.smallPadding}){
                ForEach(items,(item)=>{
                  Text(item.categoryName)
                    .border({
                      width: 1,
                      color: this.activeCategoryItem?.id === item.id ? colors.tabSelectedColor :colors.borderColor,
                      style: BorderStyle.Solid
                    })
                    .onClick(()=>{
                      if(this.activeCategoryItem?.id === item.id){
                        this.activeCategoryItem = null;
                      }else{
                        this.activeCategoryItem = item;
                      }
                      this.musicAuthorList = [];
                      this.total = 0;
                      this.useMusicAuthorList();
                    })
                    .fontColor(this.activeCategoryItem?.id === item.id ? colors.tabSelectedColor :colors.blackBackgroundColor)
                    .visibility(item.categoryName ? Visibility.Visible : Visibility.Hidden)
                    .layoutWeight(item.categoryName.length === 2 ? 1 : 2)
                    .textAlign(TextAlign.Center)
                    .height(size.inputHeight)
                    .borderRadius(size.smallBorderRaduis)
                })
              }
            })
          }
          .blockStyle()
          Column({space:size.pagePadding}){
            ForEach(this.musicAuthorList,(item:MusicAuthorInterface,index:number)=>{
              Row({space:size.pagePadding}){
                if(item.avatar){
                  Image(getMusicCover(item.avatar))
                    .width(size.middleAvaterSize)
                    .height(size.middleAvaterSize)
                    .borderRadius(size.middleAvaterSize)
                }else{
                  Text(item.authorName[0])
                    .textAlign(TextAlign.Center)
                    .width(size.middleAvaterSize)
                    .height(size.middleAvaterSize)
                    .backgroundColor(colors.pageBackgroundColor)
                    .borderRadius(size.middleAvaterSize)
                }
                Text(item.authorName).layoutWeight(1)
                Image($r("app.media.icon_music_play"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                Image(item.isLike ? $r("app.media.icon_like_active") : $r("app.media.icon_like"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              }
              if(index !== this.musicAuthorList.length - 1)Divider().height(1).color(colors.borderColor)
            })
          }
          .blockStyle()
          .margin({top:size.pagePadding,bottom:size.pagePadding})

          Row() {
            Text(this.pageNum * PAGE_SIZE < this.total || this.loading ? '正在加载更多...' : '已经到底了...')
          }.width('100%').justifyContent(FlexAlign.Center).padding({ top: size.pagePadding,bottom:size.pagePadding })
        }
        .justifyContent(FlexAlign.Start)
      }
      .onScrollEdge((side: Edge) => {
        if (this.pageNum * PAGE_SIZE < this.total) {
          this.pageNum++;
          this.useMusicAuthorList()
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