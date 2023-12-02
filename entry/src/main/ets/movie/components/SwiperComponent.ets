import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { Movieinterface } from '../interface/Index';
import {getCategoryListService} from '../service/Index';
import {HOST} from  '../../config/constant';

@Component
export default struct SwiperComponent{
  @Prop classify:string;
  @State movieList:Array<Movieinterface> = []

  private swiperController: SwiperController = new SwiperController()
  aboutToAppear(){
    this.useCategoryList()
  }
  useCategoryList(){
    getCategoryListService(this.classify,'轮播').then((res)=>{
      this.movieList = res.data.slice(0,5);
    })
  }

  build() {
    Swiper(this.swiperController) {
      ForEach(this.movieList,(movieItem:Movieinterface)=>{
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