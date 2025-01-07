import AvatarCard from './AvatarCard';
import { LengthMetrics } from '@kit.ArkUI';

@Component
export default struct BookItemCard {
  // 书籍数据
  @Prop bookItem?: Array<ESObject> = []
  // 控制是否展示音频相关内容
  @Prop bookAudioItem?: Array<ESObject> = []
  // 控制是否展示排行榜列表项
  @Prop bookRankItem?: Array<ESObject> = []
  // 控制书籍简介显示行数
  @Prop descMaxLines?: number = 3
  // 组件宽度
  @Prop widthValue?: number = 100
  // 组件高度
  @Prop heightValue?: number = 150
  // y轴间隔
  @Prop ySpaceValue?: number = 5
  // x轴间隔
  @Prop xSpaceValue?: number = 15
  // 控制是否展示书籍简介
  @Prop isShowDesc?: boolean = true
  // 控制是否展示标签
  @Prop isShowLabel?: boolean = false
  // 控制是否展示头像
  @Prop isShowAvatar?: boolean = true

  // 书籍简介子组件
  @Builder
  BookItemDesc(desc: string) {
    if (this.isShowDesc) {
      Text(desc)
        .fontSize(12)
        .fontColor("#666666")
        .lineHeight(22)
        .maxLines(this.descMaxLines)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
  }

  // 书籍分类标签子组件
  @Builder
  BookItemLabel(labelList: Array<ESObject>) {
    Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(10), cross: LengthMetrics.vp(10) } }) {
      ForEach(labelList, (item: ESObject, index) => {
        if (index <= 2) {
          Text(item.label_name)
            .fontSize(12)
            .fontColor("#666666")
            .backgroundColor("#efefef")
            .padding(5)
        }
      })
    }
  }

  build() {
    Column() {
      Row({ space: this.xSpaceValue }) {
        if (this.bookItem?.length === 1) {
          // 书籍封面
          Stack() {
            Column()
              .width(20)
              .height(this.heightValue)
              .linearGradient({
                angle: 90,
                colors: [["#b0a4a4a4", 0.0], ["#66989898", 0.5], ["#00ffffff", 1.0]]
              })
              .zIndex(999)
            Image(this.bookItem[0].goods_thumb)
              .height(this.heightValue)
              .borderRadius({ topRight: 20 })
              .borderStyle(BorderStyle.Solid)
              .borderWidth(1)
              .borderColor("#f4f4f4")
              .shadow({
                radius: vp2px(10),
                color: "#688f8f8f",
                offsetX: 15,
                offsetY: 15,
                fill: true
              })
          }
          .alignContent(Alignment.Start)

          Column({ space: this.ySpaceValue }) {
            // 书籍标题
            Text(this.bookItem[0].goods_name)
              .fontSize(18)
              .fontWeight(700)
              .lineHeight(24)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            if (this.bookItem[0].expert_info) {
              // 书籍简介
              this.BookItemDesc(this.bookItem[0].expert_info.expert_introduction)
              // 书籍分类标签
              if (this.isShowLabel) {
                this.BookItemLabel(this.bookItem[0].label_list)
              }
              // 作者头像
              if (this.isShowAvatar) {
                if (this.bookItem[0].expert_info.avatar) {
                  AvatarCard({ imgUrl: this.bookItem[0].expert_info.avatar, name: this.bookItem[0].expert_info.name })
                }
              }
            }

            if (this.bookItem[0].expert_speak_info) {
              // 书籍简介
              if (this.bookItem[0].expert_speak_info.description) {
                this.BookItemDesc(this.bookItem[0].expert_speak_info.description)
              } else {
                this.BookItemDesc(this.bookItem[0].goods_desc)
              }
              // 作者头像
              if (this.isShowAvatar) {
                if (this.bookItem[0].expert_speak_info.avatar) {
                  AvatarCard({
                    imgUrl: this.bookItem[0].expert_speak_info.avatar,
                    name: this.bookItem[0].expert_speak_info.name
                  })
                }
              }
            }
          }
          .width(`${0.65 * this.widthValue!}%`)
          .alignItems(HorizontalAlign.Start)
          .height(this.heightValue)
        }

        if (this.bookAudioItem?.length === 1) {
          // 书籍封面
          Stack() {
            Column()
              .width(20)
              .height(this.heightValue)
              .linearGradient({
                angle: 90,
                colors: [["#b0a4a4a4", 0.0], ["#66989898", 0.5], ["#00ffffff", 1.0]]
              })
              .zIndex(999)
            Image(this.bookAudioItem[0].cover_image)
              .height(this.heightValue)
              .borderRadius({ topRight: 20 })
              .borderStyle(BorderStyle.Solid)
              .borderWidth(1)
              .borderColor("#f4f4f4")
              .shadow({
                radius: vp2px(10),
                color: "#688f8f8f",
                offsetX: 15,
                offsetY: 15,
                fill: true
              })
          }
          .alignContent(Alignment.Start)

          Column({ space: this.ySpaceValue }) {
            // 书籍标题
            Text(this.bookAudioItem[0].title)
              .fontSize(18)
              .fontWeight(700)
              .lineHeight(24)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            // 展示音频信息
            Row({ space: 10 }) {
              Row({ space: 5 }) {
                Text("\ue6b4")
                  .fontFamily("iconfont")
                  .fontSize(14)
                  .fontColor("#999999")
                Text(`${Math.floor(Number(this.bookAudioItem[0].time) / 60)}:${Number(this.bookAudioItem[0].time) %
                  60}`)
                  .fontSize(14)
                  .fontColor("#999999")
              }

              Row({ space: 5 }) {
                Text("\ue6b5")
                  .fontFamily("iconfont")
                  .fontSize(14)
                  .fontColor("#999999")
                Text(`${this.bookAudioItem[0].play_num}`)
                  .fontSize(14)
                  .fontColor("#999999")
              }

            }

            // 作者头像
            if (this.isShowAvatar) {
              if (this.bookAudioItem[0].expert_info.avatar) {
                AvatarCard({
                  imgUrl: this.bookAudioItem[0].expert_info.avatar,
                  name: this.bookAudioItem[0].expert_info.name
                })
              }
            }
          }
          .width(`${0.9 * this.widthValue!}%`)
          .alignItems(HorizontalAlign.Start)
          .height(this.heightValue)
        }

        if (this.bookRankItem?.length === 1) {
          // 书籍封面
          Stack() {
            Column()
              .width(20)
              .height(this.heightValue)
              .linearGradient({
                angle: 90,
                colors: [["#b0a4a4a4", 0.0], ["#66989898", 0.5], ["#00ffffff", 1.0]]
              })
              .zIndex(999)
            Image(this.bookRankItem[0].goods_thumb)
              .height(this.heightValue)
              .borderRadius({ topRight: 20 })
              .borderStyle(BorderStyle.Solid)
              .borderWidth(1)
              .borderColor("#f4f4f4")
              .shadow({
                radius: vp2px(10),
                color: "#688f8f8f",
                offsetX: 15,
                offsetY: 15,
                fill: true
              })
          }
          .alignContent(Alignment.Start)

          Column({ space: this.ySpaceValue }) {
            // 书籍标题
            Text(this.bookRankItem[0].goods_name)
              .fontSize(18)
              .fontWeight(700)
              .lineHeight(24)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            // 展示评分
            Row({ space: 10 }) {
              Rating({ rating: Number(this.bookRankItem[0].avg_score) / 2, indicator: true })
                .stars(5)
                .stepSize(0.1)
                .height(20)
              Text(this.bookRankItem[0].avg_score.includes('.') ? this.bookRankItem[0].avg_score :
                `${this.bookRankItem[0].avg_score}.0`)
                .fontSize(16)
                .fontColor("#404040")
            }

            // 展示排行榜进步名次
            if (Number(this.bookRankItem[0].rising_ranking)) {
              Row({ space: 10 }) {
                Text(`上升${this.bookRankItem[0].rising_ranking}位 ↑`)
                  .fontSize(14)
                  .fontColor("#999999")
              }
            }
          }
          .width(`${0.65 * this.widthValue!}%`)
          .alignItems(HorizontalAlign.Start)
          .height(this.heightValue)
        }
      }
      .width(`${this.widthValue!}%`)
    }
    .margin({ bottom: 20 })
  }
}