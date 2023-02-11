<template>
  <z-paging
    ref="paging"
    bg-color="#f5f6fa"
    v-model="noticeList"
    :auto="false"
    :refresher-enabled="false"
    :auto-clean-list-when-reload="false"
  >
    <div class="header" slot="top">
      <!-- <img
        class="title_img"
        mode="widthFix"
        src="https://yycweb.hdec.com/api/sys-storage/download?f8s=eb13c370e45bba751f98552aa7cfbaed"
        alt=""
      /> -->
      <div class="iconToBox">
          <view
            class="scroll-list__line"
            v-for="(item, index) in functionList"
            :key="index"
          >
            <view
              class="scroll-list__line__item"
              v-for="(item1, index1) in item"
              :key="index1"
              @click="jumpTo(item1.url)"
            >
              <image
                class="scroll-list__line__item__image"
                :src="item1.image"
                mode=""
              ></image>
              <text class="scroll-list__line__item__text">{{
                item1.name
              }}</text>
            </view>
          </view>
      </div>
    </div>

    <div class="content">
      <div class="title">
        <div class="name">苗木详情</div>
        <div class="more" @click="jumpTo('/pages/treeDetail/index')">
          更多<span>></span>
        </div>
      </div>
      <div class="notice_list">
        <div
          class="item"
          v-for="item in noticeList"  
          :key="item.id"
          @click="jumpTo('/pages/treeDetail/index?id=' + 1)"
        >
          <div class="name">{{ item.title }}</div>
          <div class="time">{{ item.pushDate }}</div>
        </div>
      </div>
      <div class="title">
        <div class="name">记录详情</div>
        <div
          class="more"
          @click="jumpTo('/pages/treeRecord/detail')"
        >
          更多<span>></span>
        </div>
      </div>

      <div class="exemplar_list">
        <div
          class="item"
          v-for="(item, index) in exemplarList"
          :key="index"
          @click="jumpTo('/pages/partyBuilding/exemplar/detail?id=' + item.id)"
        >
          <div class="item_top">
            <u-image
              :showLoading="true"
              :showMenuByLongpress="false"
              :src="imagePrefix + item.picture"
              width="126rpx"
              height="126rpx"
              radius="10"
            ></u-image>
            <div class="item_right">
              <div class="name">{{ item.storyContent }}</div>
              <div class="user">先锋人物：{{ item.personName }}</div>
            </div>
          </div>
          <div class="item_bottom">
            {{ item.createDate }}
          </div>
        </div>
      </div>
    </div>
  </z-paging>
