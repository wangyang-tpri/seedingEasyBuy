<template>
  <view class="detail-page" v-if="product">
    <!-- 图片轮播 / 视频 -->
    <view class="swiper-wrap">
      <u-swiper
        v-if="!showVideo"
        :list="imageList"
        height="600rpx"
        :autoplay="true"
        keyName="image"
        circular
        radius="12"
      ></u-swiper>
      <video
        v-else
        :src="videoUrl"
        class="swiper-video"
        autoplay
        loop
        muted
        controls
      ></video>
      <view
        v-if="hasVideo"
        class="media-toggle"
        @click.stop="showVideo = !showVideo"
      >
        <text>{{ showVideo ? '图片' : '视频' }}</text>
      </view>
    </view>

    <!-- 价格信息 -->
    <view class="price-section">
      <text class="current-price">{{
        formatPrice(selectedSku ? selectedSku.price : product.price)
      }}</text>
      <text class="original-price" v-if="product.originalPrice"
        >¥{{ product.originalPrice }}</text
      >
      <text class="sales-text">已售 {{ product.sales || 0 }}件</text>
    </view>

    <!-- 商品名称 -->
    <view class="name-section">
      <text class="product-name">{{ product.name }}</text>
      <text class="product-subtitle" v-if="product.subtitle">{{
        product.subtitle
      }}</text>
    </view>

    <!-- SKU选择 -->
    <view class="sku-section" v-if="skus.length > 0">
      <view class="sku-header" @click="showSku = true">
        <text class="sku-label"
          >已选: {{ selectedSku ? selectedSku.skuName : "请选择规格" }}</text
        >
        <u-icon name="arrow-right" color="#999"></u-icon>
      </view>
    </view>

    <!-- 数量 -->
    <view class="qty-section">
      <text>购买数量</text>
      <u-number-box
        :value="quantity"
        :min="1"
        @change="(val) => (quantity = val.value)"
      ></u-number-box>
    </view>

    <!-- 商品详情 -->
    <view class="section-title">商品详情</view>
    <view class="desc-content" v-if="product.description">
      <rich-text :nodes="product.description"></rich-text>
    </view>

    <!-- 规格参数 -->
    <view class="specs-table" v-if="product.specs">
      <view class="spec-title">规格参数</view>
      <view class="spec-row" v-for="(val, key) in parseSpecs()" :key="key">
        <text class="spec-key">{{ key }}</text>
        <text class="spec-val">{{ val }}</text>
      </view>
    </view>

    <!-- 联系信息 -->
    <view class="specs-table" v-if="product.contactPhone || product.address">
      <view class="spec-title">联系信息</view>
      <view class="spec-row" v-if="product.contactPhone">
        <text class="spec-key spec-label-bold">联系电话</text>
        <text class="spec-val spec-phone">{{ product.contactPhone }}</text>
      </view>
      <view class="spec-row" v-if="product.address">
        <text class="spec-key">发货地址</text>
        <text class="spec-val">{{ product.address }}</text>
      </view>
    </view>

    <!-- 底部操作栏 -->
    <view class="bottom-bar">
      <view class="bottom-icons">
        <view class="bottom-icon" @click="goPage('/pages/cart/cart')"
          ><text class="bi-text">🛒</text
          ><text class="bi-label">购物车</text></view
        >
        <view class="bottom-icon" @click="toggleCollect"
          ><text class="bi-text">{{ collected ? "❤️" : "🤍" }}</text
          ><text class="bi-label">收藏</text></view
        >
      </view>
      <view class="bottom-actions">
        <view class="btn-cart" @click="addToCart">加入购物车</view>
        <view class="btn-buy" @click="buyNow">立即购买</view>
      </view>
    </view>

    <!-- SKU选择弹窗 -->
    <u-popup :show="showSku" mode="bottom" round @close="showSku = false">
      <view class="sku-popup">
        <text class="sku-title">选择规格</text>
        <view class="sku-list">
          <view
            v-for="sku in skus"
            :key="sku.id"
            :class="[
              'sku-item',
              selectedSku && selectedSku.id === sku.id ? 'active' : '',
            ]"
            @click="selectSku(sku)"
          >
            <text>{{ sku.skuName }}</text>
            <text class="sku-price">{{ formatPrice(sku.price) }}</text>
          </view>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script>
