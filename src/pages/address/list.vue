<template>
  <view class="address-page">
    <view v-if="addressList.length > 0" class="list-wrap">
      <view class="address-card" v-for="addr in addressList" :key="addr.id" @click="selectAddress(addr)">
        <!-- 第一行：姓名 + 电话 -->
        <view class="addr-row1">
          <text class="addr-name">{{ addr.receiverName }}</text>
          <text class="addr-phone">{{ addr.phone }}</text>
        </view>

        <!-- 第二行：标签 + 完整地址 -->
        <view class="addr-row2">
          <text class="addr-tag" v-if="addr.isDefault === 1">默认</text>
          <text class="addr-tag" v-if="addr.label && addr.isDefault !== 1">{{ addr.label }}</text>
          <text class="addr-text">{{ addr.fullAddress || (addr.province || '') + (addr.city || '') + (addr.district || '') + (addr.detailAddress || addr.detailAddress || '') }}</text>
        </view>

        <!-- 第三行：操作 -->
        <view class="addr-row3">
          <text class="addr-action" @click.stop="editAddress(addr.id)">编辑</text>
          <text class="addr-action del" @click.stop="confirmDelete(addr.id)">删除</text>
        </view>
      </view>
    </view>

    <!-- 空状态 -->
    <view class="empty" v-else>
      <image src="/static/placeholder.png" mode="widthFix" class="empty-img" />
      <text class="empty-text">还没有收货地址</text>
      <text class="empty-sub">点击下方按钮添加</text>
    </view>

    <!-- 新增按钮 -->
    <view class="bottom-area">
      <u-button text="新增收货地址" type="success" shape="circle" block @click="editAddress()"></u-button>
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
  padding-bottom: 160rpx;
}

.list-wrap {
  padding-top: 16rpx;
}

/* 卡片 */
.address-card {
  background: #fff;
  margin: 16rpx 30rpx;
  border-radius: 12rpx;
  padding: 30rpx;
}

/* 第一行：姓名 + 电话 */
.addr-row1 {
  display: flex;
  align-items: center;
  margin-bottom: 16rpx;
}

.addr-name {
  font-size: 32rpx;
  font-weight: 600;
  color: #222;
  margin-right: 24rpx;
}

.addr-phone {
  font-size: 28rpx;
  color: #666;
}

/* 第二行：标签 + 地址 */
.addr-row2 {
  display: flex;
  align-items: flex-start;
  margin-bottom: 20rpx;
}

.addr-tag {
  flex-shrink: 0;
  font-size: 20rpx;
  color: #07C160;
  background: #e8f8ee;
  padding: 4rpx 12rpx;
  border-radius: 4rpx;
  margin-right: 12rpx;
  margin-top: 4rpx;
}

.addr-text {
  flex: 1;
  font-size: 26rpx;
  color: #333;
  line-height: 1.5;
}

/* 第三行：操作链接 */
.addr-row3 {
  display: flex;
  gap: 48rpx;
  padding-top: 20rpx;
  border-top: 1rpx solid #f0f0f0;
}

.addr-action {
  font-size: 26rpx;
  color: #666;
}

.addr-action.del {
  color: #ee3f3f;
}

/* 空状态 */
.empty {
  text-align: center;
  padding-top: 200rpx;
}

.empty-img {
  width: 200rpx;
  opacity: 0.2;
  margin-bottom: 24rpx;
}

.empty-text {
  display: block;
  font-size: 28rpx;
  color: #999;
}

.empty-sub {
  display: block;
  font-size: 24rpx;
  color: #ccc;
  margin-top: 8rpx;
}

/* 底部按钮 */
.bottom-area {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 20rpx 30rpx;
  padding-bottom: calc(20rpx + env(safe-area-inset-bottom));
  background: #fff;
  box-shadow: 0 -1rpx 8rpx rgba(0,0,0,0.04);
  z-index: 10;
}
</style>
