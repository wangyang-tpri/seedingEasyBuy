<template>
  <view class="category-page">
    <!-- 标题 -->
    <view class="nav-bar">
      <text class="nav-title">苗木分类</text>
    </view>
    <!-- 搜索栏 -->
    <view class="search-bar">
      <u-search
        placeholder="搜索苗木名称"
        :disabled="true"
        searchIconColor="#07C160"
        bgColor="#f5f6fa"
        shape="round"
        @click="goPage('/pages/search/search')"
      ></u-search>
    </view>

    <!-- 主体 -->
    <view class="category-body">
      <!-- 左侧 -->
      <scroll-view
        scroll-y
        class="left-panel"
        :scroll-into-view="'c' + activeCategory"
      >
        <view
          v-for="cat in categories"
          :key="cat.id"
          :id="'c' + cat.id"
          :class="['left-item', { active: activeCategory === cat.id }]"
          hover-class="left-item-hover"
          @click="onCategoryClick(cat)"
        >
          <text class="left-icon">{{ getCatIcon(cat.name) }}</text>
          <text class="left-name">{{ cat.name }}</text>
        </view>
      </scroll-view>

      <!-- 右侧 -->
      <scroll-view scroll-y class="right-panel" :scroll-top="rightScrollTop">
        <!-- 分类横幅 -->
        <view class="cat-banner" v-if="activeCatName">
          <text class="banner-emoji">{{ activeCatIcon }}</text>
          <view class="banner-info">
            <text class="banner-title">{{ activeCatName }}</text>
            <text class="banner-count">共 {{ productList.length }} 件商品</text>
          </view>
        </view>

        <!-- 子分类 -->
        <scroll-view
          v-if="subCategories.length > 0"
          scroll-x
          class="sub-tags"
          :show-scrollbar="false"
        >
          <view
            v-for="sub in subCategories"
            :key="sub.id"
            :class="['sub-tag', { active: activeSub === sub.id }]"
            hover-class="sub-tag-hover"
            @click="onSubClick(sub)"
          >
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
          <view
            class="product-card"
            v-for="item in productList"
            :key="item.id"
            hover-class="product-card-hover"
            @click="goDetail(item.id)"
          >
            <view class="img-wrap">
              <image
                :src="getFirstImage(item.images)"
                mode="aspectFill"
                class="product-img"
                lazy-load
              />
              <view class="img-tag hot" v-if="item.tag === 1">特惠</view>
              <view class="img-tag new" v-else-if="item.tag === 2">新品</view>
              <view class="img-tag hot" v-else-if="item.sales > 100">热销</view>
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
import { get } from "@/utils/request";

const CAT_ICONS = {
  观赏植物: "🌸",
  果树苗木: "🍎",
  绿化苗木: "🌳",
  多肉盆栽: "🌵",
  种子种苗: "🌱",
};

export default {
  data() {
    return {
      categories: [],
      activeCategory: 0,
      activeSub: 0,
      subCategories: [],
      productList: [],
      loadingProduct: false,
      rightScrollTop: 0,
    };
  },
  computed: {
    activeCatName() {
      const found = this.categories.find((c) => c.id === this.activeCategory);
      return found ? found.name : "";
    },
    activeCatIcon() {
      return CAT_ICONS[this.activeCatName] || "🌿";
    },
  },
  onLoad(options) {
    if (options.categoryId) this.activeCategory = Number(options.categoryId);
    this.loadCategories();
  },
  onShow() {
    const id = this.$store.state.selectedCategoryId;
    if (id && id !== this.activeCategory && this.categories.length > 0) {
      this.$store.commit("SET_CATEGORY_ID", 0);
      const cat = this.categories.find((c) => c.id === id);
      if (cat) this.onCategoryClick(cat);
    }
  },
  methods: {
    getCatIcon(name) { return CAT_ICONS[name] || "🌿"; },
    async loadCategories() {
      try {
        this.categories = (await get("/category/list")) || [];
        if (this.categories.length > 0) {
          const pendingId = this.$store.state.selectedCategoryId;
          if (pendingId && !this.activeCategory && this.categories.find((c) => c.id === pendingId)) {
            this.activeCategory = pendingId;
            this.$store.commit("SET_CATEGORY_ID", 0);
          }
          if (!this.activeCategory || !this.categories.find((c) => c.id === this.activeCategory)) {
            this.activeCategory = this.categories[0].id;
          }
          const found = this.categories.find((c) => c.id === this.activeCategory);
          if (found) {
            this.subCategories = found.children || [];
            this.activeSub = this.subCategories.length > 0 ? this.subCategories[0].id : 0;
          }
          this.loadProducts(this.activeSub || this.activeCategory);
        }
      } catch (e) {}
    },
    onCategoryClick(cat) {
      if (this.activeCategory === cat.id) return;
      this.activeCategory = cat.id;
      this.rightScrollTop = 0;
      this.loadingProduct = true;
      const found = this.categories.find((c) => c.id === cat.id);
      this.subCategories = (found && found.children) || [];
      this.activeSub = this.subCategories.length > 0 ? this.subCategories[0].id : 0;
      this.productList = [];
      this.loadProducts(this.activeSub || cat.id);
    },
    onSubClick(sub) {
      if (this.activeSub === sub.id) return;
      this.activeSub = sub.id;
      this.productList = [];
      this.loadProducts(sub.id);
    },
    async loadProducts(categoryId) {
      this.loadingProduct = true;
      try {
        const result = await get(`/product/page?categoryId=${categoryId}&size=20`);
        this.productList = (result && result.records) || [];
      } catch (e) {}
      this.loadingProduct = false;
    },
    goDetail(id) { uni.navigateTo({ url: `/pages/product/detail?id=${id}` }); },
  },
};
</script>

