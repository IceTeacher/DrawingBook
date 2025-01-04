import { http } from '@kit.NetworkKit';

@Entry
@Component
export default struct EnglishPage {
  @State currentIndex: number = 0
  @State BookList: Array<ESObject> = []

  //请求英语故事
  async getEngListen() {
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/goodsAudio/getList?language=3"
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    let BookList: Array<ESObject> = res["data"]["list"];
    console.log(BookList[0].title)
    this.BookList = BookList;
    console.log("123")
  }

  aboutToAppear(): void {
    this.getEngListen()
  }

  build() {
    Scroll() {
      Column() {
        ForEach(this.BookList, (item: ESObject) => {
          Row() {
            Text(item.title)
          }
          .width("90%")
          .height(120)
          .borderWidth(1)
          .borderColor("#5cd3b4")
          .margin(15)
        })
      }
    }
  }
}