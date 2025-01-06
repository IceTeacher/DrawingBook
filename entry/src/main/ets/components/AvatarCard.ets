@Component
export default struct AvatarCard {
  @Prop imgUrl: string
  @Prop name: string

  build() {
    Row() {
      Stack() {
        // avatar
        Image(this.imgUrl)
          .width(30)
          .borderRadius(40)
        Image($r("app.media.userV"))
          .width(18)
          .margin({ right: -22, bottom: -20 })
      }

      // "name": "宸瑄",
      Text(this.name)
        .margin(5)
        .fontSize(14)
        .fontColor("#4d4d4d")
    }
  }
}