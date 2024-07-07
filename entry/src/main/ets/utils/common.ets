import {LoopMode, MusicStorageInterface} from'../music/interface';
import {MUSIC_STORAGE} from '../config/constant';
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
  // 列表数据不用存缓存，避免缓存过大，或者下次进来缓存没更新
  myMusicStorage.musicList = [];// 所有音乐
  myMusicStorage.musicList = myMusicStorage.recordList = myMusicStorage.playList = [];// 还没有播放的音乐
  myMusicStorage.audio = null;
  PersistentStorage.PersistProp<MusicStorageInterface>(MUSIC_STORAGE, myMusicStorage);
}

export const usePlayerRouter = (musicStorage:MusicStorageInterface,musicModel:MusicInterface,classifyId:number,index:number) => {
  if(musicStorage.musicItem?.id === musicModel.id && musicStorage.musicList.length !== 0){
    musicStorage.audio.play();
    musicStorage.isPlaying = true;
  }else{
    musicStorage.musicItem = musicModel;
    musicStorage.audio?.reset();
    if(musicStorage.classifyId !== classifyId || musicStorage.musicList.length === 0){
      getMusicListByClassifyIdService(classifyId,1,500).then((res)=>{
        musicStorage.musicList = res.data;
        musicStorage.playList = [...res.data];
        musicStorage.recordList.push(...musicStorage.playList.splice(index,1));
        useUpdateStorage(musicStorage);
      });
      musicStorage.classifyId = classifyId;
    }
  }
  router.pushUrl({url: 'music/pages/MusicPlayerPage'});
}

export const useAppStorage = ():MusicStorageInterface => {
  return AppStorage.Get<MusicStorageInterface>(MUSIC_STORAGE) || {
    musicItem: null,
    audio: null,
    isPlaying: true,
    musicList: [],
    classifyId: -1,
    total: 0,
    isInitPlayer:false,
    playIndex: -1,
    loop: LoopMode.ORDER,
    playList: [],// 还没有播放的音乐
    recordList:[],// 已经播放的歌曲
  };
}

export const useLike = () => {
  if (this.loading) return;
  this.loading = true;
  if (this.musicModel.isLike === 1) {
    deleteMusicLikeService(this.musicModel.id).then((res) => {
      if (res.data > 0) {
        this.musicModel.isLike = 0;
        useUpdateStorage(this.musicStorage);
        promptAction.showToast({
          message: "取消点赞成功",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        });
        emitter.emit(LIKE_INNER_EVENT,{data:this.musicModel})
      }
    }).finally(() => this.loading = false)
  } else {
    insertMusicLikeService(this.musicModel.id).then(res => {
      if (res.data > 0) {
        this.musicModel.isLike = 1;
        useUpdateStorage(this.musicStorage);
        promptAction.showToast({
          message: "添加收藏成功",
          duration: 2000,
          bottom: px2vp(display.getDefaultDisplaySync().height) / 2
        });
        emitter.emit(LIKE_INNER_EVENT,{data:this.musicModel});
      }
    }).finally(() => this.loading = false)
  }
}