<template>
  <view class="manage-page">
    <view v-if="list.length > 0" class="list-wrap">
      <view class="banner-card" v-for="item in list" :key="item.id" @click="item.linkType === 1 && item.linkValue && goDetail(item.linkValue)">
        <view class="card-top">
          <image :src="fixImageUrl(item.imageUrl)" mode="aspectFill" class="banner-img" />
          <view class="card-info">
            <text class="banner-title">{{ item.title || '未命名' }}</text>
            <text class="banner-link" v-if="item.linkType === 1">{{ getProductName(item.linkValue) }}</text>
            <text class="banner-link" v-else>未关联商品</text>
            <view :class="['status-tag', item.status === 1 ? 'on' : 'off']">
              {{ item.status === 1 ? '已启用' : '已禁用' }}
            </view>
          </view>
        </view>
        <view class="card-actions">
          <view class="btn-edit" @click.stop="openEdit(item)">编辑</view>
          <view class="btn-toggle" :class="item.status === 1 ? 'off' : 'on'" @click.stop="toggleStatus(item)">
            {{ item.status === 1 ? '禁用' : '启用' }}
          </view>
          <view class="btn-delete" @click.stop="onDelete(item.id)">删除</view>
        </view>
      </view>
    </view>

    <view class="empty" v-else>
      <view class="empty-icon">🖼️</view>
      <text class="empty-text">暂无轮播图</text>
      <text class="empty-sub">点击下方按钮添加</text>
    </view>

    <view class="bottom-area">
      <view class="btn-add" @click="showAdd = true">新增轮播图</view>
    </view>

    <!-- 新增/编辑弹窗 -->
    <u-popup :show="showAdd" mode="bottom" round @close="showAdd = false">
      <view class="popup">
        <text class="popup-title">{{ editingId ? '编辑轮播图' : '新增轮播图' }}</text>
        <view class="form-item">
          <text class="form-label">标题</text>
          <u-input v-model="form.title" placeholder="请输入标题" border="none" inputAlign="right" />
        </view>
        <view class="form-item">
          <text class="form-label">图片</text>
          <view v-if="tempImage" class="upload-item">
            <image :src="tempImage" mode="aspectFill" class="upload-img" />
            <view class="upload-remove" @click="tempImage = ''">✕</view>
          </view>
          <view class="upload-btn" @click="chooseBannerImg" v-else>
            <text class="upload-plus">+</text>
          </view>
        </view>
        <view class="form-item" @click="openProductPicker">
          <text class="form-label">关联商品</text>
          <view class="form-right">
            <text :class="{ placeholder: !selectedProductName }">{{ selectedProductName || '不关联' }}</text>
            <u-icon name="arrow-right" color="#bbb" size="14" />
          </view>
        </view>
        <view class="btn-submit" @click="onSubmit">{{ editingId ? '保存修改' : '确认添加' }}</view>
      </view>
    </u-popup>

    <!-- 商品选择弹窗 -->
    <u-popup :show="showProductPicker" mode="bottom" round @close="showProductPicker = false">
      <view class="popup">
        <text class="popup-title">选择商品</text>
        <scroll-view scroll-y class="product-scroll">
          <view v-for="p in myProducts" :key="p.id" :class="['product-item', { active: form.linkValue == p.id }]" @click="selectProduct(p)">
            <text>{{ p.name }}</text>
            <u-icon v-if="form.linkValue == p.id" name="checkbox-mark" color="#07C160" size="18" />
          </view>
          <view v-if="myProducts.length === 0" class="empty-hint">暂无已上架商品</view>
        </scroll-view>
      </view>
    </u-popup>
  </view>
</template>

