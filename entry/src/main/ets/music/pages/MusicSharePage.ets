import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import router from '@ohos.router';
import { MusicInterface, MusicStorageInterface,CircleInterface } from '../interface';
import TitleComponent from '../../movie/components/TitleComponent';
import { HOST, MUSIC_SEARCH, MUSIC_STORAGE } from '../../common/constant';
import { SocialEnum } from '../../common/enum';
import { LIKE_INNER_EVENT, PermissionValueMap } from '../../common/config';
import { deleteMusicLikeService, insertMusicLikeService, saveCircleService, searchMusicService } from '../service/Index';
import { getMusicCover, useAppStorage, useUpdateStorage } from '../../utils/common';
import { PermissionMap } from '../../common/config';
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';
import emitter from '@ohos.events.emitter';
import OptionDialogComponent from '../../movie/components/OptionDialogComponent';

@Entry
@Component
export default struct MusicSharePage {
  @State searchKeyWord:string = '黄昏';
  @State loading:boolean = false;
  @State searching:boolean = false;
  @State searchRecordList:Array<string> = AppStorage.Get(MUSIC_SEARCH) || [];
  @State searchMusicList:Array<MusicInterface> = [];// 搜索结果
  @State total:number = 0;
  @State circlrModel:CircleInterface = {
    type:SocialEnum.MUSIC,
    permission:1,
    relationId:0,// 关联音乐audio_id或者电影movie_id
    content:'',// 朋友圈内容
  } as CircleInterface;
  @State musicItem:MusicInterface = null;
  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()

  private dialogController: CustomDialogController;

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
  }

  /**
   * @description: 分享
   * @date: 2024-07-14 06:54
   * @author wuwenqiang
   */
  useSave= () => {
    if(this.loading)return;
    this.loading = true;
    saveCircleService(this.circlrModel).then(() => {
      promptAction.showToast({
        message: "发布成功",
        duration: 2000,
        bottom: px2vp(display.getDefaultDisplaySync().height) / 2
      });
      router.back();
    }).finally(()=>this.loading = false)
  }

  /**
   * @description: 选择权限
   * @date: 2024-07-14 06:54
   * @author wuwenqiang
   */
  usePermission=()=>{
    if(!this.dialogController){
      this.dialogController = new CustomDialogController({
        customStyle: true,
        builder: OptionDialogComponent({
          cancel: () => this.onCancel(),
          confirm: (value) => this.onConfirm(value),
          options: ['公开', '私密'],
        }),
        alignment: DialogAlignment.Bottom,
      })
    }
    this.dialogController.open();
  }

  onCancel(){
    this.dialogController.close();
  }

  onConfirm(value:string){
    this.dialogController.close();
    this.circlrModel = {...this.circlrModel,permission: PermissionValueMap[value]}
  }

  aboutToAppear() {
    const params = router.getParams(); // 获取传递过来的参数对象
    this.musicItem = params['musicItem'] as MusicInterface; // 获取info属性的值
    this.circlrModel.relationId = this.musicItem.id;
  }

  build() {
    Column() {
      Row(){
        Button('取消', { type: ButtonType.Capsule, stateEffect: true })
          .width(size.btnWidth)
          .height(size.inputHeight)
          .borderRadius(size.smallBorderRaduis)
          .backgroundColor(colors.blockColor)
          .fontColor(colors.tabNormalColor)
          .border({
            width:1,
            color:colors.disableTextColor
          })
          .onClick(()=>router.back())
        Button('发布', { type: ButtonType.Capsule, stateEffect: true })
          .width(size.btnWidth)
          .height(size.inputHeight)
          .borderRadius(size.smallBorderRaduis)
          .backgroundColor(colors.lineBackgroundColor)
          .onClick(this.useSave)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding(size.pagePadding)
      .backgroundColor(colors.blockColor)
      Column({space:size.pagePadding}){
        TextArea({ placeholder: "这一刻的想法" })
          .height(size.movieWidth)
          .backgroundColor(colors.textareaColor)
          .borderRadius(size.smallBorderRaduis)
          .onChange((value:string) => this.circlrModel.content = value)
        Row({space:size.pagePadding}){
          Image(getMusicCover(this.musicItem?.cover))
            .width(size.middleAvaterSize)
            .aspectRatio(1)
            .borderRadius(size.middleAvaterSize)
          Text(`${this.musicItem?.authorName} - ${this.musicItem.songName}`).layoutWeight(1)
        }
        .blockStyle()
        Row({space:size.pagePadding}){
          Image($r('app.media.icon_permission'))
            .width(size.middlIconSize)
            .aspectRatio(1)
          Text('谁可以看').layoutWeight(1)
          Text(PermissionMap[this.circlrModel.permission])
          Image($r('app.media.icon_arrow'))
            .opacity(size.opacity)
            .width(size.smallIconSize)
            .aspectRatio(1)
        }
        .blockStyle()
        .alignItems(VerticalAlign.Center)
        .onClick(this.usePermission)
      }.padding(size.pagePadding)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
  }
}