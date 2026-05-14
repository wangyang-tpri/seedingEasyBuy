/*
* @Author: liu_x25@hdec.com
* @Date: 2022-06-16 09:52:03
* @LastEditors: liu_x25@hdec.com
* @LastEditTime: 2022-06-22 11:57:03
* @Description: 村务治理相关接口
*/
import Http from "@/utils/request";
// 获取农产品列表
export function getProduct (data) {
  return Http.request({
    url: '/yyc/village/product/page',
    method: 'get',
    data
  })
}
// 获取农产品详情
export function getProductDetail (id) {
  return Http.request({
    url: `/yyc/village/product`,
    method: 'get',
    data: {
      id
    }
  })
}
// 获取村务预约列表
export function getAffairsReserve (data) {
  return Http.request({
    url: '/yyc/villageAffairsReserve/page',
    method: 'get',
    data
  })
}
// 获取活动预约列表
export function getActivityReserve (data) {
  return Http.request({
    url: '/yyc/village/volunteerActivity/page',
    method: 'get',
    data
  })
}
// 获取预约事项列表
export function getActivityList (data) {
  return Http.request({
    url: '/yyc/villageActivityCategory/page',
    method: 'get',
    data
  })
}
// 获取房屋详细地址列表
export function getPlaceList (data) {
  return Http.request({
    url: '/yyc/villageRealestateHouseManage/page',
    method: 'get',
    data
  })
}
// 图片上传
export function uploadImage (data) {
  return Http.request({
    url: "/sys-storage/upload",
    method: "post",
    headers: {
      'Content-Type': 'multipart/form-data',
      'Fawkes-Biz': 'McpKuHo4bOLjXYw+tTuyARbJZVXJNoWK7egGAlLyd29x0QowIdKWQ1WPS6OCbZWFmKYJKDHvrUyKOjSh24rnfw==',
    },
    data,
    timeout: 0
  });
}