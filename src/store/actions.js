/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-16 10:54:38
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-25 15:08:33
 * @Description: 
 */
import { getUserDetail, getDictionary, postPhone } from "@/api/common";
export const actions = {
    login ({ dispatch }, data) {
        return new Promise((resolve) => {
            postPhone(data).then((res) => {
                resolve(res)
                setTimeout(() => {
                    if (res.data) {
                        dispatch("getUserInfo");
                    } else if (res.message && (res.message == '获取session_key失败' || res.message == '入参错误')) {
                        dispatch("getUserCode")
                    }
                }, 0);
            })
        })

    },
    getUserInfo ({ commit }) {
        getUserDetail({
            userName: uni.getStorageSync("userName"),
        }).then(res => {
            if (!res.status) {
                return false;
            }
            commit("setUser", res.data);
        })

    },
    //设置字典
    getDictionary ({ commit }) {
        getDictionary().then((res) => {
            if (!res.status) {
                return false;
            }
            commit("setDictionary", res.data);
        });

    },
    getUserCode () {
        uni.login({
            provider: "weixin",
            success: (res) => {
                if (res.code) {
                    uni.setStorageSync('wxCode', res.code);
                }
            },
        });
    }
}