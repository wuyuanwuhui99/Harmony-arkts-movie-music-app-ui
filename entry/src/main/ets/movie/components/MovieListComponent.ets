import router from '@ohos.router';
import { HOST } from '../../common/constant';
import { MovieInterface } from '../interface'
import * as size from '../../theme/size';

@Component
export default struct MovieListComponent {
  @Prop gravity: string; // 排列方向，vertical | horizontal
  @Link movieList: Array<MovieInterface>;
  @State movieListGroup: Array<Array<MovieInterface>> = [];

  aboutToAppear(){
    this.movieList.forEach((item,index)=>{
      if(index % 3 === 0){
        this.movieListGroup.push([item])
      }else{
        this.movieListGroup[this.movieListGroup.length - 1].push(item);
      }
    })
  }

  build() {
    if (this.gravity === 'horizontal') {
      Scroll() {
        Row() {
          ForEach(this.movieList, (item: MovieInterface, index: number) => {
            MovieItemComponent({ movieItemStr: JSON.stringify(item),gravity:'horizontal' })
          })
        }
      }.width('100%').scrollable(this.gravity === 'horizontal' ? ScrollDirection.Horizontal : ScrollDirection.Vertical)
    } else {
      Grid() {
        ForEach(this.movieList, (item: MovieInterface, index: number) => {
          GridItem() {
            MovieItemComponent({ movieItemStr: JSON.stringify(item),gravity:'vertical' })
          }
        })
      }.columnsTemplate('1fr 1fr 1fr')
      .height('100%')
      .columnsGap(size.pagePadding)
      .rowsGap(size.pagePadding)
      .scrollBar(BarState.Off)
    }
  }
}

@Component
struct MovieItemComponent {
  @Prop movieItemStr: string;
  @State movieItem: MovieInterface = null;
  @Prop gravity: string; // 排列方向，vertical | horizontal

  aboutToAppear() {
    this.movieItem = JSON.parse(this.movieItemStr) as MovieInterface;
  }

  build() {
    Column() {
      Image(HOST + this.movieItem.localImg)
        .width(this.gravity === 'horizontal' ? size.movieWidth: '100%')
        .height(this.gravity === 'horizontal' ? size.movieHeight: 'auto')
        .borderRadius(size.blockBorderRaduis)
        .margin({ bottom: size.smallPadding })
      Text(this.movieItem.movieName)
        .maxLines(1)
        .textAlign(TextAlign.Center)
        .width(this.gravity === 'horizontal' ? size.movieWidth: '100%')
        .textOverflow({overflow: TextOverflow.Ellipsis})
        .fontSize(size.normalFontSize)
    }
    .margin({ right: size.smallPadding })
    .alignItems(HorizontalAlign.Center)
    .width(this.gravity === 'horizontal' ? size.movieWidth: '100%')
    .onClick(() => {
      router.pushUrl({
        url: 'movie/pages/MovieDetailPage', // 目标url
        params: {
          movieItem: this.movieItem
        }
      }, router.RouterMode.Standard, (err) => {
        if (err) {
          console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
        }
      });
    })
  }
}