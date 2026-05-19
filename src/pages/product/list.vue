<template>
  <view class="list-page">
    <!-- 搜索栏 -->
    <view class="search-bar" @click="goPage('/pages/search/search')">
      <view class="search-box">
        <u-icon name="search" color="#999" size="16"></u-icon>
        <text class="search-placeholder">搜索苗木</text>
      </view>
    </view>

    <!-- 排序栏 -->
    <view class="sort-row">
      <view
        v-for="s in sorts"
        :key="s.key"
        :class="['sort-item', { active: sortBy === s.key }]"
        @click="switchSort(s.key)"
      >
        <text>{{ s.label }}</text>
        <view class="sort-indicator" v-if="sortBy === s.key"></view>
      </view>
    </view>

    <!-- 商品列表 -->
    <z-paging
      ref="paging"
      v-model="productList"
      @query="loadProducts"
      use-page-scroll
      :auto-show-back-to-top="true"
    >
      <!-- 骨架屏 -->
      <view class="product-grid" v-if="loading">
        <view class="skeleton-card" v-for="i in 6" :key="'s' + i">
          <view class="sk-img"></view>
          <view class="sk-info">
            <view class="sk-line"></view>
            <view class="sk-line w60"></view>
          </view>
        </view>
      </view>

      <!-- 商品网格 -->
      <view class="product-grid" v-else-if="productList.length > 0">
        <view
          class="product-card"
          v-for="item in productList"
          :key="item.id"
          hover-class="card-hover"
          @click="goDetail(item.id)"
        >
          <view class="img-wrap">
            <image
              :src="getFirstImage(item.images)"
              mode="aspectFill"
              class="product-img"
              lazy-load
            />
            <view class="img-tag hot" v-if="item.sales > 100">热销</view>
            <view class="img-tag new" v-else-if="isNewProduct(item)">新品</view>
          </view>
          <view class="card-info">
            <text class="product-name">{{ item.name }}</text>
            <view class="card-bottom">
              <view class="price-col">
                <text class="product-price">{{ formatPrice(item.price) }}</text>
                <text
                  class="product-original"
                  v-if="item.originalPrice && item.originalPrice > item.price"
                  >{{ formatPrice(item.originalPrice) }}</text
                >
              </view>
              <text class="product-sales">已售 {{ item.sales || 0 }}</text>
            </view>
          </view>
        </view>
      </view>

      <!-- 空状态 -->
      <view class="empty-box" v-else>
        <view class="empty-icon">📭</view>
        <text class="empty-text">暂无商品</text>
        <text class="empty-sub">换个关键词试试吧</text>
      </view>
    </z-paging>
  </view>
</template>

<script>
import { get } from "@/utils/request";
export default {
  data() {
    return {
      productList: [],
      categoryId: 0,
      sortBy: "default",
      loading: false,
      sorts: [
        { key: "default", label: "综合" },
        { key: "sales", label: "销量" },
        { key: "price_asc", label: "价格↑" },
        { key: "price_desc", label: "价格↓" },
        { key: "newest", label: "最新" },
      ],
    };
  },
  onLoad(options) {
    this.categoryId = options.categoryId || 0;
  },
  methods: {
    isNewProduct(item) {
      if (!item.createTime) return false;
      const created = new Date(item.createTime.replace(/-/g, "/"));
      const now = new Date();
      return now - created < 7 * 24 * 60 * 60 * 1000;
    },
    async loadProducts(pageNo, pageSize) {
      this.loading = true;
      try {
        const result = await get(
          `/product/page?categoryId=${this.categoryId}&sortBy=${this.sortBy}&current=${pageNo}&size=${pageSize}`
        );
        const records = (result && result.records) || [];
        this.$refs.paging.complete(records);
      } catch (e) {
        this.$refs.paging.complete(false);
      }
      this.loading = false;
    },
    switchSort(key) {
      if (this.sortBy === key) return;
      this.sortBy = key;
      this.loading = true;
      this.$refs.paging.reload();
    },
    goDetail(id) {
      uni.navigateTo({ url: `/pages/product/detail?id=${id}` });
    },
  },
};
</script>

