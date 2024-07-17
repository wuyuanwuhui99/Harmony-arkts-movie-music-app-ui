// 歌曲字段
import { SocialEnum } from '../../common/enum';
import media from '@ohos.multimedia.media';
export interface MusicInterface  {
  id : number, //主键
  albumId : number, // 专辑id
  songName : string, // 歌曲名称
  authorName : string, // 歌手名称
  authorId : number, // 歌手id
  albumName : string, // 专辑
  version : string, // 版本
  language : string, // 语言
  publishDate : string, // 发布时间
  wideAudioId : number, // 未使用字段
  isPublish : number, // 是否发布
  bigPackId : number, // 未使用字段
  finalId : number, // 未使用字段
  audioId : number, // 音频id
  similarAudioId : number, // 未使用字段
  isHot : number, // 是否热门
  albumAudioId : number, // 音频专辑id
  audioGroupId : number, // 歌曲组id
  cover : string, // 歌曲图片
  playUrl : string, // 网络播放地址
  localPlayUrl : string, // 本地播放地址
  sourceName : string, // 歌曲来源
  sourceUrl : string, // 来源地址
  createTime : string, // 创建时间
  updateTime : string, // 更新时间
  label : string, // 标签
  lyrics : string, // 歌词
  isLike : number, // 是否喜欢
  times? : number //  听过的次数，在获取播放记录的时候才有
}

// 歌曲分类字段
export interface MusicClassifyInterface {
  id : number,// 分类id
  classifyName : string, // 分类时间
  permission : number,// 权限
  classifyRank : number, // 分类排名
  cover : string,// 分类图标
  disabled : number,// 是否禁用
  createTime : string,// 创建时间
  updateTime : string// 更新时间
}

// 歌手字段
export interface MusicSingerInterface {
  id : number,//主键
  authorId : number,// 歌手id
  authorName: string,// 歌手名称
  language: string,// 语言
  isPublish : number,// 是否发布
  avatar: string,// 头像
  type : number,// 类型
  country: string,// 国家
  birthday: string,// 生日
  identity : number,// 身份
  rank : number,// 排名
  createTime: string,// 创建时间
  updateTime: string,// 更新时间
  total: string// 歌曲总数
}

// 点赞字段
export interface LikeInterface {
  id?:number,
  type:SocialEnum,
  relationId:number,// 朋友圈id
  userId?:string,// 用户id
  username?:string,// 用户名称
  createTime?:string,// 创建时间
  updateTime?:string// 更新时间
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

export interface CircleInterface {
  id?:number,
  relationId:number,// 关联音乐audio_id或者电影movie_id
  content:string,// 朋友圈内容
  imgs?:string,// 朋友圈图片
  type:SocialEnum,// 类型
  permission:number,// 权限
  userId?:string,// 用户id
  username?:string,// 用户的昵称
  useravater?:string,// 用户头像
  createTime?:string,// 创建时间
  updateTime?:string,// 更新时间
  musicSongName?:string,// 歌曲名称
  musicAudioId?:string,// 歌曲id
  musicAuthorName?:string,// 歌曲作者
  musicAlbumName?:string,// 专辑名称
  musicCover?:string,// 音乐图片
  musicPlayUrl?:string,// 音乐播放地址
  musicLocalPlayUrl?:string,// 音乐本地播放地址
  musicLyrics?:string,// 歌词
  movieId?:string,// 电影id
  movieName?:string,// 电影名称
  movieDirector?:string,// 电影导演
  movieStar?:string,// 电影主演
  movieType?:string,// 电影类型
  movieCountryLanguage?:string,// 电影上映国家
  movieViewingState?:string,// 电影状态
  movieReleaseTime?:string,// 上映时间
  movieImg?:string,// 电影海报
  movieClassify?:string,// 电影分类
  movieLocalImg?:string,// 电影本地图片
  movieScore?:string,// 电影得分
  circleLikes?:Array<LikeInterface>,
  circleComments?: Array<CommentInterface>
}

export interface MuiscPlayMenuInterface {
  id:number,//主键
  name:string,// 歌单名称
  userId:string;// 用户id
  total:number;// 歌单里面的歌曲总数
  cover:string;// 歌单封面
  createTime:string;// 创建时间
  updateTime:string;// 更新时间
}

export enum LoopMode {
  ORDER,// 顺序播放
  RANDOM,// 随机播放
  REPEAT,// 单曲循环
}

// 音乐仓库
export interface MusicStorageInterface {
  musicItem: MusicInterface | null,
  audio?: media.AVPlayer,
  isPlaying: boolean,
  isInitPlayer:boolean,// 是否已经初始化播放器
  musicList: Array<MusicInterface>,
  classifyName: string,// 播放分类的名称
  playIndex: number,// 播放的下标
  total: number,
  loop: LoopMode// 默认顺序播放
  playList: Array<MusicInterface>,// 还没有播放的音乐
  recordList: Array<MusicInterface>// 已经播放的歌曲
}

export const enum SwitchEnum { // 切换模式
  NEXT,
  PREV
}

export interface  MuiscPlayMenuInterface {
  id:number,//主键
  name:string,// 歌单名称
  userId:string;// 用户id
  total:number;// 歌单里面的歌曲总数
  cover:string;// 歌单封面
  createTime:string;// 创建时间
  updateTime:string;// 更新时间
}

// 音乐收藏夹类型
export interface FavoriteDirectoryInterface {
  id?:number,//主键
  userId?:string;// 用户id
  name:string,// 用户名称
  checked?:number,// 当前这首歌曲是否在这个收藏夹内
  total?:number;// 歌单里面的歌曲总数
  createTime?:string;// 创建时间
  updateTime?:string;// 更新时间
  cover?:string;// 封面
}

// 音乐收藏夹音乐类型,只在提交时用到
export interface FavoriteMusicInterface {
  id?:number,//主键
  favoriteId:number;// 用户id
  musicId?:number,// 用户名称
  createTime?:string;// 创建时间
  updateTime?:string;// 更新时间
}