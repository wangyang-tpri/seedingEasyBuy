/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-04-28 11:30:07
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-08-09 10:26:18
 * @Description: 
 */
import Vue from 'vue'
import App from './App'
import uView from "uview-ui";
import store from './store';
import Mixin from './mixins';
Vue.use(uView);
Vue.mixin(Mixin);
Vue.prototype.$store = store
Vue.config.productionTip = false
App.mpType = 'app';


uni.$u.setConfig({
  props: {
    form: {
      labelWidth: 120
    },
    line: {
      color: "#eee"
    }
  }
})

const app = new Vue({
  ...App
})
app.$mount()