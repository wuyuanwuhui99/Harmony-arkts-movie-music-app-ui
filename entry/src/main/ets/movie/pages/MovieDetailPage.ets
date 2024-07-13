import router from '@ohos.router';
import {MovieInterface,StarInterface} from "../interface";
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {HOST} from '../../common/constant';
import TitleComponent from '../components/TitleComponent';
import {getMovieStartListService,getRecommentListService,saveViewRecordService} from '../service/Index';
@Entry
@Component
struct MovieDetailPage {
  @State movieItem:MovieInterface = null;// 电影详情
  @State starList:Array<StarInterface> = [];// 主演
  @State recommendMovieList:Array<MovieInterface> = [];// 推荐的电影

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.movieItem = params['movieItem'] as MovieInterface; // 获取info属性的值
    getMovieStartListService(this.movieItem.id).then(res => this.starList = res.data);// 获取主演
    getRecommentListService(encodeURIComponent(this.movieItem.classify)).then(res => this.recommendMovieList = res.data);// 获取推荐的电影
    saveViewRecordService(this.movieItem);// 插入浏览记录
  }

  build() {
    Column(){
      Scroll() {
        Column(){
          Row(){
            Row(){
              Image($r('app.media.icon_detail_play'))
                .width(size.bigIconSize)
                .height(size.bigIconSize)
            }
            .borderRadius(size.blockBorderRaduis)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .width(size.movieWidth)
            .height(size.movieHeight)
            .backgroundImage(HOST + this.movieItem.localImg,ImageRepeat.NoRepeat)
            .backgroundImageSize(ImageSize.Cover)
            .onClick((event:ClickEvent)=>{
              router.pushUrl({
                url: 'movie/pages/MoviePlayPage', // 目标url
                params: {
                  movieItem: this.movieItem
                }
              }, router.RouterMode.Standard, (err) => {
                if(err){
                  console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
                }
              });
            })
            Column(){
              Text(this.movieItem.movieName)
                .padding({bottom:size.smallPadding})
                .fontWeight(FontWeight.Bolder)
                .fontSize(size.bigFontSize)
              Text(this.movieItem.description?.replace(/\n|\s/g,'') || '')
                .padding({bottom:size.smallPadding})
                .fontSize(size.normalFontSize)
                .fontColor(colors.disableTextColor)
              Text(this.movieItem.star)
                .padding({bottom:size.smallPadding})
                .fontSize(size.normalFontSize)
                .fontColor(colors.disableTextColor)
              if(this.movieItem.score){
                Row(){
                  Rating().stars(this.movieItem.score).stepSize(0.1)
                  Text(this.movieItem.score.toString())
                    .padding({left:size.smallPadding})
                    .fontColor(Color.Red)
                    .fontSize(size.normalFontSize)
                    .fontWeight(FontWeight.Bolder)
                }.justifyContent(FlexAlign.Start).margin({top:size.smallPadding})
              }
            }.flexGrow(1)
            .alignItems(HorizontalAlign.Start)
            .margin({left:size.pagePadding})
          }.blockStyle()

          Column(){
            TitleComponent({title:'剧情',showMarginBottom:true})
            Text(this.movieItem.plot)
              .padding({top:size.smallPadding})
              .fontSize(size.normalFontSize)
              .fontColor(colors.disableTextColor)
          }.justifyContent(FlexAlign.Start)
          .blockStyle()

          Column(){
            TitleComponent({title:'演员',showMarginBottom:true})
            Scroll(){
              Row(){
                ForEach(this.starList,(item:StarInterface)=>{
                  Column(){
                    Image(HOST + item.localImg)
                      .width(size.movieWidth)
                      .height(size.movieHeight)
                      .borderRadius(size.blockBorderRaduis)
                      .margin({bottom:size.smallPadding})
                    Text(item.starName).fontSize(size.normalFontSize)
                  }
                  .margin({right:size.smallPadding})
                  .alignItems(HorizontalAlign.Center)
                  .width(size.movieWidth)
                })
              }
            }.width('100%').scrollable(ScrollDirection.Horizontal)
          }
          .blockStyle()

          Column(){
            TitleComponent({title:'推荐',showMarginBottom:true})
            Scroll(){
              Row(){
                ForEach(this.recommendMovieList,(item:MovieInterface)=>{
                  Column(){
                    Image(HOST + item.localImg)
                      .width(size.movieWidth)
                      .height(size.movieHeight)
                      .borderRadius(size.blockBorderRaduis)
                      .margin({bottom:size.smallPadding})
                    Text(item.movieName).fontSize(size.normalFontSize)
                  }
                  .margin({right:size.smallPadding})
                  .alignItems(HorizontalAlign.Center)
                  .width(size.movieWidth)
                })
              }
            }.width('100%').scrollable(ScrollDirection.Horizontal)
          }
          .blockStyle()

        }.justifyContent(FlexAlign.Start)
      }
    }.width('100%')
    .height('100%')
    .padding({ left: size.pagePadding, right: size.pagePadding,bottom:size.pagePadding  })
    .justifyContent(FlexAlign.Start)
    .backgroundColor(colors.pageBackgroundColor)
  }
}