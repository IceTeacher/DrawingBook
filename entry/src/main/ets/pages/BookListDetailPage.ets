import { http } from '@kit.NetworkKit';
import router from '@ohos.router';
import BookItemCard from '../components/BookItemCard';

@Entry
@Component
struct BookListDetailPage {
  @State bookList: Array<ESObject> = []
  @State moreBookList: Array<ESObject> = []
  @State recommendList: Array<ESObject> = []
  @State currentIndex: number = 0
  @State page: number = 1

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

  //获取书籍推荐列表
  async getBookMoreList(types: number, page: number) {
    let httpObject = http.createHttp();
    let url =
      "https://van.mama.cn/hb/api/goods/getRecommendGoodsList?goods_type=1&goods_position=" + page +
        "&goods_own_type=" + types + "&attr_age_val_ids=670,671,672,673&perpage=10"
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    let moreBookList: Array<ESObject> = res["data"]["list"];
    this.moreBookList.push(...moreBookList);
  }

  async getBookRecommendList(types: number, page: number) {
    let httpObject = http.createHttp();
    let url =
      "https://van.mama.cn/hb/api/goods/getRecommendGoodsList?goods_type=1&goods_position=" + page +
        "&goods_own_type=" + types + "&attr_age_val_ids=670,671,672,673&perpage=10"
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    let recommendList: Array<ESObject> = res["data"]["list"];
    this.recommendList.push(...recommendList);
  }

  aboutToAppear(): void {
    this.getBookList()
    this.getBookMoreList(1, this.page)
    this.getBookRecommendList(2, this.page)
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
    Scroll() {
      if (this.bookList.length == 1) {
        List() {
          //标题
          ListItem() {
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
          }


          //书籍列表
          ListItem() {
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
          }


          //达人怎么说
          ListItem() {
            Column() {
              Text("达人怎么说").fontSize("22").fontWeight(700).fontColor("#404040").margin(20)
              // Column() {
              // }
              // .height(150)
              // .width("80%")
              // .shadow({
              //   radius: 10,
              //   color: Color.Gray,
              //   offsetX: 10,
              //   offsetY: 10
              // })
            }
            .backgroundColor("#fcfcfc")
            .alignItems(HorizontalAlign.Start)
            .height(200)
            .width("100%")
            .margin({ top: 10 })
          }


          //我要评论
          ListItem() {
            Column() {
              Text("我要评论").fontSize("22").fontWeight(700).margin(20)
              TextInput({ placeholder: '说两句吧~~' }).width("90%").margin({ left: 20, right: 20, bottom: 20 })
            }.alignItems(HorizontalAlign.Start).backgroundColor("white").margin({ top: 10 })

          }


          //更多、推荐
          ListItem() {
            Tabs({ barPosition: BarPosition.Start }) {
              TabContent() {
                List() {
                  ForEach(this.moreBookList, (item: ESObject) => {
                    ListItem() {
                      Column() {
                        //图片
                        Stack() {
                          Column()
                            .width(20)
                            .height(150)
                            .linearGradient({
                              angle: 90,
                              colors: [["#b0a4a4a4", 0.0], ["#66989898", 0.5], ["#00ffffff", 1.0]]
                            })
                            .zIndex(999)
                          Image(item.goods_thumb)
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

                        Text(item.goods_name)
                          .textAlign(TextAlign.Center)
                          .width("100%")
                          .fontSize(18)
                          .fontWeight(700)
                          .maxLines(1)
                          .margin({ top: 10 })
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      .width("95%")
                      .backgroundColor("#f6f6f6")
                      .borderRadius(10)
                      .margin(10)
                      .padding(10)
                    }
                  })
                }.lanes(2)
                .onScrollIndex((start, end) => {
                  if (end == this.page * 10 - 1) {
                    this.page++;
                    this.getBookMoreList(1, this.page)
                  }
                  console.log(start.toString(), end.toString())
                })
              }.tabBar(this.tabBuilder("更多绘本", 0))

              TabContent() {
                List() {
                  ForEach(this.recommendList, (item: ESObject) => {
                    ListItem() {
                      Column() {
                        //图片
                        Stack() {
                          Column()
                            .width(20)
                            .height(150)
                            .linearGradient({
                              angle: 90,
                              colors: [["#b0a4a4a4", 0.0], ["#66989898", 0.5], ["#00ffffff", 1.0]]
                            })
                            .zIndex(999)
                          Image(item.goods_thumb)
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

                        Text(item.goods_name)
                          .width("100%")
                          .fontSize(18)
                          .fontWeight(700)
                          .maxLines(1)
                          .margin({ top: 10 })
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                      }
                      .width("95%")
                      .backgroundColor("#f6f6f6")
                      .borderRadius(10)
                      .margin(10)
                      .padding(10)
                    }
                  })
                }.lanes(2)
                .onScrollIndex((start, end) => {
                  if (end == this.page * 10 - 1) {
                    this.page++;
                    this.getBookRecommendList(2, this.page)
                  }
                  console.log(start.toString(), end.toString())
                })
              }.tabBar(this.tabBuilder("推荐书单", 1))
            }
            .padding(20)
            .backgroundColor("white")
            .margin({ top: 10 })
            .onChange((index) => {
              this.currentIndex = index
            })
          }

        }.backgroundColor("#f7f7f7")

      }
    }
  }
}