<template></template>
<script>
export default {
    data() {},
    onLoad(query) {
        const scene = decodeURIComponent(query.scene);
        let projectToken = uni.getStorageSync( 'token');
        let page = "/pages/treeDetail/index";
        if( projectToken ){
            uni.$u.route(page, {
                id: scene,
                from: 'wx'
            });
        }else {
            uni.setStorageSync('id', scene);
        }
    },
    methods: {

    }
};
</script>
