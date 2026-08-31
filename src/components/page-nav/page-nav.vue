<template>
  <view class="page-nav">
    <text class="page-nav-title">{{ title }}</text>
    <slot />
  </view>
</template>

<script>
/**
 * 顶部标题栏组件（含状态栏安全区内边距）
 * 用法：<page-nav title="购物车" />
 * 基础样式复用全局原子类 .page-nav/.page-nav-title
 */
export default {
  name: 'page-nav',
  props: {
    title: { type: String, default: '' }
  }
}
</script>
