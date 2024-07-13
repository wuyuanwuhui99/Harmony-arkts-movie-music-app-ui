import api from '../api/index';
import httpRequest from '../../utils/HttpUtil';
import * as types from '../interface/Index'
import { MyAwesomeData } from '../interface';
import CryptoJS from '@ohos/crypto-js';
import { CommentInterface } from '../../music/interface/Index';

/**
 * @description: 根据token获取用户信息
 * @date: 2023-12-1 23:39
 * @author wuwenqiang
 */
export const getUserDataService = (token:string):Promise<MyAwesomeData<types.UserDataInterface>>=> {
  httpRequest.setToken(token);
  return httpRequest.get<types.UserDataInterface>(api.getUserData);
}

/**
 * @description: 获取搜索框的关键词
 * @date: 2023-12-1 23:50
 * @author wuwenqiang
 */
export const getSearchKeyWordService = (classify:string):Promise<MyAwesomeData<types.MovieInterface>>=> {
  return httpRequest.get<types.MovieInterface>(api.getKeyWord,{classify});
}

/**
 * @description: 根据大分类和小分类获取电影列表数据
 * @date: 2023-12-1 23:09
 * @author wuwenqiang
 */
export const getCategoryListService = (classifyItem:types.ClassifyInterface):Promise<MyAwesomeData<Array<types.MovieInterface>>>=> {
  return httpRequest.get<Array<types.MovieInterface>>(api.getCategoryList,classifyItem)
}

/**
 * @description: 根据大分类和小分类获取电影列表数据
 * @date: 2023-12-1 23:09
 * @author wuwenqiang
 */
export const getAllCategoryListByPageNameService = (pageName:string):Promise<MyAwesomeData<Array<types.ClassifyInterface>>>=> {
  return httpRequest.get<Array<types.ClassifyInterface>>(api.getAllCategoryListByPageName,{pageName})
}

/**
 * @description: 获取用户使用天数、访问记录数量等
 * @date: 2023-12-10 10:15
 * @author wuwenqiang
 */
export const getUserMsgService = ():Promise<MyAwesomeData<types.UserMsgInterface>>=> {
  return httpRequest.get<types.UserMsgInterface>(api.getUserMsg)
}

/**
 * @description: 获取用户观看记录
 * @date: 2023-12-13 21:45
 * @author wuwenqiang
 */
