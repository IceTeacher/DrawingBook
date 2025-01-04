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
      Image(this.currentIndex === targetIndex ? on : off).width(20).height(20)
      Text(title)
        .fontSize(14)
        .fontColor(this.currentIndex === targetIndex ? '#1296db' : '#cdcdcd')
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  // 页面结构
  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End }) {
        // 首页
        TabContent() {
          HomePage()
        }
        .tabBar(this.tabBuilder("找绘本", 0, $r("app.media.tabBackground"), $r("app.media.tabBackground")))

        // 找书单
        TabContent() {
          FindBookListPage()
        }
        .tabBar(this.tabBuilder("找书单", 1, $r("app.media.tabBackground"), $r("app.media.tabBackground")))

        // 听故事
        TabContent() {
          BookListPage()
        }
        .tabBar(this.tabBuilder("听故事", 2, $r("app.media.tabBackground"), $r("app.media.tabBackground")))

        // 我
        TabContent() {
          LoginPage()
        }
        .tabBar(this.tabBuilder("我", 2, $r("app.media.tabBackground"), $r("app.media.tabBackground")))
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