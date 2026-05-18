<template>
  <view class="detail-page" v-if="product">
    <!-- 图片轮播 -->
    <u-swiper :list="imageList" height="600rpx" :autoplay="true" circular></u-swiper>

    <!-- 价格信息 -->
    <view class="price-section">
      <text class="current-price">{{ formatPrice(selectedSku ? selectedSku.price : product.price) }}</text>
      <text class="original-price" v-if="product.originalPrice">¥{{ product.originalPrice }}</text>
      <text class="sales-text">已售 {{ product.sales || 0 }}件</text>
    </view>

    <!-- 商品名称 -->
    <view class="name-section">
      <text class="product-name">{{ product.name }}</text>
      <text class="product-subtitle" v-if="product.subtitle">{{ product.subtitle }}</text>
    </view>

    <!-- SKU选择 -->
    <view class="sku-section" v-if="skus.length > 0">
      <view class="sku-header" @click="showSku = true">
        <text class="sku-label">已选: {{ selectedSku ? selectedSku.skuName : '请选择规格' }}</text>
        <u-icon name="arrow-right" color="#999"></u-icon>
      </view>
    </view>

    <!-- 数量 -->
    <view class="qty-section">
      <text>购买数量</text>
      <u-number-box :value="quantity" :min="1" @change="(val) => quantity = val.value"></u-number-box>
    </view>

    <!-- 商品详情 -->
    <view class="section-title">商品详情</view>
    <view class="desc-content" v-if="product.description">
      <rich-text :nodes="product.description"></rich-text>
    </view>

    <!-- 规格参数 -->
    <view class="section-title" v-if="product.specs">规格参数</view>
    <view class="specs-table" v-if="product.specs">
      <view class="spec-row" v-for="(val, key) in parseSpecs()" :key="key">
        <text class="spec-key">{{ key }}</text>
        <text class="spec-val">{{ val }}</text>
      </view>
    </view>

    <!-- 底部操作栏 -->
    <view class="bottom-bar">
      <view class="bottom-icons">
        <view class="bottom-icon" @click="goPage('/pages/cart/cart')"><text class="bi-text">🛒</text><text class="bi-label">购物车</text></view>
        <view class="bottom-icon" @click="toggleCollect"><text class="bi-text">{{ collected ? '❤️' : '🤍' }}</text><text class="bi-label">收藏</text></view>
      </view>
      <u-button text="加入购物车" shape="circle" @click="addToCart"></u-button>
      <u-button text="立即购买" type="success" shape="circle" @click="buyNow"></u-button>
    </view>

    <!-- SKU选择弹窗 -->
    <u-popup :show="showSku" mode="bottom" round @close="showSku = false">
      <view class="sku-popup">
        <text class="sku-title">选择规格</text>
        <view class="sku-list">
          <view v-for="sku in skus" :key="sku.id"
                :class="['sku-item', selectedSku && selectedSku.id === sku.id ? 'active' : '']"
                @click="selectSku(sku)">
            <text>{{ sku.skuName }}</text>
            <text class="sku-price">{{ formatPrice(sku.price) }}</text>
          </view>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script>
import { get, post } from '@/utils/request'
export default {
  data() {
    return {
      product: null,
      skus: [],
      images: [],
      selectedSku: null,
      quantity: 1,
      showSku: false,
      collected: false
    }
  },
  computed: {
    imageList() { return this.images.map(url => ({ image: url })) }
  },
  onLoad(options) { this.loadDetail(options.id) },
  methods: {
    async loadDetail(id) {
      uni.showLoading({ title: '加载中' })
      try {
        const result = await get(`/product/detail/${id}`)
        this.product = result.product
        this.skus = result.skus || []
        this.images = result.images ? result.images.map(img => img.imageUrl) : this.parseImages(result.product.images)
        if (this.skus.length > 0) this.selectedSku = this.skus[0]
        uni.hideLoading()
        this.checkCollected()
      } catch (e) { uni.hideLoading() }
    },
    parseImages(images) {
      if (!images) return []
      try { return typeof images === 'string' && images.startsWith('[') ? JSON.parse(images) : [images] }
      catch (e) { return [] }
    },
    parseSpecs() {
      try { return typeof this.product.specs === 'string' ? JSON.parse(this.product.specs) : this.product.specs || {} }
      catch (e) { return {} }
    },
    selectSku(sku) { this.selectedSku = sku },
    async addToCart() {
      try {
        await post('/cart/add', { productId: this.product.id, skuId: this.selectedSku ? this.selectedSku.id : null, quantity: this.quantity })
        this.showToast('已加入购物车')
      } catch (e) { this.showToast('加入购物车失败') }
    },
    buyNow() {
      this.addToCart()
      uni.switchTab({ url: '/pages/cart/cart' })
    },
    async toggleCollect() {
      try {
        await post('/collection/add', { productId: this.product.id })
        this.collected = !this.collected
        this.showToast(this.collected ? '已收藏' : '已取消收藏')
      } catch (e) {}
    },
    async checkCollected() {
      try { this.collected = await get(`/collection/check/${this.product.id}`) } catch (e) {}
    }
  }
}
</script>

<style lang="scss" scoped>
.detail-page { padding-bottom: 120rpx; }
.price-section { padding: 30rpx; background: #fff; }
.current-price { font-size: 44rpx; color: #FF6B35; font-weight: bold; }
.original-price { font-size: 26rpx; color: #999; text-decoration: line-through; margin-left: 16rpx; }
.sales-text { font-size: 24rpx; color: #999; margin-left: 16rpx; }
.name-section { padding: 0 30rpx 30rpx; background: #fff; }
.product-name { font-size: 32rpx; font-weight: bold; color: #333; }
.product-subtitle { font-size: 24rpx; color: #999; display: block; margin-top: 10rpx; }
.sku-section { padding: 30rpx; background: #fff; margin-top: 16rpx; }
.sku-header { display: flex; justify-content: space-between; }
.sku-label { font-size: 28rpx; color: #333; }
.qty-section { padding: 30rpx; background: #fff; margin-top: 16rpx; display: flex; justify-content: space-between; align-items: center; font-size: 28rpx; }
.section-title { font-size: 30rpx; font-weight: bold; padding: 30rpx 30rpx 0; }
.desc-content { padding: 20rpx 30rpx; background: #fff; }
.specs-table { padding: 20rpx 30rpx; background: #fff; margin-top: 16rpx; }
.spec-row { display: flex; justify-content: space-between; padding: 16rpx 0; border-bottom: 1rpx solid #f0f0f0; }
.spec-key { color: #999; font-size: 26rpx; }
.spec-val { color: #333; font-size: 26rpx; }
.bottom-bar { position: fixed; bottom: 0; left: 0; right: 0; background: #fff; padding: 16rpx 30rpx; display: flex; align-items: center; box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.05); }
.bottom-icons { display: flex; flex-shrink: 0; }
.bottom-icon { text-align: center; margin-right: 30rpx; }
.bi-text { font-size: 36rpx; display: block; }
.bi-label { font-size: 20rpx; color: #666; }
.sku-popup { padding: 40rpx 30rpx 60rpx; }
.sku-title { font-size: 32rpx; font-weight: bold; }
.sku-list { margin-top: 30rpx; }
.sku-item { padding: 24rpx; margin-bottom: 16rpx; background: #f5f6fa; border-radius: 12rpx; display: flex; justify-content: space-between; }
.sku-item.active { background: #e8f8ee; border: 2rpx solid #07C160; }
.sku-price { font-weight: bold; color: #FF6B35; }
</style>
