import dataPreferences from "@ohos.data.preferences"

let context = getContext(this)
let preference: dataPreferences.Preferences = null

class PreferenceModel {
  //初始化Preferences首选项
  async getPreferencesFromStorage() {
    try {
      preference = await dataPreferences.getPreferences(context, 'mystore')
    } catch (err) {
      console.error(err)
    }
  }

  //删除preferences实例对应的首选项
  async deletePreferences() {
    try {
      await dataPreferences.deletePreferences(context, 'mystore')
    } catch (err) {
      console.error(err)
    }
    preference = null
  }

  //设置key-value
  async putPreference(key:string,value:string) {
    if (preference === null) {
      await this.getPreferencesFromStorage()
    }
    try {
      await preference.put(key, value)
    } catch (err) {
      console.error(err)
    }
    await preference.flush()
  }

  //获取key对应的value
  async getPreference(key:string){
    let value = ""
    if (preference === null) {
      await this.getPreferencesFromStorage()
    }
    try {
      value = <string> await preference.get(key, null)
    } catch (err) {
      console.error(err)
    }
    return value;
  }

  //删除key对应的value
  async deletePreference(key:string) {
    try {
      await preference.delete(key)
    } catch (err) {
      console.error(err)
    }
  }

  //检查参数是否为null
  isNull(value: any) {
    if (value === null) {
      return false
    }
    return true
  }

  //获取date日期对应的浏览历史
  async getToken() {
    let token = <string> await this.getPreference('token')
    return token ?? null
  }

  //写入date日期对应的浏览历史
  setToke(token) {
    this.putPreference('token',token)
  }
}

export default new PreferenceModel()