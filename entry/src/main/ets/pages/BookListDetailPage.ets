import { http } from '@kit.NetworkKit';
import router from '@ohos.router';
import BookItemCard from '../components/BookItemCard';
import { webview } from '@kit.ArkWeb';
import { LengthMetrics } from '@kit.ArkUI';
import LoadingItem from '../components/LoadingItem';

@Entry
@Component
struct BookListDetailPage {
  @State bookList: Array<ESObject> = []
  @State moreBookList: Array<ESObject> = []
  @State recommendList: Array<ESObject> = []
  @State currentIndex: number = 0
  @State page: number = 1
  //web组件控制器
  descWebController: webview.WebviewController = new webview.WebviewController()
  // scroller滚动控制器
  scroller: Scroller = new Scroller()
  // 更多绘本或推荐书单列表
  @State recommendGoodsList: Array<ESObject> = []
  // 更多绘本或推荐书单列表状态
  @State recommendGoodsListState: number = 1
  // 更多绘本或推荐书单列表的页数
  @State recommendGoodsListPage: number = 0
  // 控制是否显示加载组件
  @State isShowLoading: boolean = true

  //获取书籍标题信息
  async getBookList() {
    let params: ESObject = router.getParams() as ESObject;
    console.log("params.id:", params.id)
    //2.创建请求对象
    let httpObject = http.createHttp();
    //3.发出请求
    let url = "https://van.mama.cn/hb/api/goods/getGoodsDetail?goods_id=" + params.id
    //等待请求结果
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    //找到需要使用的集合
    let bookList: Array<ESObject> = res["data"];
    this.bookList.push(bookList);
  }

  // 获取更多绘本或推荐书单
  async getRecommendGoodsList() {
    let httpObject = http.createHttp();
    let url =
      `https://van.mama.cn/hb/api/goods/getRecommendGoodsList?goods_type=1&goods_position=${this.recommendGoodsListPage}&goods_own_type=${this.recommendGoodsListState}&attr_age_val_ids=671,672&perpage=10&sign=&uid=`
    let res = await httpObject.request(url)
    const recommendGoodsListRes: Array<ESObject> = JSON.parse(res["result"] as string)["data"]["list"]
    if (this.recommendGoodsListPage !== 0) {
      this.recommendGoodsList.push(...recommendGoodsListRes)
    } else {
      this.recommendGoodsList = recommendGoodsListRes
    }
    console.log("更多绘本或推荐书单", JSON.stringify(JSON.parse(res["result"] as string)["data"]["list"]))
    this.isShowLoading = false
    httpObject.destroy();
  }

  aboutToAppear(): void {
    this.getBookList()
    this.getRecommendGoodsList()
  }

