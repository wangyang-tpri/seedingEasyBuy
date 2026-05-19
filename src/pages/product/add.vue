<template>
  <view class="add-page">
    <view class="form-card">
      <view class="form-item">
        <text class="form-label">商品名称</text>
        <u-input v-model="form.name" placeholder="请输入苗木名称" border="none" inputAlign="right" clearable></u-input>
      </view>
      <view class="form-item">
        <text class="form-label">副标题</text>
        <u-input v-model="form.subtitle" placeholder="简短描述" border="none" inputAlign="right" clearable></u-input>
      </view>
      <view class="form-item" @click="showCat = true">
        <text class="form-label">分类</text>
        <view class="form-right">
          <text :class="{ placeholder: !selectedCatName }">{{ selectedCatName || '请选择分类' }}</text>
          <u-icon name="arrow-right" color="#bbb" size="14"></u-icon>
        </view>
      </view>
      <view class="form-item">
        <text class="form-label">价格</text>
        <u-input v-model="form.price" type="digit" placeholder="¥0.00" border="none" inputAlign="right" clearable></u-input>
      </view>
      <view class="form-item">
        <text class="form-label">原价</text>
        <u-input v-model="form.originalPrice" type="digit" placeholder="¥0.00" border="none" inputAlign="right" clearable></u-input>
      </view>
      <view class="form-item">
        <text class="form-label">库存</text>
        <u-input v-model="form.stock" type="number" placeholder="0" border="none" inputAlign="right" clearable></u-input>
      </view>
      <view class="form-item" @click="showUnit = true">
        <text class="form-label">单位</text>
        <view class="form-right">
          <text :class="{ placeholder: !form.unit }">{{ form.unit || '请选择单位' }}</text>
          <u-icon name="arrow-right" color="#bbb" size="14"></u-icon>
        </view>
      </view>
      <view class="form-item">
        <text class="form-label">联系电话</text>
        <u-input v-model="form.phone" type="number" placeholder="请输入联系电话" border="none" inputAlign="right" clearable maxlength="11"></u-input>
      </view>
      <view class="form-item" @click="chooseLocation">
        <text class="form-label">发货地址</text>
        <view class="form-right">
          <text :class="{ placeholder: !form.address }">{{ form.address || '请选择地址' }}</text>
          <u-icon name="map" color="#bbb" size="14"></u-icon>
        </view>
      </view>
    </view>

    <view class="form-card">
      <view class="form-title">商品图片</view>
      <view class="upload-row">
        <view class="upload-item" v-for="(img, i) in images" :key="i">
          <image :src="img" mode="aspectFill" class="upload-img"></image>
          <view class="upload-remove" @click="removeImg(i)">✕</view>
        </view>
        <view class="upload-btn" @click="chooseImg" v-if="images.length < 9">
          <text class="upload-plus">+</text>
          <text class="upload-sub">添加图片</text>
        </view>
      </view>
    </view>

    <view class="form-card">
      <view class="form-title">商品视频（选填）</view>
      <view class="upload-row">
        <view class="upload-item" v-if="videoPath">
          <video :src="videoPath" class="upload-img"></video>
          <view class="upload-remove" @click="removeVideo">✕</view>
        </view>
        <view class="upload-btn" @click="chooseVideo" v-else>
          <text class="upload-plus">+</text>
          <text class="upload-sub">添加视频</text>
        </view>
      </view>
    </view>

    <view class="form-card">
      <view class="form-title">规格参数（选填）</view>
      <view class="spec-item" v-for="(spec, i) in specs" :key="i">
        <u-input v-model="spec.key" placeholder="参数名" border="none" class="spec-input"></u-input>
        <u-input v-model="spec.value" placeholder="参数值" border="none" class="spec-input" inputAlign="right"></u-input>
        <text class="spec-del" @click="specs.splice(i, 1)">✕</text>
      </view>
      <view class="add-spec" @click="specs.push({ key: '', value: '' })">+ 添加规格参数</view>
    </view>

    <view class="form-card">
      <view class="form-title">商品详情</view>
      <u--textarea v-model="form.description" placeholder="请输入商品描述" height="200" border="none"></u--textarea>
    </view>

    <view class="submit-wrap">
      <u-button text="提交上架" type="success" shape="circle" block @click="onSubmit"></u-button>
    </view>

    <!-- 分类选择（与分类页面一致，左右结构） -->
    <u-popup :show="showCat" mode="bottom" round @close="showCat = false">
      <view class="cat-popup">
        <text class="cat-title">选择分类</text>
        <view class="cat-body">
          <scroll-view scroll-y class="cat-left">
            <view
              v-for="cat in cats"
              :key="cat.id"
              :class="['cat-left-item', { active: activeParent === cat.id }]"
              @click="onCatParentClick(cat)"
            >
              <text>{{ cat.name }}</text>
            </view>
          </scroll-view>
          <scroll-view scroll-y class="cat-right">
            <view
              v-for="sub in activeSubCats"
              :key="sub.id"
              :class="['cat-right-item', { active: form.categoryId === sub.id }]"
              @click="selectCat(sub)"
            >
              <text>{{ sub.name }}</text>
              <u-icon v-if="form.categoryId === sub.id" name="checkbox-mark" color="#07C160" size="18"></u-icon>
            </view>
            <view v-if="activeSubCats.length === 0" class="cat-empty">该分类暂无子分类</view>
          </scroll-view>
        </view>
      </view>
    </u-popup>

    <!-- 单位选择 -->
    <u-popup :show="showUnit" mode="bottom" round @close="showUnit = false">
      <view class="picker-popup">
        <text class="picker-title">选择单位</text>
        <view class="picker-grid">
          <view
            v-for="u in unitOptions"
            :key="u"
            :class="['picker-item', { active: form.unit === u }]"
            @click="selectUnit(u)"
          >{{ u }}</view>
        </view>
      </view>
    </u-popup>
  </view>
