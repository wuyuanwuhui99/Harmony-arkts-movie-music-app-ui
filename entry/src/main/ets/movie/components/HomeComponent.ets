import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {UserDataInterface,ClassifyInterface} from '../interface/Index'
import {HOST} from '../../config/constant';
import {USER_DATA} from '../../config/constant';
import SwiperComponent from './SwiperComponent';
import {getSearchKeyWordService,getAllCategoryListByPageNameService} from '../service/Index';
import CategoryComponent from './CategoryComponent';

@Entry
@Component
export default struct HomeComponent{
  @State searchKeyWord:string = '';
  @StorageLink(USER_DATA) userData:UserDataInterface = null;
  @State allCategoryList:Array<ClassifyInterface> = [];
  @State currentCategoryList:Array<ClassifyInterface> = [];
  @State isScrollEnd:boolean = false;
  scroller: Scroller = new Scroller()

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }
  @Styles classifyItemStyle(){
    .width(size.largeIconSize)
    .height(size.largeIconSize)
    .margin({bottom:size.smallPadding})
  }

  aboutToAppear(){
    this.useSearchKeyWord()
    this.useAllCategoryListByPageName()
  }

  useAllCategoryListByPageName(){
    getAllCategoryListByPageNameService('首页').then((res)=>{
      this.allCategoryList = res.data;
      this.currentCategoryList = this.allCategoryList.slice(0,2)
    })
  }


  useSearchKeyWord(){
    getSearchKeyWordService('电影').then((res)=>{
      this.searchKeyWord = res.data.movieName;
    })
  }

  build() {
    Column() {
      Scroll(this.scroller){
        Column(){
          Row(){
            Image(this.userData ? HOST + this.userData.avater : '')
              .height(size.middleavaterSize)
              .width(size.middleavaterSize)
              .borderRadius(size.middleavaterSize)
            Row(){
              Text(this.searchKeyWord)
                .fontSize(size.normalFontSize)
                .fontColor(colors.disableTextColor)
            }
            .height(size.middleavaterSize)
            .borderRadius(size.middleavaterSize)
            .backgroundColor(colors.pageBackgroundColor)
            .margin({left: size.pagePadding})
            .padding({left: size.pagePadding})
            .flexGrow(1)
          }.blockStyle()
          SwiperComponent({classify:'电影'}).margin({top: size.pagePadding})
          Row(){
            Column(){
              Image($r('app.media.icon_hot')).classifyItemStyle()
              Text('热门').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column(){
              Image($r('app.media.icon_play')).classifyItemStyle()
              Text('预告').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column(){
              Image($r('app.media.icon_top')).classifyItemStyle()
              Text('最新').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column(){
              Image($r('app.media.icon_classify')).classifyItemStyle()
              Text('分类').fontSize(size.normalFontSize)
            }
            .flexGrow(1)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
          }.blockStyle()
          ForEach(this.currentCategoryList,(item:ClassifyInterface)=>{
            CategoryComponent({classifyItemStr:JSON.stringify(item)})
          })
          Row(){
            Text(this.isScrollEnd ? '已经到底了...' : '正在加载更多...')
          }.padding({top:size.pagePadding})
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .onScrollEdge((side: Edge)=>{
        if(!this.isScrollEnd){
          const length:number = this.currentCategoryList.length
          this.currentCategoryList.push(...this.allCategoryList.slice(length, length + 2))
          if(this.currentCategoryList.length === this.allCategoryList.length){
            this.isScrollEnd = true
          }
        }
      })  // 滚动方向纵向
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({left:size.pagePadding,right:size.pagePadding,bottom:size.pagePadding})
  }
}