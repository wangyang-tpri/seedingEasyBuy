<template>
  <view class="bottom-bar-fixed">
    <slot />
  </view>
</template>

<script>
/**
 * 底部固定操作栏组件（fixed + 白底 + 安全区适配）
 * 用法：
 *   <bottom-bar class="bar-flex">
 *     <view class="left">...</view>
 *     <view class="right">...</view>
 *   </bottom-bar>
 * 说明：class 会合并到根节点，页面可通过 class 补充 flex 布局；
 *       基础样式复用全局原子类 .bottom-bar-fixed
 */
export default {
  name: 'bottom-bar'
}
</script>