</template>
<script>
import { getNotice, getExemplaryDeeds } from "@/api/partyBuilding";
export default {
  data () {
    return {
      functionList: [
        [
          {
            image: "/static/images/记录.png",
            name: "苗木记录",
            url: "/pages/treeRecord/index",
          },
          {
            image: "/static/images/搜索.png",
            name: "苗木搜索",
            url: "/pages/treeSearch/index",
          },
          {
            image: "/static/images/树木资源.png",
            name: "苗木详情",
            url: "/pages/treeDetail/index",
          },
        //   {
        //     image: "/static/images/展示.png",
        //     name: "苗木展示",
        //     url: "/pages/village/product/index",
        //   },
        ],
      ],
      noticeList: [],
      exemplarList: [],
    };
  },
  onShow () {
    const page = this.$mp.page;
    if (typeof page.getTabBar === "function" && page.getTabBar()) {
      page.getTabBar().setData({
        currentTab: 0,
      });
    }
  },
  mounted () {
    if (!uni.getStorageSync("token")) {
      return false;
    }
    let page = "/pages/maintenance/inspectionTask/detail";
    if (uni.getStorageSync('id')) {
      uni.$u.route(page, {
        id: uni.getStorageSync('id'),
        from: 'wx'
      });
    }
    this._initData();
  },
  methods: {
    jumpTo (url) {
      if (!url) {
        return false;
      }
      uni.navigateTo({
        url,
      });
    },
    _initData () {
      uni.showLoading({
        title: "加载中",
      });
      return new Promise((resolve, reject) => {
        Promise.all([
          getNotice({
            page: 1,
            size: 15,
            // publishFlag: 1,
            processState: 1,
          }),
          getExemplaryDeeds({
            page: 1,
            size: 15,
            publishFlag: 1,
          }),
        ]).then((res) => {
          if (res) {
            this.noticeList = res[0].data.records || [];
            this.exemplarList = res[1].data.records || [];
            uni.hideLoading();
            resolve();
          }

        });
      });
    },
  },
};
</script>
<style lang="scss" scoped>
.header {
  height: 350rpx;
  position: relative;
  background-position: top center;
  background-size: 100%;
  background-repeat: no-repeat;
  .title_img {
    padding-top: calc(var(--status-bar-height) + 24rpx);
    width: 406rpx;
    margin: 0 50rpx 20rpx;
  }
  .iconToBox {
    width: 690rpx;
    height: 180rpx;
    background: #ffffff;
    box-shadow: 0rpx 4rpx 20rpx 0rpx rgba(192, 200, 210, 0.38);
    border-radius: 12rpx;
    position: relative;
    // top: 50%;
    left: 50%;
    transform: translate(-50%, 10%);
    .scroll-list {
      @include flex(column);
      // width: 100%;
      &__line {
        @include flex;
        margin-top: 20px;
        // overflow: hidden;
        width: 100%;
        &__item {
          width: 235rpx;
          text-align: center;
          padding: 30rpx 0 0 0;
          font-size: 28rpx;
          color: #333333;
          text-shadow: 0px 4rpx 20rpx rgba(192, 200, 210, 0.38);
          margin-top: 20rpx;

          &__image {
            margin: 0 auto;
            display: flex;
            justify-content: center;
            width: 30px;
            height: 30px;
          }

          &__text {
            margin-top: 5px;
            color: $u-content-color;
            font-size: 12px;
            text-align: center;
          }

          &--no-margin-right {
            margin-right: 0;
          }
        }
      }
    }
  }

  .function_list {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    margin: 20rpx 30rpx 20rpx;
    background: #fff;
    padding-bottom: 30rpx;
    box-shadow: 0px 4rpx 20rpx 0px rgba(192, 200, 210, 0.38);
    border-radius: 12rpx;
    .item {
      width: 25%;
      text-align: center;
      padding: 30rpx 0 0 0;
      font-size: 28rpx;
      color: #333333;
      text-shadow: 0px 4rpx 20rpx rgba(192, 200, 210, 0.38);
      .image {
        margin: 0 auto;
        display: flex;
        justify-content: center;

        .img {
          width: 64rpx;
          height: 64rpx;
          margin-bottom: 12rpx;
        }
      }
    }
  }
}
.content {
  // margin-top: 80rpx;
  /* #ifndef MP-WEIXIN */
  padding-bottom: 20rpx;
  /* #endif */
  /* #ifdef MP-WEIXIN */
  padding-bottom: 120rpx;
  /* #endif */

  .title {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10rpx 30rpx;
    font-weight: bold;
    letter-spacing: 1px;
    .name {
      padding-left: 22rpx;
      font-size: 34rpx;
      font-weight: 500;
      color: #333333;
      line-height: 48rpx;
      position: relative;
      &::after {
        position: absolute;
        content: "";
        left: 0;
        top: 0;
        bottom: 0;
        margin: auto;

        width: 6rpx;
        height: 35rpx;
        background: #027aff;
        border-radius: 3rpx;
      }
    }
    .more {
      color: #497bec;
      padding: 10rpx 0;
      background: #f5f5f5;
      font-size: 28rpx;
      border-radius: 50rpx;
      font-weight: 400;
      color: #027aff;
      display: flex;
      align-items: center;
      span {
        padding-left: 10rpx;
      }
    }
  }
  .notice_list {
    margin: 10rpx 30rpx;
    padding: 10rpx 26rpx;
    background: #ffffff;
    border-radius: 8rpx;
    width: 690rpx;
    height: 410rpx;
    box-sizing: border-box;
    overflow: hidden;
    .item {
      padding: 26rpx 0;
      letter-spacing: 1px;
      border-bottom: 1rpx solid #eee;
      &:last-child {
        border-bottom: none;
      }
      .name {
        overflow: hidden;
        white-space: nowrap;
        text-overflow: ellipsis;
        font-size: 32rpx;
        font-weight: 400;
        color: #333333;
        line-height: 40rpx;
      }
      .time {
        padding-top: 10rpx;
        color: #cbcbcb;
        font-size: 24rpx;
        font-weight: 400;
        color: #999999;
        line-height: 36rpx;
      }
    }
  }
  .exemplar_list {
    margin: 10rpx 30rpx;
    padding: 10rpx 26rpx;
    background: #ffffff;
    border-radius: 8rpx;
    width: 690rpx;
    box-sizing: border-box;
    .item {
      padding: 26rpx 0;
      .item_top {
        display: flex;
        padding-bottom: 10rpx;
        .item_right {
          padding-left: 31rpx;
          display: flex;
          height: 126rpx;
          flex-direction: column;
          justify-content: space-between;
          .name {
            font-size: 32rpx;
            font-weight: 400;
            color: #333333;
            line-height: 45rpx;
            display: -webkit-box;
            overflow: hidden;
            text-overflow: ellipsis;
            word-wrap: break-word;
            white-space: normal !important;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
          }
          .user {
            font-size: 24rpx;
            font-weight: 400;
            color: #666666;
            line-height: 36rpx;
          }
        }
      }
      .item_bottom {
        font-size: 24rpx;
        font-weight: 400;
        color: #999999;
        line-height: 36rpx;
        padding-left: 157rpx;
      }
    }
  }
}
</style>