import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { getMusicAuthorListByCategoryIdService } from '../service/Index';
import { MusicAuthorInterface } from '../interface';
import { HOST } from '../../common/constant';
import router from '@ohos.router';
import MusicAvaterComponent from './MusicAvaterComponent';

@Component
export default struct MusicAuthorComponent {
  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State authorList: Array<MusicAuthorInterface> = [];

  aboutToAppear() {

    /**
     * @description: 获取歌手列表前4条数据
     * @date: 2024-03-05 22:40
     * @author wuwenqiang
     */
    getMusicAuthorListByCategoryIdService(0, 1, 4).then((res) => {
      this.authorList = res.data;
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.icon_down'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
        Text("推荐歌手").margin({ left: size.pagePadding }).layoutWeight(1)
        Text("更多").onClick(()=>{
          router.pushUrl({
            url: 'music/pages/MusicAuthorCategoryPage', // 目标url
          })
        })
      }.alignItems(VerticalAlign.Center).margin({ bottom: size.pagePadding })

      Row() {
        ForEach(this.authorList, (item: MusicAuthorInterface) => {
          Column() {
            MusicAvaterComponent({avater:item.avatar?.toString(),title:item.authorName[0],dimension:Number(size.middleAvaterSize * 1.5),type:'author'})
            Text(item.authorName).margin({ top: size.smallPadding })
          }.width('25%').alignItems(HorizontalAlign.Center)
        })
      }
    }.blockStyle()

  }
}