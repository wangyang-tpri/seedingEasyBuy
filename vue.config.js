/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-04-28 15:12:04
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-22 15:59:42
 * @Description: 
 */
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
                target: process.env.VUE_APP_BASE_PATH_ZP,
                changeOrigin: true,
                pathRewrite: {
                    '/server-zp': ''
                }
            }
        }
    },

}