import { get, post } from "@/utils/request";

let gLoading = false;
let gLastId = null;

export default {
  data() {
    return {
      product: null,
      skus: [],
      images: [],
      selectedSku: null,
      quantity: 1,
      showSku: false,
      collected: false,
      showVideo: false,
    };
  },
  computed: {
    hasVideo() {
      return !!(this.product && this.product.video)
    },
    videoUrl() {
      if (!this.product || !this.product.video) return ''
      let url = this.product.video
      if (url.startsWith('/api/')) {
        const base = this.getBaseUrl()
        if (base) url = base + url.substring(4)
      }
      return url
    },
    imageList() {
      const base = this.getBaseUrl();
      return this.images.map((url) => {
        if (url && url.startsWith("/api/") && base) {
          url = base + url.substring(4);
        }
        return { image: url };
      });
    },
  },
  onLoad(options) {
    this.loadDetail(options.id);
  },
  methods: {
    async loadDetail(id) {
      uni.showLoading({ title: "加载中" });
      try {
        const result = await get(`/product/detail/${id}`);
        this.product = result.product;
        this.skus = result.skus || [];
        const dbImages =
          result.images && result.images.length > 0
            ? result.images.map((img) => img.imageUrl)
            : this.parseImages(result.product.images);
        this.images = dbImages;
        if (this.skus.length > 0) this.selectedSku = this.skus[0];
        uni.hideLoading();
        this.checkCollected();
      } catch (e) {
        uni.hideLoading();
      }
    },
    parseImages(images) {
      if (!images) return [];
      try {
        return typeof images === "string" && images.startsWith("[")
          ? JSON.parse(images)
          : [images];
      } catch (e) {
        return [];
      }
    },
    parseSpecs() {
      try {
        return typeof this.product.specs === "string"
          ? JSON.parse(this.product.specs)
          : this.product.specs || {};
      } catch (e) {
        return {};
      }
    },
    selectSku(sku) {
      this.selectedSku = sku;
    },
    async addToCart() {
      try {
        await post("/cart/add", {
          productId: this.product.id,
          skuId: this.selectedSku ? this.selectedSku.id : null,
          quantity: this.quantity,
        });
        this.showToast("已加入购物车");
      } catch (e) {
        this.showToast("加入购物车失败");
      }
    },
    buyNow() {
      this.addToCart();
      uni.switchTab({ url: "/pages/cart/cart" });
    },
    async toggleCollect() {
      try {
        await post("/collection/add", { productId: this.product.id });
        this.collected = !this.collected;
        this.showToast(this.collected ? "已收藏" : "已取消收藏");
      } catch (e) {}
    },
    async checkCollected() {
      try {
        this.collected =
          (await get(`/collection/check/${this.product.id}`)) || false;
      } catch (e) {}
    },
  },
};
</script>

