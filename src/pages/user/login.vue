<template>
  <view class="login-page">
    <!-- 顶部装饰 -->
    <view class="header-area">
      <view class="logo-circle">
        <text class="logo-emoji">🌳</text>
      </view>
      <text class="app-name">苗木易购</text>
      <text class="app-desc">专业苗木在线交易平台</text>
    </view>

    <!-- 登录方式 -->
    <view class="login-body">
      <!-- 微信手机号一键登录 -->
      <button
        class="wechat-btn"
        open-type="getPhoneNumber"
        @getphonenumber="onGetPhoneNumber"
      >
        <view class="wechat-icon">💬</view>
        <text>微信手机号一键登录</text>
      </button>
      <text class="wechat-hint">需微信认证小程序，开发时请用下方手机号登录</text>

      <!-- 分割线 -->
      <view class="divider">
        <view class="divider-line"></view>
        <text class="divider-text">其他方式登录</text>
        <view class="divider-line"></view>
      </view>

      <!-- 手机号登录 -->
      <view class="phone-section">
        <view class="phone-input-wrap">
          <text class="input-prefix">+86</text>
          <input
            v-model="phone"
            type="number"
            maxlength="11"
            placeholder="请输入手机号"
            class="phone-input"
          />
        </view>
        <view class="agreement" @click="agree = !agree">
          <view :class="['check-box', agree ? 'checked' : '']">
            <text v-if="agree" class="check-mark">✓</text>
          </view>
          <text class="agree-text"
            >已阅读并同意 <text class="link">《用户协议》</text> 和
            <text class="link">《隐私政策》</text></text
          >
        </view>
        <view :class="['login-btn', phone ? '' : 'disabled']" @click="phone && loginByPhone()">
          <text>登 录</text>
        </view>
      </view>

      <text class="bottom-tip">首次登录即自动注册账号</text>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return { phone: "", agree: true };
  },
  methods: {
    async onGetPhoneNumber(e) {
      if (e.detail.errMsg !== "getPhoneNumber:ok") {
        uni.showToast({ title: "获取手机号需要微信认证的小程序", icon: "none" });
        return;
      }
      uni.showLoading({ title: "登录中" });
      try {
        let code = "";
        try {
          const res = await uni.login({ provider: "weixin" });
          code = res.code;
        } catch (e) {}
        if (!code) code = "dev_" + Date.now();
        // Use WeChat returned phone if available
        const phone = e.detail.phoneNumber || this.phone || "";
        await this.$store.dispatch("login", { code, phone });
        uni.hideLoading();
        uni.switchTab({ url: "/pages/index/index" });
      } catch (err) {
        uni.hideLoading();
        uni.showToast({ title: "登录失败，请重试", icon: "none" });
      }
    },
    async loginByPhone() {
      if (!this.phone) {
        this.showToast("请输入手机号");
        return;
      }
      if (this.phone.length !== 11) {
        this.showToast("请输入正确的手机号");
        return;
      }
      uni.showLoading({ title: "登录中" });
      try {
        await this.$store.dispatch("loginByPhone", { phone: this.phone });
        uni.hideLoading();
        uni.switchTab({ url: "/pages/index/index" });
      } catch (err) {
        uni.hideLoading();
        this.showToast("登录失败，请重试");
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.login-page {
  min-height: 100vh;
  background: $bg-white;
}

.header-area {
  padding-top: calc(var(--status-bar-height) + 80rpx);
  padding-bottom: 60rpx;
  text-align: center;
  background: linear-gradient(180deg, $primary-light 0%, $bg-white 100%);
}

.logo-circle {
  width: 140rpx;
  height: 140rpx;
  border-radius: 50%;
  background: linear-gradient(135deg, $primary-color, $primary-dark);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 30rpx;
  box-shadow: 0 8rpx 24rpx rgba(7, 193, 96, 0.3);
}

.logo-emoji {
  font-size: 64rpx;
}

.app-name {
  display: block;
  font-size: 44rpx;
  font-weight: 700;
  color: #222;
  letter-spacing: 4rpx;
}

.app-desc {
  display: block;
  font-size: 26rpx;
  color: $text-hint;
  margin-top: 16rpx;
}

.login-body {
  padding: 0 50rpx;
}

.wechat-btn {
  width: 100%;
  height: 96rpx;
  background: $primary-color;
  color: $bg-white;
  border-radius: 48rpx;
  font-size: 30rpx;
  font-weight: 500;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 6rpx 20rpx rgba(7, 193, 96, 0.25);
}

.wechat-icon {
  font-size: 36rpx;
  margin-right: 12rpx;
}
.wechat-hint {
  display: block;
  text-align: center;
  font-size: 20rpx;
  color: $text-hint;
  margin-top: 12rpx;
}

.divider {
  display: flex;
  align-items: center;
  margin: 40rpx 0 36rpx;
}

.divider-line {
  flex: 1;
  height: 1rpx;
  background: #e8e8e8;
}

.divider-text {
  font-size: 24rpx;
  color: $text-placeholder;
  padding: 0 24rpx;
  flex-shrink: 0;
}

.phone-section {
}

.phone-input-wrap {
  display: flex;
  align-items: center;
  background: #f8f9fa;
  border-radius: 16rpx;
  padding: 0 24rpx;
  height: 96rpx;
  margin-bottom: 24rpx;
  border: 2rpx solid transparent;
  transition: border-color 0.2s;
}

.phone-input-wrap:focus-within {
  border-color: $primary-color;
  background: $bg-white;
}

.input-prefix {
  font-size: 30rpx;
  font-weight: 500;
  color: $text-primary;
  padding-right: 20rpx;
  border-right: 1rpx solid #e0e0e0;
  margin-right: 20rpx;
}

.phone-input {
  flex: 1;
  font-size: 28rpx;
  color: $text-primary;
  height: 100%;
}

.agreement {
  display: flex;
  align-items: center;
  margin-bottom: 32rpx;
}

.check-box {
  width: 32rpx;
  height: 32rpx;
  border-radius: 50%;
  border: 2rpx solid $border-dashed;
  margin-right: 12rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  transition: all 0.2s;
}

.check-box.checked {
  background: $primary-color;
  border-color: $primary-color;
}

.check-mark {
  font-size: 20rpx;
  color: $bg-white;
  font-weight: bold;
}

.agree-text {
  font-size: 22rpx;
  color: $text-hint;
  line-height: 1.5;
}

.link {
  color: $primary-color;
}

.login-btn {
  width: 100%;
  height: 96rpx;
  background: $gradient-green;
  border-radius: 48rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 32rpx;
  font-weight: 600;
  color: $bg-white;
  box-shadow: $shadow-green;
  &:active { opacity: 0.9; transform: scale(0.98); }
  &.disabled { opacity: 0.4; pointer-events: none; }
}
.bottom-tip {
  display: block;
  text-align: center;
  font-size: 22rpx;
  color: $text-disabled;
  margin-top: 40rpx;
}
</style>
