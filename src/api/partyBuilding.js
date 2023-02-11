/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-13 16:28:03
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-16 15:57:36
 * @Description: 党建相关接口
 */
import Http from "@/utils/request";
// 获取党建新闻
export function getNotice(data) {
    return Http.request({
        url: '/yyc/partyPushNotice/page',
        method: 'get',
        data
    })
}
export function getNoticeDetail(id) {
    return Http.request({
        url: `/yyc/partyPushNotice`,
        method: 'get',
        data: {
            id
        }
    })
}
// 获取模范事迹
export function getExemplaryDeeds(data) {
    return Http.request({
        url: '/yyc/partyExemplaryDeeds/page',
        method: 'get',
        data
    })
}
export function getExemplaryDeedsDetail(id) {
    return Http.request({
        url: `/yyc/partyExemplaryDeeds`,
        method: 'get',
        data: {
            id
        }
    })
}
// 获取模范事迹
export function getShiftManagmentList(data) {
    return Http.request({
        url: '/yyc/maintenance/inspectionSchedule/page',
        method: 'get',
        data
    })
}