import * as size from '../../theme/size';
import {UserDataInterface} from '../interface/Index'
import {HOST} from '../../config/constant';
import {USER_DATA} from '../../config/constant';

@Component
export default struct AvaterComponent{

  @StorageLink(USER_DATA) userData:UserDataInterface = null;
  @Prop dimensions:number;

  build(){
    Image(this.userData ? HOST + this.userData.avater : '')
      .height(this.dimensions)
      .width(size.middleavaterSize)
      .borderRadius(this.dimensions)
  }
}