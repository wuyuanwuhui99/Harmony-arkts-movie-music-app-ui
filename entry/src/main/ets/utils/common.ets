import {LoopMode, MusicStorageInterface} from'../music/interface';
import {HOST, MUSIC_STORAGE} from '../common/constant';
import { MusicInterface } from '../music/interface/Index';
import {getMusicListByClassifyIdService} from '../music/service/Index';
import router from '@ohos.router';

export const zerofull=(value:number):string|number=>{
  return value < 10 ? "0" + value : value + ''
}

export const formatTime=(value:string|number):string=>{
  var date =new Date(typeof value === 'string' ? value.replace(/T/,' ') : value);
  var nowDate = new Date()
  let diff = Math.ceil((nowDate.getTime()-date.getTime())/1000);
  if(diff < 60){
    return "刚刚";
  }else if(diff < 60*60){
    return Math.ceil(diff/60) + "分前";
  }else if(diff < 60*60*24){
    return Math.ceil(diff/(60*60))+"小时前";
  }else if(diff < 60*60*24*30){
    return Math.ceil(diff/(60*60*24))+"天前";
  }else if(diff < 60*60*24*30*12){
    return Math.ceil(diff/(60*60*24*30))+"个月前";
  }
  const year = zerofull(date.getFullYear());
  const month = zerofull(date.getMonth()+1);
  const dates = zerofull(date.getDate());
  const hour = zerofull(date.getHours());
  const minutes = zerofull(date.getMinutes());
  const seconds = zerofull(date.getSeconds());
  return `${year}-${month}-${dates} ${hour}:${minutes}:${seconds}`
};

export const formatSecond=(value:number,showHour:boolean = false):string => {
  if(showHour){
    return `${zerofull(Math.floor(value / (60 * 60)))}:${zerofull(Math.floor(value % (60 * 60) / 60))}:${zerofull(Math.floor(value % (60 * 60) % 60))}`
  }else{
    return `${zerofull(Math.floor(value / 60))}:${zerofull(Math.floor(value % 60))}`
  }
};

/**
 * @description: 更新缓存和状态管理器
 * @date: 2024-06-05 22:18
 * @author wuwenqiang
 */
export const useUpdateStorage = (musicStorage:MusicStorageInterface)=>{
  musicStorage.playIndex = musicStorage.musicList.findIndex(mItem => mItem.id === musicStorage.musicItem.id)
  AppStorage.SetOrCreate<MusicStorageInterface>(MUSIC_STORAGE,musicStorage);
  const myMusicStorage:MusicStorageInterface =  {...musicStorage};
  myMusicStorage.audio = null;
  PersistentStorage.PersistProp<MusicStorageInterface>(MUSIC_STORAGE, myMusicStorage);
}

export const usePlayerRouter = (musicStorage:MusicStorageInterface,musicList:Array<MusicInterface>,musicModel:MusicInterface,classifyName:string,index:number) => {
  if(musicStorage.musicItem?.id === musicModel.id && musicStorage.classifyName === classifyName){
    musicStorage.audio.play();
    musicStorage.isPlaying = true;
  }else{
    musicStorage.musicItem = musicModel;
    musicStorage.audio?.reset();
    if(musicStorage.classifyName !== classifyName){
      musicStorage.musicList = musicList;
      musicStorage.playList = [...musicList];
      musicStorage.recordList.push(...musicStorage.playList.splice(index,1));
      musicStorage.classifyName !== classifyName
    }
    useUpdateStorage(musicStorage);
  }
  router.pushUrl({url: 'music/pages/MusicPlayerPage'});
}

export const useAppStorage = ():MusicStorageInterface => {
  return AppStorage.Get<MusicStorageInterface>(MUSIC_STORAGE) || {
    musicItem: null,
    audio: null,
    isPlaying: true,
    musicList: [],
    classifyName: "",
    total: 0,
    isInitPlayer:false,
    playIndex: -1,
    loop: LoopMode.ORDER,
    playList: [],// 还没有播放的音乐
    recordList:[],// 已经播放的歌曲
  };
}

export const getMusicCover = (cover:string) => /http[s]?:\/\//.test(cover) ? cover.replace('{size}', '480') : HOST + cover