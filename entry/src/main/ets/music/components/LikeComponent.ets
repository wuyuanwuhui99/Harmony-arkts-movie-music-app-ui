import { LikeInterface } from '../interface/Index';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';

@Component
export default struct LikeComponent {
  @Prop likeList: string;
  @Prop circleId:number;

  @State mLikeList: Array<LikeInterface> = []
  aboutToAppear(){
    this.mLikeList = JSON.parse(this.likeList) as Array<LikeInterface>;
  }
  build(){
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
      Image($r('app.media.icon_music_like'))
        .width(size.smallIconSize)
        .height(size.smallIconSize)
        .margin({ top: size.smallPadding, right: size.smallPadding })
      ForEach(this.mLikeList, (cItem: LikeInterface, index: number) => {
        Text(`${cItem.username}${index === this.likeList.length - 1 ? '' : '、'}`)
          .margin({ left: size.smallPadding })
          .fontColor(colors.blueColor)
          .margin({ top: size.smallPadding })
      })
    }
  }
}

