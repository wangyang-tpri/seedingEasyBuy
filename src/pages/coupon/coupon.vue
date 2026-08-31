<template>
  <view class="coupon-page">
    <empty-state text="暂无优惠券" />
  </view>
</template>

<script>
export default {
  data() { return { list: [] } }
}
</script>

<style lang="scss" scoped>
/* 空状态复用 <empty-state> */
</style>
