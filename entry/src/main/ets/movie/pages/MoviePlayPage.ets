import router from '@ohos.router';
import web_webview from '@ohos.web.webview'
import { MovieInterface, MovieUrlInterface } from "../interface";
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { getMovieUrlService } from '../service/Index';
import { getCommentCountService, isFavoriteService, saveFavoriteService, deleteFavoriteService } from '../service/Index';
import { SocialEnum } from '../../common/enum';
import BottomDialogComponent from '../components/BottomDialogComponent';
import CommentComponent from '../components/CommentComponent';

@Entry
@Component
struct MoviePlayPage {
  @State movieItem: MovieInterface = null; // 电影详情
  @State recommendMovieList: Array<MovieInterface> = []; // 推荐的电影
  @State currentUrl: string = ''; // 当前播放地址
  @State currentUrlGroup: number = 0; // 当前选中的url分组
  @State commentTotal: number = 0; // 评论总数
  @State isFavorite: boolean = false; // 是否搜查电影
  private loading: boolean = false;
  private controller: web_webview.WebviewController = new web_webview.WebviewController();
  private customDialogController: CustomDialogController;
  @State movieUrlGroup: Array<Array<MovieUrlInterface>> = <Array<Array<MovieUrlInterface>>> []; // 电影分组

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  aboutToDisappear() {
    this.customDialogController = null;
  }

  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.movieItem = params['movieItem'] as MovieInterface; // 获取info属性的值
    this.movieItem.id = 72667;// 测试数据
    getMovieUrlService(this.movieItem.id).then(res => { // 获取电影播放地址分组
      res.data.forEach((dItem, dIndex) => {
        if (dIndex === 0) {
          this.currentUrl = dItem.url;
        }
        const index: number = this.movieUrlGroup.findIndex((mItem) => mItem[0].playGroup === dItem.playGroup)
        if (index != -1) {
          this.movieUrlGroup[index].push(dItem);
        } else {
          this.movieUrlGroup.push([dItem]);
        }
      })
    })

    /**
     * @author: wuwenqiang
     * @description: 查询评论数量
     * @date: 2024-05-25 16:30
     */
    getCommentCountService(this.movieItem.id, SocialEnum.MOVIE.toString()).then((res) => {
      this.commentTotal = res.data;
    });

    /**
     * @author: wuwenqiang
     * @description: 查询是否已经收藏
     * @date: 2024-05-25 16:30
     */
    isFavoriteService(this.movieItem.id).then((res) => {
      this.isFavorite = res.data > 0;
    })
  }

  /**
   * @author: wuwenqiang
   * @description: 创建评论
   * @date: 2024-05-25 16:30
   */
  @Builder commentBuilder() {
    CommentComponent({commentListStr:'' ,relationId: this.movieItem.id, type: SocialEnum.MOVIE.toString() })
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          if (this.currentUrl) {
            Web({ src: this.currentUrl, controller: this.controller })
              .width('100%')
              .aspectRatio(16 / 9)
              .backgroundColor(Color.Black)
          } else {
            Row().height(size.webviewHeight).width('100%').backgroundColor(Color.Black)
          }

          Column() {
            Row() {
              Image($r('app.media.icon_comment'))
                .height(size.middlIconSize)
                .width(size.middlIconSize)
                .margin({ right: size.pagePadding }).onClick(() => {
                if (!this.customDialogController) {
                  this.customDialogController = new CustomDialogController({
                    customStyle: true,
                    builder: BottomDialogComponent({
                      dialogHeight: '80%',
                      builder: this.commentBuilder.bind(this)
                    }),
                    alignment: DialogAlignment.Bottom,
                  })
                }
                this.customDialogController.open();
              })
              Text(this.commentTotal.toString())
              Blank()
              Image(this.isFavorite ? $r('app.media.icon_collection_active') : $r('app.media.icon_collection'))
                .height(size.middlIconSize)
                .width(size.middlIconSize)
                .margin({ right: size.pagePadding }).onClick(() => {
                if (this.loading) return;
                this.loading = false;
                if (this.isFavorite) {
                  deleteFavoriteService(this.movieItem.id)
                    .then(res => this.isFavorite = !(res.data > 0))
                    .finally(() => this.loading = false)
                } else {
                  saveFavoriteService(this.movieItem.id)
                    .then(res => this.isFavorite = res.data > 0)
                    .finally(() => this.loading = false)
                }
              })
              Image($r('app.media.icon_share'))
                .height(size.middlIconSize)
                .width(size.middlIconSize)
            }.blockStyle()

            Column() {
              Text(this.movieItem.movieName)
                .fontWeight(FontWeight.Bolder)
                .fontSize(size.bigFontSize)
                .padding({ bottom: size.smallPadding })
              Text(this.movieItem.star).fontSize(size.normalFontSize)
              if (this.movieItem.score) {
                Row() {
                  Rating().stars(this.movieItem.score).stepSize(0.1)
                  Text(this.movieItem.score.toString())
                    .padding({ left: size.smallPadding })
                    .fontColor(Color.Red)
                    .fontSize(size.normalFontSize)
                    .fontWeight(FontWeight.Bolder)
                }.justifyContent(FlexAlign.Start).margin({ top: size.smallPadding })
              }
            }.blockStyle().alignItems(HorizontalAlign.Start)

            Column() {
              Scroll() {
                Row() {
                  ForEach(this.movieUrlGroup, (item: Array<MovieUrlInterface>, index: number) => {
                    Text((/^\d$/.test(item[0].playGroup) ? '分组' : '') + item[0].playGroup).border({
                      width: {
                        top: this.currentUrlGroup == index ? 1 : 0,
                        bottom: this.currentUrlGroup == index ? 0 : 1,
                        left: this.currentUrlGroup == index ? 1 : 0,
                        right: this.currentUrlGroup == index ? 1 : 0
                      },
                      color: colors.pageBackgroundColor,
                      style: BorderStyle.Solid
                    }).padding(size.smallPadding)
                      .fontColor(this.currentUrlGroup == index ? Color.Orange : Color.Black)
                      .onClick(() => {
                        this.currentUrlGroup = index;
                      })
                  })
                }
              }.width('100%').scrollable(ScrollDirection.Horizontal)

              Grid() {
                ForEach(this.movieUrlGroup[this.currentUrlGroup], (item: MovieUrlInterface) => {
                  GridItem() {
                    Text(item.label)
                      .border({
                        width: 1,
                        color: this.currentUrl == item.url ? Color.Orange : Color.Black,
                        style: BorderStyle.Solid
                      })
                      .padding(size.smallPadding)
                      .fontColor(this.currentUrl == item.url ? Color.Orange : Color.Black)
                      .width('100%')
                      .textAlign(TextAlign.Center)
                      .borderRadius(size.blockBorderRaduis)
                  }
                })
              }
              .columnsTemplate('1fr 1fr 1fr 1fr')
              .columnsGap(size.smallPadding)
              .rowsGap(size.smallPadding).margin({ top: size.smallPadding })
            }.blockStyle().alignItems(HorizontalAlign.Start)
          }
          .backgroundColor(colors.pageBackgroundColor)
          .padding({ left: size.pagePadding, right: size.pagePadding, bottom: size.pagePadding })
        }.justifyContent(FlexAlign.Start)
      }
    }.width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor(colors.pageBackgroundColor)
  }
}