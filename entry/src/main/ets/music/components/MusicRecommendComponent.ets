import { getMusicListByClassifyIdService } from '../service/Index';
import { MusicInterface, MusicStorageInterface } from '../interface';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { HOST, MUSIC_STORAGE } from '../../config/constant';
import { usePlayerRouter,useAppStorage } from '../../utils/common';

// LazyForEach列表栏加载，
// 参考文档：https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-rendering-control-lazyforeach-0000001524417213-V3
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: Array<MusicInterface> = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): MusicInterface {
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
  private dataArray: Array<MusicInterface> = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): MusicInterface {
    return this.dataArray[index];
  }

  public addData(index: number, data: MusicInterface): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: MusicInterface): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}


@Component
export default struct MusicRecommendComponent {
  @Styles blockStyle(){
    .backgroundColor(colors.blockColor)
    .borderRadius(size.blockBorderRaduis)
    .padding(size.pagePadding)
    .width('100%')
    .margin({ top: size.pagePadding })
  }

  @State musicList: MyDataSource = new MyDataSource();
  @State pageNum: number = 1;
  @State total: number = 0;
  @StorageLink(MUSIC_STORAGE) musicStorage: MusicStorageInterface = useAppStorage()
  private classifyId:number = 1;
  private pageSize: number = 20;
  private scroller: Scroller = new Scroller()

  aboutToAppear() {
    this.useMusicList()
  }

  /**
   * @description: 获取推荐的20条数据，1表示推荐的id
   * @date: 2024-03-05 22:40
   * @author wuwenqiang
   */
  useMusicList() {
    getMusicListByClassifyIdService(this.classifyId, this.pageNum, this.pageSize).then((res) => {
      this.total = res.total;
      res.data.forEach((item: MusicInterface) => {
        this.musicList.pushData(item);
      })
    })
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          LazyForEach(this.musicList, (item: MusicInterface, index: number) => {
            Row() {
              if (index === 0) {
                Image($r("app.media.icon_no1"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              } else if (index === 1) {
                Image($r("app.media.icon_no2"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              } else if (index === 2) {
                Image($r("app.media.icon_no3"))
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
              } else {
                Text(index + 1 + "")
                  .width(size.smallIconSize)
                  .height(size.smallIconSize)
                  .textAlign(TextAlign.Center)
              }
              Image(/http[s]?:\/\//.test(item.cover) ? item.cover.replace('{size}', '480') : HOST + item.cover)
                .width(size.middleAvaterSize)
                .height(size.middleAvaterSize)
                .borderRadius(size.middleAvaterSize)
                .margin({ left: size.pagePadding })
              Column() {
                Text(item.songName).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                Text(item.authorName)
                  .fontColor(colors.disableTextColor)
                  .margin({ top: size.smallPadding / 2 })
                  .maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
              }.layoutWeight(1).alignItems(HorizontalAlign.Start).margin({ left: size.pagePadding })

              Image($r("app.media.icon_music_play"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.pagePadding })
                .onClick(() => usePlayerRouter(this.musicStorage,item,this.classifyId,index))
              Image(item.isLike ? $r("app.media.icon_like_active") : $r("app.media.icon_like"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.pagePadding })
              Image($r("app.media.icon_music_menu"))
                .width(size.smallIconSize)
                .height(size.smallIconSize)
                .margin({ left: size.pagePadding })
            }.blockStyle().alignItems(VerticalAlign.Center)
          })
          Row() {
            Text(this.total <= this.pageSize * this.pageNum ? '已经到底了...' : '正在加载更多...')
          }.padding({ top: size.pagePadding, bottom: size.pagePadding })
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .backgroundColor(colors.pageBackgroundColor)
      .width("100%")
      .height("100%")

      .onScrollEdge((side: Edge) => {
        if (this.total > this.pageNum * this.pageSize) {
          this.pageNum++;
          this.useMusicList();
        }
      })
    }.width('100%')
    .height('100%')
    .backgroundColor(colors.pageBackgroundColor)
    .padding({ left: size.pagePadding, right: size.pagePadding, })

  }
}