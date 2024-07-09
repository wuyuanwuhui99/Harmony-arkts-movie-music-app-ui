import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { MovieInterface } from '../interface/Index';
import TitleComponent from '../components/TitleComponent';
import MovieListComponent from '../components/MovieListComponent';
import { getRecommendSerivce, getSearchResultService } from '../service/Index';
import preference from '../../utils/PreferenceModel';

@Entry
@Component
struct MovieSearchPage {
  scroller: Scroller = new Scroller()
  @State searchKeyWord: string = ''; // 搜索词
  @State classify: string = '';
  @State recommendMovieList: Array<MovieInterface> = []; // 推荐的电影
  @State searching: boolean = false;
  @State searchMovieList: Array<MovieInterface> = [];
  @State loading: boolean = false;
  @State searchRecordList: Array<string> = []

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State movieItem: MovieInterface = null;

  async aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.movieItem = params['movieItem'] as MovieInterface; // 获取info属性的值
    this.classify = params['classify'] as string; // 获取info属性的值
    preference.getMovieSeachKeyWord().then(res => {
      this.searchRecordList = res;
    })
    getRecommendSerivce(this.classify).then(res => {
      this.recommendMovieList.push(...res.data);
    })
  }

  /**
   * @description: 音乐搜索
   * @date: 2024-01-10 23:01
   * @author wuwenqiang
   */
  useSearch = () => {
    if (this.loading) return;
    this.loading = true;
    this.searching = true;
    if (!this.searchKeyWord) {
      this.searchKeyWord = this.movieItem.movieName;
    }
    // 搜索记录写入缓存
    preference.setMovieSeachKeyWord(this.searchKeyWord).then((res) => {
      this.searchRecordList = res;
    });
    // 搜索
    getSearchResultService(this.searchKeyWord, 20, 1).then((res) => {
      this.searchMovieList = res.data;
    }).finally(() => this.loading = false)
  }

  build() {
    Scroll() {
      Column() {
        Row() {
          Row({space:size.pagePadding}) {
            TextInput({text: this.searchKeyWord, placeholder: this.movieItem?.movieName })
              .height(size.inputHeight)
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
                .margin({ right: size.pagePadding })
                .onClick(() => {
                  this.searchKeyWord = '';
                  this.searching = false;
                })
            }
          }
          .alignItems(VerticalAlign.Center)
          .borderRadius(size.inputHeight)
          .backgroundColor(colors.pageBackgroundColor)
          .layoutWeight(1)
          Text("搜索")
            .width(size.btnWidth)
            .textAlign(TextAlign.Center)
            .fontSize(size.normalFontSize)
            .margin({ left: size.pagePadding })
            .backgroundColor(colors.lineBackgroundColor)
            .borderRadius(size.pagePadding * 2)
            .height(size.inputHeight)
            .fontColor(colors.blockColor)
            .onClick(this.useSearch)
        }.blockStyle()

        if (this.searching) {
          if (!this.loading) {
            Column() {
              if (this.searchMovieList.length === 0) {
                Text("暂无搜索结果")
                  .width('100%')
                  .height(size.bigAvaterSize)
                  .textAlign(TextAlign.Center)
              } else {
                MovieListComponent({ movieList: $searchMovieList, gravity: 'vertical' })
              }
            }.blockStyle()
          }
        } else {
          Column() {
            Column() {
              TitleComponent({ title: "历史搜索",showMarginBottom:true })
              if (this.searchRecordList.length === 0) {
                Text("暂无搜索记录")
                  .width('100%')
                  .height(size.bigAvaterSize)
                  .textAlign(TextAlign.Center)
              } else {
                Flex({ wrap: FlexWrap.Wrap }) {
                  ForEach(this.searchRecordList, (item: string) => {
                    Text(item)
                      .backgroundColor(colors.pageBackgroundColor)
                      .height(size.middleAvaterSize)
                      .borderRadius(size.pagePadding * 2)
                      .textAlign(TextAlign.Center)
                      .padding({ left: size.pagePadding, right: size.pagePadding })
                      .onClick(() => {
                        this.searchKeyWord = item;
                      })
                  })
                }
              }
            }.blockStyle()

            if (this.recommendMovieList.length > 0) {
              Column() {
                TitleComponent({ title: "推荐",showMarginBottom: true })
                MovieListComponent({ movieList: $recommendMovieList, gravity: 'vertical' })
              }.blockStyle().margin({ top: size.pagePadding, bottom: size.pagePadding })
            }
          }
        }
      }.justifyContent(FlexAlign.Start)
    }
    .backgroundColor(colors.pageBackgroundColor)
    .padding({
      left: size.pagePadding,
      right: size.pagePadding
    })
    .align(Alignment.Top)
    .scrollable(ScrollDirection.Vertical)
    .height('100%')
    .width('100%')
  }
}