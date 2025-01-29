import * as colors from '../theme/color';
import * as size from '../theme/size';
import router from '@ohos.router';

@Component
export default struct NavigatorTitleComponent {
  @Prop title: string;

  build() {
    Row(){
      Image($r('app.media.icon_back'))
        .width(size.smallIconSize)
        .height(size.smallIconSize)
        .opacity(size.opacity)
        .onClick(()=>{
          router.back()
        })
      Text(this.title)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Image($r('app.media.icon_back'))
        .width(size.smallIconSize)
        .height(size.smallIconSize)
        .visibility(Visibility.Hidden)
    }
    .width('100%')
    .padding(size.pagePadding)
    .backgroundColor(colors.blockColor)
  }
}