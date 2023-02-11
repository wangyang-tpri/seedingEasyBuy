<!--
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-16 14:39:30
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-23 16:40:58
 * @Description: 人员选择组件
-->
<template>
  <u-popup
    :show="show"
    :round="20"
    @close="close"
    @touchmove.stop.prevent="0"
    :customStyle="{ paddingTop: '16rpx' }"
  >
    <div class="header">
      <u-search
        placeholder="请输入关键字"
        v-model="keyword"
        :show-action="false"
        inputAlign="center"
        @search="reload"
      ></u-search>
    </div>
    <z-paging
      ref="paging"
      v-model="userList"
      @query="_initData"
      :default-page-size="20"
      :fixed="false"
      height="70vh"
    >
      <div class="list">
        <u-checkbox-group
          v-model="selectId"
          placement="column"
          @change="checkChange"
        >
          <div class="item" v-for="item in userList" :key="item.userName">
            <div class="item_left" @click="checkItem(item.id)">
              <u-avatar
                :text="item.userFullname | getAvatar"
                randomBgColor
              ></u-avatar>
              <div class="name">{{ item.userFullname }}</div>
              <div class="mobile">{{ item.phone | getMobile }}</div>
            </div>
            <div class="item_right">
              <u-checkbox :name="item.id" shape="circle" activeColor="#1560D6">
              </u-checkbox>
            </div>
          </div>
        </u-checkbox-group>
      </div>
      <div slot="bottom">
        <div class="operate" v-if="multiple">
          <div class="num">已选：{{ selectId.length }}人</div>
          <div class="btn">
            <u-button
              text="确定"
              color="#1560D6"
              :disabled="btnDisabled"
              @click="confirm"
            ></u-button>
          </div>
        </div>
      </div>
    </z-paging>
  </u-popup>
</template>
<script>
import * as Api from "@/api/common";
export default {
  props: {
    visible: {
      type: Boolean,
      default: false,
    },
    multiple: {
      type: Boolean,
      default: false,
    },
    userRole: {
      type: String,
      default: '',
    }
  },
  data () {
    return {
      show: this.visible,
      keyword: "",
      userList: [],
      selectId: [],
      btnDisabled: true,
      userRoleData: this.userRole,
    };
  },
  watch: {
    visible (val) {
      this.show = val;
    },
    userRole (val) {
      this.userRoleData = val;
      this._initData(1, 20)
    },
  },
  filters: {
    getMobile (tel) {
      var reg = /^(\d{3})\d{4}(\d{4})$/;
      return tel.replace(reg, "$1****$2");
    },
    getAvatar (name) {
      return name.toUpperCase().substring(0, 1);
    },
  },
  methods: {
    close () {
      this.$emit("update:visible", false);
      this.selectId = [];
      this.keyword = '';
    },
    confirm () {
      let users = this.userList.filter((item) => {
        return this.selectId.indexOf(item.id) != -1;
      });
      this.$emit("success", users);
      this.close();
    },
    checkChange (e) {
      this.btnDisabled = e.length ? false : true;
      if (this.multiple) {
        return false;
      }
      this.$nextTick(() => {
        this.confirm();
      });
    },
    checkItem (id) {
      let index = this.selectId.findIndex((item) => {
        return item == id;
      });
      index == -1 ? this.selectId.push(id) : this.selectId.splice(index, 1);
      this.btnDisabled = this.selectId.length ? false : true;
      if (this.multiple) {
        return false;
      }
      this.$nextTick(() => {
        this.confirm();
      });
    },
    reload () {
      this.$refs.paging.reload();
    },
    _initData (pageNo, pageSize) {
      if (this.userRoleData) {
        switch (this.userRole) {
          case '执行人':
            Api.getUser(this.getDifferentUserRole(this.userRoleData)).then((res) => {
              this.disposeData(res)
            })
            break;
          default:
            Api.getUserBaseRole(this.getDifferentUserRole(this.userRoleData)).then((res) => {
              this.disposeData(res)
            })
            break;
        }
      } else {
        Api.getUser({
          searchValue: this.keyword,
          pageSize,
          pageNo,
          accountStatus: 1,
          sort: 'desc',
          columnName: 'id'
        }).then((res) => {
          this.disposeData(res)
        })
      }
    },
    getDifferentUserRole (role) {
      let data = {};
      switch (role) {
        case '联防队队长':
          data = {
            searchValue: this.keyword,
            pageSize: 20,
            pageNo: 1,
            roleId: '1540145062946541569'
          }
          break;
        case '执行人':
          data = {
            searchValue: this.keyword,
            pageSize: 20,
            pageNo: 1,
            orgNo: 10
          }
          break;
        case '货车预约负责人':
          data = {
            searchValue: this.keyword,
            pageSize: 20,
            pageNo: 1,
            roleId: '1557250212857122818'
          }
          break;
        case '村务预约负责人':
          data = {
            searchValue: this.keyword,
            pageSize: 20,
            pageNo: 1,
            roleId: '1557251467868377090'
          }
          break;
        case '维修中心主任':
          data = {
            searchValue: this.keyword,
            pageSize: 20,
            pageNo: 1,
            roleId: '1542424115829280769'
          }
          break;
      }
      return data;
    },
    disposeData (res) {
      if (!res.status) {
        return false;
      }
      res.data.list.forEach((item) => {
        item.isSelect = false;
      });
      this.$refs.paging.complete(res.data.list);
    }
  },
};
</script>
<style lang="scss" scoped>
.header {
  box-sizing: border-box;
  padding: 20rpx 30rpx 20rpx;
  border-bottom: 10rpx solid #eee;
  width: 750rpx;
  background: #fff;
}
.operate {
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 15rpx 30rpx;
  border-top: 10rpx solid #eee;
  box-sizing: border-box;
  font-size: 28rpx;
  .num {
    color: $uni-color-primary;
  }
  .btn {
    width: 150rpx;
  }
}
.list {
  .item {
    display: flex;
    align-items: center;
    padding: 20rpx 30rpx;
    border-bottom: 2rpx solid #eee;
    justify-content: space-between;
    font-size: 30rpx;
    .item_left {
      display: flex;
      align-items: center;
      width: 600rpx;
      .name {
        padding-left: 20rpx;
        width: 100rpx;
      }
      .mobile {
        padding-left: 10rpx;
      }
    }
  }
}
</style>