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