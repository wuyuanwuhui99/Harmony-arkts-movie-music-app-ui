import router from '@ohos.router';
import {MovieInterface} from "../interface";
@Entry
@Component
struct MovieDetailPage {
  @State movieItem:MovieInterface = null;

  onPageShow() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.movieItem = params['movieItem']; // 获取info属性的值
  }

  build() {

  }
}