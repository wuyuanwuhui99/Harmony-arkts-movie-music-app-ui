import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import AvaterComponent from './AvaterComponent';
import { UserDataInterface, UserMsgInterface, MovieInterface } from '../interface/Index';
import { USER_DATA } from '../../config/constant';
import { getUserMsgService, getPlayRecordMovieListService,getMyViewsMovieListService,getMyFavoriteMovieListService } from '../service/Index'
import { HOST } from '../../config/constant';

@Extend(Image) function classifyIconStyle(iconSize: number) {
  .width(iconSize)
  .height(iconSize)
  .margin({ right: size.pagePadding })
}

@Entry
@Component
export default struct MyComponent {
  scroller: Scroller = new Scroller()
  @State bigAvaterSize: number = size.bigAvaterSize;
  @State userMsg: UserMsgInterface = null;
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  @State showPlayRecordMovieList: boolean = true; // 展示我的观看记录
  @State playRecordMovieList: Array<MovieInterface> = []; // 观看记录列表

  @State showMyFavoriteList: boolean = false; // 显示我的收藏列表
  @State myFavoriteList: Array<MovieInterface> = []; // 我的收藏列表

  @State showMyViewList: boolean = false; // 显示我浏览过的电影
  @State myViewList: Array<MovieInterface> = []; // 显示我浏览过的电影

  @State loading: boolean = false;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  aboutToAppear() {
    this.useUserMsgService()
    this.usePlayRecord()
  }

  /**
   * @description: 获取用户使用天数、访问记录数量等
   * @date: 2023-12-10 10:20
   * @author wuwenqiang
   */
  useUserMsgService() {
    getUserMsgService().then(res => {
      this.userMsg = res.data
    })
  }

