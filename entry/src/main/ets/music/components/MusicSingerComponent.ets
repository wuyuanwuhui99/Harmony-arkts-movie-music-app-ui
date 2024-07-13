import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { getSingerListService } from '../service/Index';
import { MusicSingerInterface } from '../interface';
import { HOST } from '../../common/constant';

@Component
export default struct MusicSingerComponent {
  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State singerList: Array<MusicSingerInterface> = [];

  aboutToAppear() {

    /**
     * @description: 获取歌手列表前4条数据
     * @date: 2024-03-05 22:40
     * @author wuwenqiang
     */
    getSingerListService(null, 1, 4).then((res) => {
      this.singerList = res.data;
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_down'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
        Text("推荐歌手").margin({ left: size.pagePadding }).layoutWeight(1)
        Text("更多")
      }.alignItems(VerticalAlign.Center).margin({ bottom: size.pagePadding })

      Row() {
        ForEach(this.singerList, (item: MusicSingerInterface) => {
          Column() {
            Image(item.avatar ? (/http[s]?:\/\//.test(item.avatar) ? item.avatar.replace('{size}', '480') : HOST + item.avatar) : $r("app.media.default_avater"))
              .width(size.middleAvaterSize * 1.5)
              .height(size.middleAvaterSize * 1.5)
              .borderRadius(size.middleAvaterSize * 1.5)
            Text(item.authorName).margin({ top: size.smallPadding })
          }.width('25%').alignItems(HorizontalAlign.Center)
        })
      }
    }.blockStyle()

  }
}