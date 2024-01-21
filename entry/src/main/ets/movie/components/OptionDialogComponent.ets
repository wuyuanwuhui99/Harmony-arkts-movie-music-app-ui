import * as colors from '../../theme/color';
import * as size from '../../theme/size';

/**
 * @description: 修改新别弹窗
 * @date: 2024-01-14 21:47
 * @author wuwenqiang
 */
@CustomDialog
export default struct OptionDialogComponent {
  controller: CustomDialogController
  cancel: () => void
  confirm: (value: string) => void
  options: Array<string>

  build() {
    Column() {
      Column() {
        ForEach(this.options, (item: string, index: number) => {
          Text(item)
            .textAlign(TextAlign.Center)
            .width('100%')
            .padding(size.pagePadding)
            .backgroundColor(colors.blockColor)
            .borderRadius(size.blockBorderRaduis)
            .onClick(() => {
              this.confirm(item)
            })
          if (index !== this.options.length - 1) {
            Divider()
              .height(1)
              .backgroundColor(colors.pageBackgroundColor)
          }
        })
      }.backgroundColor(colors.blockColor)
      .borderRadius(size.blockBorderRaduis)
      .padding({ left: size.pagePadding, right: size.pagePadding })

      Divider()
        .height(size.pagePadding)
        .backgroundColor(Color.Transparent)
      Text('取消')
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding(size.pagePadding)
        .backgroundColor(colors.blockColor)
        .borderRadius(size.blockBorderRaduis)
        .onClick(() => {
          this.cancel()
        })
      Divider()
        .height(size.pagePadding)
        .backgroundColor(Color.Transparent)
    }.width('100%').backgroundColor(Color.Transparent).padding({ left: size.pagePadding, right: size.pagePadding })
  }
}