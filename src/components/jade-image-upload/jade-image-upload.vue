<template>
  <view class="imglistbx">
    <view
      :class="[
        'imglistItem',
        columnType == 'normal' ? 'column3' : 'column-three',
      ]"
      v-for="(item, index) in showList"
      :key="index"
    >
      <image
        :src="item.src"
        class="itemImg"
        @click="previewImage(index)"
        mode="aspectFill"
      ></image>
      <!-- <template>
        <u-icon
          size="18"
          name="close"
          color="#E53349"
          class="cancelBtn"
          @click="deleteImg(index)"
          v-if="deleteBtnFlag && item.status != 'compressed'"
        />
      </template> -->
      <template>
        <div class="cancelBtn">
          <u-icon
            size="14"
            name="close"
            color="#ffffff"
            @click="deleteImg(index)"
            v-if="deleteBtnFlag && item.status != 'compressed'"
          />
        </div>
      </template>
      <!-- <view class="mask" v-if="item.status == 'loading'">
        {{ item.progress }}
        <progress
          style="width: 60%; margin-top: 20rpx"
          :activeColor="activeColor"
          :percent="item.percent"
          stroke-width="8"
        ></progress>
      </view>
      <view
        class="mask"
        v-if="item.status == 'error' || item.status == 'compressed'"
        >{{ item.progress }}</view
      > -->
    </view>
    <!-- 上传控件 -->
    <view
      :class="[
        'imglistItem',
        columnType == 'normal' ? 'column3' : 'column-three',
      ]"
      @click="uploadImg"
      v-if="control && showControl"
    >
      <u-icon
        size="30"
        name="plus"
        color="#A3A3A3"
        class="itemImg uploadControl"
      ></u-icon>
    </view>
    <view class="clear"></view>
  </view>
</template>

