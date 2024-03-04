import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {MusicInterface} from '../interface';
import {getMusicListByClassifyIdService} from '../service';
import { HOST } from '../../config/constant';

@Component
export default struct MusicClassifyComponent{
  @Prop classifyId: number;
  @Prop classifyName: string;
  @State musicList:Array<MusicInterface> = []

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  aboutToAppear(){
    getMusicListByClassifyIdService(this.classifyId,1,4).then((res)=>{
      this.musicList = res.data;
    })
  }

  build(){
    Column(){
      Flex({direction:FlexDirection.Row,alignItems: ItemAlign.Center}){
        Image($r('app.media.icon_down'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
        Text(this.classifyName).margin({left:size.pagePadding}).flexGrow(1)
        Text("更多")
      }.alignSelf(ItemAlign.Start)
      Column(){
        ForEach(this.musicList,(item:MusicInterface,index:number)=>{
          Flex({direction:FlexDirection.Row,alignItems: ItemAlign.Center}){
            Image(/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}','480') : HOST + item.cover)
              .width(size.middleAvaterSize)
              .height(size.middleAvaterSize)
              .borderRadius(size.middleAvaterSize)
              .margin({right:size.pagePadding})
            Column(){
              Text(item.songName)
                .maxLines(1)
                .textOverflow({overflow: TextOverflow.Ellipsis})
              Text(item.authorName).margin({top:size.smallPadding/2})
                .maxLines(1)
                .textOverflow({overflow: TextOverflow.Ellipsis})
                .fontColor(colors.disableTextColor)
            }.flexGrow(1).alignItems(HorizontalAlign.Start)
            Image($r("app.media.icon_music_play"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .margin({left:size.pagePadding})
            Image(item.isFavorite === 0 ? $r("app.media.icon_like") : $r("app.media.icon_like_active"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .margin({left:size.pagePadding})
            Image($r("app.media.icon_music_menu"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .margin({left:size.pagePadding})
          }
          .margin({top:size.pagePadding}).padding({bottom:index === this.musicList.length - 1 ? 0 : size.pagePadding})
          .border({
            width: {
              bottom: index === this.musicList.length - 1 ? 0 : 1,
            },
            color: {
              bottom: colors.pageBackgroundColor
            },
            style: {
              bottom: BorderStyle.Solid
            }
          })
          .alignSelf(ItemAlign.Start)
        })

      }
    }.blockStyle()
  }
}