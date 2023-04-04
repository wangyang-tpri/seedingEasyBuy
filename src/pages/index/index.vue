<template>
    <view  style="width: 100%; height: 100%; text-align: center;  position: absolute; top: 50%;">
        <button open-type="getPhoneNumber" @getphonenumber="getPhoneNumber" style="width: 80%;">使用手机号登录</button>
    </view>
</template>
<script>
export default {
    data() {
        return {
            
        }
    },
    onLoad(query) {
    },
    methods: {
        getPhoneNumber(e){
            let temCode = e.detail.code;
            if( temCode ) {
                this.$request('/accessToken', 'GET', {'temCode': temCode}).then((res) => {
                    if( res ) {
                        uni.reLaunch({
                            url: '/pages/home/index'
                        })
                        uni.setStorageSync('phone', '20')
                    }
                    
                })
            }
        }
    }
};
</script>
