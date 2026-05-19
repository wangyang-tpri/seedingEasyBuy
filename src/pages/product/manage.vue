<template>
  <view class="manage-page">
    <view class="product-card" v-for="item in list" :key="item.id">
      <view class="card-top">
        <image :src="fixImageUrl(getFirstImage(item.images))" mode="aspectFill" class="card-img" />
        <view class="card-info">
          <text class="card-name">{{ item.name }}</text>
          <text class="card-price">{{ formatPrice(item.price) }}</text>
          <view class="card-meta">
            <text>库存: {{ item.stock || 0 }}</text>
            <text>销量: {{ item.sales || 0 }}</text>
          </view>
          <text :class="['status-tag', item.status === 1 ? 'on' : 'off']">
            {{ item.status === 1 ? '已上架' : '已下架' }}
          </text>
        </view>
      </view>
      <view class="card-actions">
        <view class="btn-edit" @click="goEdit(item.id)">编辑</view>
        <view class="btn-toggle" :class="item.status === 1 ? 'off' : 'on'" @click="toggleStatus(item)">
          {{ item.status === 1 ? '下架' : '上架' }}
        </view>
      </view>
    </view>
    <view class="empty-box" v-if="list.length === 0">
      <view class="empty-icon">📋</view>
      <text class="empty-text">暂无发布的苗木</text>
    </view>
  </view>
</template>

<script>
import { get, post } from '@/utils/request'
export default {
  data() { return { list: [] } },
  onShow() { this.loadList() },
  methods: {
    async loadList() {
      try { this.list = await get('/product/my') || [] } catch (e) {}
    },
    fixImageUrl(url) {
      if (!url) return '/static/placeholder.png'
      if (url.startsWith('/api/')) {
        const base = this.getBaseUrl()
        return base ? base + url.substring(4) : url
      }
      return url
    },
    goEdit(id) {
      uni.navigateTo({ url: `/pages/product/add?id=${id}` })
    },
    async toggleStatus(item) {
      const action = item.status === 1 ? '下架' : '上架'
      uni.showModal({
        title: '确认操作',
        content: `确定${action}该商品吗？`,
        success: async (res) => {
          if (res.confirm) {
            try {
              await post(`/product/status/${item.id}`)
              this.showToast(`${action}成功`)
              this.loadList()
            } catch (e) { this.showToast('操作失败') }
          }
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.manage-page { min-height: 100vh; background: #f5f6fa; padding: 20rpx 24rpx; }
.product-card { background: #fff; border-radius: 14rpx; padding: 24rpx; margin-bottom: 16rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04); }
.card-top { display: flex; }
.card-img { width: 140rpx; height: 140rpx; border-radius: 10rpx; margin-right: 20rpx; flex-shrink: 0; background: #f0f0f0; }
.card-info { flex: 1; min-width: 0; }
.card-name { font-size: 28rpx; font-weight: 600; color: #333; display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.card-price { font-size: 30rpx; color: #FF6B35; font-weight: bold; margin-top: 6rpx; display: block; }
.card-meta { display: flex; gap: 20rpx; margin-top: 6rpx; font-size: 22rpx; color: #999; }
.status-tag { display: inline-block; font-size: 20rpx; padding: 2rpx 12rpx; border-radius: 4rpx; margin-top: 6rpx; }
.status-tag.on { background: #e8f8ee; color: #07C160; }
.status-tag.off { background: #f5f5f5; color: #999; }
.card-actions { display: flex; justify-content: flex-end; gap: 16rpx; margin-top: 20rpx; padding-top: 20rpx; border-top: 1rpx solid #f0f0f0; }
.btn-edit { padding: 12rpx 36rpx; border-radius: 30rpx; border: 1rpx solid #07C160; color: #07C160; font-size: 24rpx; }
.btn-toggle { padding: 12rpx 36rpx; border-radius: 30rpx; font-size: 24rpx; color: #fff; }
.btn-toggle.off { background: #ee3f3f; }
.btn-toggle.on { background: #07C160; }
.empty-box { text-align: center; padding-top: 200rpx; }
.empty-icon { font-size: 80rpx; opacity: 0.3; margin-bottom: 20rpx; }
.empty-text { font-size: 28rpx; color: #bbb; display: block; }
</style>
