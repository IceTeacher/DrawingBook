import Chinese from '../pages/ChineseBookPage'
import English from '../pages/EnglishBookPage'

@Entry
@Component
export default struct BookListPage {
  @State currentIndex: number = 0
  @State BookList: Array<ESObject> = []

  @Builder
  tabBuilder(title: string, targetIndex: number) {
    Column() {
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? 'white' : '#5cd3b4')
        .borderColor("#5cd3b4")
        .borderWidth(1)
        .borderRadius(10)
        .backgroundColor(this.currentIndex === targetIndex ? '#5cd3b4' : 'white')
        .padding({
          top: 8,
          bottom: 8,
          left: 12,
          right: 12
        })
    }
    .width("100%")
    .height(50)
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Tabs({ barPosition: BarPosition.Start }) {
        TabContent() {
          Chinese()
        }.tabBar(this.tabBuilder('国语', 0))

        TabContent() {
          English()
        }.tabBar(this.tabBuilder('英语', 1))

        TabContent() {
        }

        TabContent() {
        }
      }.onChange((index) => {
        this.currentIndex = index
      })

      Row() {
        // Image($rawfile('play_off.png')).width(40)
        Text("连续播放").fontSize(18).fontColor("#5cd3b4")
      }.margin({ top: 5, right: 30 })

      // .onClick(()=>{
      //   //开始连续播放
      // })
    }

  }
}