<template>
  <div>
    <div class="bgImage">
      <image :src="title" class="img"/>
    </div>
    <div class="content">
      <div class="self">
        <div class="ranking">我的排名</div>
        <div class="details" v-if="selfData.length > 0">
          <span>{{rankNum}}</span>
          <span>{{user.userFullname}}</span>
          <span>{{selfData[0].integralTotal}}</span>
          
        </div>
        <div v-if="selfData.length == 0 " style="text-align: center; font-size: 32rpx">暂无积分排行数据</div>
      </div>
      <div class="rankTable">
        <div class="tableHeader">
          <span>排名</span>
          <span>姓名</span>
          <span>积分</span>
        </div>
        <div class="tableDetail">
            <div v-for="(item, index) in list" :key="index" class="item">
              <image :src='imageSrc( index + 1 )' class="rankIcon" v-if="index < 3"/>
              <span v-if="index > 2">{{index + 1 }}
              </span>
              <span>{{item.name}}</span>
              <span>{{item.integralTotal}}</span>
            </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { getScore } from "@/api/common";
export default {
  data() {
    return {
      list: [],
      selfData: [],
      rankNum: 0,
      title: require("./images/score.png"),
      first: require("./images/first.png"),
      second: require("./images/second.png"),
      three: require("./images/three.png"),
    };
  },
  methods: {
    _initData(pageNo, pageSize) {
      getScore({
        size: 10000,
        page: 1,
        column: "integralTotal",
        order: "desc",
      }).then((res) => {
        if (!res.status) {
          return false;
        }
        this.list = res.data.list;
        this.getSelfData(this.list);
      });
    },
    getSelfData(data) {
      this.selfData = data.filter((v, i, a) => {
        if (v.userName == this.user.userName) {
          this.rankNum = i + 1;
          return v;
        }
      });
    },
    imageSrc(val) {
      let iamgeObj = {
        1: this.first,
        2: this.second,
        3: this.three,
      };
      return iamgeObj[val];
    },
  },
  mounted() {
    this._initData();
  },
};
</script>
<style scoped lang="scss">
page {
  height: 100%;
}
.bgImage {
  width: 100%;
  .img {
    width: 100%;
  }
}
.content {
  border: 1px solid #ccc;
  height: calc(100% - 280rpx);
  border-radius: 5px;
  background-color: #fff;
  margin: -240rpx 3% 0;
  position: absolute;
  width: 94%;
  overflow-y: auto;
  .self {
    margin: 20rpx 20rpx;
    height: 160rpx;
    background: #fff4f1;
    border-radius: 10rpx;
    .details {
      display: flex;
      flex-direction: row;
      justify-content: space-around;
    }
    .ranking {
      color: #fd621d;
      font-size: 32rpx;
      padding-top: 30rpx;
      padding-left: 30rpx;
    }
  }
  .rankTable {
    margin: 20rpx 20rpx;
    .tableHeader {
      height: 100rpx;
      line-height: 100rpx;
      display: flex;
      flex-direction: row;
      justify-content: space-around;
      background: #f5f6fa;
      border-radius: 10rpx;
    }
    .item {
      display: flex;
      flex-direction: row;
      justify-content: space-between;
      text-align: center;
      margin: 20rpx 80rpx;
      font-size: 32rpx;
      .rankIcon {
        width: 40rpx;
        height: 40rpx;
        margin-left: -10rpx;
      }
    }
  }
}
</style>
