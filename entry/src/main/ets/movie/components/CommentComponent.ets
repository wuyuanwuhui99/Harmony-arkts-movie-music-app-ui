import TitleComponent from './TitleComponent';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {getTopCommentListService} from '../service/Index';
import { HOST } from '../../config/constant';
import { CommentInterface } from '../../music/interface/Index';
import { formatTime } from '../../utils/common';

@Component
export default struct CommentComponent{
  @Prop relationId:number;
  @Prop type:string;
  @State commentTotal:number = 0;
  @State commentList:Array<CommentInterface> = [];
  @State text:string = '';// 评论框文字
  private scroller: Scroller = new Scroller()
  aboutToAppear(){

    /**
     * @author: wuwenqiang
     * @description: 获取评论列表
     * @date: 2024-05-25 21:36
     */
    getTopCommentListService(this.relationId,this.type,1,20).then(res => {
      this.commentList = res.data;
      this.commentTotal = res.total;
    });
  }

  /**
   * @author: wuwenqiang
   * @description: 创建评论列表
   * @date: 2024-05-25 16:30
   */
  @Builder buildCommentList(commentList:Array<CommentInterface>){
    Column({space:size.pagePadding}){
      ForEach(commentList,(item:CommentInterface) => {
        Row(){
          Image(item.avater ? HOST + item.avater : $r('app.media.default_avater'))
            .width(item.topId ? size.smallAvaterSize : size.middleAvaterSize)
            .height(item.topId ? size.smallAvaterSize : size.middleAvaterSize)
            .borderRadius(item.topId ? size.smallAvaterSize : size.middleAvaterSize)
          Column(){
            Text(item.topId ? `${item.username}▶${item.replyUserName}` : item.username)
              .fontColor(colors.disableTextColor).margin({bottom:size.miniPadding})
            Text(item.content).margin({bottom:size.miniPadding})
            Text(formatTime(item.createTime)).fontColor(colors.disableTextColor)
            if(item.replyList && item.replyList.length > 0){
              Blank().height(size.pagePadding)
              this.buildCommentList(item.replyList)
            }
          }.layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({left:size.pagePadding})
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
        .width('100%')
      })
    }
  }

  build(){
    Column(){
      Text(`${this.commentTotal}条评论`)
        .padding(size.pagePadding)
        .textAlign(TextAlign.Center)
        .border({
        width: { bottom: 1 },
        color: { bottom: colors.borderColor },
        style: { bottom: BorderStyle.Solid }
      }).width('100%')
      Scroll(this.scroller) {
        if(this.commentList.length > 0) {
          this.buildCommentList(this.commentList)
        }else{
          Text('暂无评论')
            .width('100%')
            .height('100%')
            .textAlign(TextAlign.Center)
            .alignSelf(ItemAlign.Center)
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .layoutWeight(1)
      .align(Alignment.Top)
      .padding(size.pagePadding)
      Row(){
        TextInput({ placeholder: "评论", text: '' })
          .layoutWeight(1)
          .margin({right:size.pagePadding})
          .backgroundColor(colors.pageBackgroundColor)
          .height(size.inputHeight)
          .onChange((value) => {
            this.text = value;
          })
        Button('发送', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(colors.lineBackgroundColor)
          .width(size.btnWidth)
          .enabled(Boolean(this.text))
          .height(size.inputHeight)
          .margin({ left: size.pagePadding })
          .onClick(() => {

          })
      } .border({
        width: { top: 1 },
        color: { top: colors.borderColor },
        style: { top: BorderStyle.Solid }
      }).padding(size.pagePadding).width('100%')
    }.width('100%').height('100%')
  }
}