import TitleComponent from './TitleComponent';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { ClassifyInterface,MovieInterface } from '../interface/Index';
import {getCategoryListService} from '../service/Index';
import {HOST} from '../../config/constant';

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
      TitleComponent({title:this.classifyItem.category})
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
          })
        }
      }.width('100%').scrollable(ScrollDirection.Horizontal)
    }.backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }
}