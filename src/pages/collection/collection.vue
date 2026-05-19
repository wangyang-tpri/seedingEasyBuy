<template>
  <view class="collection-page">
    <view class="product-grid">
      <view class="product-card" v-for="item in list" :key="item.id" @click="goDetail(item.productId)">
        <image :src="fixImageUrl(item.image)" mode="aspectFill" class="product-img" />
        <text class="product-name">{{ item.productName }}</text>
        <text class="product-price">{{ formatPrice(item.price) }}</text>
      </view>
    </view>
    <view class="empty" v-if="list.length === 0">
      <text>暂无收藏</text>
    </view>
  </view>
</template>

<script>
import { get } from '@/utils/request'
export default {
  data() { return { list: [] } },
  onShow() { this.loadList() },
  methods: {
    fixImageUrl(url) {
      if (!url) return '/static/placeholder.png'
      if (url.startsWith('/api/')) {
        const base = this.getBaseUrl()
        return base ? base + url.substring(4) : url
      }
      return url
    },
    async loadList() {
      try { this.list = await get('/collection/list') || [] } catch (e) {}
    },
    goDetail(id) { uni.navigateTo({ url: `/pages/product/detail?id=${id}` }) }
  }
}
</script>

<style lang="scss" scoped>
.product-grid { display: flex; flex-wrap: wrap; justify-content: space-between; padding: 20rpx 30rpx; }
.product-card { width: 48%; background: #fff; border-radius: 12rpx; overflow: hidden; margin-bottom: 20rpx; }
.product-img { width: 100%; height: 200rpx; }
.product-name { display: block; font-size: 26rpx; color: #333; padding: 8rpx 12rpx 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.product-price { display: block; font-size: 28rpx; color: #FF6B35; font-weight: bold; padding: 6rpx 12rpx 16rpx; }
.empty { text-align: center; padding: 200rpx 0; color: #999; font-size: 28rpx; }
</style>
