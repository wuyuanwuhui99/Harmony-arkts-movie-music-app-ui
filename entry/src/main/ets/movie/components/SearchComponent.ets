import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { MovieInterface } from '../interface/Index';
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

  @State movieItem:MovieInterface = null
  @Prop classify:string;
  @State dimensions:number = size.middleAvaterSize;// 导入的值不能直接传给组件

  aboutToAppear(){
    this.useSearchKeyWord()
  }

  useSearchKeyWord(){
    getSearchKeyWordService(this.classify).then((res)=>{
      this.movieItem = res.data;
    })
  }

  build(){
    Row(){
      AvaterComponent({dimensions:this.dimensions})
      Row(){
        Text(this.movieItem?.movieName)
          .fontSize(size.normalFontSize)
          .fontColor(colors.disableTextColor)
      }
      .height(size.middleAvaterSize)
      .borderRadius(size.middleAvaterSize)
      .backgroundColor(colors.pageBackgroundColor)
      .margin({left: size.pagePadding})
      .padding({left: size.pagePadding})
      .flexGrow(1)
      .onClick(()=>{
        router.pushUrl({
          url: 'movie/pages/MovieSearchPage', // 目标url
          params: {
            classify:this.classify,
            movieItem: this.movieItem
          }
        }, router.RouterMode.Standard, (err) => {
          if(err){
            console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
          }
        });
      })
    }.blockStyle()
  }
}