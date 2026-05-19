<template>
  <view class="confirm-page">
    <!-- 收货地址 -->
    <view class="address-card" @click="goPage('/pages/address/list')">
      <view class="addr-left">
        <view class="addr-icon">📍</view>
        <view class="addr-body" v-if="selectedAddress">
          <view class="addr-main">
            <text class="addr-name">{{ selectedAddress.receiverName }}</text>
            <text class="addr-phone">{{ selectedAddress.phone }}</text>
            <view class="addr-tag" v-if="selectedAddress.isDefault === 1"
              >默认</view
            >
          </view>
          <text class="addr-detail">{{
            selectedAddress.fullAddress || selectedAddress.detailAddress
          }}</text>
        </view>
        <text class="no-addr" v-else>请选择收货地址</text>
      </view>
      <u-icon name="arrow-right" color="#bbb" size="16"></u-icon>
    </view>

    <!-- 商品列表（按店铺分组） -->
    <view class="items-card" v-for="(shop, i) in shopGroups" :key="i">
      <view class="shop-header">
        <text class="shop-name">{{ shop.shopName }}</text>
      </view>
      <view class="item" v-for="item in shop.items" :key="item.id">
        <image
          :src="fixImageUrl(item.productImage)"
          mode="aspectFill"
          class="item-img"
        />
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

    <!-- 优惠券 -->
    <view class="coupon-card" @click="goPage('/pages/coupon/list')">
      <view class="coupon-left">
        <view class="coupon-icon">🎫</view>
        <text class="coupon-label">优惠券</text>
      </view>
      <view class="coupon-right">
        <text class="coupon-placeholder" v-if="!selectedCoupon"
          >暂无可用优惠券</text
        >
        <text class="coupon-value" v-else
          >-{{ formatPrice(selectedCoupon.value) }}</text
        >
        <u-icon name="arrow-right" color="#bbb" size="14"></u-icon>
      </view>
    </view>

    <!-- 买家留言 -->
    <view class="msg-card">
      <view class="msg-header">
        <text class="msg-icon">✏️</text>
        <text class="msg-label">买家留言</text>
      </view>
      <u--textarea
        v-model="message"
        placeholder="选填：如有特殊要求请留言"
        maxlength="200"
        border="none"
        height="60"
        autoHeight
      ></u--textarea>
    </view>

    <!-- 金额汇总 -->
    <view class="amount-card">
      <view class="amount-title">价格明细</view>
      <view class="amount-row">
        <text>商品总额</text>
        <text>{{ formatPrice(totalAmount) }}</text>
      </view>
      <view class="amount-row">
        <text>运费</text>
        <text class="freight-free">免运费</text>
      </view>
      <view class="amount-row" v-if="selectedCoupon">
        <text>优惠券</text>
        <text class="discount">-{{ formatPrice(selectedCoupon.value) }}</text>
      </view>
      <view class="amount-divider"></view>
      <view class="amount-row total">
        <text>应付</text>
        <text class="total-price">{{ formatPrice(realAmount) }}</text>
      </view>
    </view>

    <!-- 底部占位 -->
    <view class="footer-space"></view>

    <!-- 提交按钮 -->
    <view class="submit-bar">
      <view class="submit-left">
        <text class="submit-label">实付</text>
        <text class="submit-price">{{ formatPrice(realAmount) }}</text>
      </view>
      <view class="submit-btn" @click="submitOrder">
        <text>提交订单</text>
      </view>
    </view>
  </view>
</template>

