/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-13 10:56:20
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-16 11:54:11
 * @Description: 封装请求
 */
uni.$u.http.setConfig((config) => {

    // #ifdef  H5
    config.baseURL = '/server-zp';
    // #endif

    // #ifndef  H5
    config.baseURL = process.env.VUE_APP_BASE_PATH_ZP;
    // #endif

    config.withCredentials = true;
    config.timeout = 20000;
    return config
})

// 请求拦截
uni.$u.http.interceptors.request.use((config) => { // 可使用async await 做异步操作
    // 初始化请求拦截器时，会执行此方法，此时data为undefined，赋予默认{}
    config.data = config.data || {}

    config.header['Fawkes-Auth'] = uni.getStorageSync("token");



    return config
}, config => { // 可使用async await 做异步操作
    return Promise.reject(config)
})

// 响应拦截
uni.$u.http.interceptors.response.use((response) => {
    const data = response.data
    if (data.code !== 8000000) {
        uni.$u.toast(data.message || "请求异常");
    }
    return data;
}, (response) => {
    uni.$u.toast(response.data.message || '请求失败')
    return Promise.reject(response.data)
})
export default uni.$u.http;