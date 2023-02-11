<!--
 * @Author: liu_x25@hdec.com
 * @Date: 2022-04-28 11:30:07
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-27 10:19:11
 * @Description: 
-->
<script>
import { mapActions } from "vuex";
export default {
    onLaunch: function () {
        this.getUserCode();
        if (uni.getStorageSync("token")) {
            this.getUserInfo();
        } else {
            uni.reLaunch({
                // url: "/pages/user/login",
                url: '/pages/home/index'
            });
        }
    },

    watch: {
        isLogin(val) {
            if (val) {
                this.getDictionary();
            }
        },
    },
    methods: {
        ...mapActions(["getUserInfo", "getDictionary"]),
        getUserCode() {
            uni.login({
                provider: "weixin",
                success: (res) => {
                    if (res.code) {
                      uni.setStorageSync('wxCode', res.code);
                    }
                },
            });
        },
    },
    onShow: function () {
    },
    onHide: function () {}

};
</script>
<style lang="scss">
@import "uview-ui/index.scss";
page {
    background: #f5f6fa;
}
</style>
