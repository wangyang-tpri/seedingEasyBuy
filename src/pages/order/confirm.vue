<template>
  <view class="confirm-page">
    <!-- 收货地址 -->
    <view class="address-card" @click="goPage('/pages/address/list')">
      <template v-if="selectedAddress">
        <view class="addr-main">
          <text class="addr-name">{{ selectedAddress.receiverName }}</text>
          <text class="addr-phone">{{ selectedAddress.phone }}</text>
        </view>
        <text class="addr-detail">{{ selectedAddress.fullAddress || selectedAddress.detailAddress }}</text>
      </template>
      <template v-else>
        <text class="no-addr">请选择收货地址</text>
      </template>
      <u-icon name="arrow-right" color="#ccc"></u-icon>
    </view>

    <!-- 商品列表（简化显示） -->
    <view class="items-card">
      <view class="item" v-for="item in cartItems" :key="item.id">
        <image :src="item.productImage || '/static/placeholder.png'" mode="aspectFill" class="item-img" />
        <view class="item-info">
          <text class="item-name">{{ item.productName }}</text>
          <text class="item-sku" v-if="item.skuName">{{ item.skuName }}</text>
        </view>
        <view class="item-right">
          <text class="item-price">{{ formatPrice(item.price) }}</text>
          <text class="item-qty">×{{ item.quantity }}</text>
        </view>
      </view>
    </view>

    <!-- 留言 -->
    <view class="msg-card">
      <u--textarea v-model="message" placeholder="买家留言（选填）" maxlength="200"></u--textarea>
    </view>

    <!-- 金额汇总 -->
    <view class="amount-card">
      <view class="amount-row"><text>商品总额</text><text>{{ formatPrice(totalAmount) }}</text></view>
      <view class="amount-row"><text>运费</text><text>免运费</text></view>
      <view class="amount-row total"><text>应付</text><text class="total-price">{{ formatPrice(totalAmount) }}</text></view>
    </view>

    <!-- 提交按钮 -->
    <view class="submit-bar">
      <view class="submit-left">
        <text class="submit-label">合计:</text>
        <text class="submit-price">{{ formatPrice(totalAmount) }}</text>
      </view>
      <u-button text="提交订单" type="success" shape="circle" @click="submitOrder"></u-button>
    </view>
  </view>
</template>

<script>
import { get, post } from '@/utils/request'
export default {
  data() { return { cartItems: [], selectedAddress: null, message: '' } },
  computed: {
    totalAmount() {
      return this.cartItems.reduce((sum, item) => sum + Number(item.price) * item.quantity, 0)
    }
  },
  onShow() {
    this.loadCart()
    this.loadAddress()
  },
  methods: {
    async loadCart() {
      try {
        const cartData = await get('/cart/list') || []
        this.cartItems = []
        cartData.forEach(shop => {
          shop.items.forEach(item => {
            if (item.selected === 1) this.cartItems.push(item)
          })
        })
      } catch (e) {}
    },
    async loadAddress() {
      try {
        const addresses = await get('/address/list') || []
        this.selectedAddress = addresses.find(a => a.isDefault === 1) || addresses[0] || null
      } catch (e) {}
    },
    async submitOrder() {
      if (!this.selectedAddress) { this.showToast('请选择收货地址'); return }
      if (this.cartItems.length === 0) { this.showToast('没有可结算的商品'); return }
      uni.showLoading({ title: '提交中' })
      try {
        const order = await post('/order/create', {
          addressId: this.selectedAddress.id,
          message: this.message
        })
        uni.hideLoading()
        // Pay immediately
        await post(`/order/pay/${order.id}`)
        this.showToast('下单成功')
        setTimeout(() => {
          uni.switchTab({ url: '/pages/order/list?status=-1' })
        }, 1000)
      } catch (e) {
        uni.hideLoading()
        this.showToast('下单失败')
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.confirm-page { padding-bottom: 140rpx; }
.address-card { background: #fff; margin: 20rpx 30rpx; border-radius: 12rpx; padding: 30rpx; display: flex; justify-content: space-between; align-items: center; }
.addr-main { display: flex; gap: 20rpx; margin-bottom: 10rpx; }
.addr-name { font-size: 30rpx; font-weight: bold; }
.addr-phone { font-size: 26rpx; color: #666; }
.addr-detail { font-size: 24rpx; color: #999; }
.no-addr { font-size: 28rpx; color: #999; }
.items-card { background: #fff; margin: 20rpx 30rpx; border-radius: 12rpx; padding: 20rpx 30rpx; }
.item { display: flex; padding: 16rpx 0; border-bottom: 1rpx solid #f0f0f0; }
.item:last-child { border-bottom: none; }
.item-img { width: 120rpx; height: 120rpx; border-radius: 8rpx; margin-right: 20rpx; }
.item-info { flex: 1; }
.item-name { font-size: 26rpx; color: #333; display: block; }
.item-sku { font-size: 22rpx; color: #999; }
.item-right { text-align: right; }
.item-price { font-size: 26rpx; color: #FF6B35; font-weight: bold; display: block; }
.item-qty { font-size: 24rpx; color: #999; }
.msg-card { background: #fff; margin: 20rpx 30rpx; border-radius: 12rpx; padding: 20rpx 30rpx; }
.amount-card { background: #fff; margin: 20rpx 30rpx; border-radius: 12rpx; padding: 24rpx 30rpx; }
.amount-row { display: flex; justify-content: space-between; padding: 10rpx 0; font-size: 26rpx; color: #666; }
.amount-row.total { border-top: 1rpx solid #f0f0f0; padding-top: 20rpx; margin-top: 8rpx; }
.total-price { color: #FF6B35; font-size: 32rpx; font-weight: bold; }
.submit-bar { position: fixed; bottom: 0; left: 0; right: 0; background: #fff; padding: 20rpx 30rpx; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 -2rpx 10rpx rgba(0,0,0,0.05); }
.submit-left { display: flex; align-items: baseline; }
.submit-label { font-size: 26rpx; color: #333; }
.submit-price { font-size: 36rpx; color: #FF6B35; font-weight: bold; margin-left: 10rpx; }
</style>
