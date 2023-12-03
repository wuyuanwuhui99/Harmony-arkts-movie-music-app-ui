import * as colors from '../../theme/color';
import * as size from '../../theme/size';


@Component
export default struct TitleComponent{
  @Prop title:string;

  build(){
    Flex({direction:FlexDirection.Row,alignItems: ItemAlign.Center}){
      Divider()
        .height(size.lineHeight)
        .width(size.lineWidth)
        .backgroundColor(colors.lineBackgroundColor)
        .margin({right:size.smallPadding})
      Text(this.title).fontSize(size.normalFontSize)
    }.alignSelf(ItemAlign.Start)
    .margin({bottom:size.pagePadding})
  }
}