  @Builder
  tabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontSize(this.currentIndex === targetIndex ? 22 : 20)
        .fontColor(this.currentIndex === targetIndex ? "#404040" : "#999999")
        .fontWeight(this.currentIndex === targetIndex ? 700 : 0)
        .borderWidth({ bottom: 5 })
        .borderColor(this.currentIndex === targetIndex ? "#5cd3b4" : "white")
        .padding({
          top: 8,
          bottom: 8,
          left: 12,
          right: 12
        })
    }
    .width("100%")
    .height(50)
  }

  build() {
    Scroll(this.scroller) {
      if (this.bookList.length == 1) {
        Column() {
          //标题
          Column({ space: 20 }) {
            Image(this.bookList[0].goods_img.toString()).width("85%")
            Text(this.bookList[0].goods_name.toString())
              .fontSize(22)
              .fontWeight(700)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .textAlign(TextAlign.Center)
              .width("80%")
            Row() {
              Text(this.bookList[0].label_list[0].label_name)
                .padding(5)
                .margin(5)
                .backgroundColor("#efefef")
                .fontSize(12)
                .fontColor("#666666")
              Text(this.bookList[0].label_list[1].label_name)
                .padding(5)
                .margin(5)
                .backgroundColor("#efefef")
                .fontColor("#666666")
                .fontSize(12)
            }
          }
          .width("100%")
          .height(350)
          .backgroundColor("white")
          .margin({ bottom: 15 })
          .padding(20)

          //书籍列表
          Column() {
            Text("书籍列表").fontSize("22").fontWeight(700).fontColor("#404040").margin(20)
            //书籍列表项
            List() {
              ForEach(this.bookList[0].son_list, (item: ESObject) => {
                ListItem() {
                  BookItemCard({
                    bookItem: [item],
                    widthValue: 100,
                    heightValue: 150,
                    descMaxLines: 2
                  })
                }.padding({ left: 20, right: 20 })
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

          }.width("100%").backgroundColor("white").alignItems(HorizontalAlign.Start)

          // 达人怎么说
          if (this.bookList[0].expert_speak_list[0]) {
            Column() {
              // 标题
              Text("达人怎么说").fontSize("22").fontWeight(700).fontColor("#404040").margin({ bottom: 20 })

              // 展示卡片
              Column({ space: 20 }) {
                // 头像
                Row({ space: 10 }) {
                  Image(this.bookList[0].expert_speak_list[0].avatar)
                    .width(40)
                    .height(40)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(50)
                  Column({ space: 3 }) {
                    Text() {
                      Span(`${this.bookList[0].expert_speak_list[0].name}  `)
                      ImageSpan("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAAAXNSR0IArs4c6QAABUpJREFUSA2VVk1MXFUUPvfNAKVIsSGaFkocrErUuGBBQkwqLlpNTGxJIF2wcG2MG/eNKxI3Jm6MujKmC6JNMbRpdIELGzY0jaFWasU2QEuh0XbKz1AGZt671++7fx3An3rmzXvnnnvO951z7n0zV8ljyMMrn3dXdNYvWh/ROm3XqW4TkwnGS0b0ojHZhDIy9nTfh1P/Baf+zaF07ctBXa0Ma627SGCyDBwgMhoXxjo8vS5mRpn01MGjH539J9y/JSz/drqzmmUjkqW9BEVVrEYMiDRIAyHtnLdj2JmETUjMZF6yoQNvfjy3kzjZaSjfGOlLtbmMyF7OGXwUPoa6gY4U+aTQbjPmkAq+yjn0plouL3z3QR/9amUbYfnGmT6dZuOAbGWgg3XuHFtwDGtJOcuknDNifDKwtEIdXzi/nTQSlufPdKJFo0Cti0yIqq0uJEBMW4nLxepujh3wacEA8jqjstH58+93eleJhFI1I6zMgbmEbSVgJ0TAYWDQQwJM0NqsIVj9UhhpRQiwnVjCrdnRQbTFrpkzgwLMIZS2UBVbRp3CRJyKu7u8lbM1YqT31th7g7TkecO7NOxWyK1b04vv0LxLss1lWb36lWXSntWR4o7ricJrsu+5N2Lc+sIleXCFjQODmGFMnE0q8+e6Me5iPfyEdsWoGiW3Z7+ouiZXrbf7YqW+pSDNh49G78rqoixPj7oxQbXpmj/3bncevxL9LkvOcZeJlG//gKy0qIb9sudATwShUtfcLtnmmvNlgtTqm6Tl5UEk67aErpalOHUaJHh/6aCZFrAz6U9AfsQNHS2TydYXJS3dkcr9afAiqEbyzYd8F9ymIFDLSwOSa2i2Xlzj5avfSFYu1kRBtfDZkcQY1c4ZttNZ3cO+d0gpXV/idJT8vkNWpzelqfC61D9ZsDpv63M/yub969DIAAmOVJW0JyihzU/ZzNlSOtkHbunabYZFyTdil+f2Ak5J/f7Dsrfj1Ti39WBWSjfHsSwexLPFd1OrNtd0H0LHsGmYBPW0tBABg1LfckiShn3S3PU2fFy62daarPzytS3M2WD3cy4BRKOfiagEfzG7JVSoK2vYJMvbHOrQwuYXTkiSb7R2/mivTGPdqhs1fkCwlcJEYqffxaYxiy5H+rpdatfP+9Gart7iI0rDU69gtx6M49LsuFRWF0JB0b7TgP/MRRY5ESpkIi4ZbCFkZO24VXesY2gjkTf/vCblO5fsmjLhbRKAWZ0Dn0CFaiy4WRJMco4391B2p5qssg2Lg3Tjvqz9fsGB0cAkCR7EAoQB3HJqLKkvnJgC8kz4aWP2NsYHsk5YdlXJBNauf4uXuuq2tAevrd62iPy2ApkpnPhiyu5SAJ5ywH5tEWyJHyW36/Uo3fw+vty2+bYwJusrdCQRAa08xYElbHj2JM4gajIm42OYISvnsLIyH8HKd3+SSnEmgj1KjsvBUiEIsom44eQz/Z/Zc058D1WdGoJLkQkyhiTuyZZCsg1c96RaWpKN2xdpsT5BsTwMilbG4WOkiAewnUTCxsLJuSRRAwDHopDR5hf87LpWir/K+o0L+HHCwQnCRCwH7+7yVs5ClFSV5AYKxz+dcwbf0jBofH7oYpLPHUNska0hIAVjW+3WHz+LSR/GyjnnfHDn5QNclxQw5FjH8U8u0i9IrDAYSJpPVA+CJoONOAQhMcUCOjXabIXeQSVqMp9IT8db28kY4nPy0TsePAibtDqMs2hX7QE4nE1rz6s8JON/HQfh7P8fhHfwyjKO+jgB9wPUHvXxh9pm/ye1WcLv6GJm0omcSh7rqP8Xqb+9ofyl6lUAAAAASUVORK5CYII=")
                        .width(18)
                    }
                    .fontSize(16)
                    .fontWeight(700)
                    .fontColor("#4d4d4d")

                    Text(this.bookList[0].expert_speak_list[0].user_title)
                      .fontSize(14)
                      .fontColor("#999999")
                  }
                  .alignItems(HorizontalAlign.Start)
                }

                // 标题
                Text(this.bookList[0].expert_speak_list[0].title)
                  .fontSize(18)
                  .fontWeight(700)
                  .fontColor("#404040")
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })

                // 富文本
                Web({
                  src: $rawfile("desc.html"),
                  controller: this.descWebController,
                  renderMode: RenderMode.SYNC_RENDER
                })
                  .layoutMode(WebLayoutMode.FIT_CONTENT)
                  .overScrollMode(OverScrollMode.NEVER)
                  .javaScriptAccess(true)
                  .javaScriptProxy({
                    //信息对象
                    object: {
                      getDescInfo: () => {
                        return this.bookList[0].expert_speak_list as Array<ESObject>
                      }
                    },
                    name: "app",
                    //白名单 在此配置的属性 才能被H5访问
                    methodList: ["getDescInfo"],
                    controller: this.descWebController
                  })
              }
              .alignItems(HorizontalAlign.Start)
              .width("100%")
              .padding(20)
              .borderRadius(5)
              .shadow({
                radius: 10,
                color: "#5ccbcbcb",
              })
              .backgroundColor("white")
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
            .backgroundColor("#fcfcfc")
          }

          //我要评论
          Column() {
            Text("我要评论").fontSize("22").fontWeight(700).margin(20)
            TextInput({ placeholder: '说两句吧~~' }).width("90%").margin({ left: 20, right: 20, bottom: 20 })
          }.alignItems(HorizontalAlign.Start).backgroundColor("white").margin({ top: 10 })

          // 更多绘本和推荐书单
          Column({ space: 15 }) {
            // 标题
            Row({ space: 20 }) {
              Column({ space: 5 }) {
                Text("更多绘本")
                  .fontSize("20")
                  .fontWeight(this.recommendGoodsListState === 1 ? 700 : 0)
                  .fontColor(this.recommendGoodsListState === 1 ? "#404040" : "#999999")
                Row().width(18).height(4).backgroundColor(this.recommendGoodsListState === 1 ? "#5cd3b4" : "white")
              }
              .width(100)
              .onClick(() => {
                this.recommendGoodsListPage = 0
                this.recommendGoodsListState = 1
                this.isShowLoading = true
                this.getRecommendGoodsList()
              })

              Column({ space: 5 }) {
                Text("推荐书单")
                  .fontSize("20")
                  .fontWeight(this.recommendGoodsListState === 2 ? 700 : 0)
                  .fontColor(this.recommendGoodsListState === 2 ? "#404040" : "#999999")
                Row().width(18).height(4).backgroundColor(this.recommendGoodsListState === 2 ? "#5cd3b4" : "white")
              }
              .width(100)
              .onClick(() => {
                this.recommendGoodsListPage = 0
                this.recommendGoodsListState = 2
                this.isShowLoading = true
                this.getRecommendGoodsList()
              })
            }
            .justifyContent(FlexAlign.Start)

            // 卡片列表：更多绘本
            if (this.recommendGoodsList?.length > 0 && this.recommendGoodsListState === 1) {
              Column() {
                Flex({
                  justifyContent: FlexAlign.Start, // Align items to the start (left) of the container
                  wrap: FlexWrap.Wrap,
                  space: {
                    main: LengthMetrics.vp(25), // Horizontal spacing between items
                    cross: LengthMetrics.vp(25) // Vertical spacing between items
                  }
                }) {
                  ForEach(this.recommendGoodsList, (item: ESObject) => {
                    Column({ space: 10 }) {
                      Stack() {
                        Column()
                          .width(20)
                          .height(120)
                          .linearGradient({
                            angle: 90,
                            colors: [["#b0a4a4a4", 0.0], ["#66989898", 0.5], ["#00ffffff", 1.0]]
                          })
                          .zIndex(999)
                        Image(item.goods_thumb)
                          .height(120)
                          .width(120 * 0.757)
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

                      Text(item.goods_name)
                        .width(120 * 0.757)
                        .textAlign(TextAlign.Center)
                        .fontSize(14)
                        .fontColor("#404040")
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
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
                .width(3 * 120 * 0.757 + 2 * 25)

                if (this.isShowLoading) {
                  Row() {
                    LoadingItem()
                  }
                }
              }
              .width("100%")
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }

            // 卡片列表：推荐书单
            if (this.recommendGoodsList?.length > 0 && this.recommendGoodsListState === 2) {
              Column() {
                Flex({
                  justifyContent: FlexAlign.Start, // Align items to the start (left) of the container
                  wrap: FlexWrap.Wrap,
                  space: {
                    main: LengthMetrics.vp(10), // Horizontal spacing between items
                    cross: LengthMetrics.vp(25) // Vertical spacing between items
                  }
                }) {
                  ForEach(this.recommendGoodsList, (item: ESObject) => {
                    Column({ space: 10 }) {
                      Text(item.goods_name)
                        .width(180 - 5 * 2)
                        .padding({ top: 15, left: 5, right: 5 })
                        .fontSize(16)
                        .fontColor("#404040")
                        .maxLines(1)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Image(item.goods_thumb)
                        .width(180 - 2 * 10)
                        .height((180 - 2 * 10) * 0.682)
                        .objectFit(ImageFit.Cover)
                        .padding({ left: 10, right: 10 })
                    }
                    .width(180)
                    .height(170)
                    .backgroundColor("#f6f6f6")
                    .borderRadius(5)
                    .onClick(() => {
                      router.pushUrl({
                        url: "pages/BookListDetailPage",
                        params: {
                          id: item.goods_id
                        }
                      })
                    })
                  })
                }
                .width(2 * 180 + 2 * 5)

                if (this.isShowLoading) {
                  Row() {
                    LoadingItem()
                  }
                }
              }
              .width("100%")
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
            }
          }
          .margin({ top: 10 })
          .padding({
            top: 15,
            bottom: 40,
            left: 20,
            right: 20
          })
          .alignItems(HorizontalAlign.Start)
          .width("100%")
          .backgroundColor("white")
        }.backgroundColor("#f7f7f7")

      }
    }
    .onWillScroll(() => {
      console.info('滚动到底', this.scroller.isAtEnd())
      if (this.scroller.isAtEnd()) {
        this.recommendGoodsListPage += 10
        this.isShowLoading = true
        this.getRecommendGoodsList()
      }
    })
  }
}