import { LengthMetrics, router } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import BookItemCard from '../components/BookItemCard';
import BookListItemCard from '../components/BookListItemCard';

@Entry
@Component
struct UserProfilePage {
  // 达人id
  @State masterId: String = ""
  // 用户信息
  @State userInfo: Array<ESObject> = []
  // 书单信息
  @State bookList: Array<ESObject> = []
  // 书单数量
  @State bookListCount: string = ""
  // 绘本信息
  @State bookItem: Array<ESObject> = []
  // 绘本数量
  @State bookItemCount: string = ""
  @State testArr: Array<ESObject> = []
  // 控制简介是否展开
  @State controlShow: boolean = false
  @State controlMaxLine: number = 2

  aboutToAppear(): void {
    let params: ESObject = router.getParams() as ESObject;
    this.masterId = params.masterId
    console.log("masterId:  ", this.masterId)
    this.getUserInfo()
    // this.getBookListInfo()

    this.getTest()
    // getBookItemInfo
    this.getTest2()
  }

  // 请求Test
  async getTest() {
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/goods/getGoodsListByExpert?expert_id=" + this.masterId +
      "&goods_own_type=2&page=1&perpage=10&sign=&uid="
    let res = await httpObject.request(url)
    this.bookList = JSON.parse(res["result"] as string)["data"]["list"]
    this.bookListCount = JSON.parse(res["result"] as string)["data"]["total"];
    httpObject.destroy();
  }

  // 请求Test
  async getTest2() {
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/goods/getGoodsListByExpert?expert_id=" + this.masterId +
      "&goods_own_type=1&page=1&perpage=10&sign=&uid="
    let res = await httpObject.request(url)
    this.bookItem = JSON.parse(res["result"] as string)["data"]["list"]
    this.bookItemCount = JSON.parse(res["result"] as string)["data"]["total"];
    httpObject.destroy();
  }

  async getUserInfo() {
    //2.创建请求对象
    let httpObject = http.createHttp();
    //3.发出请求
    let url = "https://van.mama.cn/hb/api/expert/getInfo?id=" + this.masterId + "&sign=&uid="
    //等待请求结果
    let res = await httpObject.request(url, {
      header: {
        platformtype: "h5"
      }
    })
    res = JSON.parse(res["result"] as string);
    //找到需要使用的集合
    let userInfo: Array<ESObject> = res["data"];
    this.userInfo.push(userInfo);
    console.log("用户信息：" + JSON.stringify(this.userInfo))
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          if (this.userInfo.length != 0) {
            Column() {
              // header
              Row() {
                Stack() {
                  // avatar
                  Image(this.userInfo[0].avatar)
                    .width(60)
                    .height(60)
                    .borderRadius(40)
                    .shadow({
                      radius: vp2px(5),
                      color: "#958f8f8f",
                      fill: true
                    })
                  Image($r("app.media.userV"))
                    .width(35)
                    .height(35)
                    .margin({ right: -42, bottom: -40 })
                }

                Column() {
                  // "name": "宸瑄",
                  Text(this.userInfo[0].name)
                    .margin(4)
                    .width("55%")
                    .fontSize(20)
                    .fontColor("#ff000000")
                    .fontWeight(700)
                  Text(this.userInfo[0].user_title)
                    .margin(4)
                    .width("55%")
                    .fontSize(16)
                    .fontColor("#939499")
                }.alignItems(HorizontalAlign.Start)
                .margin({ left: 15 })
                .height(65)

                Button("关注")
                  .width(75)
                  .height(30)
                  .fontSize(13)
                  .backgroundColor("#ff7b68")
                  .onClick(() => {
                    router.pushUrl({
                      url: "pages/LoginPage"
                    })
                  })
              }.margin({ bottom: 4 })


              Text(this.userInfo[0].introduction)
                .maxLines(this.controlMaxLine)
                .textOverflow(!this.controlShow ? { overflow: TextOverflow.Ellipsis } : { overflow: TextOverflow.None })
              Row() {
                Text(!this.controlShow ? "展开" : "收回")
                  .fontColor("#ff2adbdb")
                Text("\ue645") {
                }
                .fontSize(20)
                .rotate({
                  x: 0,
                  y: 0,
                  z: 1,
                  angle: !this.controlShow ? 180 : 0
                })
                .fontFamily("iconfont")
                .fontColor("#ff2adbdb")
                .fontSize(10)
                .height(20)
                .padding(2)
              }
              .onClick(() => {
                this.controlShow = !this.controlShow
                this.controlMaxLine = !this.controlShow ? 2 : 100
              })

            }
            // .height(170)
            .width("100%")
            .padding(10)
            .alignItems(HorizontalAlign.Start)

            // TA推荐的书单
            if (this.bookList.length > 0) {
              Column() {
                Row() {
                  Text() {
                    Span("TA推荐的书单")
                      .fontSize(20)
                      .fontWeight(700)
                    Span("  (" + this.bookListCount + "个书单)")
                      .fontSize(12)
                      .fontWeight(600)
                      .fontColor("#999")
                  }.margin(10)
                }

                Scroll() {
                  Flex({ wrap: FlexWrap.NoWrap, space: { main: LengthMetrics.vp(15) } }) {
                    ForEach(this.bookList, (item: ESObject) => {
                      BookListItemCard({
                        cardWidthValue: "80%",
                        cardHeightValue: 320,
                        imageWidthValue: "90%",
                        item
                      }).onClick(() => {
                        router.pushUrl({
                          url: "pages/BookListDetailPage",
                          params: {
                            id: item.goods_id
                          }
                        })
                      })
                    })
                  }
                }
                .scrollable(ScrollDirection.Horizontal)
                .scrollBar(BarState.Off)
                .width("100%")
                .padding({ top: 10, bottom: 20, left: 10 })
              }
              // .height(380)
              .width("100%")
              .alignItems(HorizontalAlign.Start)

            }
            // TA推荐的绘本
            if (this.bookItem.length > 0) {
              Column() {
                Row() {
                  Text() {
                    Span("TA推荐的绘本")
                      .fontSize(20)
                      .fontWeight(700)
                    Span("  (" + this.bookItemCount + "本绘本)")
                      .fontSize(12)
                      .fontWeight(600)
                      .fontColor("#999")
                  }.margin(10)
                }

                // TA推荐的绘本
                Column() {
                  ForEach(this.bookItem, (item: ESObject) => {
                    BookItemCard({ bookItem: [item], descMaxLines: 3 })
                  })
                }
                .width("100%")
                .padding({ top: 20, bottom: 20, left: 20 })
              }
              .width("100%")
              .alignItems(HorizontalAlign.Start)
            }
          }
          if (this.bookItem.length == 0 && this.bookList.length == 0) {
            Column() {
              Text("-----这是一个神秘的人-----")
                .fontSize(12)
                .fontWeight(600)
                .fontColor("#ff7e7c7c")
                .textAlign(TextAlign.Center)
                .margin({ top: 30 })
                .width(300)
            }.alignItems(HorizontalAlign.Start)
            .width("100%")
          }
        }.alignItems(HorizontalAlign.Start)
      }
      .margin({ top: 30 })

    }

  }
}