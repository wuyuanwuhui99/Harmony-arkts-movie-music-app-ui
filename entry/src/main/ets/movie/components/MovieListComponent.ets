import router from '@ohos.router';
import {HOST} from '../../config/constant';
import {MovieInterface} from '../interface'
import * as size from '../../theme/size';

@Component
export default struct MovieListComponent{
  @Prop gravity:string;// 排列方向，vertical | horizontal
  @Link movieList:Array<MovieInterface>;

  build(){
    Scroll(){
      if(this.gravity === 'horizontal'){
        Row(){
          ForEach(this.movieList,(item:MovieInterface,index:number)=>{
            MovieItemComponent({movieItemStr:JSON.stringify(item)})
          })
        }
      }else{
        Grid(){
          ForEach(this.movieList,(item:MovieInterface,index:number)=>{
            GridItem(){
              MovieItemComponent({movieItemStr:JSON.stringify(item)})
            }
          })
        }.columnsTemplate('1fr 1fr')
        .columnsGap(size.smallPadding)
        .rowsGap(size.smallPadding).margin({top:size.smallPadding})
      }

    }.width('100%').scrollable(this.gravity === 'horizontal' ? ScrollDirection.Horizontal: ScrollDirection.Vertical)
  }
}

@Component
struct MovieItemComponent{
  @Prop movieItemStr:string;

  @State movieItem:MovieInterface = null;

  aboutToAppear(){
    this.movieItem = JSON.parse(this.movieItemStr) as MovieInterface;
  }


  build(){
    Column(){
      Image(HOST + this.movieItem.localImg)
        .width(size.movieWidth)
        .height(size.movieHeight)
        .borderRadius(size.blockBorderRaduis)
        .margin({bottom:size.smallPadding})
      Text(this.movieItem.movieName).fontSize(size.normalFontSize)
    }
    .margin({right:size.smallPadding})
    .alignItems(HorizontalAlign.Center)
    .width(size.movieWidth)
    .onClick(()=>{
      router.pushUrl({
        url: 'movie/pages/MovieDetailPage', // 目标url
        params: {
          movieItem: this.movieItem
        }
      }, router.RouterMode.Standard, (err) => {
        if(err){
          console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
        }
      });
    })
  }
}