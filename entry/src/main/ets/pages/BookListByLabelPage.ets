import BookItemCard from '../components/BookItemCard';
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

  // 请求达人精选方法
  async getBookListByLabel() {
    let params: ESObject = router.getParams() as ESObject;
    let httpObject = http.createHttp();
    let url =
      "https://van.mama.cn/hb/api/goods/getTalentGoodsList?perpage=10&goods_type=1&goods_position=0&tag_id=" +
      params.id
    let res = await httpObject.request(url)
    this.bookListByLabel = JSON.parse(res["result"] as string)["data"]["list"]
    httpObject.destroy();
  }

  aboutToAppear(): void {
    this.getBookListByLabel()
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
      }
      .width("100%")
      .padding({ top: px2vp(this.topRectHeight), left: 20, right: 20 })
    }
  }
}