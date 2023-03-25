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