import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { getCircleListByTypeService } from '../service/Index';
import { CircleInterface, CommentInterface } from '../interface';
import { UserDataInterface } from '../../movie/interface';
import { HOST, USER_DATA } from '../../common/constant';
import { SocialEnum } from '../../common/enum';
import { formatTime } from '../../utils/common';
import CommentComponent from '../../movie/components/CommentComponent';
import CommentController from '../../movie/controller/CommentController';
import LikeComponent from './LikeComponent';
import LikeController from '../controller/LikeController';

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


  @State circleList: MyDataSource = new MyDataSource();
  @State total: number = 0;
  @State pageNum: number = 1;
  @State customPopup: boolean = false;
  @State handlePopup: boolean = false;
  @State circleIndex: number = -1; // 当前点击的评论和点赞弹出框的下标
  @State circleId: number = 0; // 当前点赞或评论的朋友圈id
  @State likeIndex: number = -1; // 是否已经点赞,-1表示未点赞
  @StorageLink(USER_DATA) userData: UserDataInterface = null;
  @State firstComment: CommentInterface = null; // 一级评论
  @State replyComment: CommentInterface = null; // 回复的评论

  private commentController: Array<CommentController> = [];
  private likeController: Array<LikeController> = [];

  private pageSize: number = 5;
  private scroller: Scroller = new Scroller()

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
        this.commentController.push(new CommentController())
        this.likeController.push(new LikeController())
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
        this.likeController[this.circleIndex].useLike()
        this.circleId = this.likeIndex = -1;
      }).width('50%').justifyContent(FlexAlign.Center)

      Row({ space: size.smallPadding }) {
        Image($r('app.media.icon_comment_white'))
          .width(size.smallIconSize)
          .height(size.smallIconSize)
        Text('评论').fontColor(colors.blockColor).onClick(() => {
          this.circleId = -1;
          this.commentController[this.circleIndex].openInputDialog()
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
                    this.circleIndex = index;
                    this.likeIndex = this.likeController[index].getLikeIndex();
                  })
                  .bindPopup(this.circleId === item.id, {
                    builder: this.popupBuilder, // 气泡的内容
                    placement: Placement.Left, // 气泡的弹出位置
                    popupColor: colors.disableTextColor // 气泡的背景色
                  })
              }.width('100%')

              Column() {
                LikeComponent({controller:this.likeController[index],relationId:item.id,likeList:JSON.stringify(item.circleLikes)})
                CommentComponent({controller:this.commentController[index],type:SocialEnum.MUSIC_CIRCLE.toString(),relationId:item.id,commentListStr:JSON.stringify(item.circleComments)})
                Blank().height(size.pagePadding)
              }.backgroundColor(colors.pageBackgroundColor)
              .alignItems(HorizontalAlign.Start)
              .padding({ left: size.pagePadding, right: size.pagePadding })
              .borderRadius(size.blockBorderRaduis)
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