<style lang="scss" scoped>
.detail-page {
  min-height: 100vh;
  padding-bottom: calc(120rpx + env(safe-area-inset-bottom));
  background: #f5f6fa;
}
.swiper-wrap {
  margin: 20rpx 30rpx 12rpx;
  border-radius: 12rpx;
  overflow: hidden;
  position: relative;
}
.swiper-video {
  width: 100%;
  height: 600rpx;
}
.media-toggle {
  position: absolute;
  bottom: 16rpx;
  right: 16rpx;
  padding: 8rpx 20rpx;
  border-radius: 24rpx;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 22rpx;
  color: #fff;
  z-index: 10;
}
.price-section {
  margin: 0 30rpx;
  border-radius: 12rpx 12rpx 0 0;
  padding: 28rpx 30rpx 20rpx;
  background: #fff;
}
.current-price {
  font-size: 44rpx;
  color: #ff6b35;
  font-weight: bold;
}
.original-price {
  font-size: 26rpx;
  color: #999;
  text-decoration: line-through;
  margin-left: 16rpx;
}
.sales-text {
  font-size: 24rpx;
  color: #999;
  margin-left: 16rpx;
}
.name-section {
  margin: 0 30rpx;
  padding: 0 30rpx 28rpx;
  background: #fff;
  border-radius: 0 0 12rpx 12rpx;
}
.product-name { font-size: 32rpx; font-weight: bold; color: #333; }
.product-subtitle { font-size: 24rpx; color: #999; display: block; margin-top: 10rpx; }
.sku-section {
  margin: 12rpx 30rpx 0;
  padding: 28rpx 30rpx;
  background: #fff;
  border-radius: 12rpx;
}
.sku-header { display: flex; justify-content: space-between; align-items: center; }
.sku-label { font-size: 28rpx; color: #333; }
.qty-section {
  margin: 12rpx 30rpx 0;
  padding: 28rpx 30rpx;
  background: #fff;
  border-radius: 12rpx;
  display: flex; justify-content: space-between; align-items: center;
  font-size: 28rpx; color: #333;
}
.section-title {
  font-size: 30rpx; font-weight: bold;
  margin: 12rpx 30rpx 0;
  padding: 30rpx 30rpx 16rpx;
  background: #fff;
  border-radius: 12rpx 12rpx 0 0;
}
.desc-content {
  margin: 0 30rpx;
  padding: 0 30rpx 30rpx;
  background: #fff;
  border-radius: 0 0 12rpx 12rpx;
}
.specs-table {
  margin: 12rpx 30rpx 0;
  padding: 0 30rpx 30rpx;
  background: #fff;
  border-radius: 12rpx;
}
.spec-row {
  display: flex;
  justify-content: space-between;
  padding: 16rpx 0;
  border-bottom: 1rpx solid #f0f0f0;
  &:last-child {
    border-bottom: none;
  }
}
.spec-key {
  color: #999;
  font-size: 26rpx;
}
.spec-val {
  color: #333;
  font-size: 26rpx;
}
.bottom-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  padding: 14rpx 24rpx;
  padding-bottom: calc(14rpx + env(safe-area-inset-bottom));
  display: flex;
  align-items: center;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06);
  z-index: 100;
}
.bottom-icons {
  display: flex;
  flex-shrink: 0;
  margin-right: 16rpx;
}
.bottom-icon {
  text-align: center;
  padding: 0 16rpx;
}
.bi-text {
  font-size: 36rpx;
  display: block;
}
.bi-label {
  font-size: 20rpx;
  color: #666;
}
.bottom-actions {
  display: flex;
  flex: 1;
  gap: 20rpx;
}
.btn-cart {
  flex: 1;
  text-align: center;
  font-size: 28rpx;
  font-weight: 600;
  color: #ff6b35;
  background: #fff;
  border: 2rpx solid #ff6b35;
  border-radius: 40rpx;
  padding: 18rpx 0;
  &:active {
    opacity: 0.8;
    transform: scale(0.97);
  }
}
.btn-buy {
  flex: 1;
  text-align: center;
  font-size: 28rpx;
  font-weight: 600;
  color: #fff;
  background: linear-gradient(135deg, #07c160, #06ad56);
  border-radius: 40rpx;
  padding: 18rpx 0;
  box-shadow: 0 4rpx 16rpx rgba(7, 193, 96, 0.35);
  &:active {
    opacity: 0.9;
    transform: scale(0.97);
  }
}
.sku-popup {
  padding: 40rpx 30rpx 60rpx;
}
.sku-title {
  font-size: 32rpx;
  font-weight: bold;
}
.sku-list {
  margin-top: 30rpx;
}
.sku-item {
  padding: 24rpx;
  margin-bottom: 16rpx;
  background: #f5f6fa;
  border-radius: 12rpx;
  display: flex;
  justify-content: space-between;
}
.sku-item.active {
  background: #e8f8ee;
  border: 2rpx solid #07c160;
}
.sku-price {
  font-weight: bold;
  color: #ff6b35;
}
</style>
