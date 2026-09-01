// #ifdef H5
const baseUrl = process.env.NODE_ENV === 'development' ? '/api' : process.env.VUE_APP_BASE_API
// #endif
// #ifndef H5
const baseUrl = process.env.VUE_APP_BASE_API
// #endif


const config = {
  baseUrl: baseUrl,
  timeout: 15000
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
        const result = res.data
        if (result && result.code === 200) {
          resolve(result.data)
        } else if (result && result.code === 401) {
          uni.removeStorageSync('token')
          uni.reLaunch({ url: '/pages/user/login' })
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
