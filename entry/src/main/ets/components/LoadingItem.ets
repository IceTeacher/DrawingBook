@Component
export default struct LoadingItem {
  // 旋转角度状态变量
  @State rotateAngle: number = 0;

  build() {
    Column() {
      Row({ space: 5 }) {
        // 旋转动画的图片
        Image($r("app.media.loading"))
          .width(15)
          .height(15)
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            angle: this.rotateAngle
          })
          .onAppear(() => {
            animateTo({
              duration: 500,
              curve: Curve.Linear,
              delay: 0,
              iterations: -1,
              playMode: PlayMode.Normal,
              expectedFrameRateRange: {
                min: 30,
                max: 120,
                expected: 60,
              }
            }, () => {
              this.rotateAngle = 360
            })
          })

        // 加载文字
        Text("加载中...")
          .fontSize(14)
          .fontColor("#999999");
      }
    }
    .width("100%");
  }
}
