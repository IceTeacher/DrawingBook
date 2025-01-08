import { router } from '@kit.ArkUI';

@Component
export default struct AvatarCard {
  @Prop imgUrl: string
  @Prop name: string
  @Prop masterId: string
  // 用户信息
  @State userInfo: Array<ESObject> = []

  build() {
    Row() {
      Stack() {
        // avatar
        Image(this.imgUrl)
          .height(30)
          .width(30)
          .borderRadius(40)
          .shadow({
            radius: vp2px(5),
            color: "#958f8f8f",
            fill: true
          })
        Image($r("app.media.userV"))
          .width(18)
          .height(18)
          .margin({ right: -22, bottom: -20 })
      }

      // "name": "宸瑄",
      Text(this.name)
        .margin(5)
        .fontSize(14)
        .fontColor("#4d4d4d")
    }.onClick(() => {
      console.log("触发了点击avatar跳转事件")
      router.pushUrl({
        url: "pages/UserProfilePage",
        params: {
          masterId: this.masterId,

        }
      })
    })
  }
}