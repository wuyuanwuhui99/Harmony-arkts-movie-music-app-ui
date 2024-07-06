import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface } from '../interface';
import TitleComponent from '../../movie/components/TitleComponent';
import { HOST, MUSIC_SEARCH } from '../../config/constant';
import { searchMusicService } from '../service/Index';

@Entry
@Component
export default struct MusicSearchPage {
  @State searchKeyWord:string = '黄昏';
  @State loading:boolean = false;
  @State searching:boolean = false;
  @State musicItem:MusicInterface = null;
  @State searchRecordList:Array<string> = AppStorage.Get(MUSIC_SEARCH) || [];
  @State searchMusicList:Array<MusicInterface> = [];// 搜索结果
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
  }

  /**
   * @description: 音乐搜索
   * @date: 2024-07-06 09:04
   * @author wuwenqiang
   */
  useSearch = () => {
    if (this.loading) return;
    this.loading = true;
    this.searching = true;
    if (!this.searchKeyWord) {
      this.searchKeyWord = this.musicItem.songName;
    }
    const index:number = this.searchRecordList.findIndex(item => item === this.searchKeyWord);
    index != -1 && this.searchRecordList.splice(index,1);
    this.searchRecordList.unshift(this.searchKeyWord)

    // 搜索记录写入缓存
    PersistentStorage.PersistProp<Array<string>>(MUSIC_SEARCH, this.searchRecordList);
    // 搜索
    searchMusicService(encodeURIComponent(this.searchKeyWord), 20, 1).then((res) => {
      this.searchMusicList = res.data;
    }).catch((err)=>{
      console.log(err);
    }).finally(() => this.loading = false);
  }

  build() {
    Column() {
      Row({space:size.pagePadding}){
        Row() {
          TextInput({text:this.searchKeyWord,placeholder:this.musicItem ? `${this.musicItem.authorName} - ${this.musicItem.songName}` : '请输入歌曲名或者歌手'})
            .height(size.middleAvaterSize)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onChange((value) => {
              this.searchKeyWord = value.trim();
            })

          if (this.searchKeyWord) {
            Image($r('app.media.icon_clear'))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .onClick(() => {
                this.searchKeyWord = '';
              })
              .margin({right: size.pagePadding })
              .onClick(() => {
                this.searchKeyWord = '';
                this.searching = false;
              })
          }
        }
        .borderRadius(size.middleAvaterSize)
        .backgroundColor(colors.pageBackgroundColor)
        .layoutWeight(1)

        Button('搜索', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(colors.lineBackgroundColor)
          .width(size.btnWidth)
          .height(size.inputHeight)
          .onClick(this.useSearch)
      }.blockStyle()

      if(this.searching){
        if (!this.loading) {
          if (this.searchMusicList.length === 0) {
            Column() {
              Text("暂无搜索结果")
                .width('100%')
                .height(size.bigAvaterSize)
                .textAlign(TextAlign.Center)
            }.blockStyle()
          }else{
            Scroll(){
              Column({space:size.pagePadding}){
                ForEach(this.searchMusicList,(item:MusicInterface,index:number) => {
                  Row({space:size.pagePadding}){
                    Image(/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}', '480') : HOST + item.cover)
                      .width(size.middleAvaterSize)
                      .aspectRatio(1)
                      .borderRadius(size.middleAvaterSize)
                    Column({space:size.smallPadding}){
                      Text(item.songName)
                      Text(item.authorName).fontColor(colors.disableTextColor)
                    }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                    Image($r("app.media.icon_music_play"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                      .onClick(() => {})
                    Image(item.isLike ? $r("app.media.icon_like_active") : $r("app.media.icon_like"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                      .margin({ left: size.pagePadding })
                    Image($r("app.media.icon_music_menu"))
                      .width(size.smallIconSize)
                      .height(size.smallIconSize)
                  }.alignItems(VerticalAlign.Center)
                  if(index !== this.searchMusicList.length - 1)Divider().height(1).color(colors.borderColor)
                })
              }.justifyContent(FlexAlign.Start)
            }.blockStyle().margin({bottom:size.pagePadding}).layoutWeight(1)
          }
        }
      }else{
        Column(){
          TitleComponent({ title: "历史搜索",showMarginBottom:false})
          Flex({wrap:FlexWrap.Wrap,direction:FlexDirection.Row,justifyContent: FlexAlign.SpaceBetween}){
            ForEach(this.searchRecordList,(item:string)=>{
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}