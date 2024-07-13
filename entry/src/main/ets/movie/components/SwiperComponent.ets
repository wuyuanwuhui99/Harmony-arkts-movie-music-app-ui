import * as size from '../../theme/size';
import { MovieInterface } from '../interface/Index';
import {getCategoryListService} from '../service/Index';
import {HOST} from '../../common/constant';

@Component
export default struct SwiperComponent{
  @Prop classify:string;
  @State movieList:Array<MovieInterface> = []

  private swiperController: SwiperController = new SwiperController()
  aboutToAppear(){
    this.useCategoryList()
  }
  useCategoryList(){
    getCategoryListService({classify:this.classify,category:'轮播'}).then((res)=>{
      this.movieList = res.data.slice(0,5);
    })
  }

  build() {
    if(this.movieList.length > 0){
      Swiper(this.swiperController) {
        ForEach(this.movieList,(movieItem:MovieInterface)=>{
          Image(HOST + movieItem.localImg)
            .height(size.swiperHeight)
            .width('100%')
            .borderRadius(size.blockBorderRaduis)
        })
      }
      .loop(true)
      .autoPlay(true)
      .interval(5000)
    }

  }
}