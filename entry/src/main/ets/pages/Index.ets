import BookListPage from './BookListPage';
import FindBookListPage from './FindBookListPage';
import HomePage from './HomePage';
import LoginPage from './LoginPage';

// 页面入口
@Entry
@Component
struct Index {
  // 设置沉浸式安全区域
  @StorageProp('bottomRectHeight')
  bottomRectHeight: number = 0;
  @StorageProp('topRectHeight')
  topRectHeight: number = 0;
  //记录选中的标题索引
  @State currentIndex: number = 0

  //定义单个tab标题的布局
  @Builder
  tabBuilder(title: string, targetIndex: number, on: Resource, off: Resource) {
    Column({ space: 5 }) {
      Image(this.currentIndex === targetIndex ? on : off).width(30).height(30)
      Text(title)
        .fontSize(14)
        .fontColor(this.currentIndex === targetIndex ? '#5cd3b4' : '#666666')
    }
    .width('100%')
  }

  // 页面结构
  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        // 首页
        TabContent() {
          HomePage()
        }
        .tabBar(this.tabBuilder("找绘本", 0, $r("app.media.HomePage_on"), $r("app.media.HomePage_off")))

        // 找书单
        TabContent() {
          FindBookListPage()
        }
        .tabBar(this.tabBuilder("找书单", 1, $r("app.media.FindBookListPage_on"), $r("app.media.FindBookListPage_off")))

        // 听故事
        TabContent() {
          BookListPage()
        }
        .tabBar(this.tabBuilder("听故事", 2, $r("app.media.BookListPage_on"), $r("app.media.BookListPage_off")))

        // 我
        TabContent() {
          LoginPage()
        }
        .tabBar(this.tabBuilder("我", 3, $r("app.media.LoginPage_on"), $r("app.media.LoginPage_off")))
      }
      .padding({ top: px2vp(this.topRectHeight), bottom: px2vp(this.bottomRectHeight) })
      .onChange(index => {
        //更新选中的标题
        this.currentIndex = index;
      })
    }
    .width("100%")
    .height("100%")
  }
}