import router from '@ohos.router';
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
      .width(this.dimensions)
      .borderRadius(this.dimensions).onClick(()=>{
        router.pushUrl({
          url: 'movie/pages/MovieUserPage', // 目标url
        }, router.RouterMode.Standard, (err) => {
          if(err){
            console.error(`Invoke showAlertBeforeBackPage failed, code is ${err.code}, message is ${err.message}`);
          }
        });
    })
  }
}