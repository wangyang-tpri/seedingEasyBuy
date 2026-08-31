<template>
  <view class="empty-state">
    <view v-if="icon" class="empty-icon">{{ icon }}</view>
    <text class="empty-text">{{ text }}</text>
    <text v-if="sub" class="empty-sub">{{ sub }}</text>
    <view v-if="$slots.default" class="empty-actions">
      <slot />
    </view>
  </view>
</template>

<script>
/**
 * 空状态占位组件
 * 用法：
 *   <empty-state icon="🛒" text="购物车是空的~" />
 *   <empty-state icon="📍" text="还没有收货地址" sub="点击下方按钮添加" />
 *   <empty-state icon="🛒" text="登录后可查看购物车"><view class="btn-x">去登录</view></empty-state>
 * 基础样式复用全局原子类 .empty-state/.empty-icon/.empty-text/.empty-sub
 */
export default {
  name: 'empty-state',
  props: {
    icon: { type: String, default: '' },
    text: { type: String, default: '暂无数据' },
    sub: { type: String, default: '' }
  }
}
</script>

<style lang="scss" scoped>
.empty-actions {
  margin-top: 24rpx;
}
</style>
