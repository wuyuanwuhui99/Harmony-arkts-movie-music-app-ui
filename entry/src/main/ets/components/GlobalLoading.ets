// 自定义Loading组件
import * as colors from '../theme/color';
import LoadingController from '../controller/LoadingController';
@Component
export default struct GlobalLoading {
  @State private message: string = '加载中...'
  @State private isShow: boolean = false
  public controller: LoadingController = null;

  aboutToAppear(){
    if (this.controller) {
      this.controller.attach(this); //绑定控制器
    }
  }


  // 显示/隐藏方法
  public showLoading(message?: string) {
    this.isShow  = true
    if (message) this.message  = message
  }

  public hideLoading() {
    this.isShow  = false
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      if (this.isShow)  {
        // 半透明遮罩层
        Column() {
          LoadingProgress()
            .width(80)
            .height(80)
            .color(colors.disableTextColor) // 修改动画颜色[5]()
          Text(this.message)
            .margin({ top: 20 })
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(0x00FFFFFF)
        .width('100%')
        .height('100%')
        .zIndex(999)
      }
    }
  }
}