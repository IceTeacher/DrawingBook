@Entry
@Component
export default struct LoginPage {
  @State passwordState: boolean = false
  @State text: string = ''
  controller: TextInputController = new TextInputController()

  build() {
    Column() {
      // 放置图片与欢迎
      Column() {
        Image($r("app.media.loginPic"))
          .width("50%")
          .height(180)
        Text("欢迎来到妈妈网")
          .fontSize(20)
          .fontColor("#ff7c7979")
          .margin(20)
      }.width("100%")
      .height(230)

      Row() {
        Image($r("app.media.loginFlower"))
          .width(18)
        TextInput({ text: this.text, placeholder: '| 账号 ', controller: this.controller })
          .placeholderColor(Color.Grey)
          .placeholderFont({ size: 16, weight: 400 })
          .caretColor(Color.Blue)
          .width('80%')
          .height(45)
          .margin(10)
          .fontColor(Color.Black)
          .onChange((value: string) => {
            this.text = value
          })
      }

      Row() {
        Image($r("app.media.loginLock"))
          .width(18)
        TextInput({ placeholder: '| 密码' })
          .width('80%')
          .height(45)
          .margin(10)
          .type(InputType.Password)
          .maxLength(9)
          .placeholderFont({ size: 16, weight: 400 })
          .showPasswordIcon(true)
          .showPassword(this.passwordState)
          .onSecurityStateChange(((isShowPassword: boolean) => {
            // 更新密码显示状态
            console.info('isShowPassword', isShowPassword)
            this.passwordState = isShowPassword
          }))
      }

      Button("登录")
        .width('80%')
        .margin(50)
        .backgroundColor("#ff74d27a")
        .padding(10)
        .fontSize(18)
        .fontWeight(600)
      Row() {
        Text() {
          Span("注册")
          Span(" | ")
          Span("忘记密码")
        }.fontColor("#ff7c7979")
        .margin(40)

      }
    }
    .margin({ top: 20 })
    .height('100%')
    .width('100%')
  }
}