import { http } from '@kit.NetworkKit';
import { LengthMetrics, router } from '@kit.ArkUI';
import BookItemCard from '../components/BookItemCard';

@Entry
@Component
struct RankListPage {
  // 设置沉浸式安全区域
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  @State tabArray: Array<string> = ["月总榜", "月上升榜"]
  @State currentIndex: number = 0
  @State labCategoryArray: Array<ESObject> = []
  @State labAgeArray: Array<ESObject> = []
  @State bookList: Array<ESObject> = []
  @State paramsArray: Array<string> = ["&", "&"]
  @State currentAgeIndex: number = 0
  @State currentCategoryIndex: number = 0
  // 临时参数用于储存tab类型0=总榜，1=月上升榜
  @State temp: number = 0
  // 滚动加载使用的变量
  @State page: number = 1 // 是否可以加载
  @State canLoad: boolean = true;

  @Builder
  tabBuilder(title: string, targetIndex: number) {

    Column({ space: 5 }) {
      Text(title)
        .fontSize(16)
        .fontWeight(this.currentIndex === targetIndex ? 800 : 500)
        .fontColor(this.currentIndex === targetIndex ? '#ff000000' : '#cdcdcd')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  aboutToAppear(): void {
    // 接收参数
    let params: ESObject = router.getParams() as ESObject;
    this.paramsArray[0] = (params.attr_val_id == 668 ? "&" : params.attr_val_id)
    this.paramsArray[1] = ""
    this.currentAgeIndex = params.attr_val_id - 669 + 1
    this.getCategoryLab();
    this.getBookList(this.page);
  }

  async getCategoryLab() {

    // 网络请求
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/category/getList?sign=&uid="
    let res = await httpObject.request(url, {
      header: {
        platformtype: "h5"
      }
    })
    res = JSON.parse(res["result"] as string);
    let labCategoryList: Array<ESObject> = res["data"]["category"];
    let labAgeArray: Array<ESObject> = res["data"]["age"];
    this.labCategoryArray.push(labCategoryList);
    this.labAgeArray.push(labAgeArray);
    this.labAgeArray[0].unshift({ "attr_val_id": "", "attr_name": "全部年龄" })
    this.labCategoryArray[0].unshift({ "category_id": "", "category_name": "全部类型" })
    console.log(JSON.stringify(this.labCategoryArray))
    console.log(JSON.stringify(this.labAgeArray))

  }

  async getBookList(page: number) {
    // 网络请求
    let httpObject = http.createHttp();
    let url =
      "http://van.mama.cn/hb/api/leaderboard/getList?category_id=" + this.paramsArray[1] +
        "&attr_val_id=" + this.paramsArray[0] + "&list_type=" + this.temp +
        "&page=" + page + "&perpage=10&sign=&uid="
    let res = await httpObject.request(url, {
      header: {
        platformtype: "h5"
      }
    })
    res = JSON.parse(res["result"] as string);
    let bookList: Array<ESObject> = res["data"]["list"];
    if (this.bookList.length == 1) {
      this.bookList[0] = this.bookList[0].concat(bookList)
    } else {
      this.bookList[0] = (bookList);
    }


    console.log(url + "this.paramsArray[0]:")
    console.log("Abc" + url)
    console.log(JSON.stringify(this.bookList) + "this.paramsArray[0]:")
  }

  build() {
    // 总页面
    Column() {
      // title标签
      Column() {
        // age
        Column() {
          Scroll() {
            Flex({ wrap: FlexWrap.NoWrap, space: { main: LengthMetrics.vp(15) } }) {
              ForEach(this.labAgeArray[0], (item: ESObject, index: number) => {
                ListItem() {
                  Column() {
                    Row({ space: 10 }) {
                      Column({ space: 15 }) {
                        Text(item.attr_name)
                          .width("100%")
                          .fontSize(12)
                          .padding(6)
                          .textAlign(TextAlign.Center)
                          .fontWeight(400)
                          .borderRadius(10)
                          .fontColor(index == this.currentAgeIndex ? "#5fc6c9" : "#808080")
                          .backgroundColor(index == this.currentAgeIndex ? "#eefaf7" : "#fff")
                          .onClick(() => {
                            if (index != this.currentAgeIndex) {
                              this.page = 1
                              this.currentAgeIndex = index
                              if (index != 0) {
                                this.paramsArray[0] = item.attr_val_id
                                console.log("Abc" + this.paramsArray[0])
                              } else {
                                this.paramsArray[0] = "&"
                              }
                              this.bookList = []
                              this.getBookList(1)
                            }
                          })
                      }
                      .width("24%")
                      .height("20")
                      .alignItems(HorizontalAlign.Start)
                      .justifyContent(FlexAlign.Start)
                    }
                  }
                }

              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width("100%")
          .height(30)
          .padding({ left: 20 })
        }
        .width("100%")
        .alignItems(HorizontalAlign.Start)

        // 分类
        Column() {
          Scroll() {
            Flex({ wrap: FlexWrap.NoWrap, space: { main: LengthMetrics.vp(15) } }) {
              ForEach(this.labCategoryArray[0], (item: ESObject, index: number) => {
                Column() {
                  Row({ space: 10 }) {
                    Column({ space: 15 }) {
                      Text(item.category_name)
                        .width("100%")
                        .fontSize(12)
                        .padding(6)
                        .textAlign(TextAlign.Center)
                        .fontWeight(400)
                        .borderRadius(10)
                        .fontColor(index == this.currentCategoryIndex ? "#5fc6c9" : "#808080")
                        .backgroundColor(index == this.currentCategoryIndex ? "#eefaf7" : "#fff")
                        .onClick(() => {
                          if (index != this.currentCategoryIndex) {
                            this.page = 1
                            this.currentCategoryIndex = index
                            if (index != 0) {
                              this.paramsArray[1] = item.category_id
                              console.log("Abc" + this.paramsArray[1])
                            } else {
                              this.paramsArray[1] = "&"
                            }
                            this.bookList = []
                            this.getBookList(1)
                          }
                        })
                    }
                    .width("24%")
                    .height("20")
                    .alignItems(HorizontalAlign.Start)
                    .justifyContent(FlexAlign.Start)
                  }
                }
              })
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .width("100%")
          .height(30)
          .padding({ left: 20 })
        }
        .width("100%")
        .alignItems(HorizontalAlign.Start)

      }.width("100%")
      .height(80)

      // 按钮切换榜单
      Row() {
        ForEach(this.tabArray, (item: string, index: number) => {
          Column() {
            Button(item).onClick((event: ClickEvent) => {
              if (index != this.temp) {
                this.page = 1
                this.temp = index;
                this.bookList = []
                this.getBookList(1)
              }
            }).fontColor(index == this.temp ? "#404040" : "#aaaaaa")
              .backgroundColor("#fff")
            Text()
              .height(5)
              .width("8%")
              .backgroundColor(index == this.temp ? "#5cd3b4" : "#fff")
          }
        })
      }.margin({ bottom: 10 })

      // 分页
      Column() {
        Column() {
          List() {
            ForEach(this.bookList[0], (item: ESObject, index: number) => {
              ListItem() {
                Row() {
                  Text((index + 1 < 10 ? "0" : "") + (index + 1).toString())
                    .fontColor(index + 1 < 4 ? "#d9b964" : "#9da2ab")
                    .fontSize(18)
                    .fontWeight(700)
                  Column() {
                    BookItemCard({
                      bookRankItem: [item],
                      ySpaceValue: 8,
                      widthValue: 80,
                      heightValue: 110,
                      bookTitleFontSize: 14,
                      bookTitleLineHeightSize: 16
                    }).onClick(() => {
                      router.pushUrl({
                        url: "pages/BookDetailPage",
                        params: {
                          goods_id: item.goods_id
                        }
                      })
                    })
                  }
                  .width("90%")
                  .height(110)
                }
                .width("100%")
                .height(130)
                .padding({ left: 20, right: 20 })
              }
            })
          }.onScrollIndex((start, end) => {
            console.log("ABC  this.page:" + this.page)
            console.log("ABC  page:" + start.toString(), end.toString())
            //触底条件
            if (end >= this.page * 8) {
              this.page++;
              console.log("ABC  this.page:" + this.page)
              this.getBookList(this.page);
            }
          })

        }
      }
    }
    .padding({ top: px2vp(this.topRectHeight) })

  }
}