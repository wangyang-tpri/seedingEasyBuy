import Http from '@/utils/request'
export default {
    fireInpection: {
        getData: (data) =>  {
            return Http.request({
                method: 'get',
                url: '/yyc/villageFireWarning/page',
                params: data
            })
        }
    },
}