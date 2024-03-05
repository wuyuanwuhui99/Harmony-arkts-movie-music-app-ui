import MusicSearchComponent from './MusicSearchComponent';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {MusicClassifyInterface} from '../interface';
import {getMusicClassifyService} from '../service';
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
  @State currentClassifyList: Array<MusicClassifyInterface> = [];
  @State isScrollEnd: boolean = false;
  scroller: Scroller = new Scroller()

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
          ForEach(this.allClassifyList,(item:MusicClassifyInterface)=>{
            if(item.classifyName === '推荐歌手'){
              MusicSingerComponent()
            }else{
              MusicClassifyComponent({classifyId:item.id,classifyName:item.classifyName})
            }
          })
          Row() {
            Text(this.isScrollEnd ? '已经到底了...' : '正在加载更多...')
          }.padding({ top: size.pagePadding,bottom:size.pagePadding })
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .onScrollEdge((side: Edge) => {
        if (!this.isScrollEnd) {
          const length: number = this.currentClassifyList.length
          this.currentClassifyList.push(...this.allClassifyList.slice(length, length + 2))
          if (this.currentClassifyList.length === this.allClassifyList.length) {
            this.isScrollEnd = true
          }
        }
      }) // 滚动方向纵向
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}