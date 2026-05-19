<template>
  <view class="edit-page">
    <view class="form-card">
      <!-- 收货人 -->
      <view class="field-row">
        <view class="field-label">
          <text class="label-icon">👤</text>
          <text class="label-text">收货人</text>
        </view>
        <input
          v-model="formData.receiverName"
          placeholder="请输入收货人姓名"
          class="field-input"
          placeholder-style="color: #ccc"
        />
      </view>

      <!-- 手机号 -->
      <view class="field-row">
        <view class="field-label">
          <text class="label-icon">📱</text>
          <text class="label-text">手机号</text>
        </view>
        <input
          v-model="formData.phone"
          type="number"
          maxlength="11"
          placeholder="请输入手机号"
          class="field-input"
          placeholder-style="color: #ccc"
        />
      </view>

      <!-- 所在地区 -->
      <view class="field-row" @click="chooseLocation">
        <view class="field-label">
          <text class="label-icon">📍</text>
          <text class="label-text">所在地区</text>
        </view>
        <view class="field-right">
          <text
            :class="['field-value', !formData.fullAddress && 'placeholder']"
          >
            {{ formData.fullAddress || "点击选择省/市/区" }}
          </text>
          <u-icon name="arrow-right" color="#ccc" size="14"></u-icon>
        </view>
      </view>

      <!-- 详细地址 -->
      <view class="field-row">
        <view class="field-label">
          <text class="label-icon">🏠</text>
          <text class="label-text">详细地址</text>
        </view>
        <input
          v-model="formData.detailAddress"
          placeholder="街道/门牌号/楼层"
          class="field-input"
          placeholder-style="color: #ccc"
        />
      </view>
    </view>

    <!-- 地址标签 -->
    <view class="tag-section">
      <text class="tag-title">地址标签</text>
      <view class="tag-row">
        <view
          v-for="tag in tags"
          :key="tag.value"
          :class="['tag-item', formData.label === tag.value ? 'active' : '']"
          @click="formData.label = tag.value"
        >
          <text class="tag-icon">{{ tag.icon }}</text>
          <text>{{ tag.name }}</text>
        </view>
      </view>
    </view>

    <!-- 设为默认 -->
    <view class="switch-row">
      <text class="switch-label">设为默认地址</text>
      <u-switch
        v-model="formData.isDefault"
        :activeValue="1"
        :inactiveValue="0"
        activeColor="#07C160"
      />
    </view>

    <!-- 保存 -->
    <view class="save-btn">
      <u-button
        text="保 存"
        type="success"
        shape="circle"
        block
        @click="save"
      ></u-button>
    </view>

    <!-- 删除 -->
    <view class="delete-btn" v-if="id" @click="confirmDelete">
      <text>删除地址</text>
    </view>
  </view>
</template>

