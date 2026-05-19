<template>
  <view class="address-page">
    <view v-if="addressList.length > 0" class="list-wrap">
      <view class="address-card" v-for="addr in addressList" :key="addr.id" @click="selectAddress(addr)">
        <view class="addr-row1">
          <text class="addr-name">{{ addr.receiverName }}</text>
          <text class="addr-phone">{{ addr.phone }}</text>
          <view class="addr-tag" v-if="addr.isDefault === 1">默认</view>
          <view class="addr-tag" v-else-if="addr.label">{{ addr.label }}</view>
        </view>
        <text class="addr-text">{{ addr.fullAddress || (addr.province || '') + (addr.city || '') + (addr.district || '') + (addr.detailAddress || '') }}</text>
        <view class="addr-actions">
          <view class="btn-edit" @click.stop="editAddress(addr.id)">编辑</view>
          <view class="btn-delete" @click.stop="confirmDelete(addr.id)">删除</view>
        </view>
      </view>
    </view>

    <view class="empty" v-else>
      <view class="empty-icon">📍</view>
      <text class="empty-text">还没有收货地址</text>
      <text class="empty-sub">点击下方按钮添加</text>
    </view>

    <view class="bottom-area">
      <view class="btn-add" @click="editAddress()">新增收货地址</view>
    </view>
  </view>
</template>

<script>
import { get, del } from '@/utils/request'

export default {
  data() { return { addressList: [] } },
  onShow() { this.loadList() },
  methods: {
    async loadList() {
      try { this.addressList = await get('/address/list') || [] } catch (e) {}
    },
    confirmDelete(id) {
      uni.showModal({
        title: '确认删除',
        content: '删除后不可恢复，确定删除该地址吗？',
        success: async (res) => {
          if (res.confirm) {
            try {
              await del(`/address/delete/${id}`)
              this.showToast('已删除')
              this.loadList()
            } catch (e) {}
          }
        }
      })
    },
    editAddress(id) {
      uni.navigateTo({ url: `/pages/address/edit${id ? '?id=' + id : ''}` })
    },
    selectAddress(addr) {
      const pages = getCurrentPages()
      const prevPage = pages[pages.length - 2]
      if (prevPage && prevPage.$vm && prevPage.route && prevPage.route.includes('order')) {
        prevPage.$vm.selectedAddress = addr
        uni.navigateBack()
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.address-page {
  min-height: 100vh;
  background: #f5f6fa;
  padding: 20rpx 24rpx 160rpx;
}
.list-wrap { }

.address-card {
  background: #fff;
  border-radius: 14rpx;
  padding: 24rpx;
  margin-bottom: 16rpx;
  box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04);
}

.addr-row1 {
  display: flex;
  align-items: center;
  margin-bottom: 10rpx;
}
.addr-name {
  font-size: 30rpx;
  font-weight: 600;
  color: #333;
  margin-right: 20rpx;
}
.addr-phone {
  font-size: 26rpx;
  color: #999;
  flex: 1;
}
.addr-tag {
  flex-shrink: 0;
  font-size: 20rpx;
  color: #07C160;
  background: #e8f8ee;
  padding: 2rpx 12rpx;
  border-radius: 4rpx;
}

.addr-text {
  font-size: 24rpx;
  color: #666;
  line-height: 1.5;
  display: block;
  margin-bottom: 16rpx;
}

.addr-actions {
  display: flex;
  justify-content: flex-end;
  gap: 16rpx;
  padding-top: 16rpx;
  border-top: 1rpx solid #f0f0f0;
}
.btn-edit {
  padding: 10rpx 32rpx;
  border-radius: 30rpx;
  border: 1rpx solid #07C160;
  color: #07C160;
  font-size: 24rpx;
}
.btn-delete {
  padding: 10rpx 32rpx;
  border-radius: 30rpx;
  background: #ee3f3f;
  color: #fff;
  font-size: 24rpx;
}

.empty {
  text-align: center;
  padding-top: 240rpx;
}
.empty-icon {
  font-size: 80rpx;
  opacity: 0.3;
  margin-bottom: 20rpx;
}
.empty-text {
  display: block;
  font-size: 28rpx;
  color: #bbb;
}
.empty-sub {
  display: block;
  font-size: 24rpx;
  color: #ccc;
  margin-top: 8rpx;
}

.bottom-area {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16rpx 24rpx;
  padding-bottom: calc(16rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -4rpx 20rpx rgba(0,0,0,0.06);
  z-index: 10;
}
.btn-add {
  text-align: center;
  font-size: 28rpx;
  font-weight: 600;
  color: #fff;
  background: linear-gradient(135deg, #07C160, #06AD56);
  border-radius: 40rpx;
  padding: 18rpx 0;
  box-shadow: 0 4rpx 16rpx rgba(7, 193, 96, 0.35);
  &:active { opacity: 0.9; transform: scale(0.97); }
}
</style>