<script>
import { get, post } from "@/utils/request";
export default {
  data() {
    return {
      cartItems: [],
      selectedAddress: null,
      selectedCoupon: null,
      message: "",
    };
  },
  computed: {
    shopGroups() {
      const map = {};
      this.cartItems.forEach((item) => {
        const name = item.shopName || "店铺";
        if (!map[name]) map[name] = [];
        map[name].push(item);
      });
      return Object.entries(map).map(([shopName, items]) => ({
        shopName,
        items,
      }));
    },
    totalAmount() {
      return this.cartItems.reduce(
        (sum, item) => sum + Number(item.price) * item.quantity,
        0
      );
    },
    realAmount() {
      const discount = this.selectedCoupon
        ? Number(this.selectedCoupon.value)
        : 0;
      return Math.max(0, this.totalAmount - discount);
    },
  },
  onShow() {
    this.loadCart();
    this.loadAddress();
  },
  methods: {
    async loadCart() {
      try {
        const cartData = (await get("/cart/list")) || [];
        this.cartItems = [];
        cartData.forEach((shop) => {
          shop.items.forEach((item) => {
            if (item.selected === 1) this.cartItems.push(item);
          });
        });
      } catch (e) {}
    },
    async loadAddress() {
      try {
        const addresses = (await get("/address/list")) || [];
        this.selectedAddress =
          addresses.find((a) => a.isDefault === 1) || addresses[0] || null;
      } catch (e) {}
    },
    fixImageUrl(url) {
      if (!url) return "/static/placeholder.png";
      if (url.startsWith("/api/")) {
        const base = this.getBaseUrl();
        return base ? base + url.substring(4) : url;
      }
      return url;
    },
    async submitOrder() {
      if (!this.selectedAddress) {
        this.showToast("请选择收货地址");
        return;
      }
      if (this.cartItems.length === 0) {
        this.showToast("没有可结算的商品");
        return;
      }
      uni.showLoading({ title: "提交中", mask: true });
      try {
        const order = await post("/order/create", {
          addressId: this.selectedAddress.id,
          message: this.message,
        });
        await post(`/order/pay/${order.id}`);
        uni.hideLoading();
        this.showToast("下单成功");
        setTimeout(() => {
          uni.switchTab({ url: "/pages/order/list?status=-1" });
        }, 1000);
      } catch (e) {
        uni.hideLoading();
        this.showToast("下单失败");
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.confirm-page {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 160rpx;
}

/* ========== 地址卡片 ========== */
.address-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 24rpx 24rpx 0;
  padding: 28rpx 24rpx;
  background: #fff;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.addr-left {
  display: flex;
  align-items: center;
  flex: 1;
  min-width: 0;
}
.addr-icon {
  font-size: 36rpx;
  margin-right: 20rpx;
  flex-shrink: 0;
}
.addr-body {
  flex: 1;
  min-width: 0;
}
.addr-main {
  display: flex;
  align-items: center;
  margin-bottom: 8rpx;
  gap: 12rpx;
}
.addr-name {
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
}
.addr-phone {
  font-size: 26rpx;
  color: #999;
}
.addr-tag {
  font-size: 20rpx;
  color: #07c160;
  background: #e8f8ee;
  padding: 2rpx 12rpx;
  border-radius: 6rpx;
  flex-shrink: 0;
}
.addr-detail {
  font-size: 24rpx;
  color: #666;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.no-addr {
  font-size: 28rpx;
  color: #bbb;
}

/* ========== 商品卡片 ========== */
.items-card {
  background: #fff;
  margin: 24rpx 24rpx 0;
  border-radius: 16rpx;
  overflow: hidden;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.shop-header {
  display: flex;
  align-items: center;
  padding: 20rpx 24rpx;
  background: #fafbfc;
  border-bottom: 1rpx solid #f0f0f0;
}
.shop-header::before {
  content: "";
  width: 6rpx;
  height: 28rpx;
  background: #07c160;
  border-radius: 3rpx;
  margin-right: 12rpx;
}
.shop-name {
  font-size: 26rpx;
  font-weight: 600;
  color: #333;
}
.item {
  display: flex;
  align-items: center;
  padding: 20rpx 24rpx;
  border-bottom: 1rpx solid #f8f8f8;
  &:last-child {
    border-bottom: none;
  }
}
.item-img {
  width: 140rpx;
  height: 140rpx;
  border-radius: 10rpx;
  margin-right: 16rpx;
  flex-shrink: 0;
  background: #f5f5f5;
}
.item-info {
  flex: 1;
  min-width: 0;
}
.item-name {
  font-size: 27rpx;
  color: #333;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  line-height: 1.4;
}
.item-sku {
  font-size: 22rpx;
  color: #aaa;
  margin-top: 6rpx;
  display: block;
}
.item-right {
  text-align: right;
  flex-shrink: 0;
  margin-left: 16rpx;
}
.item-price {
  font-size: 28rpx;
  color: #ff6b35;
  font-weight: 600;
  display: block;
}
.item-qty {
  font-size: 24rpx;
  color: #999;
  margin-top: 4rpx;
  display: block;
}

/* ========== 优惠券 ========== */
.coupon-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin: 24rpx 24rpx 0;
  padding: 24rpx;
  background: #fff;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.coupon-left {
  display: flex;
  align-items: center;
}
.coupon-icon {
  font-size: 30rpx;
  margin-right: 12rpx;
}
.coupon-label {
  font-size: 27rpx;
  color: #333;
  font-weight: 500;
}
.coupon-right {
  display: flex;
  align-items: center;
  gap: 8rpx;
}
.coupon-placeholder {
  font-size: 24rpx;
  color: #bbb;
}
.coupon-value {
  font-size: 26rpx;
  color: #ff6b35;
  font-weight: 600;
}

/* ========== 留言 ========== */
.msg-card {
  margin: 24rpx 24rpx 0;
  padding: 20rpx 24rpx 12rpx;
  background: #fff;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.msg-header {
  display: flex;
  align-items: center;
  margin-bottom: 8rpx;
}
.msg-icon {
  font-size: 26rpx;
  margin-right: 10rpx;
}
.msg-label {
  font-size: 27rpx;
  color: #333;
  font-weight: 500;
}

/* ========== 金额明细 ========== */
.amount-card {
  margin: 24rpx 24rpx 0;
  padding: 24rpx;
  background: #fff;
  border-radius: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.amount-title {
  font-size: 27rpx;
  font-weight: 600;
  color: #333;
  margin-bottom: 16rpx;
  padding-bottom: 16rpx;
  border-bottom: 1rpx solid #f0f0f0;
}
.amount-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10rpx 0;
  font-size: 26rpx;
  color: #666;
}
.amount-divider {
  height: 1rpx;
  background: #f0f0f0;
  margin: 12rpx 0 16rpx;
}
.amount-row.total {
  font-size: 28rpx;
  color: #333;
  font-weight: 500;
}
.freight-free {
  color: #07c160;
}
.discount {
  color: #ff6b35;
}
.total-price {
  font-size: 36rpx;
  color: #ff6b35;
  font-weight: 700;
}

/* ========== 底部占位 ========== */
.footer-space {
  height: 40rpx;
}

/* ========== 提交栏 ========== */
.submit-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #fff;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 -4rpx 20rpx rgba(0, 0, 0, 0.06);
  z-index: 100;
}
.submit-left {
  display: flex;
  align-items: baseline;
}
.submit-label {
  font-size: 24rpx;
  color: #666;
}
.submit-price {
  font-size: 40rpx;
  color: #ff6b35;
  font-weight: 700;
  margin-left: 8rpx;
}
.submit-btn {
  background: linear-gradient(135deg, #07c160, #06ad56);
  color: #fff;
  font-size: 30rpx;
  font-weight: 600;
  padding: 18rpx 56rpx;
  border-radius: 44rpx;
  box-shadow: 0 4rpx 16rpx rgba(7, 193, 96, 0.35);
  &:active {
    opacity: 0.9;
    transform: scale(0.97);
  }
}
</style>
