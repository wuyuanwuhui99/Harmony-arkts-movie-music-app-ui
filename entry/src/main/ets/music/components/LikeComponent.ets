import { LikeInterface } from '../interface/Index';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import LikeController from '../controller/LikeController';
import { USER_DATA } from '../../common/constant';
import { SocialEnum } from '../../common/enum';
import { UserDataInterface } from '../../movie/interface';
import { deleteLikeService, saveLikeService } from '../service/Index';

@Component
export default struct LikeComponent {
  @Prop likeList: string;
  @Prop relationId:number;

  @StorageLink(USER_DATA) userData: UserDataInterface = null;

  @State mLikeList: Array<LikeInterface> = []

  public controller: LikeController = null;

  private loading:boolean = false;

  aboutToAppear(){
    if (this.controller) {
      this.controller.attach(this); //绑定控制器
    }
    this.mLikeList = JSON.parse(this.likeList) as Array<LikeInterface>;
  }

  /**
   * @description: 获取点赞是否点过赞，-1为没有点过赞
   * @date: 2024-03-12 22:09
   * @author wuwenqiang
   */
  getLikeIndex():number{
    return this.mLikeList.findIndex((item:LikeInterface) => item.userId === this.userData.userId);
  }

  useLike():void{
    if(this.loading)return;
    this.loading = false;
    const index = this.getLikeIndex();
    if(index !== -1){
       deleteLikeService(this.relationId,SocialEnum.MUSIC).then(()=>{
         this.mLikeList.splice(index,1);
       }).finally(()=>{
         this.loading = false;
       });
    }else{
      const likeItem = {
        id: -1,
        relationId:this.relationId,
        type:SocialEnum.MUSIC,
      } as LikeInterface;
      saveLikeService(likeItem).then((res)=>{
        this.mLikeList.push(res.data);
      }).finally(()=>{
        this.loading = false;
      });;
    }
  }

  build(){
    Flex({ direction: FlexDirection.Row, wrap: FlexWrap.Wrap }) {
      Image($r('app.media.icon_music_like'))
        .width(size.smallIconSize)
        .height(size.smallIconSize)
        .margin({ top: size.smallPadding, right: size.smallPadding })
      ForEach(this.mLikeList, (cItem: LikeInterface, index: number) => {
        Text(`${cItem.username}${index === this.mLikeList.length - 1 ? '' : '、'}`)
          .margin({ left: size.smallPadding })
          .fontColor(colors.blueColor)
          .margin({ top: size.smallPadding })
      })
    }
  }
}

