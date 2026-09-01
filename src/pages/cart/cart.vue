<template>
  <view class="cart-page">
    <!-- 页面标题 -->
    <page-nav title="购物车" />

    <!-- 未登录 -->
    <empty-state v-if="!isLogin" icon="🛒" text="登录后可查看购物车">
      <view class="login-btn btn-outline-red" @click="goPage('/pages/mine/login')">去登录</view>
    </empty-state>

    <!-- 已登录，有商品 -->
    <template v-else-if="cartData.length > 0">
      <scroll-view scroll-y class="cart-scroll">
        <view class="shop-group" v-for="(shop, idx) in cartData" :key="idx">
          <view class="shop-header">
            <u-checkbox
              :checked="isShopAllSelected(shop)"
              @change="toggleShop(shop)"
              shape="circle"
            ></u-checkbox>
            <view class="shop-icon">🏪</view>
            <text class="shop-name">{{ shop.shopName }}</text>
          </view>
          <view class="cart-item" v-for="item in shop.items" :key="item.id">
            <u-checkbox
              :checked="item.selected === 1"
              @change="toggleItem(item)"
              shape="circle"
            ></u-checkbox>
            <image
              :src="fixImageUrl(item.productImage)"
              mode="aspectFill"
              class="item-img"
              @click="goDetail(item.productId)"
            />
            <view class="item-info">
              <text class="item-name">{{ item.productName }}</text>
              <text class="item-sku" v-if="item.skuName">{{
                item.skuName
              }}</text>
              <view class="item-bottom">
                <text class="item-price">{{ formatPrice(item.price) }}</text>
                <view class="qty-wrap">
                  <u-number-box
                    :value="item.quantity"
                    :min="1"
                    :max="item.stock || 99"
                    @change="(val) => changeQty(item, val.value)"
                  />
                </view>
              </view>
              <text
                class="stock-warn"
                v-if="item.stock && item.quantity >= item.stock * 0.8"
                >库存紧张，仅剩 {{ item.stock }} 件</text
              >
            </view>
            <view class="item-del" @click.stop="deleteItem(item)">✕</view>
          </view>
        </view>
        <view class="scroll-bottom-space"></view>
      </scroll-view>

      <!-- 底部结算栏 -->
      <bottom-bar class="cart-bar">
        <view class="bottom-left">
          <u-checkbox
            :checked="isAllSelected"
            @change="toggleAll"
            shape="circle"
          >
            <text class="select-all-text">全选</text>
          </u-checkbox>
        </view>
        <view class="bottom-right">
          <text class="count-hint" v-if="totalCount > 0">共{{ totalCount }}件</text>
          <view class="total-block">
            <text class="total-label">合计</text>
            <text class="total-price">{{ formatPrice(totalPrice) }}</text>
          </view>
          <view class="checkout-btn btn-primary" @click="checkout">
            <text>去结算</text>
            <text v-if="selectedCount > 0">({{ selectedCount }})</text>
          </view>
        </view>
      </bottom-bar>
    </template>

    <!-- 已登录，无商品 -->
    <empty-state v-else icon="🛒" text="购物车是空的~">
      <view class="go-shop-btn btn-primary" @click="switchTab('/pages/index/index')"
        >去逛逛</view
      >
    </empty-state>
  </view>
</template>

<script>
import { get, post, put, del } from "@/utils/request";
export default {
  data() {
    return { cartData: [], allSelected: true, loaded: false };
  },
  computed: {
    totalCount() {
      let count = 0;
      this.cartData.forEach((shop) => shop.items.forEach(() => count++));
      return count;
    },
    selectedCount() {
      let count = 0;
      this.cartData.forEach((shop) => {
        shop.items.forEach((item) => {
          if (item.selected === 1) count++;
        });
      });
      return count;
    },
    isAllSelected() {
      if (this.cartData.length === 0) return false;
      return this.cartData.every((shop) =>
        shop.items.every((item) => item.selected === 1)
      );
    },
    totalPrice() {
      let total = 0;
      this.cartData.forEach((shop) => {
        shop.items.forEach((item) => {
          if (item.selected === 1) total += Number(item.price) * item.quantity;
        });
      });
      return total;
    },
  },
  onShow() {
    if (!this.isLogin) return;
    this.loadCart();
  },
  methods: {
    async loadCart() {
      try {
        this.cartData = (await get("/cart/list")) || [];
      } catch (e) {}
    },
    isShopAllSelected(shop) {
      return shop.items.every((item) => item.selected === 1);
    },
    async toggleShop(shop) {
      const sel = this.isShopAllSelected(shop) ? 0 : 1;
      for (const item of shop.items) {
        await put("/cart/update", { id: item.id, selected: sel });
      }
      this.loadCart();
    },
    async toggleItem(item) {
      await put("/cart/update", {
        id: item.id,
        selected: item.selected === 1 ? 0 : 1,
      });
      this.loadCart();
    },
    async toggleAll() {
      const sel = this.isAllSelected ? 0 : 1;
      for (const shop of this.cartData) {
        for (const item of shop.items) {
          await put("/cart/update", { id: item.id, selected: sel });
        }
      }
      this.loadCart();
    },
    async changeQty(item, qty) {
      await put("/cart/update", { id: item.id, quantity: qty });
      this.loadCart();
    },
    deleteItem(item) {
      uni.showModal({
        title: "确认删除",
        content: "确定要从购物车中删除该商品吗？",
        success: async (res) => {
          if (res.confirm) {
            try {
              await del("/cart/delete/" + item.id);
              this.loadCart();
            } catch (e) {}
          }
        },
      });
    },
    checkout() {
      const selected = [];
      this.cartData.forEach((shop) => {
        shop.items.forEach((item) => {
          if (item.selected === 1) selected.push(item);
        });
      });
      if (selected.length === 0) {
        this.showToast("请选择商品");
        return;
      }
      uni.navigateTo({ url: "/pages/order/confirm" });
    },
    fixImageUrl(url) {
      if (!url) return "/static/placeholder.png";
      if (url && url.startsWith("/api/")) {
        const base = this.getBaseUrl();
        return base ? base + url.substring(4) : url;
      }
      return url;
    },
    goDetail(id) {
      uni.navigateTo({ url: `/pages/product/detail?id=${id}` });
    },
  },
};
</script>

