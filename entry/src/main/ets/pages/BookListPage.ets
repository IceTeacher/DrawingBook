import { http } from '@kit.NetworkKit';
import BookItemCard from '../components/BookItemCard';
import SearchItem from '../components/SearchItem';
import { LengthMetrics, router } from '@kit.ArkUI';
import LoadingItem from '../components/LoadingItem';
import { media } from '@kit.MediaKit';

// 当前播放内容的状态记录的类型
interface CurrentPlayAudioItemState {
  index: string,
  playMode: boolean,
  isShowPlayBar: boolean
}

@Entry
@Component
export default struct BookListPage {
  // 当前的页数
  @State currentPage: number = 1
  // 控制可以加载
  @State canLoad: boolean = true;
  // 音频书籍列表
  @State bookAudioList: Array<ESObject> = []
  // 维护切换不同语言书籍列表的状态
  @State currentBookListLanguageState: number = 0
  // 维护是否展示加载组件的状态
  @State isShowLoading: boolean = true
  // 当前播放内容的状态记录
  @State currentPlayAudioItemState: CurrentPlayAudioItemState = {
    index: "",
    playMode: false,
    isShowPlayBar: false,
  }
  // 当前播放内容
  @State currentPlayAudioItem: Array<ESObject> = []
  // 当前播放进度
  @State outSetValueOne: number = 0
  // 存储音频管理对象
  avPlayer: ESObject = null;

  // 请求中文音频书籍列表方法
  async getBookAudioList(language: number, page: number) {
    this.canLoad = false;
    let httpObject = http.createHttp();
    let url =
      `https://van.mama.cn/hb/api/goodsAudio/getList?page=${page}&language=${language}&perpage=10&sign=&uid=`
    let res = await httpObject.request(url)
    let bookAudioListRes: Array<ESObject> = JSON.parse(res["result"] as string)["data"]["list"]
    this.bookAudioList.push(...bookAudioListRes)
    if (bookAudioListRes.length == 10) {
      this.canLoad = true;
    } else {
      this.isShowLoading = false;
    }
    //this.isShowLoading = false
    httpObject.destroy();
  }

  // 生命周期钩子，创建时
  aboutToAppear(): void {
    this.getBookAudioList(0, 1)
  }

