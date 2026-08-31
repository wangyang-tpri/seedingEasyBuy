<template>
  <view class="search-page">
    <!-- 搜索框 -->
    <view class="search-bar">
      <u-search :focus="true" v-model="keyword" placeholder="搜索苗木名称" @search="onSearch" @clear="onClear" searchIconColor="#07C160"></u-search>
    </view>

    <!-- 搜索历史 -->
    <view class="history-section" v-if="!keyword && historyList.length > 0">
      <view class="history-header">
        <text class="history-title">搜索历史</text>
        <text class="history-clear" @click="clearHistory">清空</text>
      </view>
      <view class="history-tags">
        <text v-for="(item, idx) in historyList" :key="idx" class="history-tag" @click="onHistoryClick(item)">{{ item }}</text>
      </view>
    </view>

    <!-- 搜索结果 -->
    <view class="result-section" v-if="keyword">
      <view class="result-grid">
        <product-card
          v-for="item in searchList"
          :key="item.id"
          :item="item"
          :show-original="false"
          image-height="240rpx"
          @click="goDetail(item.id)"
        />
      </view>
      <view v-if="keyword && searchList.length === 0 && searched" class="empty-result">暂无相关商品</view>
    </view>
  </view>
</template>

<script>
import { get } from '@/utils/request'

export default {
  data() {
    return {
      keyword: '',
      historyList: [],
      searchList: [],
      searched: false
    }
  },
  onShow() {
    this.loadHistory()
  },
  methods: {
    loadHistory() {
      const history = uni.getStorageSync('search_history')
      this.historyList = history ? JSON.parse(history) : []
    },
    saveHistory(keyword) {
      let history = uni.getStorageSync('search_history')
      history = history ? JSON.parse(history) : []
      history = [keyword, ...history.filter(h => h !== keyword)].slice(0, 20)
      uni.setStorageSync('search_history', JSON.stringify(history))
      this.historyList = history
    },
    async onSearch(val) {
      if (!val) return
      this.keyword = val
      this.saveHistory(val)
      this.searched = true
      try {
        const result = await get(`/product/search?keyword=${encodeURIComponent(val)}&size=20`)
        this.searchList = (result && result.records) || []
      } catch (e) {}
    },
    onClear() {
      this.keyword = ''
      this.searchList = []
      this.searched = false
    },
    onHistoryClick(item) {
      this.onSearch(item)
    },
    clearHistory() {
      uni.removeStorageSync('search_history')
      this.historyList = []
    },
    goDetail(id) {
      uni.navigateTo({ url: `/pages/product/detail?id=${id}` })
    }
  }
}
</script>

<style lang="scss" scoped>
/* 搜索栏复用公共 .search-bar */
.history-section { padding: 30rpx; }
.history-header { display: flex; justify-content: space-between; margin-bottom: 20rpx; }
.history-title { font-size: 28rpx; color: $text-primary; }
.history-clear { font-size: 24rpx; color: $text-hint; }
.history-tags { display: flex; flex-wrap: wrap; }
.history-tag { padding: 12rpx 28rpx; background: $bg-page; border-radius: 30rpx; margin: 0 16rpx 16rpx 0; font-size: 24rpx; color: $text-secondary; }
.result-section { padding: 20rpx 30rpx; }
.result-grid { display: flex; flex-wrap: wrap; justify-content: space-between; }
/* 结果卡片复用公共组件 <product-card>（图片高度 240rpx，不显示销量/原价） */
.empty-result { text-align: center; color: $text-hint; padding: 100rpx; font-size: 26rpx; }
</style>
