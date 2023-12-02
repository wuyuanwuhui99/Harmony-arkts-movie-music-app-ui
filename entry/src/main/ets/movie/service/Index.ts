import api from '../api/index';
import httpRequest from '../../utils/HttpUtil';
import {UserDataInterface,Movieinterface} from '../interface/Index'
import { MyAwesomeData } from '../interface';

/**
 * @description: 根据token获取用户信息
 * @date: 2023-12-1 23:39
 * @author wuwenqiang
 */
export const getUserDataService = (token:string):Promise<MyAwesomeData<UserDataInterface>>=> {
  httpRequest.setToken(token);
  return httpRequest.get<UserDataInterface>(api.getUserData);
}

/**
 * @description: 根据大分类和小分类获取电影列表数据
 * @date: 2023-12-1 23:09
 * @author wuwenqiang
 */
export const getCategoryListService = (classify:string,category:string):Promise<MyAwesomeData<Array<Movieinterface>>>=> {
  return httpRequest.get<Array<Movieinterface>>(api.getCategoryList,{category,classify})
}