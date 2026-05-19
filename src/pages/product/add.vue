<template>
  <view class="add-page">
    <view class="form-card">
      <view class="form-item">
        <text class="form-label">商品名称</text>
        <u-input
          v-model="form.name"
          placeholder="请输入苗木名称"
          border="none"
          inputAlign="right"
          clearable
        ></u-input>
      </view>
      <view class="form-item">
        <text class="form-label">副标题</text>
        <u-input
          v-model="form.subtitle"
          placeholder="简短描述"
          border="none"
          inputAlign="right"
          clearable
        ></u-input>
      </view>
      <view class="form-item" @click="showCat = true">
        <text class="form-label">分类</text>
        <view class="form-right">
          <text :class="{ placeholder: !selectedCatName }">{{
            selectedCatName || "请选择分类"
          }}</text>
          <u-icon name="arrow-right" color="#bbb" size="14"></u-icon>
        </view>
      </view>
      <view class="form-item">
        <text class="form-label">价格</text>
        <u-input
          v-model="form.price"
          type="digit"
          placeholder="¥0.00"
          border="none"
          inputAlign="right"
          clearable
        ></u-input>
      </view>
      <view class="form-item">
        <text class="form-label">原价</text>
        <u-input
          v-model="form.originalPrice"
          type="digit"
          placeholder="¥0.00"
          border="none"
          inputAlign="right"
          clearable
        ></u-input>
      </view>
      <view class="form-item">
        <text class="form-label">库存</text>
        <u-input
          v-model="form.stock"
          type="number"
          placeholder="0"
          border="none"
          inputAlign="right"
          clearable
        ></u-input>
      </view>
      <view class="form-item">
        <text class="form-label">单位</text>
        <u-input
          v-model="form.unit"
          placeholder="株/盆/棵"
          border="none"
          inputAlign="right"
          clearable
        ></u-input>
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
      <view class="form-title">规格参数（选填）</view>
      <view class="spec-item" v-for="(spec, i) in specs" :key="i">
        <u-input
          v-model="spec.key"
          placeholder="参数名"
          border="none"
          class="spec-input"
        ></u-input>
        <u-input
          v-model="spec.value"
          placeholder="参数值"
          border="none"
          class="spec-input"
          inputAlign="right"
        ></u-input>
        <text class="spec-del" @click="specs.splice(i, 1)">✕</text>
      </view>
      <view class="add-spec" @click="specs.push({ key: '', value: '' })"
        >+ 添加规格参数</view
      >
    </view>

    <view class="form-card">
      <view class="form-title">商品详情</view>
      <u--textarea
        v-model="form.description"
        placeholder="请输入商品描述"
        height="200"
        border="none"
      ></u--textarea>
    </view>

    <view class="submit-wrap">
      <u-button
        text="提交上架"
        type="success"
        shape="circle"
        block
        @click="onSubmit"
      ></u-button>
    </view>

    <!-- 分类选择 -->
    <u-popup :show="showCat" mode="bottom" round @close="showCat = false">
      <view class="cat-popup">
        <text class="cat-title">选择分类</text>
        <scroll-view scroll-y class="cat-scroll">
          <view
            v-for="cat in cats"
            :key="cat.id"
            :class="['cat-item', { active: form.categoryId === cat.id }]"
            @click="selectCat(cat)"
          >
            <text>{{ cat.name }}</text>
            <u-icon
              v-if="form.categoryId === cat.id"
              name="checkbox-mark"
              color="#07C160"
              size="18"
            ></u-icon>
          </view>
        </scroll-view>
      </view>
    </u-popup>
  </view>
</template>

