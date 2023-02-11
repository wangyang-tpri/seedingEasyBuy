<template>
    <div>
        <div class="bgImage">
            <image src="./images/banner.png" class="img" />
        </div>
        <div class="list">
            <z-paging
                ref="paging"
                v-model="list"
                @query="_initData"
                :default-page-size="20"
            >
                <div>
                    <div
                        class="rankList"
                        @tap="jumpTo('/pages/user/scoreRankList')"
                    >
                        排行榜
                        <span style="margin-left: 30rpx">></span>
                    </div>
                    <div class="score">我的积分  
                        
                        <span>{{ selfScore }}</span>
                    </div>
                    <div
                        v-for="(item, index) in list"
                        :key="index"
                        class="item"
                    >
                        <div class="detail">
                            <span>{{ item.eventTime | formatDate }}</span>
                            <span :style="{color: item.pointsAdjustment > 0 ? 'green' : 'red'}"> {{ item.pointsAdjustment }}</span>
                        </div>
                        <div>
                            <span class="fontColor">填报人：</span>
                            <span style="color: black">

                                {{ item.userFullname }}
                            </span>
                        </div>
                        <div style="margin-top: 10px">
                            <span class="fontColor">调整原因：</span>
                            <span style="color: black">{{ item.pointsAdjustmentReason }}</span>
                        </div>
                    </div>
                </div>
            </z-paging>
        </div>
    </div>
</template>
<script>
import { getPersonnerlScore } from "@/api/common";
export default {
    data() {
        return {
            list: [],
            imageSrc: require("./images/banner.png"),
            selfScore: '',
        };
    },
    methods: {
        jumpTo(url) {
            uni.navigateTo({
                url,
            });
        },
        _initData(pageNo, pageSize) {
            getPersonnerlScore({
                size: pageSize,
                page: pageNo,
                userName: this.user.userName,
            }).then((res) => {
                if (!res.status) {
                    return false;
                }
                this.selfScore = res.data.integralTotal;
                this.$refs.paging.complete(res.data.pointsDetailsList);
            });
        },
    },
    filters: {
        formatDate(val){
            return val.split(' ')[0];
        }
    },
    watch: {},
};
</script>
<style lang="scss" scoped>
.bgImage {
    position: relative;
    top: 0;
    width: 100%;
    height: 300px;
    .img {
        width: 100%;
    }
}
.list {
    margin-top: 200px;
    background: #f5f6fa;
    position: relative;
    .item {
        margin: 20rpx 20rpx 0;
        border-bottom: 1rpx solid #f5f5f5;
        height: 110px;
        border: 1px solid #ccc;
        border-radius: 10px;
        padding: 10px 20px;
        background: #fff;
        font-size: 14px;
        .detail {
            height: 80rpx;
            border-bottom: 2px solid #ccc;
            line-height: 80rpx;
            margin-bottom: 10rpx;
            display: flex;
            flex-direction: row;
            justify-content: space-between;
        }
        .fontColor {
            color: #999999;
            font-size: 16px;
        }
    }
    .score {
        margin: 140rpx 24rpx 60rpx 40rpx;
        color: #fff;
        font-size: 40rpx;
        span {
            margin-left: 40rpx;
            font: bold 55rpx 'DIN Alternate Bold';
        }
    }
    .rankList {
        position: absolute;
        border: 1px solid #ccc;
        height: 100rpx;
        line-height: 100rpx;
        border-radius: 50rpx;
        padding-left: 40rpx;
        right: -120rpx;
        width: 300rpx;
        top: 40rpx;
        bottom: 100rpx;
        color: #fff;
        background-color: #ffffff7d;
        font-size: 36rpx;
    }
}
</style>