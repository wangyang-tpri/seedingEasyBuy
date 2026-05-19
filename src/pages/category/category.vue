<template>
  <view class="category-page">
    <!-- 搜索栏 -->
    <view class="search-bar" @click="goPage('/pages/search/search')">
      <u-search placeholder="搜索苗木名称" :disabled="true" searchIconColor="#07C160" bgColor="#f5f6fa" shape="round"></u-search>
    </view>

    <!-- 主体 -->
    <view class="category-body">
      <!-- 左侧 -->
      <scroll-view scroll-y class="left-panel" :scroll-into-view="'c' + activeCategory" scroll-with-animation>
        <view v-for="cat in categories" :key="cat.id" :id="'c' + cat.id"
              :class="['left-item', { active: activeCategory === cat.id }]"
              hover-class="left-item-hover" @click="onCategoryClick(cat)">
          <text class="left-icon">{{ getCatIcon(cat.name) }}</text>
          <text class="left-name">{{ cat.name }}</text>
        </view>
      </scroll-view>

      <!-- 右侧 -->
      <scroll-view scroll-y class="right-panel" :scroll-top="rightScrollTop" scroll-with-animation>
        <!-- 分类横幅 -->
        <view class="cat-banner" v-if="activeCatName">
          <view class="cat-banner-inner">
            <text class="banner-emoji">{{ activeCatIcon }}</text>
            <text class="banner-title">{{ activeCatName }}</text>
          </view>
        </view>

        <!-- 子分类 -->
        <scroll-view v-if="subCategories.length > 0" scroll-x class="sub-tags" :show-scrollbar="false">
          <view v-for="sub in subCategories" :key="sub.id"
                :class="['sub-tag', { active: activeSub === sub.id }]"
                hover-class="sub-tag-hover" @click="onSubClick(sub)">
            {{ sub.name }}
          </view>
        </scroll-view>

        <!-- 加载中 -->
        <view class="loading-grid" v-if="loadingProduct">
          <view class="skeleton-card" v-for="i in 4" :key="i">
            <view class="sk-img"></view>
            <view class="sk-info">
              <view class="sk-line"></view>
              <view class="sk-line w60"></view>
            </view>
          </view>
        </view>

        <!-- 商品列表 -->
        <view class="product-grid" v-else-if="productList.length > 0">
          <view class="product-card" v-for="item in productList" :key="item.id"
                hover-class="product-card-hover" @click="goDetail(item.id)">
            <view class="img-wrap">
              <image :src="getFirstImage(item.images)" mode="aspectFill" class="product-img" lazy-load />
              <view class="img-tag" v-if="item.sales > 100">热销</view>
            </view>
            <view class="card-info">
              <text class="product-name">{{ item.name }}</text>
              <view class="card-bottom">
                <view class="price-col">
                  <text class="product-price">{{ formatPrice(item.price) }}</text>
                  <text class="product-original" v-if="item.originalPrice">¥{{ item.originalPrice }}</text>
                </view>
                <text class="product-sales">{{ item.sales || 0 }}人付款</text>
              </view>
            </view>
          </view>
        </view>

        <!-- 空状态 -->
        <view v-else class="empty-box">
          <view class="empty-icon">📭</view>
          <text class="empty-text">该分类暂无商品</text>
        </view>

        <view class="safe-bottom"></view>
      </scroll-view>
    </view>
  </view>
</template>

<script>
import { get } from '@/utils/request'

const CAT_ICONS = { '观赏植物': '🌸', '果树苗木': '🍎', '绿化苗木': '🌳', '多肉盆栽': '🌵', '种子种苗': '🌱' }

