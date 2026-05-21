<template>
  <view class="home-page">
    <!-- 搜索栏 -->
    <view class="search-bar" @click="goPage('/pages/search/search')">
      <u-search
        placeholder="搜索苗木"
        :disabled="true"
        searchIconColor="#07C160"
        bgColor="#f5f6fa"
      ></u-search>
    </view>

    <!-- 轮播图 -->
    <view class="banner-wrap">
      <u-swiper
        v-if="bannerList.length > 0"
        :list="bannerList"
        height="340rpx"
        radius="12"
        :autoplay="true"
        keyName="image"
        circular
      ></u-swiper>
      <view v-else class="placeholder-banner">
        <text class="placeholder-icon">📷</text>
        <text class="placeholder-text">暂无轮播图</text>
      </view>
    </view>

    <!-- 分类导航 -->
    <view class="category-grid">
      <view
        class="category-item"
        v-for="cat in categories"
        :key="cat.id"
        @click="goCategory(cat)"
      >
        <view
          class="category-icon"
          :style="{
            background: getCatColor(cat.id).bg,
            color: getCatColor(cat.id).text,
          }"
          >{{ cat.name.charAt(0) }}</view
        >
        <text class="category-name">{{ cat.name }}</text>
      </view>
      <view v-if="categories.length === 0" class="empty-full">
        <text class="placeholder-text">暂无分类</text>
      </view>
    </view>

    <!-- 限时特惠 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">限时特惠</text>
        <text
          class="section-more"
          @click="switchTab('/pages/category/category')"
          >更多 ></text
        >
      </view>
      <view v-if="recommendList.length > 0" class="product-grid">
        <view
          class="product-card"
          v-for="item in recommendList.slice(0, 4)"
          :key="item.id"
          @click="goDetail(item.id)"
        >
          <image
            :src="getFirstImage(item.images)"
            mode="aspectFill"
            class="product-img"
          />
          <text class="product-name">{{ item.name }}</text>
          <text class="product-price">{{ formatPrice(item.price) }}</text>
          <text class="product-sales">已售 {{ item.sales || 0 }}</text>
        </view>
      </view>
      <view v-else class="product-grid">
        <view class="placeholder-card" v-for="i in 4" :key="'p' + i">
          <view class="placeholder-img"></view>
          <view class="placeholder-line"></view>
          <view class="placeholder-line short"></view>
        </view>
      </view>
    </view>

    <!-- 新品上架 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">新品上架</text>
        <text class="section-more" @click="goPage('/pages/product/list')"
          >更多 ></text
        >
      </view>
      <view v-if="newList.length > 0" class="product-grid">
        <view
          class="product-card"
          v-for="item in newList.slice(0, 4)"
          :key="item.id"
          @click="goDetail(item.id)"
        >
          <image
            :src="getFirstImage(item.images)"
            mode="aspectFill"
            class="product-img"
          />
          <text class="product-name">{{ item.name }}</text>
          <text class="product-price">{{ formatPrice(item.price) }}</text>
        </view>
      </view>
      <view v-else class="product-grid">
        <view class="placeholder-card" v-for="i in 4" :key="'n' + i">
          <view class="placeholder-img"></view>
          <view class="placeholder-line"></view>
          <view class="placeholder-line short"></view>
        </view>
      </view>
    </view>

    <!-- 热门推荐 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">热门推荐</text>
        <text
          class="section-more"
          @click="switchTab('/pages/category/category')"
          >更多 ></text
        >
      </view>
      <view v-if="hotList.length > 0" class="product-grid">
        <view
          class="product-card"
          v-for="item in hotList"
          :key="item.id"
          @click="goDetail(item.id)"
        >
          <image
            :src="getFirstImage(item.images)"
            mode="aspectFill"
            class="product-img"
          />
          <text class="product-name">{{ item.name }}</text>
          <text class="product-price">{{ formatPrice(item.price) }}</text>
          <text class="product-sales">已售 {{ item.sales || 0 }}</text>
        </view>
      </view>
      <view v-else class="product-grid">
        <view class="placeholder-card" v-for="i in 4" :key="'h' + i">
          <view class="placeholder-img"></view>
          <view class="placeholder-line"></view>
          <view class="placeholder-line short"></view>
        </view>
      </view>
    </view>

    <view class="footer-space"></view>
  </view>
</template>

