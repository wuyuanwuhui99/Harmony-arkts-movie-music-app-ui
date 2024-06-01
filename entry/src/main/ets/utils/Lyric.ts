const timeExp:RegExp = /\[(\d{2,}):(\d{2})(?:\.(\d{2,3}))?]/g

enum STATUS {
  STATE_PAUSE = 0,
  STATE_PLAYING = 1
}

interface TagRegInterface {
  title?:string,
  artist?:string,
  album?:string,
  offset?:string,
  by?:string,
}

export interface LineInterface {
  time?:number,
  txt:string,
  lineNum?:number
}

const tagRegMap:TagRegInterface = {
  title: 'ti',
  artist: 'ar',
  album: 'al',
  offset: 'offset',
  by: 'by'
}

export default class Lyric {
  private lrc:string = '';
  private tags:TagRegInterface = {};
  public lines:Array<LineInterface> = []
  private state:STATUS = STATUS.STATE_PAUSE;
  private curLine:number = 0;
  private curNum:number = 0;
  private startStamp:number = 0;
  private timer:number = 0;
  private pauseStamp:number;
  private handler:(data:LineInterface) => void

  constructor(lrc:string, handlder:(data:LineInterface) => void) {
    this.lrc = lrc;
    this.handler = handlder;
    this._init();
  }

  _init() {
    this._initTag()

    this._initLines()
  }

  _initTag() {
    for (let tag in tagRegMap) {
      const matches = this.lrc.match(new RegExp(`\\[${tagRegMap[tag]}:([^\\]]*)]`, 'i'))
      this.tags[tag] = matches && matches[1] || ''
    }
  }

  _initLines() {
    const lines:Array<string> = this.lrc.split('\n')
    for (let i = 0; i < lines.length; i++) {
      const line = lines[i]
      let result:Array<string>|null = timeExp.exec(line)
      if (result) {
        const txt = line.replace(timeExp, '').trim()
        if (txt) {
          this.lines.push({
            time: parseInt(result[1]) * 60 * 1000 + parseInt(result[2]) * 1000 + (parseInt(result[3]) || 0) * 10,
            txt
          })
        }
      }
    }

    this.lines.sort((a, b) => {
      return a.time - b.time
    })
  }

  _findCurNum(time) {
    for (let i = 0; i < this.lines.length; i++) {
      if (time <= this.lines[i].time) {
        return i
      }
    }
    return this.lines.length - 1
  }

  _callHandler(i) {
    if (i < 0) {
      return
    }
    this.handler({
      txt: this.lines[i].txt,
      lineNum: i
    })
  }

  _playRest() {
    let line = this.lines[this.curNum]
    let delay = line.time - (+new Date() - this.startStamp)

    this.timer = setTimeout(() => {
      this._callHandler(this.curNum++)
      if (this.curNum < this.lines.length && this.state === STATUS.STATE_PLAYING) {
        this._playRest()
      }
    }, delay)
  }

  play(startTime:number = 0, skipLast:boolean = false) {
    if (!this.lines.length) {
      return
    }
    this.state = STATUS.STATE_PLAYING

    this.curNum = this._findCurNum(startTime)
    this.startStamp = +new Date() - startTime

    if (!skipLast) {
      this._callHandler(this.curNum - 1)
    }

    if (this.curNum < this.lines.length) {
      clearTimeout(this.timer)
      this._playRest()
    }
  }

  togglePlay() {
    const now:number = +new Date()
    if (this.state === STATUS.STATE_PLAYING) {
      this.stop()
      this.pauseStamp = now
    } else {
      this.state = STATUS.STATE_PLAYING
      this.play((this.pauseStamp || now) - (this.startStamp || now), true)
      this.pauseStamp = 0
    }
  }

  stop() {
    this.state =STATUS.STATE_PAUSE
    clearTimeout(this.timer)
  }

  seek(offset) {
    this.play(offset)
  }
}
