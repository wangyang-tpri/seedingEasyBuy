module.exports = {
  transpileDependencies: ['uview-ui'],
  devServer: {
    proxy: {
      '/api': {
        target: process.env.VUE_APP_BASE_PATH,
        changeOrigin: true,
        pathRewrite: {
          '/api': ''
        }
      },
      '/server-zp': {
        target: 'http://10.218.72.73:8081',
        changeOrigin: true,
        pathRewrite: {
          '^/server-zp': '/'
        }
      }
    }
  },

}