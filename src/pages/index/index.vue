<template>
  <view class="container">
    <view style="position: absolute; top: 50%; width: 100%; height: 100%;">
      <button open-type="getPhoneNumber" @getphonenumber="getPhoneNumber" style="width: 80%;">使用手机号登录</button>
    </view>
  </view>
</template>
<script>
export default {
  data() {
    return {

    }
  },
  onLoad(query) {
  },
  methods: {
    getPhoneNumber(e) {
      let temCode = e.detail.code;
      if (temCode) {
        this.$request('/accessToken', 'GET', { 'temCode': temCode }).then((res) => {
          if (res) {
            uni.reLaunch({
              url: '/pages/home/index'
            })
            uni.setStorageSync('phone', '20')
          }

        })
      }
    }
  }
};
</script>
<style lang="scss" scoped>
.container {
  width: 100%;
  height: 100%;
  border: 1px solid red;
  text-align: center;
  background: linear-gradient(to bottom, #4da2cb, #67b26f);
  background: linear-gradient(90deg, #2566FE 0%, #26D4FF 100%)
}</style>
