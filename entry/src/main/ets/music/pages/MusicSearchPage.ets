import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface } from '../interface';
import TitleComponent from '../../movie/components/TitleComponent';
import { MUSIC_SEARCH } from '../../config/constant';

@Entry
@Component
export default struct MusicSearchPage {
  @State keyword:string = '';
  @State musicItem:MusicInterface = null;
  @State searchList:Array<string> = AppStorage.Get(MUSIC_SEARCH) || [];

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }


  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicItem = params['musicItem'] as MusicInterface; // 获取info属性的值
    // PersistentStorage.PersistProp<Array<string>>(MUSIC_SEARCH, myMusicStorage);
  }

  build() {
    Column() {
      Row({space:size.pagePadding}){
        TextInput({placeholder:this.musicItem ? `${this.musicItem.authorName} - ${this.musicItem.songName}` : '请输入歌曲名或者歌手'})
          .layoutWeight(1)
          .height(size.inputHeight)
          .backgroundColor(colors.pageBackgroundColor)
          .borderRadius(size.blockBorderRaduis * 2)
          .onChange((value) => {
            this.keyword = value;
          })
        Button('搜索', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(colors.lineBackgroundColor)
          .width(size.btnWidth)
          .height(size.inputHeight)
      }.blockStyle()

      Column(){
        TitleComponent({ title: "历史搜索",showMarginBottom:false})
        Flex({wrap:FlexWrap.Wrap,direction:FlexDirection.Row,justifyContent: FlexAlign.SpaceBetween}){
          ForEach(this.searchList,(item:string)=>{
            Button(item)
              .fontColor(colors.disableTextColor)
              .margin({top:size.pagePadding})
              .height(size.inputHeight)
              .backgroundColor(colors.pageBackgroundColor)
              .borderRadius(size.blockBorderRaduis * 2)
              .padding({left:size.pagePadding * 2,right:size.pagePadding * 2})
          })
        }
      }.blockStyle()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}