<style lang="scss" scoped>
.list-page {
  min-height: 100vh;
  background: #f5f6fa;
}

/* ========== 搜索栏 ========== */
.search-bar {
  padding: 16rpx 24rpx;
  // padding-top: calc(var(--status-bar-height) + 16rpx);
  background: #fff;
}
.search-box {
  display: flex;
  align-items: center;
  background: #f5f6fa;
  border-radius: 36rpx;
  padding: 16rpx 24rpx;
}
.search-placeholder {
  font-size: 26rpx;
  color: #bbb;
  margin-left: 12rpx;
}

/* ========== 排序栏 ========== */
.sort-row {
  display: flex;
  background: #fff;
  padding: 6rpx 24rpx 18rpx;
}
.sort-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 12rpx 0;
  font-size: 26rpx;
  color: #888;
  position: relative;
  transition: color 0.2s;
}
.sort-item.active {
  color: #07c160;
  font-weight: 600;
}
.sort-indicator {
  width: 24rpx;
  height: 4rpx;
  background: #07c160;
  border-radius: 2rpx;
  margin-top: 6rpx;
}

/* ========== 商品网格 ========== */
.product-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  padding: 12rpx 24rpx;
}

/* ========== 商品卡片 ========== */
.product-card {
  width: calc(50% - 8rpx);
  background: #fff;
  border-radius: 14rpx;
  overflow: hidden;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 10rpx rgba(0, 0, 0, 0.04);
  transition: all 0.18s ease;
}
.card-hover {
  transform: scale(0.97);
  box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
}

.img-wrap {
  position: relative;
  width: 100%;
  overflow: hidden;
}
.product-img {
  width: 100%;
  height: 340rpx;
  display: block;
  background: #f0f0f0;
}

.img-tag {
  position: absolute;
  top: 10rpx;
  left: 10rpx;
  font-size: 18rpx;
  color: #fff;
  padding: 4rpx 12rpx;
  border-radius: 6rpx;
  font-weight: 600;
  letter-spacing: 1rpx;
  &.hot {
    background: linear-gradient(135deg, #ff6b35, #ff5c2a);
  }
  &.new {
    background: linear-gradient(135deg, #07c160, #06ad56);
  }
}

.card-info {
  padding: 16rpx 16rpx 18rpx;
}
.product-name {
  font-size: 27rpx;
  color: #333;
  font-weight: 500;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  line-height: 1.45;
  min-height: 76rpx;
}
.card-bottom {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-top: 12rpx;
}
.price-col {
  display: flex;
  align-items: baseline;
  gap: 8rpx;
}
.product-price {
  font-size: 30rpx;
  color: #ff6b35;
  font-weight: 700;
  letter-spacing: -1rpx;
}
.product-original {
  font-size: 20rpx;
  color: #bbb;
  text-decoration: line-through;
}
.product-sales {
  font-size: 20rpx;
  color: #bbb;
  flex-shrink: 0;
}

/* ========== 骨架屏 ========== */
.skeleton-card {
  width: calc(50% - 8rpx);
  background: #fff;
  border-radius: 14rpx;
  overflow: hidden;
  margin-bottom: 16rpx;
}
.sk-img {
  width: 100%;
  height: 340rpx;
  background: linear-gradient(90deg, #f3f3f3 25%, #e8e8e8 50%, #f3f3f3 75%);
  background-size: 200% 100%;
  animation: shimmer 1.6s ease infinite;
}
.sk-info {
  padding: 16rpx 16rpx 18rpx;
}
.sk-line {
  height: 18rpx;
  background: #f3f3f3;
  border-radius: 4rpx;
  margin-bottom: 12rpx;
}
.sk-line.w60 {
  width: 60%;
}
@keyframes shimmer {
  0% {
    background-position: -200% 0;
  }
  100% {
    background-position: 200% 0;
  }
}

/* ========== 空状态 ========== */
.empty-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 220rpx;
}
.empty-icon {
  font-size: 90rpx;
  opacity: 0.3;
  margin-bottom: 20rpx;
}
.empty-text {
  font-size: 28rpx;
  color: #bbb;
}
.empty-sub {
  font-size: 24rpx;
  color: #ccc;
  margin-top: 8rpx;
}
</style>