<script>
import { get, post, put, del } from '@/utils/request'
export default {
  data() {
    return {
      list: [],
      myProducts: [],
      showAdd: false,
      showProductPicker: false,
      editingId: null,
      selectedProductName: '',
      form: { title: '', imageUrl: '', linkType: 1, linkValue: '' },
      tempImage: '',
      productNames: {}
    }
  },
  onShow() { this.loadList() },
  methods: {
    async loadList() {
      try { this.list = await get('/banner/my') || [] } catch (e) {}
    },
    async loadMyProducts() {
      try {
        this.myProducts = await get('/product/my') || []
        this.myProducts.forEach(p => { this.productNames[String(p.id)] = p.name })
      } catch (e) {}
    },
    getProductName(linkValue) {
      return this.productNames[linkValue] || '商品' + linkValue
    },
    fixImageUrl(url) {
      if (!url) return '/static/placeholder.png'
      if (url.startsWith('/api/')) {
        const base = this.getBaseUrl()
        return base ? base + url.substring(4) : url
      }
      return url
    },
    chooseBannerImg() {
      uni.chooseImage({ count: 1, sizeType: ['compressed'], success: (res) => { this.tempImage = res.tempFilePaths[0] } })
    },
    openProductPicker() {
      this.showProductPicker = true
      if (this.myProducts.length === 0) this.loadMyProducts()
    },
    selectProduct(p) {
      this.form.linkValue = String(p.id)
      this.selectedProductName = p.name
      this.showProductPicker = false
    },
    openEdit(item) {
      this.editingId = item.id
      this.form.title = item.title || ''
      this.form.linkValue = item.linkValue || ''
      this.form.linkType = item.linkType || 0
      this.tempImage = this.fixImageUrl(item.imageUrl)
      if (item.linkValue) {
        this.selectedProductName = this.getProductName(item.linkValue)
      }
      this.showAdd = true
    },
    async onSubmit() {
      if (!this.form.title) { this.showToast('请输入标题'); return }
      uni.showLoading({ title: '提交中', mask: true })
      try {
        let imageUrl = this.form.imageUrl
        if (this.tempImage && this.tempImage.startsWith('http')) {
          imageUrl = this.tempImage
        } else if (this.tempImage) {
          imageUrl = await this.uploadFile(this.tempImage)
        }
        if (this.editingId) {
          await put('/banner/update', { id: this.editingId, title: this.form.title, imageUrl, linkType: this.form.linkType, linkValue: this.form.linkValue })
        } else {
          await post('/banner/add', { title: this.form.title, imageUrl: imageUrl || '', linkType: this.form.linkType, linkValue: this.form.linkValue })
        }
        uni.hideLoading()
        this.showToast(this.editingId ? '修改成功' : '添加成功')
        this.showAdd = false
        this.editingId = null
        this.form = { title: '', imageUrl: '', linkType: 1, linkValue: '' }
        this.tempImage = ''
        this.selectedProductName = ''
        this.loadList()
      } catch (e) { uni.hideLoading(); this.showToast('操作失败') }
    },
    async toggleStatus(item) {
      try { await post(`/banner/status/${item.id}`); this.loadList() } catch (e) {}
    },
    goDetail(id) { uni.navigateTo({ url: '/pages/product/detail?id=' + id }) },
    onDelete(id) {
      uni.showModal({
        title: '确认删除', content: '确定删除该轮播图吗？',
        success: async (res) => { if (res.confirm) { try { await del(`/banner/delete/${id}`); this.loadList() } catch (e) {} } }
      })
    },
    uploadFile(filePath) {
      const baseUrl = process.env.VUE_APP_BASE_API || process.env.VUE_APP_BASE_PATH_ZP + '/api'
      const token = uni.getStorageSync('token')
      return new Promise((resolve, reject) => {
        uni.uploadFile({
          url: baseUrl + '/file/upload', filePath, name: 'file', timeout: 30000,
          header: token ? { Authorization: 'Bearer ' + token } : {},
          success: (r) => { try { const d = JSON.parse(r.data); if (d.code === 200) resolve(d.data.url); else reject(new Error(d.message)) } catch (e) { reject(e) } },
          fail: reject
        })
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.manage-page { min-height: 100vh; background: $bg-page; padding: 20rpx 24rpx 160rpx; }
.list-wrap { }

.banner-card { background: $bg-white; border-radius: 14rpx; padding: 24rpx; margin-bottom: 16rpx; box-shadow: $shadow-card; }
.card-top { display: flex; }
.banner-img { width: 200rpx; height: 120rpx; border-radius: 8rpx; flex-shrink: 0; background: $bg-input; margin-right: 16rpx; }
.card-info { flex: 1; min-width: 0; }
.banner-title { font-size: 30rpx; font-weight: 600; color: $text-primary; display: block; }
.banner-link { font-size: 24rpx; color: $text-hint; margin-top: 6rpx; display: block; }
.status-tag { display: inline-block; font-size: 20rpx; padding: 2rpx 12rpx; border-radius: 4rpx; margin-top: 8rpx; }
.status-tag.on { background: $primary-light; color: $primary-color; }
.status-tag.off { background: $bg-gray; color: $text-hint; }

.card-actions { display: flex; justify-content: flex-end; gap: 16rpx; margin-top: 16rpx; padding-top: 16rpx; border-top: 1rpx solid $bg-stripe; }
.btn-edit { padding: 10rpx 32rpx; border-radius: 30rpx; border: 1rpx solid $primary-color; color: $primary-color; font-size: 24rpx; }
.btn-toggle { padding: 10rpx 32rpx; border-radius: 30rpx; font-size: 24rpx; color: $bg-white; }
.btn-toggle.off { background: $accent-orange; }
.btn-toggle.on { background: $primary-color; }
.btn-delete { padding: 10rpx 32rpx; border-radius: 30rpx; background: $accent-red; color: $bg-white; font-size: 24rpx; }

.empty { text-align: center; padding-top: 240rpx; }
.empty-icon { font-size: 80rpx; opacity: 0.3; margin-bottom: 20rpx; }
.empty-text { display: block; font-size: 28rpx; color: $text-placeholder; }
.empty-sub { display: block; font-size: 24rpx; color: $text-disabled; margin-top: 8rpx; }

.bottom-area { position: fixed; bottom: 0; left: 0; right: 0; padding: 16rpx 24rpx; padding-bottom: calc(16rpx + env(safe-area-inset-bottom)); background: $bg-white; box-shadow: $shadow-bottom; z-index: 10; }
.btn-add { text-align: center; font-size: 28rpx; font-weight: 600; color: $bg-white; background: $gradient-green; border-radius: 40rpx; padding: 18rpx 0; box-shadow: $shadow-green; &:active { opacity: 0.9; transform: scale(0.97); } }

.popup { padding: 40rpx 30rpx 60rpx; }
.popup-title { font-size: 32rpx; font-weight: bold; display: block; margin-bottom: 24rpx; }
.form-item { display: flex; align-items: center; justify-content: space-between; padding: 20rpx 0; border-bottom: 1rpx solid $bg-stripe; }
.form-label { font-size: 27rpx; color: $text-primary; flex-shrink: 0; margin-right: 20rpx; }
.form-right { display: flex; align-items: center; gap: 8rpx; font-size: 26rpx; }
.placeholder { color: $text-placeholder; }
.btn-submit { text-align: center; margin-top: 30rpx; padding: 20rpx; background: $gradient-green; color: $bg-white; border-radius: 40rpx; font-size: 28rpx; font-weight: 600; }
.upload-item { position: relative; display: inline-block; }
.upload-img { width: 120rpx; height: 80rpx; border-radius: 8rpx; background: $bg-input; }
.upload-remove { position: absolute; top: -8rpx; right: -8rpx; width: 28rpx; height: 28rpx; border-radius: 50%; background: $accent-red; color: $bg-white; font-size: 16rpx; display: flex; align-items: center; justify-content: center; }
.upload-btn { width: 120rpx; height: 80rpx; border: 2rpx dashed $border-dashed; border-radius: 8rpx; display: flex; align-items: center; justify-content: center; }
.upload-plus { font-size: 36rpx; color: $text-placeholder; }
.product-scroll { max-height: 600rpx; }
.product-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 0; border-bottom: 1rpx solid $bg-stripe; font-size: 28rpx; }
.product-item.active { color: $primary-color; }
.empty-hint { text-align: center; color: $text-placeholder; padding: 40rpx; font-size: 26rpx; }
</style>
