import { router } from '@kit.ArkUI';

@Entry
@Component
struct BookDetailPage {
  // 获取图书id
  @State goods_id: string = ""

  aboutToAppear(): void {
    let params: ESObject = router.getParams() as ESObject;
    this.goods_id = (params.goods_id)
  }

  build() {


  }
}