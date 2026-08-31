<template>
  <view class="category-page">
    <!-- 标题 -->
    <page-nav title="苗木分类" />
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
          <product-card
            v-for="item in productList"
            :key="item.id"
            :item="item"
            :lines="2"
            :show-sales="true"
            :sales-text="(item.sales || 0) + '人付款'"
            @click="goDetail(item.id)"
          />
        </view>

        <!-- 空状态 -->
        <empty-state v-else icon="📭" text="该分类暂无商品" />

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

.search-bar {
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

/* 商品网格（卡片复用公共组件 <product-card>） */
.product-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  padding: 12rpx 4rpx 0;
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

/* 空状态（复用公共 .empty-state/.empty-icon/.empty-text） */
.safe-bottom { height: 40rpx; }
</style>
