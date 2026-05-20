<template>
  <view class="user-page">
    <!-- 用户信息 -->
    <view class="user-card">
      <view
        v-if="isLogin"
        class="user-info"
        @click="goPage('/pages/user/login')"
      >
        <u-avatar :src="user.avatar" size="120rpx"></u-avatar>
        <view class="user-text">
          <text class="user-name">{{ user.nickname || "微信用户" }}</text>
          <text class="user-phone">{{ user.phone || "点击查看资料" }}</text>
        </view>
      </view>
      <view v-else class="user-info" @click="goPage('/pages/user/login')">
        <u-avatar icon="account" size="120rpx"></u-avatar>
        <view class="user-text">
          <text class="user-name">点击登录</text>
          <text class="user-phone">登录后享受更多权益</text>
        </view>
      </view>
    </view>

    <!-- 资产 -->
    <view class="asset-row">
      <view class="asset-item"
        ><text class="asset-num">{{ user.points || 0 }}</text
        ><text class="asset-label">积分</text></view
      >
      <view class="asset-item"
        ><text class="asset-num">{{ couponCount }}</text
        ><text class="asset-label">优惠券</text></view
      >
      <view class="asset-item" @click="goPage('/pages/collection/collection')"
        ><text class="asset-num">{{ collectionCount }}</text
        ><text class="asset-label">收藏</text></view
      >
    </view>

    <!-- 订单快捷入口 -->
    <view class="order-section">
      <view
        class="section-header"
        @click="goPage('/pages/order/list?status=-1')"
      >
        <text class="section-title">我的订单</text>
        <text class="section-more">查看全部 ></text>
      </view>
      <view class="order-icons">
        <view
          class="order-icon"
          v-for="(item, idx) in orderTabs"
          :key="idx"
          @click="goPage(item.url)"
        >
          <text class="icon-text">{{ item.icon }}</text>
          <text class="icon-label">{{ item.label }}</text>
        </view>
      </view>
    </view>

    <!-- 功能菜单 -->
    <view class="menu-section">
      <view
        class="menu-item"
        v-for="menu in menus"
        :key="menu.label"
        @click="goPage(menu.url)"
      >
        <text class="menu-label">{{ menu.icon }} {{ menu.label }}</text>
        <u-icon name="arrow-right" color="#ccc" size="16"></u-icon>
      </view>
    </view>

    <!-- 退出登录 -->
    <view class="logout-wrap" v-if="isLogin">
      <u-button text="退出登录" shape="circle" @click="handleLogout" customStyle="color: $accent-red; border-color: $accent-red;"></u-button>
    </view>
  </view>
</template>

<script>
import { mapState, mapGetters } from "vuex";
import { get } from "@/utils/request";

export default {
  data() {
    return {
      collectionCount: 0,
      couponCount: 0,
      orderTabs: [
        { icon: "💰", label: "待付款", url: "/pages/order/list?status=0" },
        { icon: "📦", label: "待发货", url: "/pages/order/list?status=1" },
        { icon: "🚚", label: "待收货", url: "/pages/order/list?status=2" },
        { icon: "⭐", label: "待评价", url: "/pages/order/list?status=3" },
      ],
      menus: [
        { icon: "📍", label: "地址管理", url: "/pages/address/list" },
        { icon: "🌳", label: "苗木上架", url: "/pages/product/add" },
        { icon: "📋", label: "苗木管理", url: "/pages/product/manage" },
        { icon: "❤️", label: "我的收藏", url: "/pages/collection/collection" },
        { icon: "🎫", label: "优惠券", url: "/pages/coupon/coupon" },
      ],
    };
  },
  computed: {
    ...mapState(["isLogin", "user"]),
    ...mapGetters(["isLoggedIn"]),
  },
  onShow() {
    if (this.isLogin) this.loadCounts()
  },
  methods: {
    async loadCounts() {
      try {
        const list = await get('/collection/list') || []
        this.collectionCount = list.length
      } catch (e) {}
    },
    handleLogout() {
      this.$store.dispatch("logout");
      this.showToast("已退出登录");
    },
  },
};
</script>

<style lang="scss" scoped>
.user-page {
  padding-bottom: 40rpx;
}
.user-card {
  background: linear-gradient(135deg, $primary-color, $primary-dark);
  padding: 60rpx 40rpx 80rpx;
  padding-top: calc(var(--status-bar-height) + 60rpx);
}
.user-info {
  display: flex;
  align-items: center;
}
.user-text {
  margin-left: 30rpx;
}
.user-name {
  font-size: 36rpx;
  font-weight: bold;
  color: $bg-white;
  display: block;
}
.user-phone {
  font-size: 24rpx;
  color: rgba(255, 255, 255, 0.8);
  margin-top: 10rpx;
}
.asset-row {
  display: flex;
  background: $bg-white;
  margin: -30rpx 30rpx 20rpx;
  border-radius: 12rpx;
  padding: 30rpx 0;
  justify-content: space-around;
}
.asset-item {
  text-align: center;
}
.asset-num {
  display: block;
  font-size: 36rpx;
  font-weight: bold;
  color: $primary-color;
}
.asset-label {
  display: block;
  font-size: 22rpx;
  color: $text-hint;
  margin-top: 6rpx;
}
.order-section {
  background: $bg-white;
  margin: 0 30rpx 20rpx;
  border-radius: 12rpx;
  padding: 30rpx;
}
.section-header {
  display: flex;
  justify-content: space-between;
  margin-bottom: 30rpx;
}
.section-title {
  font-size: 30rpx;
  font-weight: bold;
  color: $text-primary;
}
.section-more {
  font-size: 24rpx;
  color: $text-hint;
}
.order-icons {
  display: flex;
  justify-content: space-around;
}
.order-icon {
  text-align: center;
}
.icon-text {
  font-size: 48rpx;
  display: block;
}
.icon-label {
  font-size: 22rpx;
  color: $text-secondary;
  margin-top: 10rpx;
}
.menu-section {
  background: $bg-white;
  margin: 0 30rpx 20rpx;
  border-radius: 12rpx;
}
.menu-item {
  display: flex;
  justify-content: space-between;
  padding: 30rpx;
  border-bottom: 1rpx solid $bg-input;
}
.menu-item:last-child {
  border-bottom: none;
}
.menu-label {
  font-size: 28rpx;
  color: $text-primary;
}
.logout-wrap {
  padding: 30rpx;
  margin-top: 20rpx;
}
</style>
