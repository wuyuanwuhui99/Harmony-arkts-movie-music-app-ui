export interface MyAwesomeData<T> {
  data: T;
  token: string;
  status:string;
  msg:string;
  total:number
}

export interface DeviceInterface{
  version:string,
  platform:string,
  device:string
}

export interface UserDataInterface {
  userId:     string;
  createDate?: string;
  updateDate?: string;
  username:   string;
  telephone:  string;
  email:      string;
  avater:     string;
  birthday:   string;
  sex:        string;
  role:       string;
  password:   string;
  sign:       string;
  region:     string;
  disabled?:   number;
  permission?: number;
}

export interface MovieInterface {
  description:string;
  classify: string;
  isRecommend: string;
  img: string;
  targetHref: string;
  updateTime: number;
  useStatus: string;
  sourceUrl: string;
  score: number;
  localImg: string;
  ranks: string;
  createTime: number;
  id: number;
  sourceName: string;
  category: string;
  movieName: string;
  star: string;
  plot: string;
}

export interface GlobalDataInterface{
  userData: UserDataInterface;
  token: string
}

export interface ClassifyInterface{
  classify: string;
  category: string
}

export interface UserMsgInterface{
  userAge: number;// 使用天数
  favoriteCount: number;// 收藏数
  playRecordCount: number;// 观看记录
  viewRecordCount: number// 浏览记录
}

export interface StarInterface {
  id: number;//主键
  starName: string;//演员名称
  img: string;//演员图片地址
  localImg:string;//演员本地图片地址
  createTime:string;//创建时间
  updateTime:string;//更新时间
  movieId:string;//对应电影的id
  role: string;//角色
  href: string;//演员的豆瓣链接地址
  works: string ;//代表作
}

export interface MovieUrlInterface {
  id:number;//主键
  movieName:string;//电影名称
  movieId:number;//对应的电影的id
  href:string;//源地址
  label:string;//集数
  createTime:string;//创建时间
  updateTime:string;//更新时间
  url:string;//播放地址
  playGroup:string;//播放分组，1, 2
}

// 评论字段
export interface  CommentInterface {
  id:number,//主键
  content:string,//评论内容
  parentId:number,//父节点id
  type:string,// 类型
  topId:number,//顶级节点id
  relationId:number,//影片id
  createTime:string,//创建时间
  updateTime:string,//更新时间
  replyCount:number,//回复数量
  userId:string,//用户id
  username:string,//用户名
  avater:string,//用户头像
  replyUserId:string,//被回复者id
  replyUserName:string,//被回复者名称
  showCommentCount:string,//显示的回复数量
  replyPageNum:number,// 回复数量
  replyList:Array<CommentInterface>// 回复列表
}