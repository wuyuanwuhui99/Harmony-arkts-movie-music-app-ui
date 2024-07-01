import { HOST } from '../../config/constant';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { FavoriteDirectoryInterface } from '../interface/Index';
import {  getFavoriteDirectoryService } from '../service/Index';

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
  private checkboxValue:Array<number> = [];
  @State favoriteDirectoryList:Array<FavoriteDirectoryInterface> = [];
  private dialogController: CustomDialogController;

  aboutToAppear() {
    getFavoriteDirectoryService(this.musicId).then((res)=>{
      res.data.forEach(item => {
        if(item.checked){
          this.checkboxValue.push(item.id);
        }
        this.favoriteDirectoryList.push(item);
      })
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

      Scroll() {
        Column(){
          Row(){
            Row(){
              Image($r("app.media.icon_add"))
                .width(size.middlIconSize)
                .aspectRatio(1)
            }.roundedSquareStyle()
            Text('新建收藏夹')
          }.width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
          ForEach(this.favoriteDirectoryList,(item:FavoriteDirectoryInterface)=>{
            Blank().height(size.pagePadding)
            Row(){
              if(item.cover){
                Image(HOST + item.cover)
                  .borderRadius(size.blockBorderRaduis)
                  .width(size.roundedSquareSize)
                  .aspectRatio(1)
              }else{
                Row(){
                  Image($r("app.media.icon_music_default_cover"))
                    .width(size.middlIconSize)
                    .aspectRatio(1)
                }.roundedSquareStyle()
              }
              Text(item.name).margin({left:size.pagePadding}).layoutWeight(1)
              Checkbox({name: 'favoriteCheckbox',  group: 'checkboxGroup'})
                .select(item.checked === 1)
                .selectedColor(colors.lineBackgroundColor)
                .onChange((value: boolean) => {
                  console.info('Checkbox1 change is'+ value)
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
        Button('添加')
          .width('100%')
          .padding(size.pagePadding)
          .backgroundColor(colors.warnColor)
          .fontColor(Color.White)
          .borderRadius(size.blockBorderRaduis * 2)
          .onClick(() => {

          })
      }.padding(size.pagePadding)
    }.width('100%').height('100%')
  }
}