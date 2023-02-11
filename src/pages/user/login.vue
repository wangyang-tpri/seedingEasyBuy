<template>
  <div class="container">
    <image
      src="https://yycweb.hdec.com/img/logo.5f4e6928.png"
      mode="widthFix"
      class="logo"
    />
    <image
      src="https://yycweb.hdec.com/api/sys-storage/download?f8s=eb13c370e45bba751f98552aa7cfbaed"
      mode="widthFix"
      class="title"
    />
    <div class="content" v-if="type == 1">
      <button
        open-type="getPhoneNumber"
        @getphonenumber="getphonenumber"
        class="submit"
      >
        手机号一键登录
      </button>
      <div class="submit1" @click="toPassWored">账号密码登录></div>
    </div>

    <div class="login" v-if="type == 2">
      <div class="inputBox">
        <u--input
          placeholder="请输入账户"
          border="bottom"
          color="#fff"
          v-model="userAccount"
          prefixIcon="account"
          prefixIconStyle="font-size: 22px;color: #909399"
        ></u--input>
      </div>

      <div class="inputBox">
        <u--input
          placeholder="请输入密码"
          password="true"
          v-model="accountPassWored"
          prefixIcon="lock"
          border="bottom"
          color="#fff"
          prefixIconStyle="font-size: 22px;color: #909399"
        ></u--input>
      </div>
      <div class="inputBox">
        <button class="submit3" @click="cancelPassLogin">取消</button>
        <button class="submit2" @click="PassLogin">登录</button>
      </div>
    </div>
  </div>
</template>
<script>
import { mapActions } from "vuex";
import { postPhoneTOUse } from "@/api/common";
export default {
  data () {
    return {
      type: 1,
      userForm: {
        username: "",
      },
      userAccount: "",
      accountPassWored: "",
    };
  },
  methods: {
    ...mapActions(["login", 'getUserInfo']),
    getphonenumber (e) {
      uni.showLoading({
        title: "登陆中",
      });
      let encryptedData = e.detail.encryptedData;
      let iv = e.detail.iv;
      let code = uni.getStorageSync("wxCode");
      this.login({
        encryptedData: encryptedData,
        iv: iv,
        code: code,
      })
        .then((res) => {
          if (res.message == '非本村居民,仅限内部人员使用') {
            uni.showToast({
              title: res.message || '',
              icon: "none",
            });
            return false;
          }
          this.disposeLoginData(res);
        })
        .catch((res) => {
          uni.hideLoading();
        });
    },
    disposeLoginData (res) {
    //   let data = res.data.body;
    //   uni.setStorageSync("token", data.access_token);
    //   uni.setStorageSync("userName", data.userName);
      uni.hideLoading();
      uni.showToast({
        title: "登录成功",
        icon: "success",
      });
      setTimeout(() => {
        uni.switchTab({
          url: "/pages/home/index",
        });
      }, 1000);
    },
    toPassWored () {
      this.type = 2;
    },
    cancelPassLogin () {
      this.type = 1;
    },
    // getDictionary () {
    //   getDictionary().then((res) => {
    //     if (!res.status) {
    //       return false;
    //     }
    //     commit("setDictionary", res.data);
    //   });

    // },
    PassLogin () {
      if (
        // this.userAccount == "13104510297" &&
        // this.accountPassWored == "fawkes@2020"
        this.userAccount == '123' &&
        this.accountPassWored == '123'
      ) {
        // postPhoneTOUse({
        //   phone: this.userAccount,
        // }).then((res) => {
        //   if (!res.status) {
        //     return false;
        //   }
        //   this.getUserInfo()
        
        // });
        this.disposeLoginData(res);
      } else {
        uni.showToast({
          title: "仅供管理员使用",
          icon: "error",
        });
      }
    },
  },
};
</script>
<style lang="scss" scoped>
.container {
  height: 100vh;
  position: relative;
  background-image: url(https://yycweb.hdec.com/static/app/app_login_back.jpg);
  background-position: center;
  background-size: 100%;
  .bg_top {
    position: absolute;
    top: 0;
    width: 100%;
  }
  .bg_bottom {
    position: absolute;
    bottom: 0;
    width: 100%;
  }
  .logo {
    width: 124rpx;
    position: absolute;
    top: 245rpx;
    left: 0;
    right: 0;
    margin: auto;
  }
  .title {
    width: 545rpx;
    position: absolute;
    top: 360rpx;
    left: 0;
    right: 0;
    margin: auto;
  }
  .content {
    position: absolute;
    top: 750rpx;
    left: 0;
    right: 0;
    margin: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
    .submit {
      width: 600rpx;
      height: 88rpx;
      background: $uni-color-primary;
      color: #fff;
      line-height: 88rpx;
      border-radius: 12rpx;
      letter-spacing: 1px;
      font-weight: 400;
    }
    .submit1 {
      width: 600rpx;
      height: 88rpx;
      color: #fff;
      line-height: 88rpx;
      text-align: center;
      border-radius: 12rpx;
      letter-spacing: 1px;
      font-weight: 400;
    }
    .tips {
      text-align: center;
      padding-top: 28rpx;
      font-size: 32rpx;
      font-weight: 400;
      color: #ffffff;
    }
  }
  .login {
    position: absolute;
    top: 550rpx;
    left: 0;
    right: 0;
    margin: auto;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
    .inputBox {
      width: 600rpx;
      height: 88rpx;
      margin-top: 30rpx;
      display: flex;
      flex-direction: row;
      align-items: center;
      justify-content: space-between;
      .submit2 {
        width: 240rpx;
        height: 68rpx;
        font-size: 28rpx;
        background: #027aff;
        color: #fff;
        line-height: 68rpx;
        border-radius: 6rpx;
        letter-spacing: 1rpx;
      }
      .submit3 {
        width: 240rpx;
        font-size: 28rpx;
        height: 68rpx;
        background: none;
        color: #fff;
        line-height: 68rpx;
        border-radius: 6rpx;
        letter-spacing: 1px;
        border: 2rpx solid #027aff;
      }
    }
  }
}
</style>