<script>
import { get, post } from "@/utils/request";
export default {
  data() {
    return {
      form: {
        name: "",
        subtitle: "",
        categoryId: 0,
        price: "",
        originalPrice: "",
        stock: "",
        unit: "",
        description: "",
      },
      images: [],
      specs: [],
      cats: [],
      selectedCatName: "",
      showCat: false,
    };
  },
  onLoad() {
    this.loadCats();
  },
  methods: {
    async loadCats() {
      try {
        this.cats = (await get("/category/list")) || [];
      } catch (e) {}
    },
    selectCat(cat) {
      this.form.categoryId = cat.id;
      this.selectedCatName = cat.name;
      this.showCat = false;
    },
    chooseImg() {
      uni.chooseImage({
        count: 9 - this.images.length,
        sizeType: ["compressed"],
        success: (res) => {
          const tasks = res.tempFilePaths.map((fp) => this.compressImage(fp));
          Promise.all(tasks).then((urls) => {
            this.images.push(...urls);
          });
        },
      });
    },
    compressImage(filePath) {
      return new Promise((resolve) => {
        uni.compressImage({
          src: filePath,
          quality: 80,
          success: (res) => resolve(res.tempFilePath),
          fail: () => resolve(filePath),
        });
      });
    },
    removeImg(i) {
      this.images.splice(i, 1);
    },
    async onSubmit() {
      if (!this.form.name) {
        this.showToast("请输入商品名称");
        return;
      }
      if (!this.form.categoryId) {
        this.showToast("请选择分类");
        return;
      }
      if (!this.form.price) {
        this.showToast("请输入价格");
        return;
      }
      if (this.images.length === 0) {
        this.showToast("请上传商品图片");
        return;
      }
      uni.showLoading({ title: "上传图片中", mask: true });
      try {
        // Upload images first
        const uploadedUrls = [];
        for (const img of this.images) {
          const url = await this.uploadImage(img);
          uploadedUrls.push(url);
        }
        // Submit form
        uni.showLoading({ title: "提交中", mask: true });
        const specObj = {};
        this.specs.forEach((s) => {
          if (s.key) specObj[s.key] = s.value;
        });
        await post("/product/add", {
          name: this.form.name,
          subtitle: this.form.subtitle,
          categoryId: this.form.categoryId,
          price: Number(this.form.price),
          originalPrice: this.form.originalPrice
            ? Number(this.form.originalPrice)
            : undefined,
          stock: Number(this.form.stock) || 0,
          unit: this.form.unit,
          description: this.form.description,
          images: JSON.stringify(uploadedUrls),
          specs: JSON.stringify(specObj),
        });
        uni.hideLoading();
        this.showToast("上架成功");
        setTimeout(() => uni.navigateBack(), 1200);
      } catch (e) {
        uni.hideLoading();
        this.showToast("上架失败");
      }
    },
    uploadImage(filePath) {
      const baseUrl =
        process.env.VUE_APP_BASE_API ||
        process.env.VUE_APP_BASE_API_ZP + "/api";
      const token = uni.getStorageSync("token");
      return new Promise((resolve, reject) => {
        uni.uploadFile({
          url: baseUrl + "/file/upload",
          filePath,
          name: "file",
          timeout: 30000,
          header: token ? { Authorization: "Bearer " + token } : {},
          success: (res) => {
            try {
              const data = JSON.parse(res.data);
              if (data.code === 200 && data.data) {
                resolve(data.data.url);
              } else {
                reject(new Error(data.message || "上传失败"));
              }
            } catch (e) {
              reject(e);
            }
          },
          fail: (err) => {
            reject(new Error(err.errMsg || "上传请求失败"));
          },
        });
      });
    },
  },
};
</script>

<style lang="scss" scoped>
.add-page {
  min-height: 100vh;
  background: #f5f6fa;
  padding-bottom: 60rpx;
}
.form-card {
  background: #fff;
  margin: 20rpx 24rpx 0;
  border-radius: 16rpx;
  padding: 8rpx 28rpx 24rpx;
  box-shadow: 0 2rpx 12rpx rgba(0, 0, 0, 0.04);
}
.form-title {
  font-size: 28rpx;
  font-weight: 600;
  color: #333;
  padding: 20rpx 0 12rpx;
}
.form-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 22rpx 0;
  border-bottom: 1rpx solid #f8f8f8;
  &:last-child {
    border-bottom: none;
  }
}
.form-label {
  font-size: 27rpx;
  color: #333;
  flex-shrink: 0;
  margin-right: 20rpx;
}
.form-right {
  display: flex;
  align-items: center;
  gap: 8rpx;
  font-size: 26rpx;
  color: #333;
}
.placeholder {
  color: #bbb;
}

.upload-row {
  display: flex;
  flex-wrap: wrap;
  gap: 16rpx;
}
.upload-item {
  position: relative;
}
.upload-img {
  width: 160rpx;
  height: 160rpx;
  border-radius: 10rpx;
  background: #f0f0f0;
}
.upload-remove {
  position: absolute;
  top: -10rpx;
  right: -10rpx;
  width: 36rpx;
  height: 36rpx;
  border-radius: 50%;
  background: #ee3f3f;
  color: #fff;
  font-size: 20rpx;
  display: flex;
  align-items: center;
  justify-content: center;
}
.upload-btn {
  width: 160rpx;
  height: 160rpx;
  border: 2rpx dashed #ddd;
  border-radius: 10rpx;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.upload-plus {
  font-size: 48rpx;
  color: #bbb;
}
.upload-sub {
  font-size: 20rpx;
  color: #bbb;
  margin-top: 4rpx;
}

.spec-item {
  display: flex;
  align-items: center;
  margin-top: 12rpx;
}
.spec-input {
  flex: 1;
  background: #f5f6fa;
  border-radius: 8rpx;
  padding: 0 16rpx;
  height: 64rpx;
}
.spec-del {
  margin-left: 12rpx;
  color: #ee3f3f;
  font-size: 26rpx;
}
.add-spec {
  color: #07c160;
  font-size: 26rpx;
  margin-top: 16rpx;
}
.submit-wrap {
  padding: 40rpx 24rpx;
}

.cat-popup {
  padding: 40rpx 30rpx 60rpx;
}
.cat-title {
  font-size: 32rpx;
  font-weight: bold;
  display: block;
  margin-bottom: 24rpx;
}
.cat-scroll {
  max-height: 600rpx;
}
.cat-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 28rpx 0;
  border-bottom: 1rpx solid #f0f0f0;
  font-size: 28rpx;
}
.cat-item.active {
  color: #07c160;
}
</style>
