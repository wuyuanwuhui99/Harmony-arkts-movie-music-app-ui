import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';

@Component
export default struct MusicCategoryComponent{
  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  @Styles categoryImgStyle(){
    .width(size.bigIconSize * 1.5)
    .height(size.bigIconSize * 1.5)
    .margin({bottom:size.pagePadding})
  }

  build(){
    Row(){
      Column(){
        Image($r('app.media.icon_music_singer')).categoryImgStyle()
        Text("歌手")
      }.width('25%')
      .alignItems(HorizontalAlign.Center)
      .onClick(()=>{
        router.pushUrl({
          url: 'music/pages/MusicAuthorCategoryPage', // 目标url
        });
      })
      Column(){
        Image($r('app.media.icon_music_classify')).categoryImgStyle()
        Text("分类歌曲")
      }.width('25%')
      .alignItems(HorizontalAlign.Center)
      .onClick(()=>{
        router.pushUrl({
          url: 'music/pages/MusicCategoryPage', // 目标url
        });
      })
      Column(){
        Image($r('app.media.icon_music_classics')).categoryImgStyle()
        Text("经典老歌")
      }.width('25%').alignItems(HorizontalAlign.Center)
      Column(){
        Image($r('app.media.icon_music_rank')).categoryImgStyle()
        Text("热门榜单")
      }.width('25%').alignItems(HorizontalAlign.Center)
    }.blockStyle()
  }
}