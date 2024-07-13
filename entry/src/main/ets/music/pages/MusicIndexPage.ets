import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import MusicCircleComponent from '../components/MusicCircleComponent'
import MusicHomeComponent from '../components/MusicHomeComponent'
import MusicMyComponent from '../components/MusicMyComponent'
import MusicRecommendComponent from '../components/MusicRecommendComponent'
import {MUSIC_STORAGE,HOST} from '../../common/constant'
import { MusicStorageInterface } from '../interface/Index';
import router from '@ohos.router';
import { useAppStorage } from '../../utils/common';
@Entry
@Component
struct MusicIndexPage {
  @State activeIndex: number = 0;
  @State isInitPage: Array<boolean> = [true, false, false, false,false];
  @StorageLink(MUSIC_STORAGE) musicStorage:  MusicStorageInterface = useAppStorage()
  @State angle:number = 0;

  onPageShow(){
    // 先销毁播放界面的监听事件,不能在播放页面销毁
    // 因为页面返回时，先执行了当前页面的onPageShow方法，再执行播放页面的aboutToDisappear方法
    // 如果在播放页面的aboutToDisappear方法中销毁监听事件，会导致当前页面的绑定的事件不生效
    this.musicStorage.audio?.off('durationUpdate');
    this.musicStorage.audio?.off('timeUpdate');

    // 重新绑定监听事件
    this.musicStorage.audio?.on('timeUpdate',()=>{
      this.angle += 5;
      if(this.angle === 360)this.angle = 0;
    });
  }

  build() {
    Stack() {
      Tabs({
        index: this.activeIndex,
        barPosition: BarPosition.End
      }) {
        TabContent() {
          MusicHomeComponent()
        }
        .tabBar(this.tabBuilder(0, '首页', $r('app.media.icon_home_active'), $r('app.media.icon_home')))

        TabContent() {
          if (this.isInitPage[1]) {
            MusicRecommendComponent()
          } else {
            Column()
          }
        }
        .tabBar(this.tabBuilder(1, '推荐', $r('app.media.icon_recomment_active'), $r('app.media.icon_recomment')))

        TabContent() {}
        .tabBar(this.placehostBuilder())


        TabContent() {
          if (this.isInitPage[3]) {
            MusicCircleComponent()
          } else {
            Column()
          }
        }
        .tabBar(this.tabBuilder(3, '音乐圈', $r('app.media.icon_music_circle_active'), $r('app.media.icon_music_circle')))

        TabContent() {
          if (this.isInitPage[4]) {
            MusicMyComponent()
          } else {
            Column()
          }
        }
        .tabBar(this.tabBuilder(4, '我的', $r('app.media.icon_user_active'), $r('app.media.icon_user')))
      }
      .barHeight(size.barHeight)
      .barMode(BarMode.Fixed)
      .onChange((index) => {
        this.isInitPage[index] = true;
        this.activeIndex = index
      })

      // 用图片组件代作为导航栏中间凸起组件
      Image(this.musicStorage?.musicItem ? HOST + this.musicStorage.musicItem.cover: $r('app.media.icon_song_default'))
        .margin({bottom:size.barHeight - size.bigAvaterSize/2 - size.miniPadding})
        .height(size.bigAvaterSize + size.miniPadding * 2)
        .height(size.bigAvaterSize + size.miniPadding * 2)
        .alignSelf(ItemAlign.Center)// 设置悬浮图标居中对齐
        .borderRadius(size.bigAvaterSize + size.miniPadding * 2)
        .backgroundColor(colors.blockColor)
        .rotate({ angle: this.angle })
        .border({
          width: size.miniPadding,
          color: colors.pageBackgroundColor,
          style: BorderStyle.Solid
        })
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)// 设置Tab组件和凸起悬浮按钮底部对齐
    .onClick(() => this.musicStorage.musicItem && router.pushUrl({url: 'music/pages/MusicPlayerPage'}));
  }

  /**
   * @description: 底部导航栏切换
   * @date: 2024-05-30 22:47
   * @author wuwenqiang
   */
  @Builder tabBuilder(index: number, title: string, selectedImage: Resource, normalImage: Resource) {
    Column() {
      Image(this.activeIndex == index ? selectedImage : normalImage)
        .width(size.middlIconSize)
        .height(size.middlIconSize)
        .margin({ top: size.smallPadding, bottom: size.smallPadding })
      Text(title)
        .fontColor(this.activeIndex == index ? colors.tabSelectedColor : colors.tabNormalColor)
        .fontSize(size.normalFontSize)
        .padding({ bottom: size.pagePadding })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * @description: 底部导航栏中间占位符，不做任何操作
   * @date: 2024-05-30 22:47
   * @author wuwenqiang
   */
  @Builder placehostBuilder(){
    Row()
  }
}