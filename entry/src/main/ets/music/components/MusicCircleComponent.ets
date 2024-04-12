import promptAction from '@ohos.promptAction'
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { getCircleListByTypeService, saveLikeService, deleteLikeService, insertCommentService } from '../service';
import { CircleInterface, CommentInterface } from '../interface';
import { UserDataInterface } from '../../movie/interface';
import { HOST, USER_DATA } from '../../config/constant';
import { formatTime } from '../../utils/common';
import { LikeInterface } from '../interface/Index';

// LazyForEach列表栏加载，
// 参考文档：https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-rendering-control-lazyforeach-0000001524417213-V3
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: Array<CircleInterface> = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): CircleInterface {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }
}

@Observed
class MyDataSource extends BasicDataSource {
  private dataArray: Array<CircleInterface> = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): CircleInterface {
    return this.dataArray[index];
  }

  public addData(index: number, data: CircleInterface): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: CircleInterface): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}

@Component
export default struct MusicCircleComponent {
  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  scroller: Scroller = new Scroller()
  @State circleList: MyDataSource = new MyDataSource();
  @State total: number = 0;
  @State pageNum: number = 1;
  @State customPopup: boolean = false;
  @State handlePopup: boolean = false;
  @State index: number = -1; // 当前点击的评论和点赞弹出框的下标
  @State circleId: number = 0; // 当前点赞或评论的朋友圈id
  @State likeIndex: number = -1; // 是否已经点赞,-1表示未点赞
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  @State firstComment: CommentInterface = null; // 一级评论
  @State replyComment: CommentInterface = null; // 回复的评论

  replyIndex: number = -1; // 回复的下标
  pageSize: number = 5;
  loading: boolean = false;

