/**
 * uni.request请求
 * 
 */
let config = {
    baseUrl: '/server-zp',
    header: {}
}
let request = ( url = '', type = 'get', data ) => {
    return new Promise((resolve, reject) => {
        uni.request({
            url: config.baseUrl + url,
            method: type,
            data: data,
            header: config.header,
        }).then( ( res) => {
            setTimeout( () => { 
                uni.hideLoading( )
            }, 200)
            resolve(  res )
        }, ( res ) => {
            if( res.statusCode == 401 ) {
                uni.reLaunch( {
                    url: "/pages/index"
                })
            }
            reject( res )
        })
    })
}
export default request