  /**
   * @description: 获取用户观看记录
   * @date: 2023-12-13 21:47
   * @author wuwenqiang
   */
  usePlayRecord() {
    getPlayRecordMovieListService().then(res => {
      this.playRecordMovieList = res.data;
    })
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Row() {
            AvaterComponent({ dimensions: this.bigAvaterSize })
            Flex({ direction: FlexDirection.Column }) {
              Text(this.userData?.username || '')
                .fontSize(size.bigFontSize)
                .fontWeight(FontWeight.Bolder)
                .margin({ bottom: size.smallPadding })
              Text(this.userData?.sign || '').fontColor(colors.disableTextColor)
            }
            .margin({ left: size.pagePadding })
            .flexGrow(1)

            Image($r('app.media.icon_edit')).height(size.bigIconSize).width(size.bigIconSize)
          }.blockStyle().width('100%').align(Alignment.Center)

          Row() {
            Column() {
              Text(this.userMsg?.userAge.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('使用天数').fontColor(colors.disableTextColor).margin({ top: size.smallPadding })
            }.flexGrow(1)

            Column() {
              Text(this.userMsg?.favoriteCount.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('收藏').fontColor(colors.disableTextColor).margin({ top: size.smallPadding })
            }.flexGrow(1)

            Column() {
              Text(this.userMsg?.playRecordCount.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('观看记录').fontColor(colors.disableTextColor).margin({ top: size.smallPadding })
            }.flexGrow(1)

            Column() {
              Text(this.userMsg?.viewRecordCount.toString()).fontSize(size.bigFontSize).fontWeight(FontWeight.Bolder)
              Text('浏览记录').fontColor(colors.disableTextColor).margin({ top: size.smallPadding })
            }.flexGrow(1)
          }.blockStyle()

          Column() {
            Row() {
              Image($r('app.media.icon_play_record')).height(size.middlIconSize).width(size.middlIconSize)
              Text('观看记录').padding({ left: size.smallPadding }).flexGrow(1)
              Image($r('app.media.icon_arrow'))
                .classifyIconStyle(size.smallIconSize)
                .rotate({ angle: this.showPlayRecordMovieList ? 90 : 0 })
            }
            .margin({
              bottom: this.showPlayRecordMovieList && this.playRecordMovieList.length > 0 ? size.pagePadding : 0
            })
            .width('100%')
            .onClick(() => {
              this.showPlayRecordMovieList = !this.showPlayRecordMovieList;
              if(this.showPlayRecordMovieList){
                getMyViewsMovieListService(1,20).then(res => this.playRecordMovieList = res.data)
              }
            })

            if (this.showPlayRecordMovieList && this.playRecordMovieList.length > 0) {
              Scroll() {
                Row() {
                  ForEach(this.playRecordMovieList, (item: MovieInterface) => {
                    Column() {
                      Image(HOST + item.localImg)
                        .width(size.movieWidth)
                        .height(size.movieHeight)
                        .borderRadius(size.blockBorderRaduis)
                        .margin({ bottom: size.smallPadding })
                      Text(item.movieName).fontSize(size.normalFontSize)
                    }
                    .margin({ right: size.smallPadding })
                    .alignItems(HorizontalAlign.Center)
                    .width(size.movieWidth)
                  })
                }
              }.width('100%').scrollable(ScrollDirection.Horizontal)
            }
          }.blockStyle().alignItems(HorizontalAlign.Start)

          Column() {
            Row() {
              Image($r('app.media.icon_collection')).classifyIconStyle(size.middlIconSize)
              Text('我的收藏').flexGrow(1)
              Image($r('app.media.icon_arrow'))
                .classifyIconStyle(size.smallIconSize)
                .rotate({ angle: this.showMyFavoriteList ? 90 : 0 })
            }.width('100%')
            .onClick(() => {
              this.showMyFavoriteList = !this.showMyFavoriteList;
              if(this.showMyFavoriteList){
                getMyFavoriteMovieListService(1,20).then(res => this.myFavoriteList = res.data)
              }
            })

            if (this.showMyFavoriteList && !this.loading && this.myFavoriteList.length > 0) {
              Scroll() {
                Row() {
                  ForEach(this.myFavoriteList, (item: MovieInterface) => {
                    Column() {
                      Image(HOST + item.localImg)
                        .width(size.movieWidth)
                        .height(size.movieHeight)
                        .borderRadius(size.blockBorderRaduis)
                        .margin({ bottom: size.smallPadding })
                      Text(item.movieName).fontSize(size.normalFontSize)
                    }
                    .margin({ right: size.smallPadding })
                    .alignItems(HorizontalAlign.Center)
                    .width(size.movieWidth)
                  })
                }
              }.width('100%').scrollable(ScrollDirection.Horizontal)
            }
          }.blockStyle().alignItems(HorizontalAlign.Start)

          Column() {
            Row() {
              Image($r('app.media.icon_record')).classifyIconStyle(size.middlIconSize)
              Text('我浏览过的电影').flexGrow(1)
              Image($r('app.media.icon_arrow')).classifyIconStyle(size.smallIconSize).rotate({
                angle: this.showMyViewList ? 90 : 0
              })
            }.width('100%')
            .onClick(() => {
              this.showMyViewList = !this.showMyViewList;
              if(this.showMyViewList){
                getMyViewsMovieListService(1,20).then(res => this.myViewList = res.data)
              }
            })
            if (this.showMyViewList && !this.loading && this.myViewList.length > 0) {
              Scroll() {
                Row() {
                  ForEach(this.myViewList, (item: MovieInterface) => {
                    Column() {
                      Image(HOST + item.localImg)
                        .width(size.movieWidth)
                        .height(size.movieHeight)
                        .borderRadius(size.blockBorderRaduis)
                        .margin({ bottom: size.smallPadding })
                      Text(item.movieName).fontSize(size.normalFontSize)
                    }
                    .margin({ right: size.smallPadding })
                    .alignItems(HorizontalAlign.Center)
                    .width(size.movieWidth)
                  })
                }
              }.width('100%').scrollable(ScrollDirection.Horizontal)
            }
          }.blockStyle().alignItems(HorizontalAlign.Start)

          Column() {
            Column() {
              Row() {
                Image($r('app.media.icon_music')).classifyIconStyle(size.middlIconSize)
                Text('音乐').flexGrow(1)
                Image($r('app.media.icon_arrow')).classifyIconStyle(size.smallIconSize)
              }.width('100%')
            }.margin({ top: size.pagePadding })
            Column() {
              Row() {
                Image($r('app.media.icon_music_circle')).classifyIconStyle(size.middlIconSize)
                Text('电影圈').flexGrow(1)
                Image($r('app.media.icon_arrow')).classifyIconStyle(size.smallIconSize)
              }.width('100%')
            }.margin({ top: size.pagePadding })
            Column() {
              Row() {
                Image($r('app.media.icon_app')).classifyIconStyle(size.middlIconSize)
                Text('小程序').flexGrow(1)
                Image($r('app.media.icon_arrow')).classifyIconStyle(size.smallIconSize)
              }.width('100%')
            }.margin({ top: size.pagePadding })
          }.blockStyle().alignItems(HorizontalAlign.Start)
        }
      }.scrollable(ScrollDirection.Vertical)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,bottom:size.pagePadding  })
  }
}