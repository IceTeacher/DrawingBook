import { http } from '@kit.NetworkKit';
import router from '@ohos.router';
import { media } from '@kit.MediaKit';
import { LengthMetrics } from '@kit.ArkUI';

// 当前播放内容的状态记录的类型
interface CurrentPlayAudioItemState {
  index: string,
  playMode: boolean,
  isShowPlayBar: boolean
}

@Entry
@Component
struct BookDetailPage {
  // 设置沉浸式安全区域
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  @State bookDetail: Array<ESObject> = []
  @State bookRecommend: Array<ESObject> = []
  @State flag: number = 1
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

  //获取书籍推荐列表
  async getBookDetail() {
    let params: ESObject = router.getParams() as ESObject;
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/goods/getGoodsDetail?goods_id=" + params.id
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    let bookDetail: Array<ESObject> = res["data"];
    this.bookDetail.push(bookDetail);
  }

  //获取书籍推荐列表
  async getBookRecommend() {
    let params: ESObject = router.getParams() as ESObject;
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/comment/getList?goods_id=" + params.id + "&perpage=10"
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    let bookRecommend: Array<ESObject> = res["data"]["list"];
    this.bookRecommend = bookRecommend;
  }

  // 生命周期钩子，页面创建时，build构建前
  aboutToAppear(): void {
    this.getBookDetail()
    this.getBookRecommend()
  }

