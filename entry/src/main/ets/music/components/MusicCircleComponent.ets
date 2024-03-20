import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {getCircleListByTypeService} from '../service';
import {CircleInterface,CommentInterface} from '../interface';
import {HOST} from '../../config/constant';
import {formatTime} from '../../utils/common';

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
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
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
export default struct MusicCircleComponent{

  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({top:size.pagePadding})
  }

  scroller: Scroller = new Scroller()
  @State circleList:MyDataSource = new MyDataSource();
  @State total:number = 0;
  @State pageNum:number = 1;
  pageSize:number = 5;

  aboutToAppear(){
    this.useCircleList();
  }

  /**
   * @description: 获取朋友圈动态数据
   * @date: 2024-03-12 22:09
   * @author wuwenqiang
   */
  useCircleList(){
    getCircleListByTypeService("music", this.pageNum, this.pageSize).then((res) => {
      res.data.forEach((item:CircleInterface)=>{
        this.circleList.pushData(item);
      })
      this.total = res.total;
    })
  }

  build(){
    Scroll(this.scroller) {
      Column(){
        LazyForEach(this.circleList,(item:CircleInterface,index:number)=>{
          Row(){
            Image(item.useravater ? HOST + item.useravater : $r("app.media.default_avater"))
              .width(size.middleAvaterSize)
              .height(size.middleAvaterSize)
              .borderRadius(size.middleAvaterSize)
              .margin({right:size.pagePadding})
            Column(){
              Text(item.username)
                .fontColor(colors.blueColor)
                .fontWeight(FontWeight.Bold)
                .margin({bottom:size.smallPadding})
              Text(item.content)
              Row(){
                Image(HOST + item.musicCover)
                  .width(size.middleAvaterSize)
                  .height(size.middleAvaterSize)
                  .borderRadius(size.middleAvaterSize)
                Text(`${item.musicSongName} - ${item.musicAuthorName}`)
                  .layoutWeight(1)
                  .margin({left:size.pagePadding})
                Image($r('app.media.icon_music_play'))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .margin({right:size.pagePadding})
              }
              .width('100%')
              .margin({top:size.pagePadding})
              .height(size.middleAvaterSize)
              .borderRadius(size.middleAvaterSize)
              .backgroundColor(colors.pageBackgroundColor)

              Row(){
                Text(formatTime(item.createTime)).fontColor(colors.disableTextColor)
                Blank()
                Image($r('app.media.icon_music_menu'))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              }.width('100%').margin({top:size.pagePadding})
              if(item.circleLikes.length > 0 || item.circleComments.length > 0){
                Column(){
                  if(item.circleLikes.length > 0){
                    Flex({ direction: FlexDirection.Row,wrap: FlexWrap.Wrap}){
                      Image($r('app.media.icon_music_like'))
                        .width(size.smallIconSize)
                        .height(size.smallIconSize)
                        .margin({top:size.smallPadding,right:size.smallPadding})
                      ForEach(item.circleLikes,(cItem:CircleInterface,index:number)=>{
                        Text(`${cItem.username}${index === item.circleLikes.length - 1 ? '' : '、'}`)
                          .margin({left:size.smallPadding})
                          .fontColor(colors.blueColor)
                          .margin({top:size.smallPadding})
                      })
                    }
                  }
                  if(item.circleComments.length > 0){
                    ForEach(item.circleComments.filter((fItem:CommentInterface)=>!fItem.parentId),(bItem:CommentInterface)=>{
                      Row(){
                        Image(bItem.avater ? HOST + bItem.avater : $r('app.media.default_avater'))
                          .width(size.middleAvaterSize)
                          .height(size.middleAvaterSize)
                          .margin({right:size.pagePadding})
                          .borderRadius(size.middleAvaterSize)
                        Column(){
                          Text(bItem.username)
                            .fontColor(colors.disableTextColor)
                            .padding({bottom:size.smallPadding})
                          Text(bItem.content).margin({bottom:size.smallPadding})
                          Text(formatTime(bItem.createTime))
                            .fontColor(colors.disableTextColor)
                            .padding({bottom:size.pagePadding})
                          ForEach(item.circleComments.filter((fItem:CommentInterface)=>fItem.topId && fItem.topId === bItem.id),(cItem:CommentInterface)=>{
                            Row(){
                              Image(cItem.avater ? HOST + cItem.avater : $r('app.media.default_avater'))
                                .width(size.smallAvaterSize)
                                .height(size.smallAvaterSize)
                                .margin({right:size.pagePadding})
                                .borderRadius(size.smallAvaterSize)
                              Column(){
                                Text(`${cItem.username}▶${cItem.replyUserName}`)
                                  .fontColor(colors.disableTextColor)
                                  .padding({bottom:size.smallPadding})
                                Text(cItem.content)
                                  .padding({bottom:size.smallPadding})
                                Text(formatTime(cItem.createTime))
                                  .fontColor(colors.disableTextColor)
                                  .padding({bottom:size.smallPadding})
                              }.alignItems(HorizontalAlign.Start).layoutWeight(1)
                            }.width('100%').alignItems(VerticalAlign.Top)
                          })
                        }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                      }
                      .alignItems(VerticalAlign.Top)
                      .width('100%')
                      .margin({top:size.pagePadding})
                    })
                  }
                }.backgroundColor(colors.pageBackgroundColor)
                .margin({top:size.pagePadding})
                .alignItems(HorizontalAlign.Start)
                .padding({left:size.pagePadding,right:size.pagePadding})
                .borderRadius(size.blockBorderRaduis)
              }
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
          }.alignItems(VerticalAlign.Top).blockStyle()
        })
        Text('——已经到底了——').fontColor(colors.disableTextColor).padding(size.pagePadding)
      }.justifyContent(FlexAlign.Start)
    }.scrollable(ScrollDirection.Vertical)
    .width("100%")
    .height("100%").align(Alignment.Top)
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding,})
    .onScrollEdge((side: Edge) => {
      if (this.total > this.pageNum * this.pageSize) {
        this.pageNum++;
        this.useCircleList();
      }
    })
  }
}
