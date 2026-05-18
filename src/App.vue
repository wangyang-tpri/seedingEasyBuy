<script>
export default {
  onLaunch() {
    this.$store.dispatch('restoreLogin')
  },
  onShow() {
    // Update cart badge on tabBar when app shows
    this.updateCartBadge()
  },
  methods: {
    updateCartBadge(count) {
      if (count > 0) {
        uni.setTabBarBadge({ index: 2, text: String(count) })
      } else {
        uni.removeTabBarBadge({ index: 2 })
      }
    }
  }
}
</script>
<style lang="scss">
@import "uview-ui/index.scss";
page {
  background: #f5f6fa;
}
</style>