  // 评论框的弹窗
  dialogController: CustomDialogController = new CustomDialogController({
    customStyle: true,
    builder: InputComponent({
      placeholder: this.replyComment ? `回复：${this.replyComment.username}` : (this.firstComment ? `评论${this.firstComment.username}` : '评论'),
      onSend: (text: string) => {
        if (this.loading) return;
        this.loading = true;
        const commentItem: CommentInterface = {
          id: 0, //主键
          content: text, //评论内容
          parentId: 0, //父节点id
          topId: 0, //顶级节点id
          type: "music_circle", // 类型
          relationId: 0, //影片id
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
        commentItem.relationId = this.circleList.getData(this.index).id;
        if (this.firstComment) { // 获取一级评论的id
          commentItem.topId = this.firstComment.id;
        }
        if (this.replyComment) { // 获取回复的id
          commentItem.parentId = this.replyComment.id;
        }
        // 发送评论
        insertCommentService(commentItem).then((res) => {
          const {circleComments} = this.circleList.getData(this.index);
          if (this.firstComment) { // 二级评论，相当于回复
            circleComments[this.replyIndex].replyList.push(res.data);
          } else { // 一级评论
            circleComments.push(res.data);
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

  aboutToAppear() {
    this.useCircleList();
  }

  /**
   * @description: 获取朋友圈动态数据
   * @date: 2024-03-12 22:09
   * @author wuwenqiang
   */
  useCircleList() {
    getCircleListByTypeService("music", this.pageNum, this.pageSize).then((res) => {
      res.data.forEach((item: CircleInterface) => {
        this.circleList.pushData(item);
      })
      this.total = res.total;
    })
  }

  // popup构造器定义弹框内容
  @Builder popupBuilder() {
    Row() {
      Row({ space: size.smallPadding }) {
        Image($r('app.media.icon_like_white'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
        Text(
            this.likeIndex !== -1 ? '取消赞' : '赞')
          .fontColor(colors.blockColor)
      }.onClick(() => {
        if (this.likeIndex !== -1) {
          deleteLikeService(this.circleList.getData(this.index).id, 'music_circle').then((res) => {
            if (res.data > 0) {
              this.circleList.getData(this.index).circleLikes.splice(this.likeIndex, 1)
            }
          });
        } else {
          const likeItem: LikeInterface = {
            type: "music_circle",
            relationId: this.circleList.getData(this.index).id
          }
          saveLikeService(likeItem).then((res) => {
            this.circleList.getData(this.index).circleLikes.push(res.data);
          })
        }
        this.circleId = -1;
      }).width('50%').justifyContent(FlexAlign.Center)

      Row({ space: size.smallPadding }) {
        Image($r('app.media.icon_comment_white'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
        Text('评论').fontColor(colors.blockColor).onClick(() => {
          this.circleId = -1;
          this.dialogController.open()
        })
      }.onClick(() => {
        this.circleId = -1;
      }).width('50%').justifyContent(FlexAlign.Center)
    }
    .width(size.popupMenuWidth)
    .height(size.popupMenuHeight)
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        LazyForEach(this.circleList, (item: CircleInterface, index: number) => {
          Row() {
            Image(item.useravater ? HOST + item.useravater : $r("app.media.default_avater"))
              .width(size.middleAvaterSize)
              .height(size.middleAvaterSize)
              .borderRadius(size.middleAvaterSize)
              .margin({ right: size.pagePadding })
            Column({ space: size.smallPadding }) {
              Text(item.username)
                .fontColor(colors.blueColor)
                .fontWeight(FontWeight.Bold)
              Text(item.content)
              Row() {
                Image(HOST + item.musicCover)
                  .width(size.middleAvaterSize)
                  .height(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                Text(`${item.musicSongName} - ${item.musicAuthorName}`)
                  .layoutWeight(1)
                  .margin({ left: size.pagePadding })
                Image($r('app.media.icon_music_play'))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({ right: size.pagePadding })
              }
              .width('100%')
              .height(size.middleAvaterSize)
              .borderRadius(size.middleAvaterSize)
              .backgroundColor(colors.pageBackgroundColor)

              Row() {
                Text(formatTime(item.createTime))
                  .layoutWeight(1)
                  .fontColor(colors.disableTextColor)
                Image($r('app.media.icon_music_menu'))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .onClick(() => {
                    this.circleId = item.id;
                    this.index = index;
                    this.likeIndex = this.circleList.getData(index)
                      .circleLikes
                      .findIndex((item: LikeInterface) => item.userId === this.userData.userId);
                  })
                  .bindPopup(this.circleId === item.id, {
                    builder: this.popupBuilder, // 气泡的内容
                    placement: Placement.Left, // 气泡的弹出位置
                    popupColor: colors.disableTextColor // 气泡的背景色
                  })
              }.width('100%')

              if (item.circleLikes.length > 0 || item.circleComments.length > 0) {
                Column() {
                  if (item.circleLikes.length > 0) {
                    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
                      Image($r('app.media.icon_music_like'))
                        .width(size.smallIconSize)
                        .height(size.smallIconSize)
                        .margin({ top: size.smallPadding, right: size.smallPadding })
                      ForEach(item.circleLikes, (cItem: CircleInterface, index: number) => {
                        Text(`${cItem.username}${index === item.circleLikes.length - 1 ? '' : '、'}`)
                          .margin({ left: size.smallPadding })
                          .fontColor(colors.blueColor)
                          .margin({ top: size.smallPadding })
                      })
                    }
                  }
                  if (item.circleComments.length > 0) {
                    ForEach(item.circleComments, (bItem: CommentInterface, cIndex: number) => {
                      Row() {
                        Image(bItem.avater ? HOST + bItem.avater : $r('app.media.default_avater'))
                          .width(size.middleAvaterSize)
                          .height(size.middleAvaterSize)
                          .margin({ right: size.pagePadding })
                          .borderRadius(size.middleAvaterSize)
                        Column({ space: size.smallPadding }) {
                          Text(bItem.username)
                            .fontColor(colors.disableTextColor)
                          Text(bItem.content).onClick(() => {
                            this.index = index;
                            this.replyComment = this.firstComment = bItem; // 回复评论
                            this.dialogController.open()
                          })
                          Text(formatTime(bItem.createTime))
                            .fontColor(colors.disableTextColor)
                          ForEach(bItem.replyList, (cItem: CommentInterface) => {
                            Row() {
                              Image(cItem.avater ? HOST + cItem.avater : $r('app.media.default_avater'))
                                .width(size.smallAvaterSize)
                                .height(size.smallAvaterSize)
                                .margin({ right: size.pagePadding })
                                .borderRadius(size.smallAvaterSize)
                              Column({ space: size.smallPadding }) {
                                Text(`${cItem.username}▶${cItem.replyUserName}`)
                                  .fontColor(colors.disableTextColor)
                                Text(cItem.content).onClick(() => {
                                  this.index = index;
                                  this.replyIndex = index;
                                  this.firstComment = bItem; // 一级评论
                                  this.replyComment = cItem; // 回复评论
                                  this.dialogController.open()
                                })
                                Text(formatTime(cItem.createTime))
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
                  Blank().height(size.pagePadding)
                }.backgroundColor(colors.pageBackgroundColor)
                .alignItems(HorizontalAlign.Start)
                .padding({ left: size.pagePadding, right: size.pagePadding })
                .borderRadius(size.blockBorderRaduis)
              }
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          }.alignItems(VerticalAlign.Top).blockStyle()
        })
        Text('——已经到底了——').fontColor(colors.disableTextColor).padding(size.pagePadding)
      }.justifyContent(FlexAlign.Start)
    }
    .scrollable(ScrollDirection.Vertical)
    .width("100%")
    .height("100%")
    .align(Alignment.Top)
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding, })
    .onScrollEdge((side: Edge) => {
      if (this.total > this.pageNum * this.pageSize) {
        this.pageNum++;
        this.useCircleList();
      }
    })
  }
}

@CustomDialog
struct InputComponent {
  @State text: string = '';
  placeholder: string = '评论';
  onSend: (value: string) => void
  controller: CustomDialogController;

  build() {
    Column() {
      Blank().layoutWeight(1).onClick(() => {
        this.controller.close()
      })
      Row() {
        TextInput({ placeholder: this.placeholder, })
          .layoutWeight(1)
          .height(size.inputHeight)
          .onChange((value) => {
            this.text = value;
          })
        Button('发送', { type: ButtonType.Capsule, stateEffect: true })
          .backgroundColor(this.text ? colors.lineBackgroundColor : colors.disableTextColor)
          .width(size.btnWidth)
          .height(size.inputHeight)
          .margin({ left: size.pagePadding })
          .onClick(() => {
            if (!this.text.trim()) {
              promptAction.showToast({
                message: '评论或回复内容不能为空',
                duration: 2000,
                bottom: '50%'
              });
              return
            }
            this.onSend(this.text);
          })
      }.backgroundColor(colors.blockColor).padding(size.pagePadding)
    }
    .height('100%')
    .width('100%')
  }
}
