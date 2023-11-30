import http from '@ohos.net.http';
import {HOST} from '../common/constant';


/**
 * @description: 声明业务数据类型
 */
export interface MyAwesomeData<T> {
  data: T,
  token: string,
  status:string,
  msg:string,
  total:number
}

class HttpRequest {
  private static instance: HttpRequest;
  private token: string;
  private constructor() { }
  /** 请求函数(单例模式)
   *
   * **注意：**
   * `method`需使用`HttpMethod`枚举类，切勿自行定义
   *
   * **示例代码**
   * ```js
   HttpRequest.getInstance().request({
   url: "/Api",
   method: HttpMethod.GET
   })
   * ```
   */
  public setToken(token:string){
    this.token = token;
  }

  public static getInstance(): HttpRequest {
    if (!this.instance) {
      this.instance = new HttpRequest()
    }
    return this.instance;
  }

  // 服务器接口请求
  public request<T>(url:string,options: http.HttpRequestOptions): Promise<MyAwesomeData<T>> {
      // 默认header
      const header = {
        "content-type": "application/json",
        "Authorization": this.token
      }
      Object.assign(header, options?.header)
      options.header = header;
      let httpRequest = http.createHttp();
      return new Promise((resolve, reject) => {
        httpRequest.request(HOST + url,options).then((response:http.HttpResponse)=>{
          if(response.responseCode === http.ResponseCode.OK){
            resolve(response.result as MyAwesomeData<T>)
          }else{
            reject(response.result as MyAwesomeData<T>)
          }
        }).finally(()=>{
          // 当该请求使用完毕时，调用destroy方法主动销毁。
          httpRequest.destroy();
        });
      })

  }

  /**
   * @description: get请求函数
   * @param {string} url 请求地址
   * @param {Object} data 请求参数
   * @param {RequestConfig} OtherConfig request其他配置
   * @return {*}
   */
  public get<T>(url: string, data?: Object) {
    return this.request<T>(url,{ method: http.RequestMethod.GET,extraData: data})
  }

  /**
   * @description: post请求函数
   * @param {string} url 请求地址
   * @param {Object} data 请求参数
   * @param {RequestConfig} OtherConfig request其他配置
   * @return {*}
   */
  public post<T>(url: string, data?: Object) {
    return this.request<T>(url,{ method: http.RequestMethod.POST,extraData: data})
  }

  /**
   * @description: delete请求函数
   * @param {string} url 请求地址
   * @param {Object} data 请求参数
   * @param {RequestConfig} OtherConfig request其他配置
   * @return {*}
   */
  public delete<T>(url: string, data?: Object) {
    return this.request<T>(url,{ method: http.RequestMethod.DELETE,extraData: data})
  }

  /**
   * @description: put请求函数
   * @param {string} url 请求地址
   * @param {Object} data 请求参数
   * @param {RequestConfig} OtherConfig request其他配置
   * @return {*}
   */
  public put<T>(url: string, data?: Object) {
    return this.request<T>(url,{ method: http.RequestMethod.PUT,extraData: data})
  }

}

export const httpRequest = HttpRequest.getInstance()