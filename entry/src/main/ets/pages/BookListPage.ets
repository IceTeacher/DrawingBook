import { http } from '@kit.NetworkKit';
import BookItemCard from '../components/BookItemCard';
import SearchItem from '../components/SearchItem';
import { LengthMetrics } from '@kit.ArkUI';
import LoadingItem from '../components/LoadingItem';

// 当前播放内容的状态记录的类型
interface CurrentPlayAudioItemState {
  index: string,
  playMode: boolean,
  isShowPlayBar: boolean
}

@Entry
@Component
export default struct BookListPage {
  // 音频书籍列表
  @State bookAudioList: Array<ESObject> = []
  // 维护切换不同语言书籍列表的状态
  @State currentBookListLanguageState: number = 0
  // 维护是否展示加载组件的状态
  @State isShowLoading: boolean = false
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

  // 请求中文音频书籍列表方法
  async getBookAudioList(language: number) {
    this.isShowLoading = true
    let httpObject = http.createHttp();
    let url =
      `https://van.mama.cn/hb/api/goodsAudio/getList?page=1&language=${language}&perpage=10&sign=&uid=`
    let res = await httpObject.request(url)
    this.bookAudioList = JSON.parse(res["result"] as string)["data"]["list"]
    this.isShowLoading = false
    httpObject.destroy();
  }

  // 生命周期钩子，创建时
  aboutToAppear(): void {
    this.getBookAudioList(0)
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

        // 确保播放器显示
        if (!this.currentPlayAudioItemState.isShowPlayBar) {
          this.currentPlayAudioItemState.isShowPlayBar = true;
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
            })
          Image(this.currentPlayAudioItem[0].cover_image).width(45).height(45).borderRadius(5)
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
              console.info('value:' + value + 'mode:' + mode.toString())
            })
            .selectedColor($r('sys.color.white'))
        }
        .width('50%')

        // 当前播放的时间
        // toFixed(0)将滑动条返回值处理为整数精度
        Text(`${Math.floor((Number(this.currentPlayAudioItem[0].time) - this.outSetValueOne) / 60)
          .toString()
          .padStart(2, '0')}:${((Number(this.currentPlayAudioItem[0].time) - this.outSetValueOne) % 60).toString()
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
              this.getBookAudioList(0)
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
              this.getBookAudioList(3)
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
        // 不展示加载库
        if (!this.isShowLoading) {
          ForEach(this.bookAudioList, (item: ESObject) => {
            ListItem() {
              Row() {
                // 音频书籍卡片
                BookItemCard({
                  bookAudioItem: [item],
                  widthValue: 80,
                  heightValue: 100,
                  ySpaceValue: 10
                })

                // 播放按钮
                this.PlayAudioButton(item)
              }
              .alignItems(VerticalAlign.Center)
            }
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

      if (this.currentPlayAudioItemState.isShowPlayBar) {
        this.PlayAudioBarCard()
      }
    }
    .width("100%")
    .height("100%")
    .alignItems(HorizontalAlign.Start)
  }
}