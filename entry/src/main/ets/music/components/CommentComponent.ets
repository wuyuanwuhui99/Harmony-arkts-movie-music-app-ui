import { HOST } from '../../config/constant';
import { CommentInterface } from '../interface/Index';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { formatTime } from '../../utils/common';
import { insertCommentService } from '../service/Index';
import CommentInputComponent from './CommentInputComponent';
import CommentController from '../controller/CommentController';

@Component
export default struct CommentComponent {
  @Prop commentList:string;
  @Prop relationId:number;
  private loading:boolean = false;
  @State firstComment:CommentInterface = null;
  @State replyComment:CommentInterface = null;
  @State replyIndex:number = -1;
  public controller: CommentController = null;
  @State mCommentList: Array<CommentInterface> = [];
  aboutToAppear(){
    this.mCommentList = JSON.parse(this.commentList) as  Array<CommentInterface>
    if (this.controller) {
      this.controller.attach(this); //绑定控制器
    }
  }

  openInputDialog(){
    this.dialogController.open();
    this.firstComment = null;
  }

  // 评论框的弹窗
  dialogController: CustomDialogController = new CustomDialogController({
    customStyle: true,
    builder: CommentInputComponent({
      placeholder: `评论${this.firstComment?.username || ''}`,
      onSend: (text: string) => {
        if (this.loading) return;
        this.loading = true;
        const commentItem: CommentInterface = {
          id: 0, //主键
          content: text, //评论内容
          parentId: 0, //父节点id
          topId: 0, //顶级节点id
          type: "music_circle", // 类型
          relationId: this.relationId, //影片id
          createTime: "", //创建时间
          updateTime: "", //更新时间
          replyCount: 0, //回复数量
          userId: "", //用户id
          username: "", //用户名
          avater: "", //用户头像
          replyUserId: "", //被回复者id
          replyUserName: "", //被回复者名称
          showCommentCount: "", //显示的回复数量
          replyPageNum: 0,
          replyList: []
        }
        if (this.firstComment) { // 获取一级评论的id
          commentItem.topId = this.firstComment.id;
        }
        if (this.replyComment) { // 获取回复的id
          commentItem.parentId = this.replyComment.id;
        }
        // 发送评论
        insertCommentService(commentItem).then((res) => {
          if (this.firstComment) { // 二级评论，相当于回复
            this.mCommentList[this.replyIndex].replyList.push(res.data);
          } else { // 一级评论
            this.mCommentList.push(res.data);
          }
          this.dialogController.close();
          this.replyComment = this.firstComment = null;
        }).finally(() => {
          this.loading = false;
        });
      }
    }),
    alignment: DialogAlignment.Bottom,
  })

  build(){
    Column(){
      ForEach(this.mCommentList, (aItem: CommentInterface, aIndex: number) => {
        Row() {
          Image(aItem.avater ? HOST + aItem.avater : $r('app.media.default_avater'))
            .width(size.middleAvaterSize)
            .height(size.middleAvaterSize)
            .margin({ right: size.pagePadding })
            .borderRadius(size.middleAvaterSize)
          Column({ space: size.smallPadding }) {
            Text(aItem.username)
              .fontColor(colors.disableTextColor)
            Text(aItem.content).onClick(() => {
              this.replyComment = this.firstComment = aItem; // 回复评论
              this.dialogController.open()
            })
            Text(formatTime(aItem.createTime))
              .fontColor(colors.disableTextColor)
            ForEach(aItem.replyList, (bItem: CommentInterface) => {
              Row() {
                Image(bItem.avater ? HOST + bItem.avater : $r('app.media.default_avater'))
                  .width(size.smallAvaterSize)
                  .height(size.smallAvaterSize)
                  .margin({ right: size.pagePadding })
                  .borderRadius(size.smallAvaterSize)
                Column({ space: size.smallPadding }) {
                  Text(`${bItem.username}▶${bItem.replyUserName}`)
                    .fontColor(colors.disableTextColor)
                  Text(bItem.content).onClick(() => {
                    this.replyIndex = aIndex;
                    this.firstComment = aItem; // 一级评论
                    this.replyComment = bItem; // 回复评论
                    this.dialogController.open();
                  })
                  Text(formatTime(bItem.createTime))
                    .fontColor(colors.disableTextColor)
                }.alignItems(HorizontalAlign.Start).layoutWeight(1)
              }.width('100%').alignItems(VerticalAlign.Top)
            })
          }.layoutWeight(1).alignItems(HorizontalAlign.Start)
        }
        .alignItems(VerticalAlign.Top)
        .width('100%')
        .margin({ top: size.pagePadding })
      })
    }
  }
}

