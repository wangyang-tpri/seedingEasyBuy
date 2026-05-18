<template>
  <view class="list-page">
    <!-- 搜索 + 筛选栏 -->
    <view class="filter-bar">
      <view class="search-box" @click="goPage('/pages/search/search')">
        <u-search placeholder="搜索苗木" :disabled="true" searchIconColor="#07C160" bgColor="#f5f6fa"></u-search>
      </view>
      <view class="sort-row">
        <text v-for="s in sorts" :key="s.key" :class="['sort-item', sortBy === s.key ? 'active' : '']" @click="switchSort(s.key)">{{ s.label }}</text>
      </view>
    </view>

    <!-- 商品列表 -->
    <z-paging ref="paging" v-model="productList" @query="loadProducts">
      <view class="product-grid">
        <view class="product-card" v-for="item in productList" :key="item.id" @click="goDetail(item.id)">
          <image :src="getFirstImage(item.images)" mode="aspectFill" class="product-img" />
          <text class="product-name">{{ item.name }}</text>
          <view class="product-bottom">
            <text class="product-price">{{ formatPrice(item.price) }}</text>
            <text class="product-sales">已售 {{ item.sales || 0 }}</text>
          </view>
        </view>
      </view>
    </z-paging>
  </view>
</template>

<script>
import { get } from '@/utils/request'
export default {
  data() {
    return {
      productList: [],
      categoryId: 0,
      sortBy: 'default',
      sorts: [
        { key: 'default', label: '综合' },
        { key: 'sales', label: '销量' },
        { key: 'price_asc', label: '价格↑' },
        { key: 'price_desc', label: '价格↓' },
        { key: 'newest', label: '最新' }
      ]
    }
  },
  onLoad(options) {
    this.categoryId = options.categoryId || 0
  },
  methods: {
    async loadProducts(pageNo, pageSize) {
      try {
        const result = await get(`/product/page?categoryId=${this.categoryId}&sortBy=${this.sortBy}&current=${pageNo}&size=${pageSize}`)
        this.$refs.paging.complete(result.records || [])
      } catch (e) {
        this.$refs.paging.complete(false)
      }
    },
    switchSort(key) {
      this.sortBy = key
      this.$refs.paging.reload()
    },
    goDetail(id) {
      uni.navigateTo({ url: `/pages/product/detail?id=${id}` })
    }
  }
}
</script>

<style lang="scss" scoped>
.filter-bar { background: #fff; }
.search-box { padding: 16rpx 30rpx; }
.sort-row { display: flex; padding: 20rpx 30rpx; border-top: 1rpx solid #f0f0f0; }
.sort-item { flex: 1; text-align: center; font-size: 26rpx; color: #666; }
.sort-item.active { color: #07C160; font-weight: bold; }
.product-grid { display: flex; flex-wrap: wrap; justify-content: space-between; padding: 20rpx 30rpx; }
.product-card { width: 48%; background: #fff; border-radius: 12rpx; overflow: hidden; margin-bottom: 20rpx; }
.product-img { width: 100%; height: 340rpx; }
.product-name { display: block; font-size: 26rpx; color: #333; padding: 10rpx 16rpx 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.product-bottom { display: flex; justify-content: space-between; align-items: center; padding: 8rpx 16rpx 16rpx; }
.product-price { font-size: 28rpx; color: #FF6B35; font-weight: bold; }
.product-sales { font-size: 22rpx; color: #999; }
</style>