<script>
import * as imageConversion from './lib/conversion.js'
export default {
  name: 'jade-image-upload',
  props: {
    //数据源
    list: {
      type: Array,
      default: function () {
        return []
      }
    },
    //是否显示上传控件
    control: {
      type: Boolean,
      default: true
    },
    //进度条颜色
    activeColor: {
      type: String,
      default: '#25C55A'
    },
    //是否显示删除按钮
    deleteBtnFlag: {
      type: Boolean,
      default: true
    },
    //行类型 normal，other两种类型，other是部分美化后的效果
    columnType: {
      type: String,
      default: 'normal'
    },
    //上传最大数量
    maxCount: {
      type: Number,
      default: 3
    },
    //照片超出压缩大小 MB
    compressSize: {
      type: Number,
      default: 5
    },
    //照片限制大小 MB
    imageSize: {
      type: Number,
      default: 20
    }
  },
  data () {
    return {
      showList: [],
      showControl: true,
      //防止重复点击
      isClick: true,
      tempFiles: '',
    }
  },
  watch: {
    list: {
      handler (v) {
        this.showList = v
      },
      deep: true,
      immediate: true
    },
    showList: {
      handler (v) {
        if (v.length >= this.maxCount) {
          this.showControl = false
          return
        }
        this.showControl = true;
      },
      immediate: true
    }
  },
  created () { },
  methods: {
    // 上传图片
    uploadImg () {
      if (!this.isClick) {
        return
      }
      this.isClick = false
      setTimeout(() => {
        this.isClick = true;
      }, 1000);
      uni.chooseImage({
        sizeType: ['compressed'],
        // #ifndef H5
        sourceType: ['album', 'camera'],
        // #endif
        count: this.maxCount,
        success: async (chooseImageRes) => {
          let tempFilePaths = chooseImageRes.tempFilePaths;
          // console.log(chooseImageRes, 'chooseImageRes')
          // #ifdef H5

          this.tempFiles = chooseImageRes.tempFiles
          let tempList = []
          for (let i in this.tempFiles) {
            let size = this.tempFiles[i].size
            if (size / 1024 / 1024 > this.imageSize) {
              uni.showToast({
                icon: 'none',
                title: `图片不能超过${this.imageSize}MB`
              })
              return
            }
            if (size / 1024 / 1024 > this.compressSize) { //超过5MB压缩
              let file = {}
              file.src = tempFilePaths[i]
              // file.file = tempFiles[i]
              file.progress = '正在压缩'
              file.status = 'compressed'
              file.index = this.showList.length
              this.showList.push(file)
              tempList.push(file)
            } else {
              let file = new Object()
              file.src = tempFilePaths[i]
              file.url = tempFilePaths[i];
              file.progress = '上传'
              file.percent = 0
              file.status = 'loading'
              file.file = this.tempFiles[i]
              file.index = this.showList.length
              this.showList.push(file)
              tempList.push(file)
            }
          }


          for (let i in this.showList) { //每次上传都更新index索引
            this.showList[i].index = i
          }
          for (let i in tempList) {
            if (tempList[i].status == 'compressed') { //图片压缩，一般压缩质量和宽度
              let data =
                await imageConversion.compress(tempList[i].file, {
                  quality: 0.99, //图片压缩质量
                  width: 750, //图片压缩宽度
                  // height: 200, //图片压缩高度
                  orientation: 1, //图片压缩方向
                })
              // console.log('压缩图',data);
              let compressfile = tempList[i]
              compressfile.src = window.URL.createObjectURL(data)
              compressfile.progress = '正上传'
              compressfile.percent = 0
              compressfile.status = 'loading'


              tempList[i] = this.showList[tempList[i].index] = compressfile
            }
          }
          // console.log(this.showList);
          this.$emit("chooseFile", tempList)
          // #endif

          // #ifndef H5
          let newFilePaths = tempFilePaths.map((item, i ) => {
            let file = new Object()
            file.src = item
            file.url = item;
            file.progress = '上传'
            file.percent = 0
            file.status = 'loading'
            file.file = chooseImageRes.tempFiles[i]
            file.index = this.showList.length
            // file.file = tempFiles.tempFiles[0]
            this.showList.push(file)
            return file
          })

          for (let i in this.showList) { //每次上传都更新index索引
            this.showList[i].index = i
          }
          this.$emit("chooseFile", newFilePaths)
          // #endif
        }
      });
    },
    //删除图片
    deleteImg (eq) {
      this.showList.splice(eq, 1);
      this.$emit("imgDelete", eq)
    },
    // 预览图片
    previewImage (eq) {
      let getUrl = this.showList
      let urls = []
      getUrl.forEach(item => {
        urls.push(item.src)
      })
      uni.previewImage({
        current: urls[eq],
        urls: urls

      })
    },
  }
}
</script>

<style lang="scss" scoped>
.imglistbx {
  width: 100%;
  height: 100%;
}

.imglistItem {
  position: relative;
  float: left;
  margin-bottom: 20rpx;
  border-radius: 10rpx;
}

.column3 {
  width: 33.3333%;
  height: 180rpx;
}

.column-three {
  margin-left: 13rpx;
  margin-bottom: 13rpx;
  width: 148rpx;
  height: 148rpx;
  display: flex;
  flex-direction: row;
  justify-content: center;
  align-items: center;
  background-color: #f6f6f6;

  //   &:nth-of-type(3n + 1) {
  //     margin-left: 0;
  //   }

  .uploadControl {
    font-size: 60rpx;
  }

  .itemImg,
  .mask {
    width: 100%;
    border-radius: 8rpx;
  }

  .cancelBtn {
    display: inline-flex;
    position: absolute;
    padding: 4rpx 6rpx;
    border-radius: 8rpx;
    background-color: rgba(0, 0, 0, 0.6);
    top: 0;
  }

  .mask {
    left: 0;
  }
}

.itemImg {
  width: 80%;
  height: 100%;
  margin: 0 auto;
  display: block;
  border-radius: 10rpx;
}

.mask {
  position: absolute;
  top: 0;
  left: 10%;
  width: 80%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  font-size: 24rpx;
  color: #ffffff;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  z-index: 3;
}

.cancelBtn {
  position: absolute;
  top: -20rpx;
  right: 0rpx;
  z-index: 5;
}

/* 上传控件 */
.uploadControl {
  font-size: 50rpx;
  color: #888;
  background-color: #f6f6f6;
  display: flex;
  justify-content: center;
  align-items: center;
}

/*  上传  str end*/
.clear {
  clear: both;
}
</style>
