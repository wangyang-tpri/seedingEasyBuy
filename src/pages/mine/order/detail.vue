<template>
  <view class="detail-page" v-if="order">
    <!-- 收货信息 -->
    <view class="info-card">
      <view class="info-row"><text class="info-label">收货人:</text><text>{{ order.receiverName || '-' }}</text></view>
      <view class="info-row"><text class="info-label">电话:</text><text>{{ order.receiverPhone || '-' }}</text></view>
      <view class="info-row"><text class="info-label">地址:</text><text>{{ order.receiverAddress || '-' }}</text></view>
    </view>

    <!-- 订单信息 -->
    <view class="info-card">
      <view class="info-row"><text class="info-label">订单号:</text><text>{{ order.orderNo }}</text></view>
      <view class="info-row"><text class="info-label">下单时间:</text><text>{{ formatDate(order.createTime) }}</text></view>
      <view class="info-row" v-if="order.payTime"><text class="info-label">支付时间:</text><text>{{ formatDate(order.payTime) }}</text></view>
    </view>

    <!-- 商品列表 -->
    <view class="items-card">
      <view class="order-item" v-for="item in items" :key="item.id">
        <image :src="fixImageUrl(item.productImage)" mode="aspectFill" class="item-img" />
        <view class="item-info">
          <text class="item-name">{{ item.productName }}</text>
          <text class="item-sku" v-if="item.skuName">{{ item.skuName }}</text>
          <text class="item-price">{{ formatPrice(item.price) }} × {{ item.quantity }}</text>
        </view>
      </view>
    </view>

    <!-- 金额 -->
    <view class="amount-card">
      <view class="amount-row"><text>商品总额</text><text>{{ formatPrice(order.totalAmount) }}</text></view>
      <view class="amount-row"><text>运费</text><text>{{ formatPrice(order.freight) }}</text></view>
      <view class="amount-row total"><text>实付</text><text class="total-price">{{ formatPrice(order.payAmount) }}</text></view>
    </view>
  </view>
</template>

<script>
import { get } from '@/utils/request'
export default {
  data() { return { order: null, items: [] } },
  onLoad(options) { this.loadDetail(options.id) },
  methods: {
    fixImageUrl(url) {
      if (!url) return '/static/placeholder.png'
      if (url.startsWith('/api/')) {
        const base = this.getBaseUrl()
        return base ? base + url.substring(4) : url
      }
      return url
    },
    async loadDetail(id) {
      try {
        const result = await get(`/order/detail/${id}`)
        this.order = result.order
        this.items = result.items || []
      } catch (e) {}
    }
  }
}
</script>

<style lang="scss" scoped>
.info-card { background: $bg-white; margin: 20rpx 30rpx; border-radius: 12rpx; padding: 24rpx 30rpx; }
.info-row { display: flex; padding: 12rpx 0; font-size: 26rpx; }
.info-label { color: $text-hint; width: 140rpx; flex-shrink: 0; }
.items-card { background: $bg-white; margin: 20rpx 30rpx; border-radius: 12rpx; padding: 20rpx 30rpx; }
.order-item { display: flex; padding: 16rpx 0; border-bottom: 1rpx solid $bg-input; }
.order-item:last-child { border-bottom: none; }
.item-img { width: 120rpx; height: 120rpx; border-radius: 8rpx; margin-right: 20rpx; }
.item-info { flex: 1; }
.item-name { font-size: 26rpx; color: $text-primary; display: block; }
.item-sku { font-size: 22rpx; color: $text-hint; }
.item-price { font-size: 26rpx; color: $accent-orange; font-weight: bold; }
.amount-card { background: $bg-white; margin: 20rpx 30rpx; border-radius: 12rpx; padding: 24rpx 30rpx; }
.amount-row { display: flex; justify-content: space-between; padding: 12rpx 0; font-size: 26rpx; color: $text-secondary; }
.amount-row.total { border-top: 1rpx solid $bg-input; padding-top: 20rpx; margin-top: 10rpx; }
.total-price { color: $accent-orange; font-size: 32rpx; font-weight: bold; }
</style>
