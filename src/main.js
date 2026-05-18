import Vue from 'vue'
import App from './App'
import uView from 'uview-ui'
import store from './store'
import Mixin from './mixins'

Vue.use(uView)
Vue.mixin(Mixin)
Vue.prototype.$store = store
Vue.config.productionTip = false

uni.$u.setConfig({
  props: {
    form: { labelWidth: 120 },
    line: { color: '#eee' }
  }
})

store.dispatch('restoreLogin')

App.mpType = 'app'
const app = new Vue({ ...App })
app.$mount()
