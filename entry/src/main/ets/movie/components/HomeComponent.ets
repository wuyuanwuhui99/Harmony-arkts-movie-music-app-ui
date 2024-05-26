import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { ClassifyInterface } from '../interface/Index'
import SwiperComponent from './SwiperComponent';
import { getAllCategoryListByPageNameService } from '../service/Index';
import CategoryComponent from './CategoryComponent';
import SearchComponent from './SearchComponent';

@Entry
@Component
export default struct HomeComponent {
  @State allCategoryList: Array<ClassifyInterface> = [];
  @State currentCategoryList: Array<ClassifyInterface> = [];
  @State isScrollEnd: boolean = false;
  private scroller: Scroller = new Scroller()

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @Styles classifyItemStyle(){
    .width(size.bigIconSize)
    .height(size.bigIconSize)
    .margin({ bottom: size.smallPadding })
  }

  aboutToAppear() {
    this.useAllCategoryListByPageName()
  }

  useAllCategoryListByPageName() {
    getAllCategoryListByPageNameService('首页').then((res) => {
      this.allCategoryList = res.data;
      this.currentCategoryList = this.allCategoryList.slice(0, 2)
    })
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          SearchComponent({ classify: '电影' })
          SwiperComponent({ classify: '电影' }).margin({ top: size.pagePadding })
          Row() {
            Column() {
              Image($r('app.media.icon_hot')).classifyItemStyle()
              Text('热门').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Image($r('app.media.icon_play')).classifyItemStyle()
              Text('预告').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Image($r('app.media.icon_top')).classifyItemStyle()
              Text('最新').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Image($r('app.media.icon_classify')).classifyItemStyle()
              Text('分类').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }.blockStyle()

          ForEach(this.currentCategoryList, (item: ClassifyInterface) => {
            CategoryComponent({ classifyItemStr: JSON.stringify(item) })
          })
          Row() {
            Text(this.isScrollEnd ? '已经到底了...' : '正在加载更多...')
          }.padding({ top: size.pagePadding,bottom:size.pagePadding })
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .onScrollEdge((side: Edge) => {
        if (!this.isScrollEnd) {
          const length: number = this.currentCategoryList.length
          this.currentCategoryList.push(...this.allCategoryList.slice(length, length + 2))
          if (this.currentCategoryList.length === this.allCategoryList.length) {
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