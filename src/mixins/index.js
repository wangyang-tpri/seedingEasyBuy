import { mapState, mapGetters } from 'vuex'

export default {
  computed: {
    ...mapState(['isLogin', 'user']),
    ...mapGetters(['isLoggedIn'])
  },
  methods: {
    // Price formatting
    formatPrice(price) {
      if (price == null) return '¥0.00'
      let p = Number(price)
      return '¥' + p.toFixed(2)
    },
    // Get base URL for API resources
    getBaseUrl() {
      return process.env.VUE_APP_BASE_API
    },
    // Get first image from JSON array, convert relative paths to absolute
    getFirstImage(images) {
      if (!images) return '/static/placeholder.png'
      try {
        if (typeof images === 'string' && images.startsWith('[')) {
          const arr = JSON.parse(images)
          if (arr.length > 0) {
            let url = arr[0]
            if (url && url.startsWith('/api/')) {
              const base = this.getBaseUrl()
              url = base ? base + url.substring(4) : url
            }
            return url
            console.log(url)
          }
          return '/static/placeholder.png'
        }
      } catch (e) { }
      let url = images
      if (url && url.startsWith('/api/')) {
        const base = this.getBaseUrl()
        url = base ? base + url.substring(4) : url
      }
      return url || '/static/placeholder.png'
    },
    // Navigate to page
    goPage(url) {
      uni.navigateTo({ url })
    },
    // Switch tab
    switchTab(url) {
      uni.switchTab({ url })
    },
    // Show toast
    showToast(title, icon = 'none') {
      uni.showToast({ title, icon })
    },
    // Format date
    formatDate(dateStr) {
      if (!dateStr) return ''
      return dateStr.replace('T', ' ').substring(0, 19)
    },
    // Get order status text
    getOrderStatus(status) {
      const map = {
        0: '待付款', 1: '待发货', 2: '待收货',
        3: '待评价', 4: '已完成', 5: '已取消', 6: '售后'
      }
      return map[status] || '未知'
    },
    // Get order status class
    getOrderStatusColor(status) {
      const map = {
        0: '#FF6B35', 1: '#07C160', 2: '#07C160',
        3: '#07C160', 4: '#999999', 5: '#999999', 6: '#FF6B35'
      }
      return map[status] || '#999999'
    }
  }
}
