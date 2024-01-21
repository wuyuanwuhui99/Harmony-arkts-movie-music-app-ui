import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { ClassifyInterface } from '../interface/Index'
import SwiperComponent from './SwiperComponent';
import { getAllCategoryListByPageNameService } from '../service/Index';
import CategoryComponent from './CategoryComponent';
import SearchComponent from './SearchComponent';

@Entry
@Component
export default struct TVComponent{
  @State allCategoryList: Array<ClassifyInterface> = [];
  @State currentCategoryList: Array<ClassifyInterface> = [];
  @State isScrollEnd: boolean = false;
  scroller: Scroller = new Scroller()

  aboutToAppear() {
    this.useAllCategoryListByPageName()
  }

  useAllCategoryListByPageName() {
    getAllCategoryListByPageNameService('电视剧').then((res) => {
      this.allCategoryList = res.data;
      this.currentCategoryList = this.allCategoryList.slice(0, 2)
    })
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column(){
          SearchComponent({ classify: '电视剧' })
          SwiperComponent({ classify: '电视剧' }).margin({ top: size.pagePadding })
          ForEach(this.currentCategoryList, (item: ClassifyInterface) => {
            CategoryComponent({ classifyItemStr: JSON.stringify(item) })
          })
          Row() {
            Text(this.isScrollEnd ? '已经到底了...' : '正在加载更多...')
          }.padding({ top: size.pagePadding,bottom:size.pagePadding })
        }
      }.scrollable(ScrollDirection.Vertical)
      .onScrollEdge((side: Edge) => {
        if (!this.isScrollEnd) {
          const length: number = this.currentCategoryList.length
          this.currentCategoryList.push(...this.allCategoryList.slice(length, length + 2))
          if (this.currentCategoryList.length === this.allCategoryList.length) {
            this.isScrollEnd = true
          }
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}