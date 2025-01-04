@Component
export default struct avatarCard {
  @State message: string = 'Hello World';
  @Prop imgUrl: string
  @Prop name: string

  build() {
    Row() {
      Stack() {
        // avatar
        Image(this.imgUrl)
          .width(30)
          .margin(5)
          .borderRadius(40)
        Image($r("app.media.userV"))
          .width(18)
          .margin({ right: -22, bottom: -20 })
      }

      // "name": "宸瑄",
      Text(this.name)
        .margin(5)

    }
  }
}