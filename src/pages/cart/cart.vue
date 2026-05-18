<template>
  <view class="cart-page">
    <!-- 未登录 -->
    <view v-if="!isLogin" class="empty-cart">
      <image src="/static/placeholder.png" mode="widthFix" class="empty-img" />
      <text class="empty-text">登录后可查看购物车</text>
      <view style="padding: 0 40rpx"><u-button text="去登录" type="success" size="small" shape="circle" block @click="goPage('/pages/user/login')"></u-button></view>
    </view>

    <!-- 已登录，有商品 -->
    <template v-else-if="cartData.length > 0">
      <view class="shop-group" v-for="(shop, idx) in cartData" :key="idx">
        <view class="shop-header">
          <u-checkbox :checked="isShopAllSelected(shop)" @change="toggleShop(shop)"></u-checkbox>
          <text class="shop-name">{{ shop.shopName }}</text>
        </view>
        <view class="cart-item" v-for="item in shop.items" :key="item.id">
          <u-checkbox :checked="item.selected === 1" @change="toggleItem(item)"></u-checkbox>
          <image :src="item.productImage || '/static/placeholder.png'" mode="aspectFill" class="item-img" @click="goDetail(item.productId)" />
          <view class="item-info">
            <text class="item-name">{{ item.productName }}</text>
            <text class="item-sku" v-if="item.skuName">{{ item.skuName }}</text>
            <view class="item-bottom">
              <text class="item-price">{{ formatPrice(item.price) }}</text>
              <u-number-box :value="item.quantity" :min="1" :max="item.stock || 99" @change="(val) => changeQty(item, val.value)" />
            </view>
          </view>
        </view>
      </view>
      <view class="bottom-bar">
        <u-checkbox :checked="isAllSelected" @change="toggleAll" label="全选"></u-checkbox>
        <view class="bottom-right">
          <text class="total-text">合计: <text class="total-price">{{ formatPrice(totalPrice) }}</text></text>
          <u-button type="success" size="small" shape="circle" text="去结算" @click="checkout"></u-button>
        </view>
      </view>
    </template>

    <!-- 已登录，无商品 -->
    <view v-else class="empty-cart">
      <image src="/static/placeholder.png" mode="widthFix" class="empty-img" />
      <text class="empty-text">购物车是空的~</text>
      <view style="padding: 0 40rpx"><u-button text="去逛逛" type="primary" size="small" shape="circle" block @click="switchTab('/pages/index/index')"></u-button></view>
    </view>
  </view>
</template>

<script>
import { get, post, put } from '@/utils/request'
export default {
  data() { return { cartData: [], allSelected: true, loaded: false } },
  computed: {
    isAllSelected() {
      if (this.cartData.length === 0) return true
      return this.cartData.every(shop => shop.items.every(item => item.selected === 1))
    },
    totalPrice() {
      let total = 0
      this.cartData.forEach(shop => {
        shop.items.forEach(item => {
          if (item.selected === 1) total += Number(item.price) * item.quantity
        })
      })
      return total
    }
  },
  onShow() {
    if (!this.isLogin) return
    this.loadCart()
  },
  methods: {
    async loadCart() {
      try { this.cartData = await get('/cart/list') || [] } catch (e) {}
    },
    isShopAllSelected(shop) {
      return shop.items.every(item => item.selected === 1)
    },
    async toggleShop(shop) {
      const sel = this.isShopAllSelected(shop) ? 0 : 1
      for (const item of shop.items) {
        await put('/cart/update', { id: item.id, selected: sel })
      }
      this.loadCart()
    },
    async toggleItem(item) {
      await put('/cart/update', { id: item.id, selected: item.selected === 1 ? 0 : 1 })
      this.loadCart()
    },
    async toggleAll() {
      const sel = this.isAllSelected ? 0 : 1
      for (const shop of this.cartData) {
        for (const item of shop.items) {
          await put('/cart/update', { id: item.id, selected: sel })
        }
      }
      this.loadCart()
    },
    async changeQty(item, qty) {
      await put('/cart/update', { id: item.id, quantity: qty })
      this.loadCart()
    },
    checkout() {
      const selected = []
      this.cartData.forEach(shop => {
        shop.items.forEach(item => {
          if (item.selected === 1) selected.push(item)
        })
      })
      if (selected.length === 0) { this.showToast('请选择商品'); return }
      uni.navigateTo({ url: '/pages/order/confirm' })
    },
    goDetail(id) { uni.navigateTo({ url: `/pages/product/detail?id=${id}` }) }
  }
}
</script>

<style lang="scss" scoped>
.cart-page { padding-bottom: 120rpx; min-height: 100vh; }
.shop-group { margin: 20rpx 30rpx; background: #fff; border-radius: 12rpx; overflow: hidden; }
.shop-header { display: flex; align-items: center; padding: 20rpx; border-bottom: 1rpx solid #f0f0f0; }
.shop-name { font-size: 28rpx; font-weight: bold; color: #333; margin-left: 16rpx; }
.cart-item { display: flex; align-items: center; padding: 20rpx; border-bottom: 1rpx solid #f0f0f0; }
.cart-item:last-child { border-bottom: none; }
.item-img { width: 140rpx; height: 140rpx; border-radius: 8rpx; margin: 0 16rpx; flex-shrink: 0; }
.item-info { flex: 1; min-width: 0; }
.item-name { font-size: 26rpx; color: #333; display: block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.item-sku { font-size: 22rpx; color: #999; margin-top: 4rpx; display: block; }
.item-bottom { display: flex; justify-content: space-between; align-items: center; margin-top: 16rpx; }
.item-price { font-size: 28rpx; color: #FF6B35; font-weight: bold; }
.bottom-bar { position: fixed; bottom: 0; left: 0; right: 0; background: #fff; padding: 20rpx 30rpx; padding-bottom: calc(20rpx + env(safe-area-inset-bottom)); display: flex; justify-content: space-between; align-items: center; box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.05); z-index: 100; }
.bottom-right { display: flex; align-items: center; }
.total-text { font-size: 26rpx; color: #333; margin-right: 20rpx; }
.total-price { font-size: 32rpx; color: #FF6B35; font-weight: bold; }
.empty-cart { text-align: center; padding-top: 200rpx; }
.empty-img { width: 240rpx; margin-bottom: 30rpx; }
.empty-text { display: block; font-size: 28rpx; color: #999; margin-bottom: 40rpx; }
</style>
