import SearchItem from '../components/SearchItem';
import { http } from '@kit.NetworkKit';
import router from '@ohos.router';
import BookListItemCard, { BookListItem } from '../components/BookListItemCard';
import { LengthMetrics } from '@kit.ArkUI';

@Entry
@Component
export default struct FindBookListPage {
  // 设置沉浸式安全区域
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  // 达人书单状态
  @State necessaryGoodsBookList: Array<ESObject> = []
  @Prop marginFlag: boolean = true

  // 请求达人书单方法
  async getNecessaryGoodsBookList() {
    let httpObject = http.createHttp();
    let url =
      `https://van.mama.cn/hb/api/goods/getNecessaryGoodsList?perpage=10&goods_type=1&goods_position=0&sign=&uid=`
    let res = await httpObject.request(url)
    this.necessaryGoodsBookList = JSON.parse(res["result"] as string)["data"]["list"]
    httpObject.destroy();
  }

  // 生命周期钩子，创建时
  aboutToAppear() {
    this.getNecessaryGoodsBookList()
  }

  build() {
    Column() {
      Row() {
        SearchItem()
      }
      .width("100%")
      .padding({ left: 20, right: 20 })

      Scroll() {
        Flex({ direction: FlexDirection.Column, space: { cross: LengthMetrics.vp(15) } }) {
          ForEach(this.necessaryGoodsBookList, (item: BookListItem) => {
            Row() {
              BookListItemCard({
                cardWidthValue: "100%",
                cardHeightValue: 380,
                imageWidthValue: "95%",
                item
              })
            }
            .margin({ bottom: 20 })
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
      }
      .height("100%")
      .padding(20)
    }
    .height('100%')
    .width('100%')
    .padding(this.marginFlag ? { top: px2vp(this.topRectHeight), bottom: px2vp(this.bottomRectHeight) } : "")
  }
}