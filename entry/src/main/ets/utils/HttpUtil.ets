import http from '@ohos.net.http';
import {HOST} from '../common/constant';
import {MyAwesomeData} from '../movie/interface/Index'
import promptAction from '@ohos.promptAction';
import display from '@ohos.display';

/**
 * @description: 声明业务数据类型
 */

enum STATUS {
  SUCCESS = 'SUCCESS',
  FAIL = 'FAIL',
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

      const defaultOptions:http.HttpRequestOptions = {
        extraData: null,
        method: http.RequestMethod.GET,
        connectTimeout: 10000,
        readTimeout: 10000,
        header:  {
          "content-type": "application/json",
          "Authorization": this.token
        }
      }

      options = {...defaultOptions,...options}

      let httpRequest = http.createHttp();
      return new Promise((resolve, reject) => {
        httpRequest.request(HOST + url,options).then((response:http.HttpResponse)=>{
          const result:MyAwesomeData<T> = JSON.parse(response.result.toString()) as MyAwesomeData<T>
          if(result.status == STATUS.SUCCESS){
            resolve(result)
          }else{
            promptAction.showToast({
              message: result.msg,
              duration: 2000,
              bottom: px2fp(display.getDefaultDisplaySync().height) / 2
            });
            reject(result)
          }
        }).catch((err:Error)=>{
          promptAction.showToast({
            message: `请求错误，地址：${HOST + url}${options.extraData &&'，请求参数：'+ JSON.stringify(options.extraData)},错误信息： ${JSON.stringify(err)}`,
            duration: 2000,
            bottom: px2fp(display.getDefaultDisplaySync().height) / 2
          });
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
  public get<T>(url: string, data?: Object):Promise<MyAwesomeData<T>> {
     return this.request<T>(url, { method: http.RequestMethod.GET, extraData: data })
  }
  /**
   * @description: post请求函数
   * @param {string} url 请求地址
   * @param {Object} data 请求参数
   * @param {RequestConfig} OtherConfig request其他配置
   * @return {*}
   */
  public post<T>(url: string, data?: Object): Promise<MyAwesomeData<T>> {
    return this.request<T>(url,{ method: http.RequestMethod.POST,extraData: data})
  }

  /**
   * @description: delete请求函数
   * @param {string} url 请求地址
   * @param {Object} data 请求参数
   * @param {RequestConfig} OtherConfig request其他配置
   * @return {*}
   */
  public delete<T>(url: string, data?: Object): Promise<MyAwesomeData<T>> {
    return this.request<T>(url,{ method: http.RequestMethod.DELETE,extraData: data})
  }

  /**
   * @description: put请求函数
   * @param {string} url 请求地址
   * @param {Object} data 请求参数
   * @param {RequestConfig} OtherConfig request其他配置
   * @return {*}
   */
  public put<T>(url: string, data?: Object): Promise<MyAwesomeData<T>> {
    return this.request<T>(url,{ method: http.RequestMethod.PUT,extraData: data})
  }

}

export default HttpRequest.getInstance()