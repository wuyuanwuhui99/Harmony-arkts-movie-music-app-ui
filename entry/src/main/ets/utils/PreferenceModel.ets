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
    return 'eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MTk4NDE4NjUsInN1YiI6IntcImF2YXRlclwiOlwiL3N0YXRpYy91c2VyL2F2YXRlci_lkLTmgKjlkLTmgpQuanBnXCIsXCJiaXJ0aGRheVwiOlwiMTk5MC0xMC04XCIsXCJjcmVhdGVEYXRlXCI6MTU2NTcwMTMxNjAwMCxcImRpc2FibGVkXCI6MCxcImVtYWlsXCI6XCIyNzUwMTg3MjNAcXEuY29tXCIsXCJwZXJtaXNzaW9uXCI6MCxcInJvbGVcIjpcInB1YmxpY1wiLFwic2V4XCI6XCLnlLdcIixcInNpZ25cIjpcIuaXoOaAqO-8jOacieaClFwiLFwidGVsZXBob25lXCI6XCIxNTMwMjY4Njk0N1wiLFwidXBkYXRlRGF0ZVwiOjE1NjU3MDEzMjIwMDAsXCJ1c2VySWRcIjpcIuWQtOW_p-WQtOiZkVwiLFwidXNlcm5hbWVcIjpcIuWQtOW_p-WQtOiZkVwifSIsImV4cCI6MTcyMjQzMzg2NX0.GbEsgtlPl4SaN9ccE9L1EDlmHDZ3cyWyJbtqlsUas0E';
    // let token = <string> await this.getPreference('token')
    // return token ?? null
  }

  //写入date日期对应的浏览历史
  async setToke(token) {
    return this.putPreference('token',token)
  }

  //获取date日期对应的浏览历史
  async getPassword(userId:string) {
    let token = <string> await this.getPreference(userId)
    return token ?? null
  }

  //写入date日期对应的浏览历史
  setPassword(userId:string,password:string) {
    this.putPreference(userId,password);
  }

  //获取date日期对应的浏览历史
  async getMovieSeachKeyWord():Promise<Array<string>> {
    let movieSearchKeyWord = <string> await this.getPreference('movieSearchKeyWord');
    if(movieSearchKeyWord){
      return JSON.parse(movieSearchKeyWord)
    }else {
      return []
    }
  }

  // 电影搜索记录
  async setMovieSeachKeyWord(keyWord):Promise<Array<string>> {
    const movieSearchKeyWord:Array<string> = await this.getMovieSeachKeyWord();
    const index = movieSearchKeyWord.findIndex(item => item === keyWord);
    if(index !== -1){
      movieSearchKeyWord.splice(index,1)
    }
    movieSearchKeyWord.unshift(keyWord);
    // 最多只存十条记录
    if(movieSearchKeyWord.length > 10)movieSearchKeyWord.splice(10,movieSearchKeyWord.length - 10)
    return movieSearchKeyWord;
  }
}

export default new PreferenceModel()