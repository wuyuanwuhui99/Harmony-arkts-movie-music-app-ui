import {getMusicListByClassifyIdService} from '../service';
import {MusicInterface} from '../interface';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {HOST} from '../../config/constant';

@Component
export default struct MusicRecommendComponent{

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State musicList:Array<MusicInterface> = [];
  @State pageNum:number = 1;
  @State total:number = 0;
  pageSize:number = 20;
  scroller: Scroller = new Scroller()
  isScrollEnd:boolean = false;


  aboutToAppear(){
    this.useMusicList()
  }

  /**
   * @description: 获取推荐的20条数据，1表示推荐的id
   * @date: 2024-03-05 22:40
   * @author wuwenqiang
   */
  useMusicList(){
    getMusicListByClassifyIdService(1,this.pageNum,this.pageSize).then((res)=>{
      this.total = res.total;
      this.musicList.push(...res.data);
    })
  }

  build(){
    Column(){
      Scroll(this.scroller) {
        Column(){
          ForEach(this.musicList,(item:MusicInterface,index:number)=>{
            Flex({direction:FlexDirection.Row,alignItems: ItemAlign.Center}){
              if(index===0){
                Image($r("app.media.icon_no1"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              }else if(index===1){
                Image($r("app.media.icon_no2"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              }else if(index===2){
                Image($r("app.media.icon_no3"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              }else{
                Text(index+1+"")
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .textAlign(TextAlign.Center)
              }
              Image(/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}','480') : HOST + item.cover)
                .width(size.middleAvaterSize)
                .height(size.middleAvaterSize)
                .borderRadius(size.middleAvaterSize)
              .margin({left:size.pagePadding})
              Column(){
                Text(item.songName).maxLines(1).textOverflow({overflow:TextOverflow.Ellipsis})
                Text(item.authorName)
                  .fontColor(colors.disableTextColor)
                  .margin({top:size.smallPadding/2})
                  .maxLines(1).textOverflow({overflow:TextOverflow.Ellipsis})
              }.flexGrow(1).alignItems(HorizontalAlign.Start).margin({left:size.pagePadding})
              Image($r("app.media.icon_music_play"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({left:size.pagePadding})
              Image(item.isFavorite ? $r("app.media.icon_like_active") : $r("app.media.icon_like"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({left:size.pagePadding})
              Image($r("app.media.icon_music_menu"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({left:size.pagePadding})
            }.blockStyle()
          })
        }
      }.scrollable(ScrollDirection.Vertical)
      .backgroundColor(colors.pageBackgroundColor)
      .width("100%")
      .height("100%")

      .onScrollEdge((side: Edge) => {
        if (this.total > this.pageNum * this.pageSize) {
          this.pageNum++;
          this.useMusicList();
        }
      })
    }.width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})

  }
}