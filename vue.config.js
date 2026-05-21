module.exports = {
  transpileDependencies: ['uview-ui'],
  devServer: {
    proxy: {
      '/api': {
        target: process.env.VUE_APP_BASE_API,
        changeOrigin: true,
        pathRewrite: {
          '/api': ''
        }
      },
    }
  },

}