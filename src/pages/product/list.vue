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
      <template #loading>
        <view class="product-grid">
          <view class="skeleton-card-2" v-for="i in 6" :key="'s' + i">
            <view class="skeleton-img"></view>
            <view class="sk-info">
              <view class="skeleton-line"></view>
              <view class="skeleton-line skeleton-line-w60"></view>
            </view>
          </view>
        </view>
      </template>

      <!-- 商品网格 -->
      <view class="product-grid" v-if="productList.length > 0">
        <product-card
          v-for="item in productList"
          :key="item.id"
          :item="item"
          :show-original="item.originalPrice && item.originalPrice > item.price"
          :show-sales="true"
          @click="goDetail(item.id)"
        />
      </view>

      <!-- 空状态 -->
      <template #empty>
        <empty-state icon="📭" text="暂无商品" sub="换个关键词试试吧" />
      </template>
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
      try {
        const result = await get(
          `/product/page?categoryId=${this.categoryId}&sortBy=${this.sortBy}&current=${pageNo}&size=${pageSize}`
        );
        const records = (result && result.records) || [];
        this.$refs.paging.complete(records);
      } catch (e) {
        this.$refs.paging.complete(false);
      }
    },
    switchSort(key) {
      if (this.sortBy === key) return;
      this.sortBy = key;
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
  background: $bg-page;
}

/* ========== 搜索栏（复用公共 .search-bar） ========== */
.search-box {
  display: flex;
  align-items: center;
  background: $bg-page;
  border-radius: 36rpx;
  padding: 16rpx 24rpx;
}
.search-placeholder {
  font-size: 26rpx;
  color: $text-placeholder;
  margin-left: 12rpx;
}

/* ========== 排序栏 ========== */
.sort-row {
  display: flex;
  background: $bg-white;
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
  color: $primary-color;
  font-weight: 600;
}
.sort-indicator {
  width: 24rpx;
  height: 4rpx;
  background: $primary-color;
  border-radius: 2rpx;
  margin-top: 6rpx;
}

/* ========== 商品网格 ========== */
.product-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  padding: 24rpx 24rpx 12rpx;
} /* 容器内边距页面自定，卡片复用 .product-card-2 */

/* ========== 商品卡片（复用公共组件 <product-card>） ========== */

/* ========== 骨架屏（复用 .skeleton-card-2/.skeleton-img/.skeleton-line） ========== */
.sk-info {
  padding: 16rpx 16rpx 18rpx;
}

/* ========== 空状态（复用 <empty-state>） ========== */
</style>
