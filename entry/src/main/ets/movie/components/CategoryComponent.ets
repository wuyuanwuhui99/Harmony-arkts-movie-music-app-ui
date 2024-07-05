import TitleComponent from './TitleComponent';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { ClassifyInterface,MovieInterface } from '../interface/Index';
import {getCategoryListService} from '../service/Index';
import MovieListComponent from './MovieListComponent';
@Component
export default struct CategoryComponent{
  @Prop classifyItemStr:string;// Prop不能传递object对象
  @State classifyItem:ClassifyInterface = null;
  @State movieList:Array<MovieInterface> = [];

  aboutToAppear(){
    // 把字符串转成对象
    this.classifyItem = JSON.parse(this.classifyItemStr) as ClassifyInterface;
    this.useCategoryList();
  }

  useCategoryList(){
    getCategoryListService(this.classifyItem).then((res)=>{
      this.movieList = res.data;
    })
  }

  build(){
    Column(){
      TitleComponent({title:this.classifyItem.category,showMarginBottom:true})
      if(this.movieList.length > 0){// 必须加判断，否则后更新的数据不会触发MovieListComponent组件重新渲染
        MovieListComponent({gravity:'horizontal',movieList:$movieList})
      }
    }.backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }
}