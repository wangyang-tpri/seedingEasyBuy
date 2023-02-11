/*
 * @Author: xie_sm
 * @Date: 2022-03-16 08:57:40
 * @LastEditors: xie_sm
 * @LastEditTime: 2022-03-17 14:42:47
 * @FilePath: \mobile-template\src\api\file.js
 * @Description: 参考凤翎web端，存储服务相关接口
 *
 */
import request from "@/utils/request";

/**
 *
 * @param {*} data f8s或g9s参数
 * @returns axios实例
 */
export function getFileToken (data) {
  return request.request({
    url: "/sys-storage/file",
    method: "post",
    data: data,
  });
}

/**
 *
 * @param {*} f8s 文件filetoken
 * @returns
 */
export function downloadFile (f8s) {
  return request.request({
    url: "/sys-storage/download",
    method: "get",
    params: {
      f8s,
    },
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    responseType: "blob",
  });
}
/**
 * 合并多个文件到文件组中
 * @param {*} groupToken 文件组token
 * @param {*} data fileToken数组
 * @returns
 */
export function changeFileG9s (groupToken, data) {
  return request.request({
    url: `/sys-storage/file/token?groupToken=${groupToken}`,
    method: "put",
    data: data,
  });
}
