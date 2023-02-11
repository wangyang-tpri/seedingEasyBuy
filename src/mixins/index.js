/*
 * @Author: liu_x25@hdec.com
 * @Date: 2022-06-23 14:40:38
 * @LastEditors: liu_x25@hdec.com
 * @LastEditTime: 2022-06-23 15:47:35
 * @Description: 全局混入类
 */
import { mapState } from "vuex";
export default {
    data() {
        return {
            imagePrefix:
                process.env.VUE_APP_BASE_PATH + "/sys-storage/download_image?f8s=",
        };
    },
    computed: {
        ...mapState(["isLogin", "dictionary", "user"]),
    },
    methods: {
        getLabel(code, dictionaryName) {
            if (!this.dictionary[dictionaryName]) {
                return code;
            }
            let item = this.dictionary[dictionaryName].find((item) => {
                return item.code == code;
            });
            return item ? item["zh-CN"] : code;
        },
    }
}