export default {
  data() {
    return {
      categories: [],
      activeCategory: 0,
      activeSub: 0,
      subCategories: [],
      productList: [],
      loadingProduct: false,
      rightScrollTop: 0
    }
  },
  computed: {
    activeCatName() {
      const found = this.categories.find(c => c.id === this.activeCategory)
      return found ? found.name : ''
    },
    activeCatIcon() {
      return CAT_ICONS[this.activeCatName] || '🌿'
    }
  },
  onLoad(options) {
    if (options.categoryId) this.activeCategory = Number(options.categoryId)
    this.loadCategories()
  },
  onShow() {
    const id = this.$store.state.selectedCategoryId
    if (id && id !== this.activeCategory && this.categories.length > 0) {
      this.$store.commit('SET_CATEGORY_ID', 0)
      const cat = this.categories.find(c => c.id === id)
      if (cat) this.onCategoryClick(cat)
    }
  },
  methods: {
    getCatIcon(name) { return CAT_ICONS[name] || '🌿' },

    async loadCategories() {
      try {
        this.categories = await get('/category/list') || []
        if (this.categories.length > 0) {
          const pendingId = this.$store.state.selectedCategoryId
          if (pendingId && !this.activeCategory && this.categories.find(c => c.id === pendingId)) {
            this.activeCategory = pendingId
            this.$store.commit('SET_CATEGORY_ID', 0)
          }
          if (!this.activeCategory || !this.categories.find(c => c.id === this.activeCategory)) {
            this.activeCategory = this.categories[0].id
          }
          const found = this.categories.find(c => c.id === this.activeCategory)
          if (found) {
            this.subCategories = found.children || []
            this.activeSub = this.subCategories.length > 0 ? this.subCategories[0].id : 0
          }
          this.loadProducts(this.activeSub || this.activeCategory)
        }
      } catch (e) {}
    },

    onCategoryClick(cat) {
      if (this.activeCategory === cat.id) return
      this.activeCategory = cat.id
      this.rightScrollTop = 0
      const found = this.categories.find(c => c.id === cat.id)
      this.subCategories = (found && found.children) || []
      this.activeSub = this.subCategories.length > 0 ? this.subCategories[0].id : 0
      this.productList = []
      this.loadProducts(this.activeSub || cat.id)
    },

    onSubClick(sub) {
      if (this.activeSub === sub.id) return
      this.activeSub = sub.id
      this.productList = []
      this.loadProducts(sub.id)
    },

    async loadProducts(categoryId) {
      this.loadingProduct = true
      try {
        const result = await get(`/product/page?categoryId=${categoryId}&size=20`)
        this.productList = (result && result.records) || []
      } catch (e) {}
      this.loadingProduct = false
    },

    goDetail(id) { uni.navigateTo({ url: `/pages/product/detail?id=${id}` }) }
  }
}
</script>

<style lang="scss" scoped>
/* ========== 整体 ========== */
.category-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: #f5f6fa;
}

.search-bar {
  padding: 16rpx 24rpx;
  padding-top: calc(var(--status-bar-height) + 36rpx);
  background: #fff;
}

.category-body {
  display: flex;
  flex: 1;
  overflow: hidden;
}

/* ========== 左侧 ========== */
.left-panel {
  width: 180rpx;
  background: #f5f6fa;
  padding-top: 4rpx;
}

.left-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 28rpx 8rpx;
  position: relative;
  min-height: 108rpx;
  transition: background 0.2s ease;
}

.left-item-hover {
  opacity: 0.7;
}

.left-item.active {
  background: #fff;
}

.left-item.active::after {
  content: '';
  position: absolute;
  left: 0;
  top: 50%;
  transform: translateY(-50%);
  width: 5rpx;
  height: 40rpx;
  background: #07C160;
  border-radius: 0 3rpx 3rpx 0;
}

.left-icon {
  font-size: 34rpx;
  margin-bottom: 10rpx;
  transition: transform 0.2s ease;
}

.left-item.active .left-icon {
  transform: scale(1.15);
}

.left-name {
  font-size: 24rpx;
  color: #888;
  text-align: center;
  font-weight: 500;
  line-height: 1.3;
  transition: color 0.2s ease;
}

