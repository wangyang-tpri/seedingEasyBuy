/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-23 14:53:14
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-27 08:48:49
 * @Description: 
 */
Component({
    /**
     * 组件的属性列表
     */
    properties: {

    },

    /**
     * 组件的初始数据
     */
    data: {
        currentTab: -1,
        showMore: false,
        list: [
            {
                pagePath: "/pages/home/index",
                iconPath: "/static/icon/home.png",
                selectedIconPath: "/static/icon/home_on.png",
                text: "首页",
            },
            {
                pagePath: "//pages/home/add",
                iconPath: "/static/icon/add.png",
                isBig: true,
            },
            {
                pagePath: "/pages/matter/index",
                iconPath: "/static/icon/aboutme.png",
                selectedIconPath: "/static/icon/aboutme_on.png",
                text: "与我相关",
            },
            {
                pagePath: "/pages/user/index",
                iconPath: "/static/icon/user.png",
                selectedIconPath: "/static/icon/user_on.png",
                text: "我的",
            },
        ],
        functionList: [
            {
                image: "/static/images/car.png",
                name: "苗木预约",
                url: "/pages/truckReservation/index",
            },
            {
                image: "/static/images/calendar.png",
                name: "村务预约",
                url: "/pages/village/affairsReserve/index",
            },
            {
                image: "/static/images/bell.png",
                name: "报警管理",
                url: '/pages/warning/index'
            },
            {
                image: "/static/images/event.png",
                name: "事项管理",
                url: "/pages/maintenance/incidentReport/index",
            },
            {
                image: "/static/images/task.png",
                name: "巡检任务",
                url: "/pages/maintenance/inspectionTask/index",
            },
            {
                image: "/static/images/maintenance.png",
                name: "资产检修",
                url: "/pages/operation/maintenanceEvent/index",
            }
        ],
    },

    /**
     * 组件的方法列表
     */
    methods: {
        switchTab (e) {
            let that = this
            const idx = e.currentTarget.dataset.index
            const path = e.currentTarget.dataset.path
            // 跳转页面
            wx.switchTab({
                url: path,
            })
            that.setData({
                currentTab: idx
            })
        },
        jumpTo (e) {
            const url = e.currentTarget.dataset.path
            wx.navigateTo({
                url
            })
            this.close();
        },
        showMoreHandler () {
            this.setData({
                showMore: !this.data.showMore
            })
        },
        close () {
            this.setData({
                showMore: false
            })
        },
        close2 () {

        },
    }

})