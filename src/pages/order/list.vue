<template>
  <view class="order-page">
    <u-tabs :list="tabs" :current="currentTab" @change="changeTab" :activeStyle="{ color: '#07C160' }"></u-tabs>
    <z-paging ref="paging" v-model="orderList" @query="loadOrders" :auto="false" :fixed="false" class="order-paging">
      <view class="order-card" v-for="order in orderList" :key="order.id" @click="goDetail(order.id)">
        <view class="order-header">
          <text class="order-shop">店铺{{ order.shopId }}</text>
          <text :style="{ color: getOrderStatusColor(order.status) }">{{ getOrderStatus(order.status) }}</text>
        </view>
        <view class="order-body">
          <text class="order-no">订单号: {{ order.orderNo }}</text>
          <text class="order-amount">{{ formatPrice(order.payAmount) }}</text>
          <text class="order-time">{{ formatDate(order.createTime) }}</text>
        </view>
        <view class="order-actions">
          <u-button v-if="order.status === 0" text="去支付" type="success" size="small" shape="circle" @click.stop="onPay(order)"></u-button>
          <u-button v-if="order.status === 1" text="提醒发货" size="small" shape="circle" @click.stop></u-button>
          <u-button v-if="order.status === 2" text="确认收货" type="success" size="small" shape="circle" @click.stop="onConfirm(order)"></u-button>
          <u-button v-if="order.status === 3" text="去评价" size="small" shape="circle" @click.stop></u-button>
          <u-button v-if="order.status === 0" text="取消" size="small" shape="circle" @click.stop="onCancel(order)"></u-button>
        </view>
      </view>
    </z-paging>
  </view>
</template>

<script>
import { get, post } from '@/utils/request'
export default {
  data() {
    return {
      currentTab: 0,
      orderList: [],
      tabs: [
        { name: '全部' }, { name: '待付款' }, { name: '待发货' },
        { name: '待收货' }, { name: '待评价' }
      ]
    }
  },
  onLoad(options) {
    this.currentTab = Math.max(0, parseInt(options.status || -1) + 1)
  },
  onShow() { this.$refs.paging && this.$refs.paging.reload() },
  methods: {
    async loadOrders(pageNo, pageSize) {
      const statusMap = [-1, 0, 1, 2, 3]
      const status = statusMap[this.currentTab]
      try {
        const result = await get(`/order/list?status=${status}&page=${pageNo}&size=${pageSize}`)
        this.$refs.paging.complete(result.records || [])
      } catch (e) { this.$refs.paging.complete(false) }
    },
    changeTab(e) {
      this.currentTab = e.index
      this.$refs.paging.reload()
    },
    async onPay(order) {
      uni.showLoading({ title: '支付中' })
      try {
        await post(`/order/pay/${order.id}`)
        uni.hideLoading()
        this.showToast('支付成功')
        this.$refs.paging.reload()
      } catch (e) { uni.hideLoading() }
    },
    async onCancel(order) {
      uni.showModal({
        title: '提示',
        content: '确定取消该订单吗？',
        success: async (res) => {
          if (res.confirm) {
            try {
              await post(`/order/cancel/${order.id}`)
              this.$refs.paging.reload()
            } catch (e) {}
          }
        }
      })
    },
    async onConfirm(order) {
      uni.showModal({
        title: '提示',
        content: '确认已收到商品？',
        success: async (res) => {
          if (res.confirm) {
            try {
              await post(`/order/confirm_receive/${order.id}`)
              this.$refs.paging.reload()
            } catch (e) {}
          }
        }
      })
    },
    goDetail(id) { uni.navigateTo({ url: `/pages/order/detail?id=${id}` }) }
  }
}
</script>

<style lang="scss" scoped>
.order-page {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
  background: #f5f6fa;
}
.order-paging {
  flex: 1;
}
.order-card { background: #fff; margin: 16rpx 24rpx 0; border-radius: 14rpx; padding: 24rpx 28rpx; }
.order-card:last-child { margin-bottom: 16rpx; }
.order-header { display: flex; justify-content: space-between; font-size: 28rpx; margin-bottom: 16rpx; }
.order-shop { font-weight: bold; color: #333; }
.order-body { font-size: 24rpx; color: #666; }
.order-no, .order-amount, .order-time { display: block; margin-bottom: 8rpx; }
.order-amount { font-size: 30rpx; color: #FF6B35; font-weight: bold; }
.order-actions { display: flex; justify-content: flex-end; gap: 16rpx; margin-top: 20rpx; }
</style>
