import httpRequest from '../../utils/HttpUtil';
import deviceInfo from '@ohos.deviceInfo'; //设备信息
// import { deviceInfo } from '@kit.BasicServicesKit';
import { DeviceInterface, UserDataInterface } from '../interface/Index'
import preference from '../../utils/PreferenceModel';
import { DEVICE_INFO, USER_DATA } from '../../common/constant';
import { getUserDataService } from '../service/Index';
import router from '@ohos.router';

@Entry
@Component
struct LaunchPage {
  @State activeIndex: number = 0;
  @State isInitPage: Array<boolean> = [true, false, false, false];
  @State isInitIndex: boolean = false;

  build() {
    Column() {
      Text('欢迎使用')
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .height('100%')
  }

  async aboutToAppear() {
    const {marketName,productModel,sdkApiVersion} = deviceInfo
    AppStorage.SetOrCreate<DeviceInterface>(DEVICE_INFO, {device:productModel,platform:marketName,version:sdkApiVersion.toString()})
    const token: string = <string> await preference.getToken();
    setTimeout(()=>{// 加载用户信息
      if(token){
        getUserDataService(token).then((res) => {
          preference.setToke(res.token);
          httpRequest.setToken(res.token);
          AppStorage.SetOrCreate<UserDataInterface>(USER_DATA, res.data)
          router.replaceUrl({
            url: 'movie/pages/IndexPage'
          });
        }).catch(()=>{
          router.replaceUrl({
            url: 'movie/pages/MovieLoginPage'
          });
        })
      }else{
        router.replaceUrl({
          url: 'movie/pages/MovieLoginPage'
        });
      }

    },1000)

  }
}