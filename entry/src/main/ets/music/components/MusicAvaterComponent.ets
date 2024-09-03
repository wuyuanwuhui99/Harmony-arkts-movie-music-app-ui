import * as colors from '../../theme/color';
import { getMusicCover } from '../../utils/common';

@Component
export default struct MusicAvaterComponent {
  @Prop avater: string;
  @Prop title:string;
  @Prop type:string;
  @Prop dimension:number;

  build(){
    if(this.avater){
      Image(getMusicCover(this.avater))
        .width(this.dimension)
        .height(this.dimension)
        .borderRadius(this.dimension)
    }else if(this.type === 'music'){
      Image($r('app.media.default_cover'))
        .width(this.dimension)
        .height(this.dimension)
        .borderRadius(this.dimension)
    }else{
      Text(this.title)
        .textAlign(TextAlign.Center)
        .width(this.dimension)
        .height(this.dimension)
        .backgroundColor(colors.pageBackgroundColor)
        .borderRadius(this.dimension)
    }
  }
}

