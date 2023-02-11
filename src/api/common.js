/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-15 10:38:59
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-27 10:16:58
 * @Description: 公共请求
 */
import Http from "@/utils/request";
// 获取用户列表
export function getUser (data) {
    return Http.request({
        url: '/sys-user/users/page',
        method: 'get',
        data
    })
}
// 获取用户详情
export function getUserDetail (data) {
    return Http.request({
        url: '/sys-user/userInfo',
        method: 'get',
        data
    })
}
// 获取字典列表
export function getDictionary (data) {
    return Http.request({
        url: '/sys-system/dictionary/detail/list',
        method: 'get',
        data
    })
}
// 获取用户积分
export function getScore (data) {
    return Http.request({
        url: '/yyc/civilizationPointsAdjustment/rankingPage',
        method: 'get',
        data
    })
}

//根据角色获取用户
export function getUserBaseRole (data) {
    return Http.request({
        url: '/sys-system/role/users/page',
        method: 'get',
        data: data
    })
}
/**
 * 获取当前用户的积分调整信息
 */
export function getPersonnerlScore (data) {
    return Http.request({
        method: 'get',
        url: '/yyc/civilizationPointsAdjustment/myCivilizationPoints',
        params: data
    })
}
/**
 * 通过手机号登录小程序
 */
export function postPhone (data) {
    return Http.request({
        method: 'post',
        url: '/yyc/weChatApplet/login',
        data: data
    })
}
/**
 * 通过手机号无需密码登录小程序
 */
export function postPhoneTOUse (data) {
    return Http.request({
        method: 'post',
        url: '/yyc/weChatApplet/loginByPhone',
        data: data
    })
}