<script>
import { get, post, put, del } from "@/utils/request";
export default {
  data() {
    return {
      id: null,
      formData: {
        receiverName: "",
        phone: "",
        province: "",
        city: "",
        district: "",
        fullAddress: "",
        detailAddress: "",
        isDefault: 0,
        label: "",
      },
      tags: [
        { name: "家", value: "家", icon: "🏠" },
        { name: "公司", value: "公司", icon: "🏢" },
        { name: "学校", value: "学校", icon: "🏫" },
      ],
    };
  },
  onLoad(options) {
    if (options.id) {
      this.id = options.id;
      this.loadDetail();
    }
  },
  methods: {
    async loadDetail() {
      try {
        const list = (await get("/address/list")) || [];
        const addr = list.find((a) => a.id == this.id);
        if (addr) this.formData = { ...addr };
      } catch (e) {}
    },
    chooseLocation() {
      uni.chooseLocation({
        success: (res) => {
          if (res.address) {
            this.formData.fullAddress = res.address;
            // 尝试解析省市
            const addr = res.address;
            const provMatch = addr.match(
              /^(.+?省|.+?自治区|北京|上海|天津|重庆)/
            );
            if (provMatch) this.formData.province = provMatch[1];
            const cityMatch = addr.match(/(?:省|自治区)(.+?市)/);
            if (cityMatch) this.formData.city = cityMatch[1];
            const distMatch = addr.match(/(?:市)(.+?区|.+?县)/);
            if (distMatch) this.formData.district = distMatch[1];
          }
          if (res.name && !this.formData.detailAddress) {
            this.formData.detailAddress = res.name;
          }
        },
        fail: () => {
          this.showToast("请授权位置权限");
        },
      });
    },
    async save() {
      if (!this.formData.receiverName || !this.formData.phone) {
        this.showToast("请填写收货人和手机号");
        return;
      }
      if (!this.formData.detailAddress) {
        this.showToast("请填写详细地址");
        return;
      }
      uni.showLoading({ title: "保存中" });
      try {
        if (this.id) {
          await put("/address/update", { ...this.formData, id: this.id });
        } else {
          await post("/address/add", this.formData);
        }
        uni.hideLoading();
        this.showToast("保存成功");
        setTimeout(() => uni.navigateBack(), 800);
      } catch (e) {
        uni.hideLoading();
        this.showToast("保存失败");
      }
    },
    confirmDelete() {
      uni.showModal({
        title: "提示",
        content: "确定删除该地址吗？",
        success: async (res) => {
          if (res.confirm) {
            try {
              await del(`/address/delete/${this.id}`);
              this.showToast("已删除");
              setTimeout(() => uni.navigateBack(), 800);
            } catch (e) {}
          }
        },
      });
    },
  },
};
</script>

<style lang="scss" scoped>
.edit-page {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 60rpx;
}

.form-card {
  background: #fff;
  margin: 20rpx 30rpx;
  border-radius: 16rpx;
  overflow: hidden;
}

.field-row {
  display: flex;
  align-items: center;
  padding: 0 30rpx;
  height: 100rpx;
  border-bottom: 1rpx solid #f5f5f5;
  transition: background 0.15s;
}

.field-row:last-child {
  border-bottom: none;
}

.field-row:active {
  background: #fafafa;
}

.field-label {
  display: flex;
  align-items: center;
  width: 160rpx;
  flex-shrink: 0;
}

.label-icon {
  font-size: 30rpx;
  margin-right: 12rpx;
}

.label-text {
  font-size: 28rpx;
  color: #333;
  font-weight: 500;
}

.field-input {
  flex: 1;
  font-size: 28rpx;
  color: #333;
  text-align: right;
  height: 100%;
}

.field-right {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: flex-end;
}

.field-value {
  font-size: 28rpx;
  color: #333;
}

.field-value.placeholder {
  color: #ccc;
}

/* 地址标签 */
.tag-section {
  background: #fff;
  margin: 20rpx 30rpx;
  border-radius: 16rpx;
  padding: 30rpx;
}

.tag-title {
  font-size: 28rpx;
  font-weight: 500;
  color: #333;
  display: block;
  margin-bottom: 24rpx;
}

.tag-row {
  display: flex;
  gap: 20rpx;
}

.tag-item {
  flex: 1;
  height: 72rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f6fa;
  border-radius: 12rpx;
  font-size: 26rpx;
  color: #666;
  border: 2rpx solid transparent;
  transition: all 0.2s;
}

.tag-item.active {
  background: #e8f8ee;
  border-color: #07c160;
  color: #07c160;
  font-weight: 500;
}

.tag-icon {
  font-size: 28rpx;
  margin-right: 8rpx;
}

/* 默认开关 */
.switch-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: #fff;
  margin: 20rpx 30rpx;
  border-radius: 16rpx;
  padding: 24rpx 30rpx;
}

.switch-label {
  font-size: 28rpx;
  color: #333;
  font-weight: 500;
}

/* 保存按钮 */
.save-btn {
  padding: 40rpx 30rpx 0;
}

/* 删除按钮 */
.delete-btn {
  text-align: center;
  padding: 30rpx;
  margin-top: 20rpx;
  font-size: 28rpx;
  color: #ff6b35;
}
</style>
