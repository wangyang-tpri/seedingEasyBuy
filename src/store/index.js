/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-13 14:31:30
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-20 10:18:19
 * @Description: vuex封装
 */
import Vue from 'vue';
import Vuex from "vuex";
Vue.use(Vuex)
import { mutations } from "./mutations.js"
import { getters } from "./getters.js"
import { actions } from "./actions.js"
const store = new Vuex.Store({
    state: {
        isLogin: false,
        user: {},
        dictionary: {}
    },
    mutations,
    getters,
    actions
})
for (let item in store.state) {
    uni.getStorageSync(item) ? store.state[item] = (uni.getStorageSync(item)) : {};
}
export default store;