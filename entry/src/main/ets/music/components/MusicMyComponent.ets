import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import AvaterComponent from '../../movie/components/AvaterComponent';
import { UserDataInterface } from '../../movie/interface/Index'
import { HOST,USER_DATA } from '../../config/constant';
import {getMySingerService,getMusicPlayMenuService,getMusicRecordService} from '../service';
import {MusicSingerInterface,MuiscPlayMenuInterface} from '../interface';
import { MusicInterface } from '../interface/Index';

@Component
export default struct MusicMyComponent{
  scroller: Scroller = new Scroller()

  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  @State dimensions:number = size.middleAvaterSize;// 导入的值不能直接传给组件
  @State myMusicMenuList:Array<MuiscPlayMenuInterface> = [];// 我的歌单
  @State mySingerList:Array<MusicSingerInterface> = [];// 我关注的歌手列表
  @State myRecordMusicList:Array<MusicInterface> =[];// 我听过的歌曲
  @State isFoldRecordMusic:boolean = false;// 是否折叠我听过的歌曲
  @State isFoldMySinger:boolean = false;// 是否折叠我关注的歌手

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  aboutToAppear(){
    getMySingerService(1,5).then((res)=>{
      this.mySingerList = res.data;
    });
    getMusicPlayMenuService().then(res => this.myMusicMenuList = res.data);
    getMusicRecordService(1,5).then(res => this.myRecordMusicList = res.data);
  }



  build(){
    Scroll(this.scroller) {
      Column(){
        Row(){
          AvaterComponent({dimensions:this.dimensions})
          Column(){
            Text(this.userData && this.userData.username).fontWeight(FontWeight.Bold)
            Text(this.userData && this.userData.sign).fontColor(colors.disableTextColor)
          }.alignItems(HorizontalAlign.Start).margin({left:size.pagePadding})
        }.blockStyle()

        Row(){
          Column(){
            Image($r("app.media.icon_menu_board"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("播放清单")
          }.width('25%')
          Column(){
            Image($r("app.media.icon_menu_like"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("喜欢")
          }.width('25%')
          Column(){
            Image($r("app.media.icon_menu_collect"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("收藏")
          }.width('25%')
          Column(){
            Image($r("app.media.icon_menu_history"))
              .width(size.middlIconSize)
              .height(size.middlIconSize)
              .margin({bottom:size.pagePadding})
            Text("历史播放")
          }.width('25%')
        }.blockStyle()

        Column(){
          Row(){
            Image($r("app.media.icon_down")).width(size.smallIconSize).height(size.smallIconSize)
            Text("我的歌单").margin({left:size.pagePadding})
            Blank()
            Image($r("app.media.icon_add")).width(size.smallIconSize).height(size.smallIconSize)
          }.width('100%')
          ForEach(this.myMusicMenuList,(item:MuiscPlayMenuInterface)=>{
            Row(){
              Image(item.cover ? HOST + item.cover : $r("app.media.default_avater"))
                .width(size.middleAvaterSize)
                .height(size.middleAvaterSize)
                .borderRadius(size.middleAvaterSize)
              Column(){
                Text(item.name)
                Text(item.total.toString() + '首').fontColor(colors.disableTextColor)
              }.margin({left:size.pagePadding}).alignItems(HorizontalAlign.Start)
              Blank()
              Image($r("app.media.icon_music_play"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({left:size.pagePadding})
              Image($r("app.media.icon_music_menu"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({left:size.pagePadding})
            }.width('100%').margin({top:size.pagePadding})
          })
        }.blockStyle()

        Column(){
          Row(){
            Image($r("app.media.icon_down"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .onClick(()=>{
                this.isFoldMySinger = !this.isFoldMySinger;
                if(!this.isFoldMySinger){
                  getMusicPlayMenuService().then(res => this.myMusicMenuList = res.data);
                }
              }).rotate({ angle: this.isFoldMySinger ? 90 : 0 })
            Text("我关注的歌手").margin({left:size.pagePadding})
            Blank()
            Text("更多").fontColor(colors.disableTextColor)
          }.width('100%')
          if(!this.isFoldMySinger){
            ForEach(this.mySingerList,(item:MusicSingerInterface)=>{
              Row(){
                Image(item.avatar ? (/http[s]?:\/\//.test(item.avatar) ? item.avatar.replace('{size}', '480') : HOST + item.avatar) : $r("app.media.default_avater"))
                  .width(size.middleAvaterSize)
                  .height(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                Column(){
                  Text(item.authorName)
                  Text(item.total.toString() + '首').fontColor(colors.disableTextColor)
                }.margin({left:size.pagePadding}).alignItems(HorizontalAlign.Start)
                Blank()
                Image($r("app.media.icon_music_play"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({left:size.pagePadding})
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({left:size.pagePadding})
              }.width('100%').margin({top:size.pagePadding})
            })
          }
        }.blockStyle()

        Column(){
          Row(){
            Image($r("app.media.icon_down"))
              .width(size.smallIconSize)
              .height(size.smallIconSize)
              .onClick(()=>{
                this.isFoldRecordMusic = !this.isFoldRecordMusic;
                if(!this.isFoldRecordMusic){
                  getMusicRecordService(1,5).then(res => this.myRecordMusicList = res.data);
                }
              }).rotate({ angle: this.isFoldRecordMusic ? 90 : 0 })
            Text("我听过的歌曲").margin({left:size.pagePadding})
            Blank()
            Text("更多").fontColor(colors.disableTextColor)
          }.width('100%')
          if(!this.isFoldRecordMusic){// 如果是展开状态
            ForEach(this.myRecordMusicList,(item:MusicInterface)=>{
              Row(){
                Image(item.cover ? (/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}', '480') : HOST + item.cover) : $r("app.media.default_avater"))
                  .width(size.middleAvaterSize)
                  .height(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                Column(){
                  Text(item.songName)
                  Text(`听过${item.times.toString()}次`).fontColor(colors.disableTextColor)
                }.margin({left:size.pagePadding}).alignItems(HorizontalAlign.Start)
                Blank()
                Image($r("app.media.icon_music_play"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({left:size.pagePadding})
                Image($r("app.media.icon_music_menu"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({left:size.pagePadding})
              }.width('100%').margin({top:size.pagePadding})
            })
          }

        }.blockStyle()
      }

    }.scrollable(ScrollDirection.Vertical)
    .width("100%")
    .height("100%").align(Alignment.Top)
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}