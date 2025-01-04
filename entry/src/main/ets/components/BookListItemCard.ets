import AvatarCard from './AvatarCard'

export interface BookListItem {
  goods_id: string
  goods_name: string
  goods_desc: string
  goods_thumb: string
  goods_number: string
  shop_price: string
  is_on_sale: string
  buy_type: string
  cat_id: string
  goods_own_type: string
  sort_order: string
  score: string
  user_score: string
  avg_score: string
  app_name: string
  last_update: string
  click_rate: string
  click_count: string
  expert_id: string
  expert_description: string
  expert_title: string
  expert_introduction: string
  gallery: Gallery[]
  attribute_age: AttributeAge[]
  tag_age: string
  expert: Expert
}

interface Gallery {
  images: string
}

interface AttributeAge {
  attr_id: string
  attr_val_id: string
  attr_name: string
}

interface Expert {
  id: string
  name: string
  avatar: string
  user_title: string
  introduction: string
  description: string
  expert_introduction: string
}


@Component
export default struct BookListItemCard {
  @Prop widthValue: string
  @Prop item: BookListItem

  // BookListItemCard
  build() {
    Column({ space: 15 }) {
      Image(this.item.goods_thumb)
        .width("80%")
        .height(140)
        .borderRadius({ topRight: 20 })

      Row() {
        Text(this.item.goods_name)
          .fontSize(18)
          .fontWeight(700)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      Row() {
        Text(this.item.expert_description)
          .fontSize(14)
          .fontColor("#666666")
          .lineHeight(24)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      Row() {
        AvatarCard({ imgUrl: this.item.expert.avatar, name: this.item.expert.name })
      }
      .width("100%")
      .justifyContent(FlexAlign.Start)
    }
    .margin({ right: 20 })
    .width(this.widthValue)
    .padding(20)
    .borderRadius(15)
    .borderStyle(BorderStyle.Solid)
    .borderWidth(1)
    .borderColor("#f4f4f4")
    .shadow({
      radius: 25,
      color: "#c9f6f6f6",
      offsetX: 25,
      offsetY: 25
    })
  }
}