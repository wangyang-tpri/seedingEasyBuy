<template>
    <z-paging ref="paging" bg-color="#f5f6fa" v-model="noticeList" :auto="false" :refresher-enabled="false"
        :auto-clean-list-when-reload="false">

        <div class="header" slot="top">
            <div style="width: 90%; margin-left: 5%; margin-top: 150rpx">
                <u--input placeholder="请输入苗木名称" suffixIcon="search" suffixIconStyle="color: #909399"
                    shape="circle" v-model="searchName" @change="search" @clear="_initData" custom-style="background:#fff;"></u--input>
            </div>
        </div>

        <div class="content">
            <div class="title">
                <div class="name">记录详情</div>
            </div>
            <view class="con_table">
                <view class="table_header">
                    <text style="width: 40%"> 树名</text>
                    <text style="width: 40%">时间</text>
                    <text style="width: 20%">操作</text>
                </view>
                <view>
                    <view v-for="( item, index ) in treeData" :key="index" class="table_header"
                        style="border-bottom: 1px dotted green; background-color: #ddd;">
                        <text style="width: 40%">
                            {{ item.name }}
                        </text>
                        <text style="width: 40%">
                            {{ item.box_date.split('T')[0] }}
                        </text>
                        <text class="info_detail" @click="jumpTo(`/pages/treeDetail/index?messageId=${item.message_id}`)">
                            详情
                        </text>
                    </view>
                </view>

            </view>
        </div>
    </z-paging>
</template>
<script>
export default {
    components: {
    },
    data() {
        return {
            functionList: [
                {
                    image: "/static/images/记录.png",
                    name: "苗木记录",
                    url: "./pages/treeRecord/index",
                },

            ],
            noticeList: [],
            exemplarList: [],
            value: '',
            treeData: '',
            searchName: ''
        };
    },
    onShow() {
        this._initData()
    },
    mounted() {
    },
    methods: {
        search(){
            this.$request('/keyWord/search', 'GET', {'searchName': this.searchName }).then(( res ) => {
                if (res) {
                    this.treeData = res[1].data;
                } else {

                }
            })
        },
        jumpTo(url) {
            if (!url) {
                return false;
            }
            uni.navigateTo({
                url,
            });
        },
        _initData() {
            uni.showLoading({
                title: "加载中",
            });
            this.$request('/stored/info', 'GET', '').then((res) => {
                this.treeData = res[1].data;
            })
        },
    },
    onLoad() {

    }
};
</script>
<style lang="scss" scoped>
.header {
    height: 300rpx;
    position: relative;
    background-position: top center;
    background-size: 100%;
    background-repeat: no-repeat;
    background-image: url(https://img.huamu.com/data/upload/article/201807/12/201807120919327838.jpg);
    .search_input {
        border-radius: 100rpx;
        border-color: blue !important;
        margin-left: 52rpx !important;
        width: 80%;
        margin-top: 100rpx;
    }

    .search_icon {
        position: absolute;
        right: 90rpx;
        top: 30rpx;
    }

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
                margin-top: 10px;
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
    margin-top: 20rpx;
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
            font-weight: bold;
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

    .con_table {
        width: 90%;
        padding: 20rpx 5%;

        .table_header {
            font-size: 18px;
            display: flex;
            justify-content: space-between;
            background-color: #ccc;
            height: 36px;
            line-height: 36px;
            padding: 0 20px;
            text-align: center;

            .info_detail {
                color: blue;
                width: 20%;
                text-align: center;
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