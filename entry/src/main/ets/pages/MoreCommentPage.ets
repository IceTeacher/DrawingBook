import { http } from '@kit.NetworkKit';
import router from '@ohos.router';

@Entry
@Component
struct MoreCommentPage {
  @State bookRecommend: Array<ESObject> = []
  // 设置沉浸式安全区域
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  @State bookListByLabel: Array<string> = []

  //获取书籍推荐列表
  async getBookRecommend() {
    let params: ESObject = router.getParams() as ESObject;
    let httpObject = http.createHttp();
    let url = "https://van.mama.cn/hb/api/comment/getList?goods_id=" + params.id + "&perpage=10"
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    let bookRecommend: Array<ESObject> = res["data"]["list"];
    this.bookRecommend = bookRecommend;
  }

  // 生命周期钩子，页面创建时，build构建前
  aboutToAppear(): void {
    this.getBookRecommend()
  }

  build() {
    Scroll() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
          ForEach(this.bookRecommend, (item: ESObject) => {
            Column() {
              Row({ space: 10 }) {
                Image(item.user_info.avatar).width(35).height(35).objectFit(ImageFit.Cover).borderRadius(50)
                Column() {
                  Text(item.user_info.username).fontWeight(700).fontSize(16)
                  Text(item.user_info.birthday_title).fontColor("#999999").fontSize(14)
                  Text(item.message)
                    .fontColor("#666666")
                    .fontSize(14)
                    .margin({ top: 20 })
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Row({ space: 140 }) {
                    Text(item.show_time).fontColor("#999999").fontSize(14)
                    Text("回复").fontColor("#999999").fontSize(14)
                  }.margin({ top: 15 })
                }
                .alignItems(HorizontalAlign.Start)
                .justifyContent(FlexAlign.Center)
              }
              .alignItems(VerticalAlign.Top)
            }.height(150).borderWidth({ bottom: 1 }).borderColor("#f8f8f8").padding({ top: 15 })
          })
          Column() {
            Text("-已经到底了-").fontColor("#999999").margin({ top: 20, bottom: 60 })
          }
        }.padding({ top: px2vp(this.topRectHeight), left: 20, right: 20 })

        Row({ space: 5 }) {
          TextInput({ placeholder: '写下你的评论' }).width("90%")
          Image($r('app.media.sent')).width(25)
        }.margin({ bottom: 10 })
      }
    }.width("100%")
  }
}