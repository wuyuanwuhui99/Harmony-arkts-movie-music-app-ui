import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {getSearchKeyWordService} from '../service/Index';
import AvaterComponent from './AvaterComponent';
@Component
export default struct SearchComponent{

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  @Prop classify:string;
  @State searchKeyWord:string = '';
  @State dimensions:number = size.middleAvaterSize;// 导入的值不能直接传给组件

  aboutToAppear(){
    this.useSearchKeyWord()
  }

  useSearchKeyWord(){
    getSearchKeyWordService(this.classify).then((res)=>{
      this.searchKeyWord = res.data.movieName;
    })
  }

  build(){
    Row(){
      AvaterComponent({dimensions:this.dimensions})
      Row(){
        Text(this.searchKeyWord)
          .fontSize(size.normalFontSize)
          .fontColor(colors.disableTextColor)
      }
      .height(size.middleAvaterSize)
      .borderRadius(size.middleAvaterSize)
      .backgroundColor(colors.pageBackgroundColor)
      .margin({left: size.pagePadding})
      .padding({left: size.pagePadding})
      .flexGrow(1)
    }.blockStyle()
  }
}