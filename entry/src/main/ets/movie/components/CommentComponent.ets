import TitleComponent from './TitleComponent';
import * as colors from '../../theme/color';
import * as size from '../../theme/size';
import { ClassifyInterface,MovieInterface } from '../interface/Index';
import {insertCommentService,getTopCommentListService} from '../service';
import MovieListComponent from './MovieListComponent';
import { HOST, SocialEnum } from '../../config/constant';
import { CommentInterface } from '../../music/interface/Index';
import { formatTime } from '../../utils/common';

@Component
export default struct CommentComponent{
  @Prop relationId:number;
  @Prop type:string;
  @State commentTotal:number = 0;
  @State commentList:Array<CommentInterface> = [];
  private scroller: Scroller = new Scroller()
  aboutToAppear(){

    /**
     * @author: wuwenqiang
     * @description: 获取评论列表
     * @date: 2024-05-25 21:36
     */
    getTopCommentListService(this.relationId,this.type,1,20).then(res => {
      this.commentList = res.data;
      this.commentTotal = res.total;
    });
  }

  build(){
    Column(){
      Text(`${this.commentTotal}条评论`).padding(size.pagePadding)
      Scroll(this.scroller) {
        Column(){
          ForEach(this.commentList,(item:CommentInterface) => {
            Row(){
              Image(item.avater ? HOST + item.avater : $r('app.media.default_avater'))
                .width(size.middleAvaterSize)
                .height(size.middleAvaterSize)
              Column(){
                Text(item.username)
                Text(item.content)
                Text(formatTime(item.createTime))
              }
            }
          })
        }
      }.flexGrow(1)
    }
  }
}