  // 创建音频对象
  async createAvPlayer(url: string) {
    //切换资源时 销毁之前的音频对象
    if (this.avPlayer) {
      this.avPlayer.release()
    }
    //创建音频管理对象
    let avPlayer: media.AVPlayer = await media.createAVPlayer();
    //监听状态变化事件
    avPlayer.on('stateChange', async (state: string, reason: media.StateChangeReason) => {
      switch (state) {
        case 'idle': // 成功调用reset接口后触发该状态机上报
          avPlayer.release(); // 调用release接口销毁实例对象
          break;
        case 'initialized': // avplayer 设置播放源后触发该状态上报
          avPlayer.prepare();
          console.log("音频", "初始化完毕")
          break;
        case 'prepared': // prepare调用成功后上报该状态机
          console.info('AVPlayer state prepared called.');
          avPlayer.play(); // 调用播放接口开始播放
          this.currentPlayAudioItemState.playMode = true
          break;
        case 'completed': // 播放结束后触发该状态机上报
          console.info('AVPlayer state completed called.');
          console.log("播放完毕")
          for (let i = 0; i < this.bookAudioList.length; i++) {
            if (this.currentPlayAudioItem[0]?.id === this.bookAudioList[i].id) {
              console.log("找到了下一个播放项", i + 1)
              this.createAvPlayer(this.bookAudioList[i + 1].video_url)
              this.currentPlayAudioItem = [this.bookAudioList[i + 1]]
              this.currentPlayAudioItemState = {
                index: this.bookAudioList[i + 1].id,
                playMode: true,
                isShowPlayBar: true,
              }
              return
            }
          }
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    });
    //监听时长变化事件
    avPlayer.on("timeUpdate", () => {
      console.log("音频", "时长变化", avPlayer.currentTime / 1000)
      this.outSetValueOne = avPlayer.currentTime / 1000
    })
    //指定播放地址
    avPlayer.url = url;
    this.avPlayer = avPlayer;
  }

  // 播放按钮子组件
  @Builder
  PlayAudioButton(item: ESObject) {
    Text() {
      Span(this.currentPlayAudioItemState.playMode ?
        this.currentPlayAudioItemState.index === item.id ? "\ue687" : "\ue686" : "\ue686")
        .fontFamily("iconfont")
        .fontSize(24)
        .lineHeight(24)
      Span(this.currentPlayAudioItemState.playMode ?
        this.currentPlayAudioItemState.index === item.id ? "暂停" : "播放" : "播放")
        .baselineOffset(LengthMetrics.vp(3))
    }
    .width(70)
    .height(30)
    .borderRadius(30)
    .backgroundColor(this.currentPlayAudioItemState.playMode ?
      this.currentPlayAudioItemState.index === item.id ? "#6ad487" : "#ff7b68" : "#ff7b68")
    .fontSize(14)
    .fontColor("#fff")
    .lineHeight(14)
    .textAlign(TextAlign.Center)
    .onClick(() => {
      if (this.currentPlayAudioItemState.index === item.id) {
        // 如果点击的是当前正在播放的音频
        this.currentPlayAudioItemState.playMode = !this.currentPlayAudioItemState.playMode;

        if (this.currentPlayAudioItemState.playMode) {
          // 若现在没有播放，则恢复播放
          this.avPlayer.play();
        } else {
          // 若现在正在播放，则暂停音频
          this.avPlayer.pause();
        }

        // 确保播放器显示
        if (!this.currentPlayAudioItemState.isShowPlayBar) {
          this.currentPlayAudioItemState.isShowPlayBar = true;
          this.createAvPlayer(item.video_url)
        }
      } else {
        // 如果点击的是其他音频，切换到新的音频
        this.currentPlayAudioItemState = {
          index: item.id,
          playMode: true, // 播放新音频时，设置为播放状态
          isShowPlayBar: true // 播放器显示
        };
        // 记录当前播放的音频项
        this.currentPlayAudioItem = [item];
        // 播放音频
        this.createAvPlayer(item.video_url)
      }

      console.log("index", this.currentPlayAudioItemState.index);
      console.log("item.id", item.id);
      console.log("playMode", this.currentPlayAudioItemState.playMode);
      console.log("isShowPlayBar", this.currentPlayAudioItemState.isShowPlayBar);
    });

  }

  // 播放器子组件
  @Builder
  PlayAudioBarCard() {
    Stack() {
      Row() {
        Row({ space: 5 }) {
          // 关闭按钮和音频封面
          Text("\ue646")
            .fontSize(24)
            .fontColor($r('sys.color.comp_background_list_card'))
            .fontWeight(700)
            .fontFamily("iconfont")
            .onClick(() => {
              this.currentPlayAudioItemState.isShowPlayBar = false
              this.currentPlayAudioItemState.playMode = false
              // 销毁音频对象
              this.avPlayer.pause()
              this.avPlayer.release()
            })
          Image(this.currentPlayAudioItem[0].expert_info.avatar).width(45).height(45).borderRadius(5)
        }

        // 进度条
        Row() {
          Slider({
            value: this.outSetValueOne,
            min: 0,
            max: Number(this.currentPlayAudioItem[0].time),
            style: SliderStyle.OutSet
          })
            .onChange((value: number, mode: SliderChangeMode) => {
              this.outSetValueOne = value
              this.avPlayer.seek(value * 1000)
              console.info('value:' + value + 'mode:' + mode.toString())
            })
            .selectedColor($r('sys.color.white'))
        }
        .width('50%')

        // 当前播放的时间
        // toFixed(0)将滑动条返回值处理为整数精度
        Text(`${Math.floor((Number(this.currentPlayAudioItem[0].time) - this.outSetValueOne) / 60)
          .toString()
          .padStart(2, '0')}:${Math.floor((Number(this.currentPlayAudioItem[0].time) - this.outSetValueOne) % 60)
          .toString()
          .padStart(2, '0')}`
        ).fontSize(14)
          .width(40)
          .fontColor($r('sys.color.comp_background_list_card'))

        // 播放按钮
        Text(this.currentPlayAudioItemState.playMode ? "\ue64b" : "\ue649")
          .fontSize(34)
          .fontColor($r('sys.color.comp_background_list_card'))
          .fontFamily("iconfont")
          .onClick(() => {
            this.currentPlayAudioItemState.playMode = !this.currentPlayAudioItemState.playMode
            if (this.currentPlayAudioItemState.playMode) {
              // 若现在没有播放，则恢复播放
              this.avPlayer.play();
            } else {
              // 若现在正在播放，则暂停音频
              this.avPlayer.pause();
            }
          })
      }
      .padding(10)
      .width("92%")
      .height(60)
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundBlurStyle(BlurStyle.Thin,
        { colorMode: ThemeColorMode.DARK, adaptiveColor: AdaptiveColor.DEFAULT, scale: 1.0 })
      .position({ x: '4%', y: '-10%' })
      .borderRadius(15)
      .shadow({
        radius: vp2px(5),
        color: "#958f8f8f",
        fill: true
      })
    }
    .alignContent(Alignment.Center)
  }

  @Builder
  build() {
    Column() {
      // 顶部搜索栏
      Row() {
        SearchItem()
      }
      .padding({ left: 20, right: 20 })
      .margin({ bottom: 10 })

      // 顶部标签
      Row() {
        Row({ space: 5 }) {
          Text("国语")
            .width(50)
            .height(25)
            .backgroundColor(this.currentBookListLanguageState === 0 ? "#5cd3b4" : "#ffffff")
            .border({
              style: BorderStyle.Solid,
              color: "#5cd3b4",
              width: 1,
              radius: 5
            })
            .fontSize(14)
            .fontColor(this.currentBookListLanguageState === 0 ? "#ffffff" : "#5cd3b4")
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.currentBookListLanguageState = 0
              this.bookAudioList = []
              this.isShowLoading = true
              this.currentPage = 1
              this.getBookAudioList(0, 1)
              this.currentPlayAudioItemState.playMode = false
              this.currentPlayAudioItemState.isShowPlayBar = false
              // 销毁音频对象
              this.avPlayer.pause()
              this.avPlayer.release()
            })
          Text("英语")
            .width(50)
            .height(25)
            .backgroundColor(this.currentBookListLanguageState === 3 ? "#5cd3b4" : "#ffffff")
            .border({
              style: BorderStyle.Solid,
              color: "#5cd3b4",
              width: 1,
              radius: 5
            })
            .fontSize(14)
            .fontColor(this.currentBookListLanguageState === 3 ? "#ffffff" : "#5cd3b4")
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.currentBookListLanguageState = 3
              this.bookAudioList = []
              this.isShowLoading = true
              this.currentPage = 1
              this.getBookAudioList(3, 1)
              this.currentPlayAudioItemState.playMode = false
              this.currentPlayAudioItemState.isShowPlayBar = false
              // 销毁音频对象
              this.avPlayer.pause()
              this.avPlayer.release()
            })
        }

