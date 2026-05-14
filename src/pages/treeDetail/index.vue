<template>
  <div>

    <view class="wrap" style="width: 90%; padding: 0 5%;">
      <u-swiper :list="imageList" height="200"></u-swiper>
    </view>
    <view style="padding: 0 5%;">
      <view style="margin-top: 50rpx">
        <view>
          <view style="font-weight: bold;">联系电话</view>
          <view v-for="( item, index ) in phoneData" :key="index"
            style="padding-top: 50rpx; display: flex; justify-content: space-between;">
            <img src="../../static/phone_icon.png" style="width: 80rpx; height: 80rpx">
            <view style=" margin-left: -270rpx; ">
              <view style="color: #7F7F7F; font-size: 12px;">{{ item.name }}</view>
              <view style="font-weight: bold; font-size: 14px; margin-top: 10rpx;">{{ item.phone }}</view>
            </view>
            <view style="text-align: center;" @click="makCall( item.phone )">
              <img src="../../static/dial.png" style="width: 60rpx; height: 60rpx; margin-left: -160rpx">
              <view style="margin-top: -54rpx; color: #7F7F7F; font-size: 12px; margin-right: 20rpx;">拨号</view>
            </view>
          </view>
        </view>
      </view>
      <view style="margin: 40rpx 0">
        <view style="margin-top: 30rpx; height: 340rpx; ">
          <map id="map" :longitude="lon" :latitude="lat" scale="14.5" :markers="markers" bindmarkertap="markTap"
            show-location="true" style="width: 100%; height: 100%;"></map>
        </view>
        <view
          style="background: linear-gradient(90deg, #2566FE 0%, #26D4FF 100%); height: 36px;color: white; line-height: 36px; margin-top: 30rpx; font-size: 24rpx; border-radius: 20rpx; text-align: center;"
          @click="navagatorTo">
          <img src="../../static/naviIcon.png"
            style="width: 40rpx; height: 40rpx; vertical-align: middle; margin: -8rpx 5rpx 0 0;">
          <text>点击导航</text>
        </view>
      </view>
    </view>
  </div>
</template>
<script>

export default {
  data() {
    return {
      treeList: [],
      treeSource: require('@/static/images/树木资源.png'),
      phoneData: [{
        name: '杨木',
        phone: '18601131716',
      }, {
        name: '王玉涛',
        phone: '18943356687'
      }],
      list: [
        'http://117.33.156.59:8005/sys-storage/download_image?f8s=a05a4a9548aed3a251dcbd03c974212b ',
        'http://117.33.156.59:8005/sys-storage/download_image?f8s=28aea89bb5f8f39034c6119c6fb6bbf0',
      ],
      markers: [{
        iconPath: '../../static/singIcon.png',
        latitude: '',
        longitude: '',
        height: 34,
        width: 34,
        id: 1
      }],
      lat: 34.312622,
      lon: 108.841665,
      imageList: [],
    }
  },
  /**
  * 选址地址
  * 图片展示
  * 手机号登录3个问题
  */
  methods: {

    makCall(phone) {
      uni.makePhoneCall({
        phoneNumber: phone
      })
    },
    navagatorTo() {
      uni.openLocation({
        latitude: this.lat,
        longitude: this.lon,
        name: '',
        scale: 15,
        address: '目的地'
      })
    },

  },
  onLoad(options) {
    let messageId = options.messageId;
    this.$request('/eachTreeInfo', 'GET', { 'messageId': messageId }).then((res) => {
      this.treeList = res[1].data.data;
      console.log(res)
    })
    this.$request('/eachTreeImage', 'GET', { 'messageId': messageId }).then((res) => {
      res[1].data.data.forEach((element, index) => {
        let imgPath = '', imageData = '', base64 = '', fs = '';
        base64 = "data:image/PNG;base64," + element;
        imgPath = wx.env.USER_DATA_PATH + '/e-invoice' + index + '.png';
        imageData = base64.replace(/^data:image\/\w+;base64,/, "");
        fs = wx.getFileSystemManager();
        fs.writeFileSync(imgPath, imageData, "base64");
        fs.close();
        this.imageList.push( imgPath )
      });
    })
  },
  mounted() {

  }
}
</script>
<style scoped lang="scss">
.buildDetails {
  .wrap {
    width: 90%;
    padding-left: 5%;
    height: 400rpx;

    .cut_sty {
      width: 240rpx;
      height: 40rpx;
      border-radius: 20rpx;
      font-size: 24rpx;
      line-height: 40rpx;
      background-color: black;
      opacity: 0.9;
      margin: -120rpx 0 0 20rpx;
      z-index: 1000;

      .cut_item_sty {
        color: white;
        width: 80rpx;
        display: inline-block;
        text-align: center;
      }

      .click_item_sty {
        color: black;
        background: white;
        border-radius: 20rpx;
        height: 40rpx;
        width: 80rpx
      }
    }
  }

  .label-sty {
    font-size: 24rpx;
    padding: 5rpx 10rpx;
    border-radius: 10rpx;
    color: white;
    background: linear-gradient(90deg, #26aeff 0%, #25d3ff 100%);
  }
}
</style>