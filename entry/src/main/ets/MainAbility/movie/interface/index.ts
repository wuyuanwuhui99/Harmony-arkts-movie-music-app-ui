export interface MyAwesomeData<T> {
  data: T,
  token: string,
  status:string,
  msg:string,
  total:number
}


export interface UserDataInterface {
  userId:     string;
  createDate: string;
  updateDate: string;
  username:   string;
  telephone:  string;
  email:      string;
  avater:     string;
  birthday:   string;
  sex:        string;
  role:       string;
  password:   string;
  sign:       string;
  region:     string;
  disabled:   number;
  permission: number;
}

export interface Movieinterface {
  classify: string;
  isRecommend: string;
  img: string;
  targetHref: string;
  updateTime: number;
  useStatus: string;
  sourceUrl: string;
  score: number;
  localImg: string;
  ranks: string;
  createTime: number;
  id: number;
  sourceName: string;
  category: string;
  movieName: string;
}

export interface GlobalDataInterface{
  userData: UserDataInterface,
  token: string
}