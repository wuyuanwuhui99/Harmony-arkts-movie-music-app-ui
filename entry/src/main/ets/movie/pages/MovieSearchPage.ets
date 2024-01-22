import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { MovieInterface } from '../interface/Index';
import TitleComponent from '../components/TitleComponent';
import MovieListComponent from '../components/MovieListComponent';
import {getRecommendSerivce} from '../service/Index';
@Entry
@Component
struct MovieSearchPage {
  scroller: Scroller = new Scroller()
  @State searchkeyWord: string = ''; // 搜索词
  @State classify:string = '';
  @State movieList:Array<MovieInterface> = [];

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State movieItem: MovieInterface = null;

  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.movieItem = params['movieItem'] as MovieInterface; // 获取info属性的值
    this.classify = params['classify'] as string; // 获取info属性的值
    getRecommendSerivce(this.classify).then(res=>{
      this.movieList.push(...res.data);
    })
  }

  build() {
    Column() {
      Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center }) {
        TextInput({ placeholder: this.movieItem && this.movieItem.movieName })
          .flexGrow(1)
          .height(size.middleAvaterSize)
          .backgroundColor(colors.pageBackgroundColor)
          .onChange((value) => {
            this.searchkeyWord = value;
          })
        Text("搜索")
          .width('25%')
          .textAlign(TextAlign.Center)
          .fontSize(size.normalFontSize)
          .margin({ left: size.pagePadding })
          .backgroundColor(colors.lineBackgroundColor)
          .borderRadius(size.pagePadding * 2)
          .height(size.middleAvaterSize)
          .fontColor(colors.blockColor)
      }.blockStyle()

      Scroll(this.scroller) {
        Column(){
          Column() {
            TitleComponent({ title: "历史搜索" })
            Flex({ wrap: FlexWrap.Wrap }) {
              Text('长津湖之水门桥')
                .backgroundColor(colors.pageBackgroundColor)
                .height(size.middleAvaterSize)
                .borderRadius(size.pagePadding * 2)
                .textAlign(TextAlign.Center)
                .padding({ left: size.pagePadding, right: size.pagePadding })
            }
          }.blockStyle()

          Column(){
            TitleComponent({ title: "推荐" })
            MovieListComponent({movieList:$movieList,gravity:'vertical'})
          }.blockStyle().margin({top:size.pagePadding,bottom:size.pagePadding})
        }

      }.flexGrow(1).width('100%').scrollable(ScrollDirection.Vertical)
    }
    .backgroundColor(colors.pageBackgroundColor)
    .padding({
      left: size.pagePadding,
      right: size.pagePadding
    })
    .height('100%')
    .width('100%')
  }
}