</template>

<script>
import { get, post } from '@/utils/request'

const CAT_ICONS = { '观赏植物': '🌸', '果树苗木': '🍎', '绿化苗木': '🌳', '多肉盆栽': '🌵', '种子种苗': '🌱' }

export default {
  data() {
    return {
      form: {
        name: '',
        subtitle: '',
        categoryId: 0,
        price: '',
        originalPrice: '',
        stock: '',
        unit: '',
        address: '',
        phone: '',
        description: ''
      },
      images: [],
      videoPath: '',
      specs: [],
      cats: [],
      activeParent: 0,
      selectedCatName: '',
      showCat: false,
      unitOptions: ['株', '盆', '棵', '袋', '包', '斤', '公斤', '捆', '平方米'],
      showUnit: false
    }
  },
  computed: {
    activeSubCats() {
      const found = this.cats.find(c => c.id === this.activeParent)
      return (found && found.children) || []
    }
  },
  onLoad() {
    this.loadCats()
  },
  methods: {
    async loadCats() {
      try {
        this.cats = await get('/category/list') || []
        if (this.cats.length > 0) {
          this.activeParent = this.cats[0].id
        }
      } catch (e) {}
    },
    onCatParentClick(cat) {
      this.activeParent = cat.id
    },
    selectCat(cat) {
      this.form.categoryId = cat.id
      const parent = this.cats.find(c => c.id === this.activeParent)
      this.selectedCatName = (parent ? parent.name + ' > ' : '') + cat.name
    },
    selectUnit(u) {
      this.form.unit = u
      this.showUnit = false
    },
    chooseLocation() {
      uni.authorize({
        scope: 'scope.userLocation',
        success: () => {
          uni.chooseLocation({
            success: (res) => {
              this.form.address = res.address || res.name
            },
            fail: () => {
              uni.showToast({ title: '选择地址失败', icon: 'none' })
            }
          })
        },
        fail: () => {
          uni.showModal({
            title: '需要位置权限',
            content: '请授权位置权限后选择发货地址',
            confirmText: '去设置',
            success: (r) => {
              if (r.confirm) {
                uni.openSetting({})
              }
            }
          })
        }
      })
    },
    chooseImg() {
      uni.chooseImage({
        count: 9 - this.images.length,
        sizeType: ['compressed'],
        success: (res) => {
          const tasks = res.tempFilePaths.map(fp => this.compressImage(fp))
          Promise.all(tasks).then(urls => { this.images.push(...urls) })
        }
      })
    },
    compressImage(filePath) {
      return new Promise((resolve) => {
        uni.compressImage({
          src: filePath,
          quality: 80,
          success: (res) => resolve(res.tempFilePath),
          fail: () => resolve(filePath)
        })
      })
    },
    removeImg(i) { this.images.splice(i, 1) },
    chooseVideo() {
      uni.chooseVideo({
        sourceType: ['album', 'camera'],
        maxDuration: 30,
        success: (res) => {
          this.videoPath = res.tempFilePath
        }
      })
    },
    removeVideo() { this.videoPath = '' },
    async onSubmit() {
      if (!this.form.name) { this.showToast('请输入商品名称'); return }
      if (!this.form.categoryId) { this.showToast('请选择分类'); return }
      if (!this.form.price) { this.showToast('请输入价格'); return }
      if (this.images.length === 0) { this.showToast('请上传商品图片'); return }
      uni.showLoading({ title: '上传图片中', mask: true })
      try {
        const uploadedUrls = []
        for (const img of this.images) {
          const url = await this.uploadImage(img)
          uploadedUrls.push(url)
        }
        // Upload video if exists
        let videoUrl = ''
        if (this.videoPath) {
          uni.showLoading({ title: '上传视频中', mask: true })
          videoUrl = await this.uploadImage(this.videoPath)
        }
        uni.showLoading({ title: '提交中', mask: true })
        const specObj = {}
        this.specs.forEach(s => { if (s.key) specObj[s.key] = s.value })
        await post('/product/add', {
          name: this.form.name,
          subtitle: this.form.subtitle,
          categoryId: this.form.categoryId,
          price: Number(this.form.price),
          originalPrice: this.form.originalPrice ? Number(this.form.originalPrice) : undefined,
          stock: Number(this.form.stock) || 0,
          unit: this.form.unit,
          phone: this.form.phone,
          description: this.form.description,
          address: this.form.address,
          video: videoUrl || undefined,
          images: JSON.stringify(uploadedUrls),
          specs: JSON.stringify(specObj)
        })
        uni.hideLoading()
        this.showToast('上架成功')
        setTimeout(() => uni.navigateBack(), 1200)
      } catch (e) {
        uni.hideLoading()
        this.showToast('上架失败')
      }
    },
    uploadImage(filePath) {
      const baseUrl = process.env.VUE_APP_BASE_API || process.env.VUE_APP_BASE_PATH_ZP + '/api'
      const token = uni.getStorageSync('token')
      return new Promise((resolve, reject) => {
        uni.uploadFile({
          url: baseUrl + '/file/upload',
          filePath,
          name: 'file',
          timeout: 30000,
          header: token ? { Authorization: 'Bearer ' + token } : {},
          success: (res) => {
            try {
              const data = JSON.parse(res.data)
              if (data.code === 200 && data.data) {
                resolve(data.data.url)
              } else {
                reject(new Error(data.message || '上传失败'))
              }
            } catch (e) { reject(e) }
          },
          fail: (err) => { reject(new Error(err.errMsg || '上传请求失败')) }
        })
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.add-page { min-height: 100vh; background: #f5f6fa; padding-bottom: 60rpx; }
.form-card { background: #fff; margin: 20rpx 24rpx 0; border-radius: 16rpx; padding: 8rpx 28rpx 24rpx; box-shadow: 0 2rpx 12rpx rgba(0,0,0,0.04); }
.form-title { font-size: 28rpx; font-weight: 600; color: #333; padding: 20rpx 0 12rpx; }
.form-item { display: flex; align-items: center; justify-content: space-between; padding: 22rpx 0; border-bottom: 1rpx solid #f8f8f8; &:last-child { border-bottom: none; } }
.form-label { font-size: 27rpx; color: #333; flex-shrink: 0; margin-right: 20rpx; }
.form-right { display: flex; align-items: center; gap: 8rpx; font-size: 26rpx; color: #333; }
.placeholder { color: #bbb; }

.upload-row { display: flex; flex-wrap: wrap; gap: 16rpx; }
.upload-item { position: relative; }
.upload-img { width: 160rpx; height: 160rpx; border-radius: 10rpx; background: #f0f0f0; }
.upload-remove { position: absolute; top: -10rpx; right: -10rpx; width: 36rpx; height: 36rpx; border-radius: 50%; background: #ee3f3f; color: #fff; font-size: 20rpx; display: flex; align-items: center; justify-content: center; }
.upload-btn { width: 160rpx; height: 160rpx; border: 2rpx dashed #ddd; border-radius: 10rpx; display: flex; flex-direction: column; align-items: center; justify-content: center; }
.upload-plus { font-size: 48rpx; color: #bbb; }
.upload-sub { font-size: 20rpx; color: #bbb; margin-top: 4rpx; }

.spec-item { display: flex; align-items: center; margin-top: 12rpx; }
.spec-input { flex: 1; background: #f5f6fa; border-radius: 8rpx; padding: 0 16rpx; height: 64rpx; }
.spec-del { margin-left: 12rpx; color: #ee3f3f; font-size: 26rpx; }
.add-spec { color: #07C160; font-size: 26rpx; margin-top: 16rpx; }
.submit-wrap { padding: 40rpx 24rpx; }

/* 分类选择（左右结构） */
.cat-popup { padding: 40rpx 0 60rpx; }
.cat-title { font-size: 32rpx; font-weight: bold; padding: 0 30rpx 24rpx; display: block; }
.cat-body { display: flex; height: 600rpx; }
.cat-left { width: 200rpx; background: #f5f6fa; }
.cat-left-item { padding: 28rpx 20rpx; font-size: 26rpx; color: #666; text-align: center; }
.cat-left-item.active { background: #fff; color: #07C160; font-weight: 600; }
.cat-right { flex: 1; padding: 0 20rpx; }
.cat-right-item { display: flex; justify-content: space-between; align-items: center; padding: 24rpx 16rpx; border-bottom: 1rpx solid #f8f8f8; font-size: 27rpx; }
.cat-right-item.active { color: #07C160; }
.cat-empty { text-align: center; color: #bbb; font-size: 26rpx; padding-top: 80rpx; }

/* 单位选择 */
.picker-popup { padding: 40rpx 30rpx 60rpx; }
.picker-title { font-size: 32rpx; font-weight: bold; display: block; margin-bottom: 24rpx; }
.picker-grid { display: flex; flex-wrap: wrap; gap: 16rpx; }
.picker-item { width: calc(25% - 12rpx); text-align: center; padding: 22rpx 0; background: #f5f6fa; border-radius: 10rpx; font-size: 26rpx; color: #333; }
.picker-item.active { background: #e8f8ee; color: #07C160; font-weight: 600; }
</style>