  // 生命周期钩子，返回按钮触发时
  onBackPress() {
    // 销毁音频对象
    this.avPlayer?.pause()
    this.avPlayer?.release()
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
          // 销毁音频对象
          this.avPlayer?.pause()
          this.avPlayer?.release()
          break;
        default:
          console.info('AVPlayer state unknown called.');
          break;
      }
    });
    //监听时长变化事件
    avPlayer.on("timeUpdate", () => {
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
    });
  }

  // 播放器子组件
  @Builder
  PlayAudioBarCard() {
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
    .position({ x: '4%', y: '80%' })
    .borderRadius(15)
    .shadow({
      radius: vp2px(5),
      color: "#958f8f8f",
      fill: true
    })
  }

  build() {
    Stack() {
      Scroll() {
        Column() {
          if (this.bookDetail.length == 1) {
            //顶部标题
            Row({ space: 20 }) {
              //图片
              Stack({ alignContent: Alignment.Center }) {
                Stack() {
                  Column()
                    .width(20)
                    .height(150)
                    .linearGradient({
                      angle: 90,
                      colors: [["#b0a4a4a4", 0.0], ["#66989898", 0.5], ["#00ffffff", 1.0]]
                    })
                    .zIndex(999)
                  Image(this.bookDetail[0].goods_img)
                    .height(150)
                    .borderRadius({ topRight: 20 })
                    .borderStyle(BorderStyle.Solid)
                    .borderWidth(1)
                    .borderColor("#f4f4f4")
                    .shadow({
                      radius: vp2px(10),
                      color: "#688f8f8f",
                      offsetX: 15,
                      offsetY: 15,
                      fill: true
                    })
                }
                .alignContent(Alignment.Start)

                if (this.bookDetail[0].audio_list[0]) {
                  Row() {
                    Text(this.currentPlayAudioItemState.playMode ? "\uE687" : "\uE686")
                      .fontFamily("iconfont")
                      .fontColor(this.currentPlayAudioItemState.playMode ? "#5cd3b4" : "#ff7b68")
                      .fontSize(40)
                      .lineHeight(40)
                      .position({ y: 1 })
                  }
                  .justifyContent(FlexAlign.Center)
                  .alignItems(VerticalAlign.Center)
                  .width(40)
                  .height(40)
                  .backgroundColor("white")
                  .borderRadius(100)
                  .onClick(() => {
                    const item: Array<ESObject> = this.bookDetail[0].audio_list[0]
                    if (this.currentPlayAudioItemState.index === item["id"]) {
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
                        this.createAvPlayer(item["video_url"])
                      }
                    } else {
                      // 如果点击的是其他音频，切换到新的音频
                      this.currentPlayAudioItemState = {
                        index: item["id"],
                        playMode: true, // 播放新音频时，设置为播放状态
                        isShowPlayBar: true // 播放器显示
                      };
                      // 记录当前播放的音频项
                      this.currentPlayAudioItem = [item];
                      // 播放音频
                      this.createAvPlayer(item["video_url"])
                    }
                  });
                }
              }

              //右
              Column({ space: 12 }) {
                Text(this.bookDetail[0].goods_name)
                  .fontSize(18)
                  .fontWeight(700)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
                  ForEach(this.bookDetail[0].label_list, (item: ESObject) => {
                    Text(item.label_name)
                      .padding(5)
                      .margin(3)
                      .fontSize(12)
                      .borderRadius(10)
                      .backgroundColor("#fff4f2")
                      .fontColor("#ff5c38")
                  })
                }

                Column({ space: 8 }) {
                  Row() {
                    Text("作者").width(60).fontColor("#404040").fontSize(12)
                    Text(this.bookDetail[0].author)
                      .fontColor("#808080")
                      .fontSize(12)
                      .width("60%")
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.alignItems(VerticalAlign.Top).width("100%")

                  Row() {
                    Text("出版社").width(60).fontColor("#404040").fontSize(12)
                    Text(this.bookDetail[0].press_name).fontColor("#808080").fontSize(12)
                  }.alignItems(VerticalAlign.Top).width("100%")
                }

                Row() {
                  Text("购买实体绘本").fontColor("#666666").fontSize(12)
                }.backgroundColor("#f5f5f5").padding(10).borderRadius(20).margin({ bottom: 20 })

              }
              .width("60%")
              .alignItems(HorizontalAlign.Start)
              .justifyContent(FlexAlign.Start)
            }
            .width("100%")
            .alignItems(VerticalAlign.Top)
            .backgroundColor("white")
            .padding({ top: px2vp(this.topRectHeight), left: 20, right: 20 })


            //评分
            Row({ space: 20 }) {
              Image("data:image/png;base64,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")
                .height(43).width("22%")
              Column({ space: 10 }) {
                ForEach(this.bookDetail[0].goods_ability_list, (item: ESObject) => {
                  Row({ space: 8 }) {
                    Text(item.title)
                      .width(80)
                      .fontColor("#808080")
                      .fontSize(12)
                    Progress({ value: Number(item.score), total: 5 }).color("#ffd566")
                      .width("65%")
                    Text(item.score).fontSize(12)
                  }
                })
              }.width("60%")
            }
            .margin({ top: 10 })
            .padding(20)
            .width("100%")
            .backgroundColor("white")
            .borderWidth({ top: 1 })
            .borderColor("#efefef")

            //听故事
            if (this.bookDetail[0].audio_list[0]) {
              Column() {
                Text("听故事").fontSize("18").fontWeight(700).fontColor("#404040").margin({ bottom: 15 })
                Row({ space: 5 }) {
                  // 作者头像
                  Image(this.bookDetail[0].audio_list[0].expert_info.avatar)
                    .width(40)
                    .height(40)
                    .borderRadius(50)
                  Column({ space: 5 }) {
                    // 标题
                    Text(this.bookDetail[0].goods_name)
                      .fontSize(15)
                      .fontColor("#4d4d4d")
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    // 音频、播放量展示区域
                    Row({ space: 20 }) {
                      Row({ space: 5 }) {
                        Text("\ue6b4")
                          .fontFamily("iconfont")
                          .fontSize(14)
                          .fontColor("#999999")
                        Text(`${Math.floor(Number(this.bookDetail[0].audio_list[0].time) /
                          60)}:${Number(this.bookDetail[0].audio_list[0].time) %
                          60}`)
                          .fontSize(14)
                          .fontColor("#999999")
                      }

                      Row({ space: 5 }) {
                        Text("\ue6b5")
                          .fontFamily("iconfont")
                          .fontSize(14)
                          .fontColor("#999999")
                        Text(`${this.bookDetail[0].audio_list[0].play_num}`)
                          .fontSize(14)
                          .fontColor("#999999")
                      }
                    }
                  }
                  .width("70%")
                  .alignItems(HorizontalAlign.Start)

                  // 播放按钮
                  this.PlayAudioButton(this.bookDetail[0].audio_list[0])
                }
              }
              .margin({ top: 10 })
              .padding({
                top: 15,
                bottom: 15,
                left: 20,
                right: 20
              })
              .alignItems(HorizontalAlign.Start)
              .width("100%")
              .backgroundColor("white")
            }

            //评论
            Column() {
              Text("读过的用户怎么说").fontSize("18").fontWeight(700).fontColor("#404040")
              ForEach(this.bookRecommend, (item: ESObject, index) => {
                if (index < 5) {
                  Column() {
                    Row({ space: 10 }) {
                      Image(item.user_info.avatar).width(35).height(35).objectFit(ImageFit.Cover).borderRadius(50)
                      Column() {
                        Text(item.user_info.username).fontWeight(700).fontSize(16)
                        Text(item.user_info.birthday_title).fontColor("#999999").fontSize(14)
                        Text(item.message).fontColor("#666666").fontSize(14).margin({ top: 20 })
                        Row({ space: 140 }) {
                          Text(item.show_time).fontColor("#999999").fontSize(14)
                          Text("回复").fontColor("#999999").fontSize(14)
                        }.margin({ top: 15 })
                      }
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.Center)
                    }
                    .alignItems(VerticalAlign.Top)
                  }.height(150).borderWidth({ bottom: 1 }).borderColor("#f8f8f8").padding({ top: 15 })
                }
                if (index >= 5) {
                  Row() {
                    Text("展示更多评论....").fontColor("#5cd3b4")
                  }
                  .onClick(() => {
                    router.pushUrl({
                      url: "pages/MoreCommentPage"
                    })
                  })
                }
              })

            }
            .margin({ top: 10 })
            .width("100%")
            .backgroundColor("white")
            .alignItems(HorizontalAlign.Start)
            .padding({
              top: 15,
              bottom: 15,
              left: 20,
              right: 20
            })

          }
        }
      }

      if (this.currentPlayAudioItemState.isShowPlayBar) {
        this.PlayAudioBarCard()
      }
    }
    .alignContent(Alignment.Center)
    .backgroundColor("#f7f7f7")
  }
}