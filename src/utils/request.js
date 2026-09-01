/**
 * H5 统一走同源代理：
 * 开发环境 → devServer proxy（vue.config.js）
 * 生产环境 → nginx 反向代理（nginx.conf）
 * 小程序/App 无同源策略，直接用后端绝对地址
 */


// #ifdef H5
const baseUrl = '/api'
// #endif
// #ifndef H5
const baseUrl = process.env.VUE_APP_BASE_API
// #endif


const config = {
  baseUrl: baseUrl,
  timeout: 15000
}

// 防止多个并发 401 请求重复跳转登录页
let isRedirecting = false
function handleUnauthorized() {
  if (isRedirecting) return
  isRedirecting = true
  uni.removeStorageSync('token')
  uni.removeStorageSync('user')
  uni.reLaunch({ url: '/pages/user/login' })
  setTimeout(() => { isRedirecting = false }, 2000)
}

function request(url = '', method = 'GET', data) {
  const token = uni.getStorageSync('token')
  const header = {
    'content-type': 'application/json'
  }
  if (token) {
    header['Authorization'] = 'Bearer ' + token
  }
  return new Promise((resolve, reject) => {
    uni.request({
      url: config.baseUrl + url,
      method: method,
      data: data,
      dataType: 'json',
      header: header,
      timeout: config.timeout,
      success: (res) => {
        // HTTP 401：后端拦截器返回的 token 无效/过期（响应体为空）
        if (res.statusCode === 401) {
          handleUnauthorized()
          reject({ message: '登录已过期，请重新登录' })
          return
        }
        const result = res.data
        if (result && result.code === 200) {
          resolve(result.data)
        } else if (result && result.code === 401) {
          // 业务码 401：后端正常返回但 code=401
          handleUnauthorized()
          reject(result)
        } else {
          const msg = (result && result.message) || '请求失败'
          reject({ message: msg })
        }
      },
      fail: (err) => {
        reject(err)
      }
    })
  })
}

export default request

export const get = (url, params) => request(url, 'GET', params)
export const post = (url, data) => request(url, 'POST', data)
export const put = (url, data) => request(url, 'PUT', data)
export const del = (url, data) => request(url, 'DELETE', data)
