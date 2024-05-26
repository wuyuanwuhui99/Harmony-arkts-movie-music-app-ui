import MusicSearchComponent from './MusicSearchComponent';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {MusicClassifyInterface} from '../interface';
import {getMusicClassifyService} from '../service/Index';
import MusicClassifyComponent from './MusicClassifyComponent';
import MusicCategoryComponent from './MusicCategoryComponent';
import MusicSingerComponent from './MusicSingerComponent';

@Component
export default struct MusicCircleComponent{

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State allClassifyList: Array<MusicClassifyInterface> = [];
  @State pageNum: number = 3;
  scroller: Scroller = new Scroller();


  aboutToAppear(){
    getMusicClassifyService().then((res)=>{
      this.allClassifyList = res.data;
    });
  }

  build(){
    Column() {
      Scroll(this.scroller) {
        Column() {
          MusicSearchComponent()
          MusicCategoryComponent()
          ForEach(this.allClassifyList.slice(0,this.pageNum),(item:MusicClassifyInterface)=>{
            if(item.classifyName === '推荐歌手'){
              MusicSingerComponent()
            }else{
              MusicClassifyComponent({classifyId:item.id,classifyName:item.classifyName})
            }
          })
          Row() {
            Text(this.pageNum == this.allClassifyList.length ? '已经到底了...' : '正在加载更多...')
          }.padding({ top: size.pagePadding,bottom:size.pagePadding })
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .onScrollEdge((side: Edge) => {
        if (this.pageNum < this.allClassifyList.length) {
          this.pageNum++;
        }
      }) // 滚动方向纵向
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}