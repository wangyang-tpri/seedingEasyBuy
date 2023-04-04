<script>
export default {
    onLaunch: function () {
        if( uni.getStorageSync('phone')) {
            uni.reLaunch({
                url: '/pages/home/index'
            })
        }
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
