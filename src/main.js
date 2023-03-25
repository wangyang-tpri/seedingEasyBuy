import Vue from 'vue'
import App from './App'
import uView from "uview-ui";
import store from './store';
import Mixin from './mixins';
import request  from './utils/request';
Vue.use(uView);
Vue.mixin(Mixin);
Vue.prototype.$store = store
Vue.config.productionTip = false
Vue.prototype.$request = request
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