<style lang="scss" scoped>
.category-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $bg-white;
}

.nav-bar {
  padding: calc(var(--status-bar-height) + 50rpx) 30rpx 16rpx;
  background: $bg-white;
  text-align: center;
}
.nav-title {
  font-size: 36rpx;
  font-weight: 700;
  color: $text-primary;
}
.search-bar {
  padding: 12rpx 30rpx 20rpx;
  background: $bg-white;
  box-shadow: 0 1rpx 0 rgba(0,0,0,0.04);
  z-index: 10;
}

.category-body {
  display: flex;
  flex: 1;
  overflow: hidden;
}

/* ========== 左侧 ========== */
.left-panel {
  width: 170rpx;
  background: #f7f8fa;
  flex-shrink: 0;
}
.left-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 24rpx 4rpx;
  position: relative;
  min-height: 100rpx;
}
.left-item-hover { opacity: 0.7; }
.left-item.active {
  background: $bg-white;
  &::before {
    content: '';
    position: absolute;
    left: 0;
    top: 20rpx;
    bottom: 20rpx;
    width: 4rpx;
    background: $primary-color;
    border-radius: 0 2rpx 2rpx 0;
  }
}
.left-icon {
  font-size: 32rpx;
  margin-bottom: 8rpx;
  transition: transform 0.2s;
}
.left-item.active .left-icon {
  transform: scale(1.12);
}
.left-name {
  font-size: 22rpx;
  color: $text-hint;
  font-weight: 500;
  line-height: 1.3;
}
.left-item.active .left-name {
  color: $primary-color;
  font-weight: 600;
}

/* ========== 右侧 ========== */
.right-panel {
  flex: 1;
  background: $bg-white;
  padding: 0 16rpx;
}

/* 分类横幅 */
.cat-banner {
  display: flex;
  align-items: center;
  margin: 16rpx 0 4rpx;
  padding: 20rpx 24rpx;
  background: linear-gradient(135deg, #f0faf2 0%, #f8fdf9 100%);
  border-radius: 14rpx;
}
.banner-emoji {
  font-size: 44rpx;
  margin-right: 18rpx;
}
.banner-info {
  flex: 1;
}
.banner-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #1a1a1a;
  display: block;
}
.banner-count {
  font-size: 22rpx;
  color: $text-hint;
  margin-top: 4rpx;
}

/* 子分类 */
.sub-tags {
  white-space: nowrap;
  padding: 12rpx 0 4rpx;
}
.sub-tag {
  display: inline-block;
  padding: 10rpx 24rpx;
  margin-right: 10rpx;
  border-radius: 20rpx;
  font-size: 23rpx;
  color: $text-secondary;
  background: #f5f6fa;
  transition: all 0.2s;
  line-height: 1.4;
}
.sub-tag-hover { opacity: 0.75; }
.sub-tag.active {
  background: $primary-color;
  color: $bg-white;
  font-weight: 500;
}

/* 商品网格 */
.product-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  padding: 12rpx 4rpx 0;
}
.product-card {
  width: calc(50% - 8rpx);
  background: $bg-white;
  border-radius: $radius-lg;
  overflow: hidden;
  margin-bottom: 12rpx;
  box-shadow: $shadow-md;
}
.product-card-hover {
  transform: scale(0.98);
  box-shadow: 0 4rpx 16rpx rgba(0,0,0,0.1);
}

.img-wrap {
  position: relative;
  width: 100%;
  overflow: hidden;
}
.product-img {
  width: 100%;
  height: 200rpx;
  display: block;
  background: $bg-input;
}
.img-tag {
  position: absolute;
  top: 6rpx;
  left: 6rpx;
  background: $gradient-orange;
  color: $bg-white;
  font-size: 18rpx;
  padding: 3rpx 8rpx;
  border-radius: $radius-sm;
  font-weight: 600;
  &.hot { background: $gradient-orange; }
  &.new { background: $gradient-green; }
}

.card-info {
  padding: 10rpx 14rpx 14rpx;
}
.product-name {
  font-size: 25rpx;
  color: $text-primary;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
}
.card-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 6rpx;
}
.price-col {
  display: flex;
  align-items: baseline;
  gap: 6rpx;
}
.product-price {
  font-size: 28rpx;
  color: $accent-orange;
  font-weight: 700;
}
.product-original {
  font-size: 18rpx;
  color: $text-placeholder;
  text-decoration: line-through;
}
.product-sales {
  font-size: 18rpx;
  color: $text-placeholder;
}

/* 骨架 */
.loading-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  padding: 12rpx 4rpx 0;
}
.skeleton-card {
  width: calc(50% - 8rpx);
  background: $bg-white;
  border-radius: $radius-lg;
  overflow: hidden;
  margin-bottom: 12rpx;
}
.sk-img {
  width: 100%;
  height: 200rpx;
  background: linear-gradient(90deg, #f5f5f5 25%, #eee 50%, #f5f5f5 75%);
  background-size: 200% 100%;
  animation: shimmer 1.6s ease infinite;
}
.sk-info { padding: 10rpx 14rpx 14rpx; }
.sk-line { height: 16rpx; background: #f3f3f3; border-radius: 3rpx; margin-bottom: 10rpx; }
.sk-line.w60 { width: 60%; }

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

/* 空状态 */
.empty-box {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 180rpx;
}
.empty-icon { font-size: 72rpx; opacity: 0.2; margin-bottom: 16rpx; }
.empty-text { font-size: 26rpx; color: $text-placeholder; }

.safe-bottom { height: 40rpx; }
</style>
