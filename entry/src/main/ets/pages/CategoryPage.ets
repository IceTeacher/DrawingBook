import { http } from '@kit.NetworkKit';
import router from '@ohos.router';

@Entry
@Component
struct CategoryPage {
  // 设置沉浸式安全区域
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  @State category: Array<ESObject> = []

  async getCategory() {
    //2.创建请求对象
    let httpObject = http.createHttp();
    //3.发出请求
    let url = "https://van.mama.cn/hb/api/category/getFcList?position=1&sign=&uid="
    //等待请求结果
    let res = await httpObject.request(url)
    res = JSON.parse(res["result"] as string);
    //找到需要使用的集合
    let category: Array<ESObject> = res["data"]["list"];
    this.category = category;
  }

  aboutToAppear(): void {
    this.getCategory()
  }

  build() {
    Scroll() {
      Column() {
        ForEach(this.category, (item: ESObject, index) => {
          Column() {
            Text(item.name).fontWeight(700).fontSize(20).margin({ left: 10, bottom: 15, top: 10 })
            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
              ForEach(item["tag_list"], (icon: ESObject) => {
                Column() {
                  Image(icon.image).width(40)
                  Text(icon.name).fontSize(12).fontColor("#808080")
                }.width(55).margin(8)
                .onClick(() => {
                  router.pushUrl({
                    url: "pages/BookListByLabelPage",
                    params: {
                      id: icon.id,
                    }
                  })
                })
              })
            }
          }.alignItems(HorizontalAlign.Start)
        })
      }
      .padding({ bottom: px2vp(this.bottomRectHeight) })
    }
    .padding({ top: px2vp(this.topRectHeight) })
  }
}