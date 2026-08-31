<template>
  <view
    class="product-card-2"
    hover-class="product-card-hover"
    @click="$emit('click')"
  >
    <view class="img-wrap">
      <image
        :src="displayImage"
        mode="aspectFill"
        class="product-card-img"
        :style="{ height: imageHeight }"
        lazy-load
      />
      <view v-if="displayTag === 1" class="img-tag tag-hot">特惠</view>
      <view v-else-if="displayTag === 2" class="img-tag tag-new">新品</view>
      <view v-else-if="showHot && Number(displaySales) > 100" class="img-tag tag-hot">热销</view>
    </view>
    <view class="card-info">
      <text :class="['card-name', lines > 1 ? 'card-name--2' : '']">{{ displayName }}</text>
      <view v-if="showSales || showOriginal" class="card-bottom">
        <view class="price-col">
          <text class="card-price">{{ formatPrice(displayPrice) }}</text>
          <text v-if="showOriginal && displayOriginal" class="card-original">¥{{ formatPrice(displayOriginal) }}</text>
        </view>
        <text v-if="showSales" class="card-sales">{{ salesText || '已售 ' + displaySales }}</text>
      </view>
      <text v-else class="card-price">{{ formatPrice(displayPrice) }}</text>
    </view>
  </view>
</template>

<script>
/**
 * 商品卡片组件（图片 + 角标 + 名称 + 价格 + 销量）
 * 用法：
 *   <product-card :item="item" :show-sales="true" :lines="2" @click="goDetail(item.id)" />
 * 常用属性：
 *   item         商品对象（含 images/name/price/originalPrice/sales/tag/productName 等）
 *   image/name/price/original/sales/tag  可单独覆盖 item 内字段
 *   showSales    是否显示销量（默认 false）
 *   showOriginal 是否显示划线原价（默认 true）
 *   showHot      销量>100 是否自动显示“热销”角标（默认 true）
 *   imageHeight  图片高度（默认 200rpx）
 *   salesText    自定义销量文案（如“12人付款”）
 *   lines        名称行数（默认 1，传 2 显示两行截断）
 * 事件：click
 */
export default {
  name: 'product-card',
  props: {
    item: { type: Object, default: null },
    image: { type: String, default: '' },
    name: { type: String, default: '' },
    price: { type: [String, Number], default: 0 },
    original: { type: [String, Number], default: 0 },
    sales: { type: [String, Number], default: 0 },
    tag: { type: [String, Number], default: 0 },
    showSales: { type: Boolean, default: false },
    showOriginal: { type: Boolean, default: true },
    showHot: { type: Boolean, default: true },
    imageHeight: { type: String, default: '200rpx' },
    salesText: { type: String, default: '' },
    lines: { type: Number, default: 1 }
  },
  computed: {
    displayName() {
      if (this.name) return this.name
      const item = this.item
      return (item && (item.name || item.productName)) || ''
    },
    displayPrice() {
      return Number(this.price) || Number((this.item && this.item.price)) || 0
    },
    displayOriginal() {
      return Number(this.original) || Number((this.item && this.item.originalPrice)) || 0
    },
    displaySales() {
      return Number(this.sales) || Number((this.item && this.item.sales)) || 0
    },
    displayTag() {
      return Number(this.tag) || Number((this.item && this.item.tag)) || 0
    },
    displayImage() {
      if (this.image) return this.image
      const item = this.item
      if (!item) return '/static/placeholder.png'
      return this.getFirstImage(item.images || item.image)
    }
  }
}
</script>

<style lang="scss" scoped>
.img-wrap {
  position: relative;
  width: 100%;
  overflow: hidden;
}
.card-info {
  padding: 10rpx 14rpx 14rpx;
}
.card-name {
  display: block;
  font-size: 26rpx;
  color: $text-primary;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.card-name--2 {
  white-space: normal;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  line-height: 1.4;
}
.card-bottom {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-top: 6rpx;
}
.price-col {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
}
.card-price {
  font-size: 30rpx;
  color: $accent-orange;
  font-weight: bold;
}
.card-original {
  font-size: 20rpx;
  color: $text-placeholder;
  text-decoration: line-through;
}
.card-sales {
  font-size: 22rpx;
  color: $text-hint;
  flex-shrink: 0;
}
.product-card-hover {
  transform: scale(0.97);
  opacity: 0.9;
}
</style>