<style lang="scss" scoped>
.cart-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  background: $bg-page;
  overflow: hidden;
}

/* ========== 页面标题 ========== */
/* ========== 滚动区域 ========== */
.cart-scroll {
  flex: 1;
  overflow-y: auto;
}
.scroll-bottom-space {
  height: 20rpx;
}

/* 页面标题复用公共 .page-nav/.page-nav-title */

/* ========== 店铺分组 ========== */
.shop-group {
  margin: 20rpx 24rpx 0;
  background: $bg-white;
  border-radius: 16rpx;
  overflow: hidden;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.shop-header {
  display: flex;
  align-items: center;
  padding: 20rpx 24rpx;
  background: $bg-light;
  border-bottom: 1rpx solid $bg-input;
}
.shop-icon {
  font-size: 28rpx;
  margin-left: 8rpx;
  margin-right: 10rpx;
}
.shop-name {
  font-size: 27rpx;
  font-weight: 600;
  color: $text-primary;
}

/* ========== 购物车条目 ========== */
.cart-item {
  display: flex;
  align-items: flex-start;
  padding: 20rpx 24rpx;
  border-bottom: 1rpx solid $bg-stripe;
  &:last-child {
    border-bottom: none;
  }
}
.item-img {
  width: 150rpx;
  height: 150rpx;
  border-radius: 10rpx;
  margin: 0 16rpx;
  flex-shrink: 0;
  background: $bg-gray;
}
.item-info {
  flex: 1;
  min-width: 0;
}
.item-name {
  font-size: 27rpx;
  color: $text-primary;
  display: -webkit-box;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
  overflow: hidden;
  line-height: 1.4;
}
.item-sku {
  font-size: 22rpx;
  color: #aaa;
  margin-top: 4rpx;
  display: block;
}
.item-bottom {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 18rpx;
}
.item-price {
  font-size: 30rpx;
  color: $accent-orange;
  font-weight: 700;
}
.qty-wrap {
  flex-shrink: 0;
}
.stock-warn {
  display: block;
  font-size: 20rpx;
  color: $accent-orange;
  margin-top: 6rpx;
}
.item-del {
  flex-shrink: 0;
  width: 44rpx;
  height: 44rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  color: $accent-red;
  font-weight: bold;
  margin-left: 8rpx;
}

/* ========== 底部结算栏（容器复用 <bottom-bar>，这里只补 flex 布局） ========== */
.cart-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.bottom-left {
  flex-shrink: 0;
}
.select-all-text {
  font-size: 26rpx;
  color: $text-primary;
  margin-left: 8rpx;
}
.bottom-right {
  display: flex;
  align-items: center;
  gap: 16rpx;
}
.total-block {
  display: flex;
  align-items: baseline;
}
.total-label {
  font-size: 24rpx;
  color: $text-secondary;
}
.total-price {
  font-size: 36rpx;
  color: $accent-orange;
  font-weight: 700;
  margin-left: 6rpx;
}
.checkout-btn {
  padding: 16rpx 40rpx;
  white-space: nowrap;
}

/* ========== 空状态操作按钮（结构复用 <empty-state>，slot 内按钮样式） ========== */
.login-btn {
  padding: 14rpx 48rpx;
  margin-top: 20rpx;
}
.go-shop-btn {
  padding: 14rpx 48rpx;
  margin-top: 20rpx;
}
</style>
