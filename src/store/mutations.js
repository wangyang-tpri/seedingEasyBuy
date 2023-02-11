/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-16 10:53:27
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-20 10:18:29
 * @Description: 
 */
export const mutations = {
    // 用户登录
    setUser(state, data) {
        state.user = data;
        state.isLogin = true;
    },
    // 设置字典
    setDictionary(state, data) {
        state.dictionary = data;
        data && uni.setStorageSync("dictionary", data);
    },

}