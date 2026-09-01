<template>
  <view class="home-page">
    <!-- 固定头部 -->
    <view class="header-fixed">
      <page-nav title="苗木易购" />
      <view class="search-bar">
        <view class="search-box" @click="goPage('/pages/search/search')">
          <u-search
            placeholder="搜索苗木"
            :disabled="true"
            searchIconColor="#07C160"
            bgColor="#f5f6fa"
          ></u-search>
        </view>
        <view class="add-btn" @click="onAddClick">
          <text class="add-icon">+</text>
        </view>
      </view>
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
        :title="true"
        @click="onBannerClick"
      ></u-swiper>
      <view v-else class="placeholder-banner">
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

    <!-- 限时特惠 - 横向滚动大卡片 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">限时特惠</text>
        <text
          class="section-more"
          @click="switchTab('/pages/category/category')"
          >更多 ></text
        >
      </view>
      <scroll-view
        v-if="recommendList.length > 0"
        scroll-x
        class="flash-scroll"
      >
        <view
          class="flash-card"
          v-for="item in recommendList.slice(0, 4)"
          :key="item.id"
          @click="goDetail(item.id)"
        >
          <image
            :src="getFirstImage(item.images)"
            mode="aspectFill"
            class="flash-img"
          />
          <view class="flash-tag">特惠</view>
          <view class="flash-info">
            <text class="flash-name">{{ item.name }}</text>
            <view class="flash-bottom">
              <text class="flash-price">{{ formatPrice(item.price) }}</text>
              <text class="flash-original" v-if="item.originalPrice"
                >¥{{ item.originalPrice }}</text
              >
            </view>
            <text class="flash-sales">已售 {{ item.sales || 0 }}</text>
          </view>
        </view>
      </scroll-view>
      <view v-else class="placeholder-row">
        <view class="placeholder-card" v-for="i in 3" :key="'p' + i">
          <view class="placeholder-img"></view>
          <view class="placeholder-line"></view>
          <view class="placeholder-line short"></view>
        </view>
      </view>
    </view>

    <!-- 新品上架 - 2列网格 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">新品上架</text>
        <text class="section-more" @click="goPage('/pages/product/list')"
          >更多 ></text
        >
      </view>
      <view v-if="newList.length > 0" class="new-grid">
        <product-card
          v-for="item in newList.slice(0, 4)"
          :key="item.id"
          :item="item"
          tag="2"
          :show-original="false"
          @click="goDetail(item.id)"
        />
      </view>
      <view v-else class="new-grid">
        <view class="placeholder-card" v-for="i in 4" :key="'n' + i">
          <view class="placeholder-img"></view>
          <view class="placeholder-line"></view>
          <view class="placeholder-line short"></view>
        </view>
      </view>
    </view>

    <!-- 热门推荐 - 纵向列表 -->
    <view class="section">
      <view class="section-header">
        <text class="section-title">热门推荐</text>
        <text
          class="section-more"
          @click="switchTab('/pages/category/category')"
          >更多 ></text
        >
      </view>
      <view v-if="hotList.length > 0" class="hot-list">
        <view
          class="hot-card"
          v-for="item in hotList"
          :key="item.id"
          @click="goDetail(item.id)"
        >
          <image
            :src="getFirstImage(item.images)"
            mode="aspectFill"
            class="hot-img"
          />
          <view class="hot-info">
            <text class="hot-name">{{ item.name }}</text>
            <view class="hot-meta">
              <text class="hot-price">{{ formatPrice(item.price) }}</text>
              <text class="hot-sales">已售 {{ item.sales || 0 }}</text>
            </view>
          </view>
        </view>
      </view>
      <view v-else class="placeholder-row">
        <view class="placeholder-card" v-for="i in 3" :key="'h' + i">
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
        return { image: url, title: item.title };
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
    onBannerClick(index) {
      const banner = this.banners[index];
      if (banner && banner.linkType === 1 && banner.linkValue) {
        uni.navigateTo({ url: "/pages/product/detail?id=" + banner.linkValue });
      }
    },
    onAddClick() {
      if (this.isLogin) {
        uni.navigateTo({ url: "/pages/mine/product/add" });
      } else {
        uni.navigateTo({ url: "/pages/mine/login" });
      }
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
.header-fixed {
  position: sticky;
  top: 0;
  z-index: 100;
  background: $bg-white;
}
.search-bar {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.search-box {
  flex: 1;
  min-width: 0;
}
.add-btn {
  width: 40rpx;
  height: 40rpx;
  border-radius: 50%;
  background: $gradient-green;
  box-shadow: 0 2rpx 8rpx rgba(7, 193, 96, 0.3);
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
}
.add-icon {
  color: $bg-white;
  font-size: 32rpx;
  font-weight: 500;
  margin-top: -3rpx;
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
  margin: 0 auto 20rpx;
}
.category-name {
  font-size: 26rpx;
  font-weight: bold;
  color: $text-primary;
}

/* 区块 */
.section {
  margin: 0 30rpx 30rpx;
}

/* 商品卡片 - 网格 */
.flash-scroll {
  white-space: nowrap;
}
.flash-card {
  display: inline-block;
  width: 300rpx;
  margin-right: 16rpx;
  background: $bg-white;
  border-radius: 14rpx;
  overflow: hidden;
  box-shadow: $shadow-md;
  position: relative;
  &:last-child {
    margin-right: 0;
  }
}
.flash-img {
  width: 300rpx;
  height: 220rpx;
  display: block;
  background: $bg-input;
}
.flash-tag {
  position: absolute;
  top: 0;
  left: 0;
  background: $gradient-orange;
  color: $bg-white;
  font-size: 20rpx;
  font-weight: 600;
  padding: 6rpx 16rpx;
  border-radius: 0 0 10rpx 0;
}
.flash-info {
  padding: 16rpx 18rpx;
}
.flash-name {
  font-size: 26rpx;
  color: $text-primary;
  font-weight: 500;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.flash-bottom {
  display: flex;
  align-items: baseline;
  gap: 10rpx;
  margin-top: 8rpx;
}
.flash-price {
  font-size: 32rpx;
  color: $accent-orange;
  font-weight: 700;
}
.flash-original {
  font-size: 22rpx;
  color: $text-placeholder;
  text-decoration: line-through;
}
.flash-sales {
  font-size: 20rpx;
  color: $text-hint;
  margin-top: 4rpx;
  display: block;
}

.new-grid {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}
/* 新品卡片复用公共组件 <product-card> */

.hot-list {
}
.hot-card {
  display: flex;
  background: $bg-white;
  border-radius: 12rpx;
  overflow: hidden;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.06);
  padding: 16rpx;
}
.hot-img {
  width: 160rpx;
  height: 160rpx;
  border-radius: 10rpx;
  flex-shrink: 0;
  background: $bg-input;
  margin-right: 20rpx;
}
.hot-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.hot-name {
  font-size: 28rpx;
  color: $text-primary;
  font-weight: 500;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  line-height: 1.4;
}
.hot-meta {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-top: 12rpx;
}
.hot-price {
  font-size: 30rpx;
  color: $accent-orange;
  font-weight: 700;
}
.hot-sales {
  font-size: 22rpx;
  color: $text-hint;
}

.placeholder-row {
  display: flex;
  gap: 16rpx;
}
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
