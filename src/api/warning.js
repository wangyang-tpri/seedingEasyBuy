/**
 * 报警模块相关的接口
 */
import Http from '@/utils/request'
export default {
    fire: {
        getData: (data) =>  {
            return Http.request({
                method: 'get',
                url: '/yyc/villageFireWarning/page',
                params: data
            })
        }
    },
    clothOccupy: {
        getData: (data) => {
            return Http.request({
                method: 'get',
                url: '/yyc/clothOccupationRoadOperationAlarm/page',
                params: data
            })
        }
    },
    personnel: {
        getData: (data) => {
            return Http.request({
                method: 'get',
                url: 'yyc/abnormalPersonnelAlarm/page',
                params: data
            })
        }
    },
    forklift: {
        getData: (data) => {
            return Http.request({
                method: 'get',
                url: 'yyc/alarmManagement/page',
                params: data
            })
        }
    },
    car: {
        getData: (data) => {
            return Http.request({
                method: 'get',
                url: 'yyc/vehicleOccupancyAlarm/page',
                params: data
            })
        }
    }
}