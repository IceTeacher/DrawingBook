import { http } from '@kit.NetworkKit';
import avatarCard from './AvatarCard';

@Component
export default struct BookItemCard {
  // BookItemCard
  @State BookList: Array<ESObject> = []
  @State goods_position: number = 0
  @State canload: boolean = true
  @State haveMore: boolean = true;

  aboutToAppear(): void {
    this.getBookItemCard(0);
  }

  async getBookItemCard(goods_position: number) {
    this.canload = false;
    // 网络请求
    let httpObject = http.createHttp();
    let url =
      "https://van.mama.cn/hb/api/goods/getTalentGoodsList?perpage=10&goods_type=1&goods_position=0" + goods_position +
        "&from=index&sign=&uid="
    let res = await httpObject.request(url, {
      header: {
        platformtype: "h5"
      }
    })
    res = JSON.parse(res["result"] as string);
    let BookList: Array<ESObject> = res["data"]["list"];
    this.BookList.push(...BookList);
    if (BookList.length >= 1 && this.BookList.length <= 100) {
      this.canload = true;
    } else {
      this.haveMore = false;
    }

  }

  build() {

    Column() {
      List() {
        ForEach(this.BookList, (item: ESObject) => {
          ListItem() {
            Row() {
              // goods_thumb
              Image(item.goods_thumb)
                .height(130)
                .borderRadius({ topRight: 20 })

              Column() {
                // goods_name
                Text(item.goods_name)
                  .fontSize(18)
                  .fontWeight(600)
                  .lineHeight(24)
                  .margin(5)
                // expert_introduction
                Text(item.expert_info.expert_introduction)
                  .fontWeight(400)
                  .fontSize(11)
                  .margin(5)
                avatarCard({ imgUrl: item.expert_info.avatar, name: item.expert_info.name })
              }.margin(8)
              .width("65%")
              .alignItems(HorizontalAlign.Start)
              .height(130)
            }
            .padding(10)
          }
        })
        ListItem() {
          Text(this.haveMore ? "让我缓缓~~~" : "人家也是有底线的~~~")
            .fontSize(14)
            .fontWeight(600)
            .margin({ left: 100 })
        }
      }.onScrollIndex((start, end) => {
        console.log(start.toString(), end.toString())
        if (end >= (this.goods_position + 10) && this.canload) {
          this.goods_position += 10;
          console.log(this.goods_position.toString())
          this.getBookItemCard(this.goods_position)
        }
      })
    }
  }
}