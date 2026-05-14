/*
* @Author: liu_x25@hdec.com
* @Date: 2022-06-22 14:16:26
* @LastEditors: liu_x25@hdec.com
* @LastEditTime: 2022-06-25 14:45:22
* @Description: 
*/
import Http from "@/utils/request";
// 获取事项管理列表
export function getIncidentReport(data) {
  return Http.request({
    url: '/yyc/operationAndMaintenanceManagement/page',
    method: 'get',
    data:data
  })
}
// 获取巡检路线
export function getInspectionRoute(data) {
  return Http.request({
    url: '/yyc/maintenanceInspectionPort/page',
    method: 'get',
    data
  })
}
export function getInspectionRouteDetail(id) {
  return Http.request({
    url: `/yyc/maintenanceInspectionPort`,
    method: 'get',
    data: {
      id
    }
  })
}

export function record(data){
  return Http.request({
    url: '/yyc/inspectionRecord',
    method: 'post',
    data: data
  })
}
export function getByRouterId(data){
  return Http.request({
    url: '/yyc/inspectionRecord/getByRouteId',
    method: 'get',
    params: data
  })
}
export function routerPage(data){
  return Http.request({
    url: '/yyc/inspectionRecord/page',
    method: 'get',
    params: data
  })
}
export function getPathList(data){
  return Http.request({
    url: '/yyc/inspectionRecord/queryInspectionTasksPage',
    method: 'get',
    params: data
  })
}