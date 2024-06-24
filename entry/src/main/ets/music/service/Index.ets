import api from '../api/index';
import httpRequest from '../../utils/HttpUtil';
import * as types from '../interface/Index'
import { MyAwesomeData } from '../../movie/interface';
import {SocialEnum} from '../../config/constant';
/**
 * @description: 获取推荐的音乐
 * @date: 2024-03-02 22:44
 * @author wuwenqiang
 */
export const getKeyWordMusicService = ():Promise<MyAwesomeData<types.MusicInterface>> => {
  return httpRequest.get<types.MusicInterface>(api.getKeywordMusic);
}

/**
 * @description: 获取模块分类
 * @date: 2024-03-02 22:44
 * @author wuwenqiang
 */
export const getMusicClassifyService = ():Promise<MyAwesomeData<Array<types.MusicClassifyInterface>>> => {
  return httpRequest.get<Array<types.MusicClassifyInterface>>(api.getMusicClassify);
}

/**
 * @description: 获取模块分类
 * @date: 2024-03-03 11:50
 * @author wuwenqiang
 */
export const getMusicListByClassifyIdService = (classifyId:number,pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.MusicInterface>>> => {
  return httpRequest.get<Array<types.MusicInterface>>(`${api.getMusicListByClassifyId}?classifyId=${classifyId}&pageNum=${pageNum}&pageSize=${pageSize}`);
}

/**
 * @description: 获取推荐的歌手
 * @date: 2024-03-03 18:23
 * @author wuwenqiang
 */
export const getSingerListService = (category:string,pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.MusicSingerInterface>>> => {
  return httpRequest.get<Array<types.MusicSingerInterface>>(`${api.getSingerList}?${category != '' && category != null ? "category=" + category + "&" : ""}pageNum=${pageNum}&pageSize=${pageSize}`);
}

/**
 * @description: 获取音乐圈数据
 * @date: 2024-03-03 18:23
 * @author wuwenqiang
 */
export const getCircleListByTypeService = (type:string,pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.CircleInterface>>> => {
  return httpRequest.get<Array<types.CircleInterface>>(`${api.getCircleListByType}?type=${type}&pageNum=${pageNum}&pageSize=${pageSize}`);
}

/**
 * @description: 点赞
 * @date: 2024-03-12 23:25
 * @author wuwenqiang
 */
export const saveLikeService = (likeItem:types.LikeInterface):Promise<MyAwesomeData<types.LikeInterface>> => {
  return httpRequest.post<types.LikeInterface>(api.saveLike,likeItem);
}

/**
 * @description: 删除点赞
 * @date: 2024-03-12 23:25
 * @author wuwenqiang
 */
export const deleteLikeService = (relationId:number,type:SocialEnum):Promise<MyAwesomeData<number>> => {
  return httpRequest.delete<number>(`${api.deleteLike}?relationId=${relationId}&type=${type}`);
}

/**
 * @description: 添加评论
 * @date: 2024-03-12 23:25
 * @author wuwenqiang
 */
export const insertCommentService = (commentItem:types.CommentInterface):Promise<MyAwesomeData<types.CommentInterface>> => {
  return httpRequest.post<types.CommentInterface>(api.insertComment,commentItem);
}

/**
 * @description: 获取用户歌单
 * @date: 2024-03-16 23:25
 * @author wuwenqiang
 */
export const getMusicPlayMenuService = ():Promise<MyAwesomeData<Array<types.MuiscPlayMenuInterface>>> => {
  return httpRequest.get<Array<types.MuiscPlayMenuInterface>>(api.getMusicPlayMenu);
}

/**
 * @description: 获取我关注的歌手
 * @date: 2024-03-17 22:12
 * @author wuwenqiang
 */
export const getMySingerService = (pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.MusicSingerInterface>>> => {
  return httpRequest.get<Array<types.MusicSingerInterface>>(`${api.getMySinger}?pageNum=${pageNum}&pageSize=${pageSize}`);
}

/**
 * @description: 获取播放记录
 * @date: 2024-03-17 22:12
 * @author wuwenqiang
 */
export const getMusicRecordService = (pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.MusicInterface>>> => {
  return httpRequest.get<Array<types.MusicInterface>>(`${api.getMusicRecord}?pageNum=${pageNum}&pageSize=${pageSize}`);
}

/**
 * @description: 获取播放记录
 * @date: 2024-03-17 22:12
 * @author wuwenqiang
 */
export const getClassifyMusicByIndexService = (classifyId:number,index:number):Promise<MyAwesomeData<types.MusicInterface>> => {
  return httpRequest.get<types.MusicInterface>(`${api.getClassifyMusicByIndex}?classifyId=${classifyId}&index=${index}`);
}

/**
 * @description: 插入播放记录
 * @date: 2024-03-17 22:12
 * @author wuwenqiang
 */
export const insertMusicRecordService = (musicModel:types.MusicInterface):Promise<MyAwesomeData<number>> => {
  return httpRequest.post<number>(api.insertMusicRecord,musicModel);
}

/**
 * @description: 添加收藏
 * @date: 2024-05-12 12:21
 * @author wuwenqiang
 */
export const insertMusicLikeService = (musicId:number):Promise<MyAwesomeData<number>> => {
  return httpRequest.post<number>(api.insertMusicLike + musicId,{});
}

/**
 * @description: 删除收藏
 * @date: 2024-05-12 12:21
 * @author wuwenqiang
 */
export const deleteMusicLikeService = (musicId:number):Promise<MyAwesomeData<number>> => {
  return httpRequest.delete<number>(api.deleteMusicLike + musicId);
}