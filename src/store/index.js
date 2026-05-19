import Vue from 'vue'
import Vuex from 'vuex'
import { get, post, put, del } from '../utils/request'

Vue.use(Vuex)

const state = {
  token: '',
  isLogin: false,
  user: {},
  selectedCategoryId: 0
}

const mutations = {
  SET_TOKEN(state, token) {
    state.token = token
    uni.setStorageSync('token', token)
  },
  SET_USER(state, user) {
    state.user = user
    state.isLogin = true
    uni.setStorageSync('user', JSON.stringify(user))
  },
  SET_LOGIN(state, status) {
    state.isLogin = status
    if (!status) {
      state.token = ''
      state.user = {}
      uni.removeStorageSync('token')
      uni.removeStorageSync('user')
    }
  },
  UPDATE_USER(state, data) {
    state.user = { ...state.user, ...data }
    uni.setStorageSync('user', JSON.stringify(state.user))
  },
  SET_CATEGORY_ID(state, id) {
    state.selectedCategoryId = id
  }
}

const actions = {
  async login({ commit }, { code, phone }) {
    const res = await post('/auth/login', { code, phone })
    commit('SET_TOKEN', res.token)
    commit('SET_USER', res.user)
    return res
  },
  async loginByPhone({ commit }, { phone }) {
    const res = await post('/auth/login_by_phone', { phone })
    commit('SET_TOKEN', res.token)
    commit('SET_USER', res.user)
    return res
  },
  async fetchUserInfo({ commit }) {
    const user = await get('/user/info')
    commit('SET_USER', user)
    return user
  },
  async updateProfile({ commit }, data) {
    await put('/user/info', data)
    commit('UPDATE_USER', data)
  },
  logout({ commit }) {
    commit('SET_LOGIN', false)
  },
  restoreLogin({ commit }) {
    const token = uni.getStorageSync('token')
    const user = uni.getStorageSync('user')
    if (token && user) {
      try {
        commit('SET_TOKEN', token)
        commit('SET_USER', JSON.parse(user))
        return true
      } catch (e) { }
    }
    return false
  }
}

const getters = {
  isLoggedIn: state => state.isLogin,
  user: state => state.user,
  token: state => state.token
}

export default new Vuex.Store({
  state,
  mutations,
  actions,
  getters
})
