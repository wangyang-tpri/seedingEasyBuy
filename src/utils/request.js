/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-13 10:56:20
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-27 10:19:07
 * @Description: 封装请求
 */
uni.$u.http.setConfig((config) => {

    // #ifdef  H5
    config.baseURL = '/api';
    // #endif

    // #ifndef  H5
    config.baseURL = process.env.VUE_APP_BASE_PATH;
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
        // uni.$u.toast(data.message || "请求异常");
        // uni.$u.toast("请求异常");
    }
    return data;
}, (response) => {
    if (response.statusCode == 401) {
        uni.clearStorage();
        uni.reLaunch({
            // url: "/pages/user/login",
            url: '/pages/home/index'
        });
        return Promise.reject(response.data)
    }
    // uni.$u.toast(response.data.message || '请求失败')
    uni.$u.toast('请求失败')
    return Promise.reject(response.data)
})
export default uni.$u.http;