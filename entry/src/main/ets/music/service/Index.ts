import api from '../api/index';
import httpRequest from '../../utils/HttpUtil';
import * as types from '../interface/Index'
import { MyAwesomeData } from '../../movie/interface';

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
