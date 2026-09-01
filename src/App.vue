<script>
const PUBLIC_PAGES = [
  'pages/index/index',
  'pages/category/category',
  'pages/product/list',
  'pages/product/detail',
  'pages/search/search',
  'pages/mine/login'
]

export default {
  onLaunch() {
    this.$store.dispatch('restoreLogin')
    this.setupAuthGuard()
  },
  onShow() {
    this.updateCartBadge()
  },
  methods: {
    setupAuthGuard() {
      const checkLogin = () => {
        const token = uni.getStorageSync('token')
        return !!token
      }
      uni.addInterceptor('navigateTo', {
        invoke(args) {
          if (!checkLogin() && !PUBLIC_PAGES.some(p => args.url.startsWith('/' + p))) {
            uni.reLaunch({ url: '/pages/mine/login' })
            return false
          }
        }
      })
      uni.addInterceptor('switchTab', {
        invoke(args) {
          const requiresAuth = ['pages/cart/cart', 'pages/user/user']
          if (!checkLogin() && requiresAuth.some(p => args.url.startsWith('/' + p))) {
            uni.reLaunch({ url: '/pages/mine/login' })
            return false
          }
        }
      })
    },
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
@import "@/common/atomic.scss";
page {
  background: $bg-page;
}
</style>