<script>
import { get } from "@/utils/request";
export default {
  data() {
    return {
      banners: [],
      categories: [],
      recommendList: [],
      newList: [],
      hotList: [],
      loading: false,
      loaded: false,
    };
  },
  computed: {
    bannerList() {
      const base = this.getBaseUrl();
      return this.banners.map((item) => {
        let url = item.imageUrl;
        if (url && url.startsWith("/api/") && base) {
          url = base + url.substring(4);
        }
        return { image: url };
      });
    },
  },
  onShow() {
    this.loadData(!this.loaded);
  },
  onPullDownRefresh() {
    this.loadData(false);
  },
  methods: {
    async loadData(showLoading = false) {
      if (this.loading) return;
      this.loading = true;
      if (showLoading) {
        uni.showLoading({ title: "加载中", mask: true });
      }
      try {
        const [banners, categories, recommends, newProducts] =
          await Promise.all([
            get("/banner/list"),
            get("/category/list"),
            get("/product/recommend?size=6"),
            get("/product/new?size=6"),
          ]);
        this.banners = banners || [];
        this.categories = (categories || []).slice(0, 5);
        this.recommendList = (recommends && recommends.records) || [];
        this.newList = (newProducts && newProducts.records) || [];
        this.hotList =
          this.recommendList.length > 0
            ? this.recommendList.slice().reverse()
            : [];
        this.loaded = true;
      } catch (e) {
        if (showLoading) {
          uni.showToast({ title: "加载失败，下拉刷新重试", icon: "none" });
        }
      } finally {
        if (showLoading) {
          uni.hideLoading();
        }
        uni.stopPullDownRefresh();
        this.loading = false;
      }
    },
    getCatColor(id) {
      const colors = {
        1: { bg: "#FFF0F5", text: "#E85D75" },
        2: { bg: "#FFF7E6", text: "#E8A44C" },
        3: { bg: "#E8F8EE", text: "$primary-color" },
        4: { bg: "#EDF4FF", text: "#4A90D9" },
        5: { bg: "#FFF3E0", text: "#E67E22" },
      };
      return colors[id] || { bg: "$bg-page", text: "$text-hint" };
    },
    goCategory(cat) {
      this.$store.commit("SET_CATEGORY_ID", cat.id);
      uni.switchTab({ url: "/pages/category/category" });
    },
    goDetail(id) {
      uni.navigateTo({ url: `/pages/product/detail?id=${id}` });
    },
  },
};
</script>

<style lang="scss" scoped>
.home-page {
  padding-bottom: 20rpx;
}
.search-bar {
  padding: 20rpx 30rpx;
  padding-top: calc(var(--status-bar-height) + 40rpx);
  background: $bg-white;
}
.banner-wrap {
  margin: 20rpx 30rpx;
}

/* 轮播图占位 */
.placeholder-banner {
  height: 340rpx;
  border-radius: 12rpx;
  background: $bg-input;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.placeholder-icon {
  font-size: 60rpx;
  margin-bottom: 16rpx;
}
.placeholder-text {
  font-size: 24rpx;
  color: $text-placeholder;
}

/* 分类 */
.category-grid {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  padding: 30rpx 30rpx 10rpx;
  background: $bg-white;
  margin: 0 30rpx 20rpx;
  border-radius: 12rpx;
  min-height: 160rpx;
}
.category-item {
  width: 20%;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin-bottom: 20rpx;
}
.category-icon {
  width: 80rpx;
  height: 80rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;

  font-size: 32rpx;
  font-weight: bold;
  margin: 0 auto 10rpx;
}
.category-name {
  font-size: 22rpx;
  color: $text-primary;
}

/* 区块 */
.section {
  margin: 0 30rpx 30rpx;
}
.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20rpx;
}
.section-title {
  font-size: 32rpx;
  font-weight: bold;
  color: $text-primary;
  padding-left: 16rpx;
  position: relative;
}
.section-title::before {
  content: "";
  position: absolute;
  left: 0;
  top: 6rpx;
  bottom: 6rpx;
  width: 6rpx;
  background: $primary-color;
  border-radius: 3rpx;
}
.section-more {
  font-size: 24rpx;
  color: $text-hint;
}

/* 商品卡片 - 网格 */
.product-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}
.product-card {
  width: calc(50% - 10rpx);
  background: $bg-white;
  border-radius: 12rpx;
  overflow: hidden;
  margin-bottom: 20rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.08);
}
.product-img {
  width: 100%;
  height: 200rpx;
  display: block;
}
.product-name {
  display: block;
  font-size: 26rpx;
  color: $text-primary;
  padding: 10rpx 16rpx 0;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.product-price {
  display: block;
  font-size: 30rpx;
  color: $accent-orange;
  font-weight: bold;
  padding: 6rpx 16rpx 0;
}
.product-sales {
  display: block;
  font-size: 22rpx;
  color: $text-hint;
  padding: 4rpx 16rpx 16rpx;
}

/* 骨架占位 */
.placeholder-card {
  width: calc(50% - 10rpx);
  background: $bg-white;
  border-radius: 12rpx;
  overflow: hidden;
  margin-bottom: 20rpx;
}
.placeholder-img {
  width: 100%;
  height: 200rpx;
  background: $bg-input;
}
.placeholder-line {
  height: 20rpx;
  background: $bg-input;
  border-radius: 4rpx;
  margin: 16rpx 16rpx 0;
}
.placeholder-line.short {
  width: 60%;
  margin-top: 12rpx;
  margin-bottom: 16rpx;
}

.empty-full {
  width: 100%;
  text-align: center;
  padding: 40rpx 0;
}
.footer-space {
  height: 40rpx;
}
</style>
