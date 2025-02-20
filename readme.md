# DrawingBook 项目

## 项目简介

DrawingBook 是一个 HarmonyOS NEXT
下的绘本阅读和管理应用，旨在为用户提供便捷的绘本查找、阅读和管理功能。该应用包含首页、书单查找、听故事、登录、书单详情、书籍详情、排行榜、分类、带有分类标签的书籍列表、个人资料和更多评论等多个页面。

## 项目架构

DrawingBook 项目基于 HarmonyOS 5.0.0 (12)，使用 ArkTS 和 ArkUI 构建。项目架构主要包括以下部分：

1. **页面组件**：每个页面独立封装为一个组件（.ets 文件），页面之间通过路由进行跳转。
2. **公共组件**：封装常用的组件，例如搜索框、列表项等，便于在多个页面中复用。
3. **状态管理**：使用全局状态管理工具，管理应用中的全局状态，例如用户信息、书籍数据等。
4. **网络请求**：封装网络请求模块，统一处理与后端服务器的通信。
5. **样式管理**：使用统一的样式管理方案，确保应用的一致性和可维护性。

## 项目预览

<img src="./readme/1.png" alt="首页" style="zoom: 25%;" />

<img src="./readme/2.png" alt="找书单" style="zoom: 25%;" />

<img src="./readme/3.png" alt="听故事" style="zoom: 25%;" />

<img src="./readme/4.png" alt="书籍详情" style="zoom: 25%;" />

## 页面描述

### 1. 首页 (HomePage.ets)

- 搜索框：封装组件放在最外盒子
- 轮播图：点击跳转到 BookDetailPage 页面
- 分类：点击跳转到 CategoryPage 页面，展示两行分类
- 达人书单：内嵌跳转到 BookListDetailPage 页面，外部点击跳转到 FindBookListPage 页面
- 热门榜单：点击跳转到 RankListPage 页面
- 达人精选列表：点击跳转到 BookDetailPage 页面，列表项拆成组件 BookItemCard.ets，并支持下拉滚动

### 2. 找书单 (FindBookListPage.ets)

- 滚动列表：点击跳转到 BookListDetailPage 页面

### 3. 听故事 (BookListPage.ets)

- 分成两个 Tab（中，英）
    - Tab 框
    - List 列表项：点击跳转到 BookDetailPage 页面，并支持下拉滚动
    - 音频播放

### 4. 登录 (LoginPage.ets)

- 表单布局

### 5. 书单详情页 (BookListDetailPage.ets)

- 书单上部分封面、标题区域
- 书籍列表：点击跳转到 BookDetailPage 页面，使用组件 BookItemCard.ets，并支持下拉滚动
- 达人怎么说：条件渲染，使用 web 组件，支持动态高度
- 评论
- 更多和推荐：使用 Tab 组件，包含“更多”和“推荐”两个选项卡，支持列表的滚动加载

### 6. 书籍详情页 (BookDetailPage.ets)

- 顶部封面、标题、标签、作者、出版社区域
- 评分
- 听故事：秒换算时间，按钮播放音频
- 达人怎么说：条件渲染，使用 web 组件，支持动态高度
- 简介：条件渲染，使用 web 组件，支持动态高度
- 评论
- 更多和推荐：使用 Tab 组件，包含“更多”和“推荐”两个选项卡，支持列表的滚动加载

### 7. 排行榜页 (RankListPage.ets)

- 两行可横向滚动的列表
- Tab 组件：包含“月总榜”和“月上升榜”两个选项卡
- 列表：点击跳转到 BookDetailPage 页面，五星推荐暂定

### 8. 全部分类页 (CategoryPage.ets)

- 列表
- 列表项：点击跳转到 BookDetailPage 页面

### 9. 带有分类标签的书籍列表页 (BookListByLabelPage.ets)

- 列表
- 列表项

### 10. 个人资料页面 (UserProfilePage.ets)

- 列表

### 11. 更多评论页面 (MoreCommentPage.ets)

- 所有评论显示

## 任务分配

- @lexxx_rich：搜索框、达人精选列表、登录表单布局、排行榜页可横向滚动的列表和 Tab 组件、个人资料页面列表
- @iceteacher：轮播图、达人书单、热门榜单、滚动列表、听故事列表项、音频播放、达人怎么说、简介
- @guonaijie：分类、Tab 框、书单上部分封面和标题区域、书籍列表、评论、更多和推荐、书籍详情页顶部封面和标签区域、评分、听故事功能、评论、分类列表和列表项、带有分类标签的书籍列表和列表项、更多评论页面

## 贡献

感谢项目成员的辛勤付出和贡献。

