import { LengthMetrics } from '@kit.ArkUI';
import { http } from '@kit.NetworkKit';
import type { BookListItem } from '../components/BookListItemCard';
import BookListItemCard from '../components/BookListItemCard';

@Entry
@Component
export default struct HomePage {
  // 好书列表状态
  @State goodBookList: Array<ESObject> = []
  // 达人书单状态
  @State necessaryGoodsBookList: Array<ESObject> = []
  // 热门榜单状态
  @State homeLeaderBoardList: Array<ESObject> = []

  // 请求好书速递方法
  async getGoodBookList() {
    let httpObject = http.createHttp();
    let url = `https://van.mama.cn/hb/api/recommend/goodBookList?sign=&uid=`
    let res = await httpObject.request(url)
    this.goodBookList = JSON.parse(res["result"] as string)["data"]["single_list"]
    httpObject.destroy();
  }

  // 请求达人书单方法
  async getNecessaryGoodsBookList() {
    let httpObject = http.createHttp();
    let url =
      `https://van.mama.cn/hb/api/goods/getNecessaryGoodsList?perpage=10&goods_type=1&goods_position=0&sign=&uid=`
    let res = await httpObject.request(url)
    this.necessaryGoodsBookList = JSON.parse(res["result"] as string)["data"]["list"]
    httpObject.destroy();
  }

  // 请求热门榜单方法
  async getHomeLeaderBoardList() {
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/leaderboard/homeLeaderboard?sign=&uid="
    let res = await httpObject.request(url)
    this.homeLeaderBoardList = JSON.parse(res["result"] as string)["data"]["list"]
    // console.log("homeLeaderBoardList", JSON.stringify(this.homeLeaderBoardList))
    httpObject.destroy();
  }

  // 生命周期钩子，创建时
  aboutToAppear() {
    this.getGoodBookList()
    this.getNecessaryGoodsBookList()
    this.getHomeLeaderBoardList()
  }

  build() {
    Scroll() {
      Column() {
        // 好书速递
        Column() {
          // 模块顶部标题部分
          Row() {
            Text("好书速递")
              .fontSize(24)
              .fontWeight(700)
              .fontColor("#404040")
          }
          .padding({ left: 20, right: 20 })

          // 模块主体
          Scroll() {
            Flex({ wrap: FlexWrap.NoWrap, space: { main: LengthMetrics.vp(15) } }) {
              ForEach(this.goodBookList, (item: ESObject) => {
                Column() {
                  Row({ space: 10 }) {
                    Column() {
                      Image(item.goods_thumb)
                        .height(130)
                        .borderRadius({ topRight: 20 })
                    }

                    Column({ space: 15 }) {
                      Text(item.goods_name)
                        .width("70%")
                        .fontSize(18)
                        .fontWeight(700)
                        .fontColor("#40404")
                      Text(item.goods_desc)
                        .width("70%")
                        .fontSize(14)
                        .fontColor("#666")
                        .maxLines(3)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                    }
                    .width("85%")
                    .height("100%")
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Start)
                  }
                  .width("100%")
                }
                .width("85%")
                .height(165)
                .padding(15)
                .borderRadius(15)
                .borderStyle(BorderStyle.Solid)
                .borderWidth(1)
                .borderColor("#f4f4f4")
                .shadow({
                  radius: 25,
                  color: "#c9f6f6f6",
                  offsetX: 25,
                  offsetY: 25
                })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width("100%")
          .height(200)
          .padding({ left: 20 })
        }
        .width("100%")
        .alignItems(HorizontalAlign.Start)

        // 两行分类
        Column() {
          Text("两行分类")
        }
        .width("100%")
        .padding({ top: 20, bottom: 20, left: 20 })

        // 达人书单
        Column() {
          // 模块顶部标题部分
          Row({ space: 5 }) {
            Text("达人书单")
              .fontSize(24)
              .fontWeight(700)
              .fontColor("#404040")
            Text("200位阅读推广人联手推荐")
              .fontSize(14)
              .fontColor("#999999")
            Text("37个书单 >")
              .fontSize(14)
              .fontColor("#999999")
          }
          .width("100%")
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.SpaceBetween)

          // 模块主体
          Scroll() {
            Flex({ wrap: FlexWrap.NoWrap, space: { main: LengthMetrics.vp(15) } }) {
              ForEach(this.necessaryGoodsBookList, (item: BookListItem) => {
                BookListItemCard({ widthValue: "80%", item })
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width("100%")
          .padding({ top: 20, bottom: 20, left: 20 })
        }
        .width("100%")
        .alignItems(HorizontalAlign.Start)

        // 热门榜单
        Column() {
          // 模块顶部标题部分
          Row({ space: 5 }) {
            Text("热门榜单")
              .fontSize(24)
              .fontWeight(700)
              .fontColor("#404040")
            Text("详细榜单 >")
              .fontSize(14)
              .fontColor("#999999")
          }
          .width("100%")
          .padding({ left: 20, right: 20 })
          .justifyContent(FlexAlign.SpaceBetween)

          // 模块主体
          Scroll() {
            Flex({ wrap: FlexWrap.NoWrap, space: { main: LengthMetrics.vp(15) } }) {
              ForEach(this.homeLeaderBoardList, (item: ESObject) => {
                Column({ space: 25 }) {
                  Text(item.title)
                    .fontSize(18)
                    .fontWeight(700)
                    .fontColor("#404040")
                    .textAlign(TextAlign.Center)
                  Row() {
                    Flex({ alignContent: FlexAlign.Center, alignItems: ItemAlign.End }) {
                      Image(decodeURIComponent(item.gallery[1].image))
                        .height(80)
                      Image(decodeURIComponent(item.gallery[0].image))
                        .height(100)
                        .margin({ left: -15, right: -15 })
                        .zIndex(999)
                      Image(decodeURIComponent(item.gallery[2].image))
                        .height(80)
                    }
                    .width("100%")
                  }
                  .width("100%")
                }
                .backgroundColor("#f6f6f6")
                .width("50%")
                .padding(30)
                .borderRadius(15)
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width("100%")
          .padding({ top: 20, bottom: 20, left: 20 })
        }
        .width("100%")
        .alignItems(HorizontalAlign.Start)

        // 达人精选
        Column() {
          // 模块顶部标题部分
          Row({ space: 5 }) {
            Text("达人精选")
              .fontSize(24)
              .fontWeight(700)
              .fontColor("#404040")
            Text("8年绘本馆馆长精选绘本")
              .fontSize(14)
              .fontColor("#999999")
          }
          .width("100%")
          .padding({ left: 20, right: 20 })

          // 模块主体
          Column() {
            // 此处写列表结构
            Text("列表结构")
          }
          .width("100%")
          .padding({ top: 20, bottom: 20, left: 20 })
        }
        .width("100%")
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .backgroundColor("#FCFCFC")

    }
    .height('100%')
  }
}