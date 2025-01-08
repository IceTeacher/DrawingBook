import SearchItem from '../components/SearchItem';
import { http } from '@kit.NetworkKit';
import router from '@ohos.router';
import BookListItemCard, { BookListItem } from '../components/BookListItemCard';
import { LengthMetrics } from '@kit.ArkUI';
import LoadingItem from '../components/LoadingItem';

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
  // 维护是否展示加载组件的状态
  @State isShowLoading: boolean = true
  @Prop marginFlag: boolean = true
  @State goods_position: number = 0 // 当前的页数
  @State canLoad: boolean = true // 控制可以加载

  // 请求达人书单方法
  async getNecessaryGoodsBookList(goods_position: number) {
    this.canLoad = false;
    let httpObject = http.createHttp();
    let url =
      `https://van.mama.cn/hb/api/goods/getNecessaryGoodsList?perpage=10&goods_type=1&goods_position=` +
        goods_position + `&sign=&uid=`
    let res = await httpObject.request(url)
    let necessaryGoodsBookList1: Array<ESObject> = JSON.parse(res["result"] as string)["data"]["list"]
    this.necessaryGoodsBookList.push(...necessaryGoodsBookList1)
    if (necessaryGoodsBookList1.length == 10 && this.goods_position < 5) {
      this.canLoad = true;
    } else {
      this.isShowLoading = false;
    }
    httpObject.destroy();
  }

  // 生命周期钩子，创建时
  aboutToAppear() {
    this.getNecessaryGoodsBookList(0)
  }

  build() {
    Column() {
      Row() {
        SearchItem()
      }
      .width("100%")
      .padding({ left: 20, right: 20 })

      List() {
        if (this.necessaryGoodsBookList.length) {
          ForEach(this.necessaryGoodsBookList, (item: BookListItem) => {
            ListItem() {
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
            }

          })
        }
        if (this.isShowLoading) {
          ListItem() {
            LoadingItem()
          }
          .padding(20)
        }

      }.padding({ left: 20, right: 20 })
      .width("100%")
      .height("85%")
      .onScrollIndex((start, end) => {
        console.log(start.toString(), end.toString())
        //触底条件
        if (end == ((this.goods_position + 1) * 10 - 1) && this.canLoad) {
          console.log("加载了")
          this.isShowLoading = true
          this.goods_position++;
          this.getNecessaryGoodsBookList(this.goods_position);
        }
      })

      Scroll() {
        Flex({ direction: FlexDirection.Column, space: { cross: LengthMetrics.vp(15) } }) {
          // ForEach(this.necessaryGoodsBookList, (item: BookListItem) => {
          //   Row() {
          //     BookListItemCard({
          //       cardWidthValue: "100%",
          //       cardHeightValue: 380,
          //       imageWidthValue: "95%",
          //       item
          //     })
          //   }
          //   .margin({ bottom: 20 })
          //   .onClick(() => {
          //     router.pushUrl({
          //       url: "pages/BookListDetailPage",
          //       params: {
          //         id: item.goods_id
          //       }
          //     })
          //   })
          // })
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