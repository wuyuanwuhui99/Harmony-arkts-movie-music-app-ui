import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import emitter from '@ohos.events.emitter'
import { MusicInterface,MusicStorageInterface } from '../interface';
import { getMusicListByClassifyIdService } from '../service/Index';
import { MUSIC_STORAGE } from '../../common/constant';
import { LIKE_INNER_EVENT } from '../../common/config';
import {usePlayerRouter, useAppStorage, getMusicCover} from '../../utils/common';
import router from '@ohos.router';

@Component
export default struct NavigatorTitleComponent {
  @Prop title: string;

  build() {
    Row(){
      Image($r('app.media.icon_back'))
        .width(size.smallIconSize)
        .height(size.smallIconSize)
        .opacity(size.opacity)
        .onClick(()=>{
          router.back()
        })
      Text(this.title)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      Image($r('app.media.icon_back'))
        .width(size.smallIconSize)
        .height(size.smallIconSize)
        .visibility(Visibility.Hidden)
    }
    .width('100%')
    .padding(size.pagePadding)
    .backgroundColor(colors.blockColor)
  }
}