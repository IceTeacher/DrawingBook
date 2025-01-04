@Component
export default struct SearchItem {
  build() {
    Row() {
      Search({ placeholder: "入园" })
        .width("100%")
    }
  }
}