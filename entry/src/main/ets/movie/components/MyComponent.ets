import router from '@ohos.router';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import AvaterComponent from './AvaterComponent';
import { UserDataInterface, UserMsgInterface, MovieInterface } from '../interface/Index';
import { USER_DATA, HOST} from '../../common/constant';
import {
  getUserMsgService,
  getPlayRecordMovieListService,
  getMyViewsMovieListService,
  getMyFavoriteMovieListService
} from '../service/Index'

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

  @Styles classifyIconStyle(){
    .width(size.middlIconSize)
    .height(size.middlIconSize)
    .margin({ right: size.smallPadding })
  }

  @Styles arrowIconStyle(){
    .width(size.smallIconSize)
    .height(size.smallIconSize)
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
    getPlayRecordMovieListService(1,20).then(res => {
      this.playRecordMovieList = res.data;
    })
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Row() {
            AvaterComponent({ dimensions: this.bigAvaterSize })
            Column() {
              Text(this.userData?.username || '')
                .fontSize(size.bigFontSize)
                .fontWeight(FontWeight.Bolder)
                .margin({ bottom: size.smallPadding })
              Text(this.userData?.sign || '').fontColor(colors.disableTextColor)
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: size.pagePadding })
            .layoutWeight(1)
            Image($r('app.media.icon_edit'))
              .height(size.bigIconSize)
              .width(size.bigIconSize)
              .onClick(() => router.pushUrl({ url: 'movie/pages/MovieUserPage'}))
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
              Image($r('app.media.icon_play_record')).classifyIconStyle()
              Text('观看记录').flexGrow(1)
              Image($r('app.media.icon_arrow'))
                .arrowIconStyle()
                .opacity(size.opacity)
                .rotate({ angle: this.showPlayRecordMovieList ? 90 : 0 })
            }
            .margin({
              bottom: this.playRecordMovieList?.length > 0 ? size.pagePadding : 0
            })
            .width('100%')
            .onClick(() => {
              this.showPlayRecordMovieList = !this.showPlayRecordMovieList;
              if (this.showPlayRecordMovieList) {
                getMyViewsMovieListService(1, 20).then(res => this.playRecordMovieList = res.data)
              }
            })

            if (this.playRecordMovieList?.length > 0) {
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
              Image($r('app.media.icon_collection')).classifyIconStyle()
              Text('我的收藏').flexGrow(1)
              Image($r('app.media.icon_arrow'))
                .opacity(size.opacity)
                .arrowIconStyle()
                .rotate({ angle: this.showMyFavoriteList ? 90 : 0 })
            }.width('100%')
            .onClick(() => {
              this.showMyFavoriteList = !this.showMyFavoriteList;
              if (this.showMyFavoriteList) {
                getMyFavoriteMovieListService(1, 20).then(res => this.myFavoriteList = res.data)
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
              Image($r('app.media.icon_record')).classifyIconStyle()
              Text('我浏览过的电影').flexGrow(1)
              Image($r('app.media.icon_arrow')).opacity(size.opacity).arrowIconStyle().rotate({
                angle: this.showMyViewList ? 90 : 0
              })
            }.width('100%')
            .onClick(() => {
              this.showMyViewList = !this.showMyViewList;
              if (this.showMyViewList) {
                getMyViewsMovieListService(1, 20).then(res => this.myViewList = res.data)
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
                Image($r('app.media.icon_music')).classifyIconStyle()
                Text('音乐').flexGrow(1)
                Image($r('app.media.icon_arrow')).opacity(size.opacity).arrowIconStyle()
              }.width('100%').onClick(()=>{
                router.pushUrl({
                  url: 'music/pages/MusicIndexPage', // 目标url
                }, router.RouterMode.Standard, (err) => {
                  if (err) {
                    console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
                  }
                });
              })
            }

            Column() {
              Row() {
                Image($r('app.media.icon_music_circle')).classifyIconStyle()
                Text('电影圈').flexGrow(1)
                Image($r('app.media.icon_arrow')).opacity(size.opacity).arrowIconStyle()
              }.width('100%')
            }.margin({ top: size.pagePadding }).padding({ top: size.pagePadding }).border({
              width: {
                top: 1
              },
              color: {
                top: colors.borderColor
              },
              style: {
                top: BorderStyle.Solid
              }
            })

            Column() {
              Row() {
                Image($r('app.media.icon_app')).classifyIconStyle()
                Text('小程序').flexGrow(1)
                Image($r('app.media.icon_arrow')).opacity(size.opacity).arrowIconStyle()
              }.width('100%')
            }.margin({ top: size.pagePadding }).padding({ top: size.pagePadding }).border({
              width: {
                top: 1
              },
              color: {
                top: colors.borderColor
              },
              style: {
                top: BorderStyle.Solid
              }
            })
          }.blockStyle().margin({top:size.pagePadding,bottom:size.pagePadding}).alignItems(HorizontalAlign.Start)
        }
      }.scrollable(ScrollDirection.Vertical)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
  }
}