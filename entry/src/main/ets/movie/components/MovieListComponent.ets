import router from '@ohos.router';
import {HOST} from '../../config/constant';
import {MovieInterface} from '../interface'
import * as size from '../../theme/size';

@Component
export default struct MovieListComponent{
  @Prop movieListStr:string;
  @State movieList:Array<MovieInterface> = []

  aboutToAppear(){
    // 把字符串转成对象
    this.movieList = JSON.parse(this.movieListStr) as Array<MovieInterface>;
  }

  build(){
    Scroll(){
      Row(){
        ForEach(this.movieList,(item:MovieInterface)=>{
          Column(){
            Image(HOST + item.localImg)
              .width(size.movieWidth)
              .height(size.movieHeight)
              .borderRadius(size.blockBorderRaduis)
              .margin({bottom:size.smallPadding})
            Text(item.movieName).fontSize(size.normalFontSize)
          }
          .margin({right:size.smallPadding})
          .alignItems(HorizontalAlign.Center)
          .width(size.movieWidth)
          .onClick((event: ClickEvent)=>{
            router.pushUrl({
              url: 'movie/pages/MovieDetailPage', // 目标url
              params: {
                movieItem: item
              }
            }, router.RouterMode.Standard, (err) => {
              if(err){
                console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
              }
            });
          })
        })
      }
    }.width('100%').scrollable(ScrollDirection.Horizontal)
  }
}