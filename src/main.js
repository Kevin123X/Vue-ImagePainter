import Vue from 'vue'
import App from './App.vue'
import './plugins/element.js'
import  './assets/icon/iconfont.js'
Vue.config.productionTip = false
// init commit
new Vue({
  render: h => h(App),
}).$mount('#app')
