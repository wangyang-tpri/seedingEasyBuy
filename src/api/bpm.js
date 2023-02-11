/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-15 10:38:59
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-20 19:48:30
 * @Description: 流程引擎相关
 */
import Http from "@/utils/request";
// 获取任务代办
export function getUserTasks (data) {
    return Http.request({
        url: '/sys-bpm/userTasks',
        method: 'get',
        data
    })
}
// 获取表单列表
export function getRelTasks (data) {
    return Http.request({
        url: '/sys-bpm/relTasks',
        method: 'get',
        data
    })
}
// 获取历史流程处理
export function getProcessHistory (bizId) {
    return Http.request({
        url: '/sys-bpm/process/history',
        method: 'get',
        data: {
            bizId
        }
    })
}
// 获取流程详情
export function getTaskDetail (taskId) {
    return Http.request({
        url: `/sys-bpm/userTask?taskId=${taskId}`,
        method: 'get',
    })
}
// 获取表单按钮
export function getFormButton (taskId) {
    return Http.request({
        url: "/sys-bpm/process/button",
        method: 'get',
        data: {
            taskId
        }
    })
}
// 表单退回
export function formReject (params) {
    return Http.request({
        url: "/sys-bpm/process/reject",
        method: 'put',
        params
    })
}
// 表单委托
export function formDelegate (params) {
    return Http.request({
        url: "/sys-bpm/process/delegate",
        method: 'put',
        params
    })
}
// 查询表单
export function formQuery (data) {
    return Http.request({
        url: "/yyc/form/query",
        method: 'post',
        data
    })
}
// 表单提交
export function formCommit (data) {
    return Http.request({
        url: "/yyc/form/commit",
        method: 'post',
        data
    })
}
// 获取历史流程数据
export function getFlowHistory (taskId) {
    return Http.request({
        url: `/sys-bpm/process/button?taskId=${taskId}`,
        method: 'get',
    })
}
//获取当前流程的节点
export function getFlowInstance (data) {
    return Http.request({
        url: '/sys-bpm/process/history/instance',
        method: 'get',
        params: data
    })
}

//根据id或部门获取对应的人员
export function getUsersBaseDepart (data) {
    return Http.request({
        url: '/sys-user/users/page',
        method: 'get',
        params: data,
    })
}
//获取上传文件
export function getUploaderFile (data) {
    return Http.request({
        url: '/sys-storage/file',
        method: 'POST',
        data,
    })
}
//文件下载接口
export function downloadUploaderFile (taskId) {
    return Http.request({
        url: `/sys-storage/download_image?f8s=${taskId}`,
        method: 'get',
    })
}