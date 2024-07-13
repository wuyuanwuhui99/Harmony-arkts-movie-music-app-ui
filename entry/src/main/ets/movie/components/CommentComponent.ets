import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { getTopCommentListService, insertCommentService } from '../service/Index';
import { HOST } from '../../common/constant';
import { CommentInterface } from '../../music/interface/Index';
import { formatTime } from '../../utils/common';
import BottomDialogComponent from './BottomDialogComponent';
import CommentController from '../controller/CommentController';

// 传入buildCommentList方法必须是一个对象形式，否则无法实现响应式
interface CommentParamsInterface {
  commentList: Array<CommentInterface>
}

@Component
export default struct CommentComponent {
  @Prop relationId: number;
  @Prop commentListStr: string; // 评论数组字符串
  @Prop type: string;
  @State commentTotal: number = 0;
  @State commentList: Array<CommentInterface> = [];
  @State text: string = ''; // 评论框文字
  @State firstComment: CommentInterface = null;
  @State replyComment: CommentInterface = null;
  @State replyIndex: number = -1;
  @State focusableInput: boolean = false;
  private loading: boolean = false;
  private scroller: Scroller = new Scroller()
  private dialogController: CustomDialogController;
  public controller: CommentController = null;

  aboutToAppear() {
    if (this.controller) {
      this.controller.attach(this); //绑定控制器
    }
    /**
     * @author: wuwenqiang
     * @description: 获取评论列表
     * @date: 2024-05-25 21:36
     */
    if (this.commentListStr) {
      this.commentList = JSON.parse(this.commentListStr) as Array<CommentInterface>;
    } else {
      getTopCommentListService(this.relationId, this.type, 1, 20).then(res => {
        this.commentList = res.data;
        this.commentTotal = res.total;
      });
    }
  }

  /**
   * @author: wuwenqiang
   * @description: 打开评论框弹窗
   * @date: 2024-05-26 14:26
   */
  openInputDialog(): void {
    if (!this.dialogController) {
      this.dialogController = new CustomDialogController({
        customStyle: true,
        builder: BottomDialogComponent({
          dialogHeight: 'auto',
          builder: this.buildCommentInput.bind(this)
        }),
        alignment: DialogAlignment.Bottom,
      })
    }
    this.dialogController.open()
  }

  /**
   * @author: wuwenqiang
   * @description: 创建评论框
   * @date: 2024-05-26 14:26
   */
  @Builder buildCommentInput() {
    Column() {
      Row() {
        TextInput({
          text: this.text,
          placeholder: this.replyComment ? `回复${this.replyComment.username}` : (this.firstComment ? `回复${this.firstComment.username}` : '评论')
        }).defaultFocus(true)
          .layoutWeight(1)
          .focusable(this.focusableInput)
          .height(size.inputHeight)
          .onChange((value) => {
            this.text = value;
          })
          .onClick(() => {
            this.focusableInput = true
          })
        Button('发送', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(colors.lineBackgroundColor)
          .width(size.btnWidth)
          .enabled(Boolean(this.text))
          .height(size.inputHeight)
          .margin({ left: size.pagePadding })
          .onClick(() => {
            if (this.loading) return;
            this.loading = true;
            const commentItem: CommentInterface = {
              id: 0, //主键
              content: this.text, //评论内容
              parentId: this.replyComment?.id, //父节点id
              topId: this.firstComment?.id, //顶级节点id
              type: this.type, // 类型
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
            // 发送评论
            insertCommentService(commentItem).then((res) => {
              if (this.firstComment) { // 二级评论，相当于回复
                // 必须重新解构，然后再赋值，否则添加回复不生效
                const commentItem = { ...this.commentList[this.replyIndex] };
                commentItem.replyList === null && (commentItem.replyList = []);
                commentItem.replyList.push(res.data); // 添加回复列表
                this.commentList.splice(this.replyIndex, 1, commentItem); // 替换掉原数据里面的那一条数据
              } else { // 一级评论
                this.commentList.push(res.data);
              }
              // 重新赋值，改变对象的内存地址，否则添加回复不生效
              this.dialogController?.close();
              this.replyComment = this.firstComment = null;
              this.text = '';
              this.focusableInput = false;
            }).finally(() => {
              this.loading = false;
            });
          })
      }.backgroundColor(colors.blockColor).padding(size.pagePadding)
    }
    .width('100%')
  }

  /**
   * @author: wuwenqiang
   * @description: 点击弹出评论框
   * @date: 2024-05-26 14:26
   */
  useReply(item: CommentInterface, index: number) {
    if (this.commentListStr) {
      this.openInputDialog();
    }
    this.focusableInput = true;
    this.replyIndex = index;
    if (item.topId) {
      this.replyComment = item; // 二级评论，即回复的内容
      this.firstComment = this.commentList.find(aItem => aItem.id === item.topId)
    } else {
      this.replyComment = this.firstComment = item; // 点击的是一级评论
    }
  }

  /**
   * @author: wuwenqiang
   * @description: 创建评论列表,参数必须用对象或者接口形式传递，否则参数变化了，视图不更新
   * @date: 2024-05-25 16:30
   */
  @Builder buildCommentList(commentParams: CommentParamsInterface) {
    Column({ space: size.pagePadding }) {
      ForEach(commentParams.commentList, (aItem: CommentInterface, aIndex: number) => {
        Row() {
          Image(aItem.avater ? HOST + aItem.avater : $r('app.media.default_avater'))
            .width(aItem.topId ? size.smallAvaterSize : size.middleAvaterSize)
            .height(aItem.topId ? size.smallAvaterSize : size.middleAvaterSize)
            .borderRadius(aItem.topId ? size.smallAvaterSize : size.middleAvaterSize)
          Column() {
            Text(aItem.topId ? `${aItem.username}▶${aItem.replyUserName}` : aItem.username)
              .fontColor(colors.disableTextColor).margin({ bottom: size.miniPadding })
            Text(aItem.content).margin({ bottom: size.miniPadding })
            Text(formatTime(aItem.createTime)).fontColor(colors.disableTextColor)
            if (aItem.replyList?.length > 0) {
              Blank().height(size.pagePadding)
              // 参数必须用对象或者接口形式传递，否则参数变化了，视图不更新
              this.buildCommentList({ commentList: aItem.replyList })
            }
          }.layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
          .margin({ left: size.pagePadding })
          .onClick(this.useReply.bind(this, aItem, aIndex))
        }
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
        .width('100%')
      })
    }
  }

  build() {
    if(this.commentListStr){
      Column(){
        if(this.commentList.length > 0){
          Blank().height(size.pagePadding)
        }
        this.buildCommentList({ commentList: this.commentList })
      }
    }else{
      Column() {
        Text(`${this.commentTotal}条评论`)
          .padding(size.pagePadding)
          .textAlign(TextAlign.Center)
          .border({
            width: { bottom: 1 },
            color: { bottom: colors.borderColor },
            style: { bottom: BorderStyle.Solid }
          }).width('100%')

        Scroll(this.scroller) {
          if (this.commentList.length > 0) {
            // 必须用对象的方式传递，否则this.commentList发生变化之后，视图不会更新
            this.buildCommentList({ commentList: this.commentList })
          } else{
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

        if (!this.commentListStr) {
          Divider().height(1).color(colors.borderColor)
          this.buildCommentInput()
        }
      }.width('100%').height('100%')
    }
  }
}