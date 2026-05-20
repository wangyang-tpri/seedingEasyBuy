<template>
  <view class="coupon-page">
    <view class="empty">
      <text>暂无优惠券</text>
    </view>
  </view>
</template>

<script>
export default {
  data() { return { list: [] } }
}
</script>

<style lang="scss" scoped>
.empty { text-align: center; padding: 200rpx 0; color: $text-hint; font-size: 28rpx; }
</style>
