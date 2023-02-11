<!--
 * @Author: liu_x25@hdec.com
 * @Date: 2022-04-28 16:08:44
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-27 10:24:23
 * @Description: 
-->
<template>
  <div class="container">
    <div class="back">
      <image
        src="https://yycweb.hdec.com/api/sys-storage/download?f8s=8c0c5be5df6efbd0a9e38cd86b54ec46"
        class="img"
        mode="widthFix"
      />
    </div>
    <div class="content">
      <div class="title">个人中心</div>
      <div class="user">
        <u-avatar :src="imagePrefix + user.photoToken" size="130rpx"></u-avatar>
        <div class="user_c">
          <div class="name">{{ user.userFullname }}</div>
          <div class="desc" v-if="user.orgList && user.orgList.length > 0">
            {{ user.orgList[0].name }}
          </div>
        </div>
      </div>
      <div class="list">
        <div class="item">
          <div class="name">
            <image class="img" src="/static/user/mobile.png" />手机号
          </div>
          <div class="val">{{ user.phone }}</div>
        </div>
        <div class="item" v-if="user.idcardNumber">
          <div class="name">
            <image class="img" src="/static/user/idcard.png" />身份证号
          </div>
          <div class="val">{{ user.idcardNumber }}</div>
        </div>
        <div class="item" v-if="user.education">
          <div class="name">
            <image class="img" src="/static/user/edu.png" />学历
          </div>
          <div class="val">
            {{ getLabel(user.education, "degreeType") }}
          </div>
        </div>
      </div>
      <div class="list">
        <div class="item" @tap="jumpTo('/pages/user/scoreRank')">
          <div class="name">
            <image class="img" src="/static/user/score.png" />我的积分
          </div>
          <div class="more">
            <span>{{ score }}</span
            >>
          </div>
        </div>
        <div class="item" @tap="jumpTo('/pages/shiftManagment/index')">
          <div class="name">
            <image class="img" src="/static/user/cal.png" />我的排班
          </div>
          <div class="more">></div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { getScore } from "@/api/common";
export default {
  data () {
    return {
      score: 0,
    };
  },
  onShow: function () {
    const page = this.$mp.page;
    if (typeof page.getTabBar === "function" && page.getTabBar()) {
      page.getTabBar().setData({
        currentTab: 4,
      });
    }
    getScore({
      userName: uni.getStorageSync("userName"),
    }).then((res) => {
      if (!res.status) {
        return false;
      }
      if (res.data.total > 0) {
        this.score = res.data.list[0].integralTotal;
      }
    });
  },
  methods: {
    jumpTo (url) {
      uni.navigateTo({
        url,
      });
    },
  },
};
</script>
<style lang="scss" scoped>
.container {
  .back {
    position: absolute;
    top: 0;
    width: 100%;
    height: 500rpx;
    .img {
      width: 100%;
    }
  }
  .content {
    position: relative;
    padding-top: calc(var(--status-bar-height) + 5px);
    .title {
      padding: 0 30rpx 30rpx;
      font-size: 36rpx;
      font-weight: 500;
      color: #ffffff;
    }
    .user {
      background: #fff;
      border-radius: 12rpx;
      margin: 30rpx;
      padding: 40rpx;
      display: flex;
      align-items: center;
      .user_c {
        padding-left: 36rpx;
        .name {
          font-size: 36rpx;
          font-weight: 500;
          color: #333333;
          line-height: 50rpx;
        }
        .desc {
          padding-top: 10rpx;
          font-size: 24rpx;
          font-weight: 400;
          color: #666666;
          line-height: 33rpx;
        }
      }
    }
    .list {
      margin: 30rpx;
      padding: 10rpx 40rpx 10rpx 30rpx;
      background: #fff;
      border-radius: 12rpx;
      .item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 20rpx 0;
        border-bottom: 1rpx solid #eee;
        &:last-child {
          border-bottom: none;
        }
        .name {
          display: flex;
          align-items: center;
          font-size: 32rpx;
          font-weight: 400;
          color: #999999;
          .img {
            width: 44rpx;
            height: 44rpx;
            margin: 10rpx;
          }
        }
        .val {
          font-size: 32rpx;
          font-weight: 400;
          color: #555555;
        }
        .more {
          font-size: 30rpx;
          color: #cccccc;
          span {
            padding-right: 20rpx;
            font-size: 34rpx;
            font-weight: 500;
            color: #fc5151;
          }
        }
      }
    }
  }
}
</style>