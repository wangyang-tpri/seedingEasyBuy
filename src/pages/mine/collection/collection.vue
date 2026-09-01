<template>
  <view class="collection-page">
    <view class="product-grid product-grid-2">
      <product-card
        v-for="item in list"
        :key="item.id"
        :item="item"
        :show-original="false"
        @click="goDetail(item.productId)"
      />
    </view>
    <empty-state v-if="list.length === 0" icon="🤍" text="暂无收藏" />
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
/* 网格复用 .product-grid-2；卡片复用公共组件 <product-card>；空状态复用 <empty-state> */
</style>