        Row({ space: 8 }) {
          Text("\ue6b6")
            .fontFamily("iconfont")
            .fontSize(18)
            .fontColor("#5cd3b4")
          Text("连续播放")
            .fontSize(14)
            .fontColor("#5cd3b4")
        }
        .onClick(() => {
          if (this.currentPlayAudioItem.length === 0) {
            this.createAvPlayer(this.bookAudioList[0].video_url)
            this.currentPlayAudioItem = [this.bookAudioList[0]]
            this.currentPlayAudioItemState = {
              index: this.bookAudioList[0].id,
              playMode: true,
              isShowPlayBar: true,
            }
          } else {
            if (!this.currentPlayAudioItemState.playMode) {
              // 若现在没有播放，则恢复播放
              this.avPlayer.play();
              this.currentPlayAudioItemState.playMode = true
            }
          }
        })
      }
      .padding({ left: 20, right: 20 })
      .margin({ bottom: 10 })
      .width("100%")
      .justifyContent(FlexAlign.SpaceBetween)

      // 分割线
      Line()
        .width("100%")
        .height("1px")
        .startPoint([0, 0])
        .endPoint([0, "100%"])
        .backgroundColor("#ebebeb")

      List() {
        if (this.bookAudioList.length) {
          ForEach(this.bookAudioList, (item: ESObject) => {
            ListItem() {
              Row() {
                // 音频书籍卡片
                BookItemCard({
                  bookAudioItem: [item],
                  widthValue: 80,
                  heightValue: 100,
                  ySpaceValue: 10,
                })

                // 播放按钮
                this.PlayAudioButton(item)
              }
              .alignItems(VerticalAlign.Center)
            }
            .onClick(() => {
              router.pushUrl({
                url: "pages/BookDetailPage",
                params: {
                  id: item.goods_id
                }
              })
            })
          })
        }
        if (this.isShowLoading) {
          ListItem() {
            LoadingItem()
          }
          .padding(20)
        }

      }
      .padding({ left: 20, right: 20 })
      .width("100%")
      .height("85%")
      .onScrollIndex((start, end) => {
        console.log(start.toString(), end.toString())
        //触底条件
        if (end >= this.currentPage * 10 - 1 && this.canLoad) {
          this.isShowLoading = true
          this.currentPage++;
          this.getBookAudioList(this.currentBookListLanguageState, this.currentPage);
        }
      })

      if (this.currentPlayAudioItemState.isShowPlayBar) {
        this.PlayAudioBarCard()
      }
    }
    .width("100%")
    .height("100%")
    .alignItems(HorizontalAlign.Start)
  }
}