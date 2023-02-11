<template>
    <div>
        <!-- <z-paging
            ref="paging"
            v-model="treeList"
            @query="initData"
            :default-page-size="20"
            :fixed="false"
            height="70vh"
        > -->

            <div class="container">
                <div class="tree_one" v-for="( item, index) in treeList" :key="index">
                    <image :src= "item.imageUrl" alt="" style="width: 80px; height: 80px; margin-top: 20rpx"/>
                    <div>
                        <span>名称:{{ item.name }}</span>
                    </div>
                    <div>大小:{{ item.size }}</div>


                </div>
            </div>
        <!-- </z-paging> -->
    </div>
</template>
<script>

export default {
    data(){
        return {
            treeList: [],
            treeSource: require('@/static/images/树木资源.png')
        }
    },
    methods: {
        initData(){
            this.treeList.push({
                imageUrl: this.treeSource,
                name: '法桐',
                size: '50cm'
            },{
                imageUrl: this.treeSource,
                name: '法桐',
                size: '50cm'
            },{
                imageUrl: this.treeSource,
                name: '法桐',
                size: '50cm'
            },{
                imageUrl: this.treeSource,
                name: '法桐',
                size: '50cm'
            },{
                imageUrl: this.treeSource,
                name: '法桐',
                size: '50cm'
            })
            return this.treeList;
        }
    },
    mounted(){
        this.initData()
    }
}
</script>
<style scoped lang="scss">
.container {
    height: 500px;
    display: flex;
    justify-content: flex-start;
    flex-wrap: wrap;
    margin-top: 20rpx;
    .tree_one {
        width: 340rpx;
        height: 260rpx;
        margin-left: 22rpx;
        text-align: center;
        font-size: 24rpx;
        box-shadow: 0px 4rpx 20rpx 0px rgba(192, 200, 210, 0.38);
    }
}
</style>