.left-item.active .left-name {
  color: #07C160;
}

/* ========== 右侧 ========== */
.right-panel {
  flex: 1;
  background: #fff;
  border-radius: 24rpx 0 0 0;
  margin-left: -12rpx;
  padding: 0 20rpx 0 16rpx;
}

.cat-banner {
  margin: 20rpx 0 8rpx;
}

.cat-banner-inner {
  display: flex;
  align-items: center;
  padding: 24rpx 28rpx;
  background: linear-gradient(135deg, #e8f8ee 0%, #f5faf7 100%);
  border-radius: 16rpx;
}

.banner-emoji {
  font-size: 48rpx;
  margin-right: 20rpx;
}

.banner-title {
  font-size: 30rpx;
  font-weight: 600;
  color: #1a1a1a;
}

/* 子分类 */
.sub-tags {
  white-space: nowrap;
  padding: 12rpx 0 8rpx;
}

.sub-tag {
  display: inline-block;
  padding: 12rpx 28rpx;
  margin-right: 12rpx;
  border-radius: 24rpx;
  font-size: 24rpx;
  color: #666;
  background: #f5f6fa;
  transition: all 0.2s ease;
  line-height: 1.4;
}

.sub-tag-hover {
  opacity: 0.75;
}

.sub-tag.active {
  background: #07C160;
  color: #fff;
  font-weight: 500;
}

/* 商品网格 */
.product-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}

.product-card {
  width: calc(50% - 6rpx);
  background: #fff;
  border-radius: 14rpx;
  overflow: hidden;
  margin-bottom: 14rpx;
  box-shadow: 0 1rpx 8rpx rgba(0,0,0,0.04);
  transition: all 0.18s ease;
}

.product-card-hover {
  transform: scale(0.97);
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.08);
}

.img-wrap {
  position: relative;
}

.product-img {
  width: 100%;
  height: 220rpx;
  display: block;
  background: #f0f0f0;
}

.img-tag {
  position: absolute;
  top: 8rpx;
  left: 8rpx;
  background: linear-gradient(135deg, #FF6B35, #ff5c2a);
  color: #fff;
  font-size: 18rpx;
  padding: 2rpx 10rpx;
  border-radius: 4rpx;
  font-weight: 500;
  letter-spacing: 1rpx;
}

.card-info {
  padding: 14rpx 14rpx 16rpx;
}

.product-name {
  font-size: 26rpx;
  color: #333;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  line-height: 1.45;
  min-height: 74rpx;
  font-weight: 500;
}

.card-bottom {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  margin-top: 10rpx;
}

.price-col {
  display: flex;
  align-items: baseline;
  gap: 6rpx;
}

.product-price {
  font-size: 30rpx;
  color: #FF6B35;
  font-weight: 700;
  letter-spacing: -1rpx;
}

.product-original {
  font-size: 20rpx;
  color: #bbb;
  text-decoration: line-through;
}

.product-sales {
  font-size: 18rpx;
  color: #bbb;
}

/* 骨架 */
.loading-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}

.skeleton-card {
  width: calc(50% - 6rpx);
  background: #fff;
  border-radius: 14rpx;
  overflow: hidden;
  margin-bottom: 14rpx;
}

.sk-img {
  width: 100%;
  height: 220rpx;
  background: linear-gradient(90deg, #f5f5f5 25%, #efefef 50%, #f5f5f5 75%);
  background-size: 200% 100%;
  animation: shimmer 1.6s ease infinite;
}

.sk-info {
  padding: 14rpx 14rpx 16rpx;
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
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

/* 空状态 */
.empty-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 200rpx;
}

.empty-icon {
  font-size: 80rpx;
  margin-bottom: 20rpx;
  opacity: 0.3;
}

.empty-text {
  font-size: 26rpx;
  color: #bbb;
}

.safe-bottom {
  height: 40rpx;
}
</style>
