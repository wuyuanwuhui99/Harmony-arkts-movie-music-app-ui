import { HOST } from '../../common/constant';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { FavoriteDirectoryInterface, FavoriteMusicInterface } from '../interface/Index';
import {  getFavoriteDirectoryService, insertMusicFavoriteService,insertFavoriteDirectoryService } from '../service/Index';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';
import { getMusicCover } from '../../utils/common';

@Extend(Row) function roundedSquareStyle  () {
  .alignItems(VerticalAlign.Center)
  .justifyContent(FlexAlign.Center)
  .backgroundColor(colors.pageBackgroundColor)
  .borderRadius(size.blockBorderRaduis)
  .width(size.roundedSquareSize)
  .aspectRatio(1)
}

@Component
export default struct FavoriteComponent {
  @Prop musicId: number;
  @Prop isFavorite:boolean;
  @State checkboxValue:Array<number> = [];
  @State favoriteDirectoryList:Array<FavoriteDirectoryInterface> = [];
  @State isCreateFavoriteDirectory:boolean = false;
  @State favoriteName:string = '';
  public onFavorite: (isFavorite:boolean) => void;

  aboutToAppear() {
    getFavoriteDirectoryService(this.musicId).then((res)=>{
      res.data.forEach(item => {
        item.checked && this.checkboxValue.push(item.id);
        this.favoriteDirectoryList.push(item);
      })
    })
  }

  useAddFavorite = () => {
    const favoriteList:Array<FavoriteMusicInterface> = this.checkboxValue.map(item=>{
      return {favoriteId:item} as FavoriteMusicInterface
    });
    insertMusicFavoriteService(this.musicId,favoriteList).then(res => {
      if(res.data > 0){
        promptAction.showToast({
          message: favoriteList.length == 0 ? '取消收藏成功' :'添加收藏成功',
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        })
        this.onFavorite(favoriteList.length !== 0);
      }
    })
  }

  build() {
    Column() {
      Text('收藏夹')
        .padding(size.pagePadding)
        .textAlign(TextAlign.Center)
        .border({
          width: { bottom: 1 },
          color: { bottom: colors.borderColor },
          style: { bottom: BorderStyle.Solid }
        }).width('100%')
      if(this.isCreateFavoriteDirectory){
        Column({space:size.pagePadding}){
          Row(){
            Text('*').fontColor(Color.Red)
            Text('名称')
            TextInput({ text: this.favoriteName, placeholder: '请输入收藏夹名称' })
              .height(size.middleAvaterSize)
              .backgroundColor(colors.pageBackgroundColor)
              .borderRadius(size.smallBorderRaduis)
              .margin({left:size.pagePadding})
              .onChange((value) => {
                this.favoriteName = value.trim();
              }).layoutWeight(1)
          }
          .width('100%')

          Row(){
            Text('*').visibility(Visibility.Hidden)
            Text('封面')
            Row(){
              Image($r('app.media.icon_add'))
                .width(size.middlIconSize)
                .aspectRatio(1)
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)
            .backgroundColor(colors.pageBackgroundColor)
            .borderRadius(size.smallBorderRaduis)
            .margin({left:size.pagePadding})
            .width(size.bigAvaterSize)
            .aspectRatio(1)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)

          Button('创建')
            .width('100%')
            .padding(size.pagePadding)
            .backgroundColor(colors.warnColor)
            .fontColor(Color.White)
            .borderRadius(size.blockBorderRaduis * 2)
            .onClick(() => {
              const favoriteDirectory:FavoriteDirectoryInterface = {
                name:this.favoriteName,
                cover: null
              }
              insertFavoriteDirectoryService(favoriteDirectory).then(res => {
                this.isCreateFavoriteDirectory = false;
                this.favoriteDirectoryList.unshift(res.data);
                promptAction.showToast({
                  message: '创建收藏夹成功',
                  duration: 2000,
                  bottom: px2vp(display.getDefaultDisplaySync().height) / 2
                })
              });
            })

          Button('取消')
            .width('100%')
            .padding(size.pagePadding)
            .border({width:1,color:colors.borderColor})
            .backgroundColor(Color.Transparent)
            .fontColor(Color.Black)
            .borderRadius(size.blockBorderRaduis * 2)
            .onClick(() => {
              this.isCreateFavoriteDirectory = false
            })
        }.padding(size.pagePadding)
      }else{
        Scroll() {
          Column(){
            Row(){
              Row(){
                Image($r("app.media.icon_add"))
                  .width(size.middlIconSize)
                  .aspectRatio(1)
              }.roundedSquareStyle()
              Text('新建收藏夹')
            }.width('100%').onClick(() => this.isCreateFavoriteDirectory = true)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            ForEach(this.favoriteDirectoryList,(item:FavoriteDirectoryInterface)=>{
              Blank().height(size.pagePadding)
              Row(){
                if(item.cover){
                  Image(getMusicCover(item.cover))
                    .width(size.middleAvaterSize)
                    .height(size.middleAvaterSize)
                    .borderRadius(size.middleAvaterSize)
                }else {
                  Text(item.name[0])
                    .textAlign(TextAlign.Center)
                    .width(size.middleAvaterSize)
                    .height(size.middleAvaterSize)
                    .backgroundColor(colors.pageBackgroundColor)
                    .borderRadius(size.middleAvaterSize)
                }
                Column({space:size.smallPadding}){
                  Text(item.name)
                  Text(`${item.total}首`).fontColor(colors.disableTextColor)
                }.alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                .margin({left:size.pagePadding})
                Checkbox({name: 'favoriteCheckbox',  group: 'checkboxGroup'})
                  .select(item.checked === 1)
                  .selectedColor(colors.lineBackgroundColor)
                  .onChange((value: boolean) => {
                    item.checked = value ? 1 : 0;
                    this.checkboxValue.length = 0;
                    this.favoriteDirectoryList.forEach( item => item.checked && this.checkboxValue.push(item.id))
                  })
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Center)
            })
          }
        }
        .scrollable(ScrollDirection.Vertical)
        .layoutWeight(1)
        .align(Alignment.Top)
        .padding(size.pagePadding)
        Column(){
          Button(this.isFavorite && this.checkboxValue.length == 0 ? '取消收藏': `添加${this.checkboxValue.length > 0 ? `（已选${this.checkboxValue.length}个）` : ''}`)
            .width('100%')
            .padding(size.pagePadding)
            .backgroundColor(colors.warnColor)
            .fontColor(Color.White)
            .borderRadius(size.blockBorderRaduis * 2)
            .onClick(this.useAddFavorite)
        }.padding(size.pagePadding)
      }

    }.width('100%').height('100%')
  }
}