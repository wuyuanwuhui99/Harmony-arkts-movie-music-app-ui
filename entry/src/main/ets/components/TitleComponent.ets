import * as colors from '../theme/color';
import * as size from '../theme/size';


@Component
export default struct TitleComponent{
  @Prop title:string;
  @Prop showMarginBottom:boolean;

  build(){
    Row(){
      Divider()
        .height(size.lineHeight)
        .width(size.lineWidth)
        .backgroundColor(colors.lineBackgroundColor)
        .margin({right:size.smallPadding})
      Text(this.title).fontSize(size.normalFontSize)
    }.alignSelf(ItemAlign.Start)
    .margin({bottom:this.showMarginBottom ? size.pagePadding : 0})
  }
}