export const getPlayRecordMovieListService = (pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.MovieInterface>>>=> {
  return httpRequest.get<Array<types.MovieInterface>>(`${api.getPlayRecord}?pageNum=${pageNum}&pageSize=${pageSize}`)
}

/**
 * @description: 获取用户收藏的电影
 * @date: 2023-12-15 22:26
 * @author wuwenqiang
 */
export const getMyFavoriteMovieListService = (pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.MovieInterface>>>=> {
  return httpRequest.get<Array<types.MovieInterface>>(`${api.getFavorite}?pageNum=${pageNum}&pageSize=${pageSize}`)
}

/**
 * @description: 获取用户浏览过的电影
 * @date: 2023-12-15 23:28
 * @author wuwenqiang
 */
export const getMyViewsMovieListService = (pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<types.MovieInterface>>>=> {
  return httpRequest.get<Array<types.MovieInterface>>(`${api.getViewRecord}?pageNum=${pageNum}&pageSize=${pageSize}`)
}

/**
 * @description: 获取演员信息
 * @date: 2023-12-16 18:26
 * @author wuwenqiang
 */
export const getMovieStartListService = (movieId:number):Promise<MyAwesomeData<Array<types.StarInterface>>>=> {
  return httpRequest.get<Array<types.StarInterface>>(`${api.getStar}${movieId}`)
}

/**
 * @description: 获取推荐的电影
 * @date: 2023-12-16 18:28
 * @author wuwenqiang
 */
export const getRecommentListService = (classify:string):Promise<MyAwesomeData<Array<types.MovieInterface>>>=> {
  return httpRequest.get<Array<types.MovieInterface>>(`${api.getRecommend}?classify=${classify}`)
}

/**
 * @description: 插入浏览记录
 * @date: 2023-12-23 22:12
 * @author wuwenqiang
 */
export const saveViewRecordService = (movieItem:types.MovieInterface):Promise<MyAwesomeData<number>>=> {
  return httpRequest.post<number>(api.saveViewRecord,movieItem)
}

/**
 * @description: 获取电影地址分株
 * @date: 2023-12-26 22:45
 * @author wuwenqiang
 */
export const getMovieUrlService = (movieId:number):Promise<MyAwesomeData<Array<types.MovieUrlInterface>>>=> {
  return httpRequest.get<Array<types.MovieUrlInterface>>(`${api.getMovieUrl}?movieId=${movieId}`)
}

/**
 * @description: 修改用户信息
 * @date: 2024-01-10 23:01
 * @author wuwenqiang
 */
export const updateUserDataService = (userData:types.UserDataInterface):Promise<MyAwesomeData<number>>=>{
  return httpRequest.put<number>(api.updateUser,userData)
};

/**
 * @description: 登录
 * @date: 2024-01-15 21:32
 * @author wuwenqiang
 */
export const loginService = (userId:string,password:string):Promise<MyAwesomeData<number>>=>{
  password = CryptoJS.MD5(password).toString();// 使用md5加密
  return httpRequest.post<number>(api.login,{userId,password})
};

/**
 * @description: 注册
 * @date: 2024-01-21 14:48
 * @author wuwenqiang
 */
export const registerService = (userData:types.UserDataInterface):Promise<MyAwesomeData<number>>=>{
  userData = {...userData};
  userData.password = CryptoJS.MD5(userData.password).toString();// 使用md5加密
  return httpRequest.put<number>(api.register,userData)
};

/**
 * @description: 注册
 * @date: 2024-01-21 14:48
 * @author wuwenqiang
 */
export const verifyUserIdService = (userId:string):Promise<MyAwesomeData<number>>=>{
  return httpRequest.get<number>(`${api.verifyUserId}?userId=${userId}`)
};

/**
 * @description: 获取推荐的电影
 * @date: 2024-01-22 23:05
 * @author wuwenqiang
 */
export const getRecommendSerivce = (classify:string):Promise<MyAwesomeData<Array<types.MovieInterface>>>=>{
  return httpRequest.get<Array<types.MovieInterface>>(`${api.getRecommend}?classify=${encodeURIComponent(classify)}`)
};


/**
 * @description: 电影搜索
 * @date: 2024-01-23 22:12
 * @author wuwenqiang
 */
export const getSearchResultService = (keyword:string, pageSize:number = 20, pageNum:number = 1):Promise<MyAwesomeData<Array<types.MovieInterface>>>=>{
  return httpRequest.get<Array<types.MovieInterface>>(`${api.getSearchResult}?keyword=${encodeURIComponent(keyword)}&pageSize=${pageSize}&pageNum=${pageNum}`)
};


/**
 * @author: wuwenqiang
 * @description: 获取影片评论总数
 * @date: 2023-12-28 23:18
 */
export const getCommentCountService = (id:number,type:string):Promise<MyAwesomeData<number>>=>{
  return httpRequest.get<number>(`${api.getCommentCount}?relationId=${id}&type=${type}&pageSize=20&pageNum=1`)
};

/**
 * @author: wuwenqiang
 * @description: 查询是否已经收藏
 * @date: 2023-12-28 22:53
 */
export const isFavoriteService = (movieId:number):Promise<MyAwesomeData<number>>=>{
  return httpRequest.get<number>(`${api.isFavorite}?movieId=${movieId}`)
};

/**
 * @author: wuwenqiang
 * @description: 添加收藏
 * @date: 2023-12-28 22:58
 */
export const saveFavoriteService = (movieId:number):Promise<MyAwesomeData<number>>=>{
  return httpRequest.post<number>(`${api.saveFavorite}/${movieId}`,{})
};

/**
 * @author: wuwenqiang
 * @description: 取消收藏
 * @date: 2023-12-28 22:58
 */
export const deleteFavoriteService = (movieId:number):Promise<MyAwesomeData<number>>=>{
  return httpRequest.delete<number>(`${api.deleteFavorite}/${movieId}`);
};

/**
 * @author: wuwenqiang
 * @description: 取消收藏
 * @date: 2023-12-28 22:58
 */
export const insertCommentService = (commentItem:CommentInterface):Promise<MyAwesomeData<CommentInterface>> => {
  return httpRequest.post<CommentInterface>(api.insertComment,commentItem);
}

/**
 * @description: 获取一级评论
 * @date: 2024-05-12 12:21
 * @author wuwenqiang
 */
export const getTopCommentListService = (relationId:number,type:string,pageNum:number,pageSize:number):Promise<MyAwesomeData<Array<CommentInterface>>> => {
  return httpRequest.get<Array<CommentInterface>>(`${api.getTopCommentList}?relationId=${relationId}&type=${type}&pageSize=${pageSize}&pageNum=${pageNum}`);
}
