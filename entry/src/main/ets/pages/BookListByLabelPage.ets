import BookItemCard from '../components/BookItemCard';
import LoadingItemPage from '../components/LoadingItem';
import { http } from '@kit.NetworkKit';
import router from '@ohos.router';

@Entry
@Component
struct BookListByLabelPage {
  // 设置沉浸式安全区域
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  @State bookListByLabel: Array<string> = []
  @State page: number = 1
  @State canLoad: boolean = true
  @State url: string = ""

  // 请求达人精选方法
  async getBookListByLabel(page: number) {
    this.canLoad = false
    let params: ESObject = router.getParams() as ESObject;
    let httpObject = http.createHttp();
    if (params.id < 674) {
      this.url =
        "https://van.mama.cn/hb/api/goods/getTalentGoodsList?perpage=10&goods_type=1&goods_position=" +
          (page * 10 - 1) + "&attr_val_id=" +
        params.id
    } else {
      this.url = "https://van.mama.cn/hb/api/goods/getTalentGoodsList?perpage=10&goods_type=1&goods_position=" +
        (page * 10 - 1) + "&tag_id=" +
      params.id
    }

    let res = await httpObject.request(this.url)
    res = JSON.parse(res["result"] as string)
    let bookList: Array<ESObject> = res["data"]["list"]
    this.bookListByLabel.push(...bookList)
    this.canLoad = true
    // httpObject.destroy();
  }

  aboutToAppear(): void {
    this.getBookListByLabel(1)
  }

  build() {
    Column() {
      // 模块主体
      List() {
        ForEach(this.bookListByLabel, (item: ESObject) => {
          ListItem() {
            BookItemCard({
              bookItem: [item],
              descMaxLines: 3,
              isShowAvatar: false,
              isShowLabel: true
            })
          }.onClick(() => {
            router.pushUrl({
              url: "pages/BookDetailPage",
              params: {
                id: item.goods_id
              }
            })
          })
        })
        ListItem() {
          LoadingItemPage()
        }
      }
      .width("100%")
      .padding({ top: px2vp(this.topRectHeight), left: 20, right: 20 })
      .onScrollIndex((start, end) => {
        console.log("start,end:", start, end)
        if (end == this.page * 10 - 1 && this.canLoad) {
          this.page++
          this.getBookListByLabel(this.page)
        }
      })
    }
  }
}