/**
* uni.request请求
* 
*/
let config = {
  baseUrl: 'http://10.218.72.80:8081',
  header: { 'content-type': 'application/x-www-form-urlencoded' }
}
let request = (url = '', type = 'GET', data) => {
  uni.showLoading({
    title: "加载中",
  });
  return new Promise((resolve, reject) => {
    uni.request({
      url: config.baseUrl + url,
      method: type,
      data: data,
      dataType: 'json',
      header: config.header,
    }).then((res) => {
      setTimeout(() => {
        uni.hideLoading()
      }, 200)
      resolve(res)
    }, (res) => {
      if (res.statusCode == 401) {
        uni.reLaunch({
          url: "/pages/index"
        })
      }
      reject(res)
    })
  })
}
export default request