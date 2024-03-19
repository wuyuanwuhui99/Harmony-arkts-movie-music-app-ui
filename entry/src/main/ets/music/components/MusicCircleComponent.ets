import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import {getCircleListByTypeService} from '../service';
import {MusicInterface,MusicSingerInterface,CircleInterface} from '../interface';
import {HOST} from '../../config/constant';

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
          Flex({ direction: FlexDirection.Row }){
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
                  .flexGrow(1)
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
            }.flexGrow(1).alignItems(HorizontalAlign.Start)
          }.blockStyle()
        })
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
