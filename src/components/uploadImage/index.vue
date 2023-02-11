<template>
  <div>
    <jade-image-upload
      :list="imageList"
      :control="flowType !== 'view' ? true : false"
      :columnType="columnType"
      :maxCount="maxCount"
      :deleteBtnFlag="flowType == 'view' ? false : true"
      :compressSize="compressSize"
      :imageSize="imageSize"
      @chooseFile="handleAfterRead"
      @imgDelete="remove"
    >
    </jade-image-upload>
  </div>
</template>
<script>
import { uuid } from "@/utils/param";
import { changeFileG9s } from "@/api/file";
import { getUploaderFile } from "@/api/bpm";
import { isImage } from "@/utils/file";
import jadeImageUpload from "@/components/jade-image-upload/jade-image-upload.vue";
import axios from "axios";
const cancelTokenObj = new Map();
export default {
  name: "uploadImage",
  components: { jadeImageUpload },
  props: {
    imageStr: {
      type: String,
      default: "",
    },
    type: {
      type: String,
      default: "",
    },
  },
  data () {
    return {
      allfileList: [],
      fileTokenList: [],
      imageG9s: "",
      imageList: [],
      control: true,
      columnType: "other",
      maxCount: 6,
      compressSize: 0.2,
      imageSize: 2,
      flowType: this.type,
    };
  },
  watch: {
    imageStr () {
      this.imageG9s = this.imageStr;
      this.imageG9s &&
        this.flowType != "add" &&
        getUploaderFile({
          g9s: [this.imageG9s],
        }).then((res) => {
          if (!res.status) {
            return false;
          }
          let fileTokenList = res.data;
          const fileList = [];
          fileTokenList.forEach((item) => {
            let isImageType = isImage(item.fileName);
            let fileItem = {
              file: {
                name: item.fileName,
                size: item.size,
              },
              response: item,
              isImage: isImageType,
              fileToken: item.fileToken,
            };
            // 展示图片
            if (isImageType) {
              fileItem.url = `${process.env.VUE_APP_BASE_PATH}/sys-storage/download_image?f8s=${item.fileToken}`;
              fileItem.src = `${process.env.VUE_APP_BASE_PATH}/sys-storage/download_image?f8s=${item.fileToken}`;
            } else {
              // 展示文件
              fileItem.url = item.fileToken;
            }
            this.imageList.push(fileItem);
          });
        });
    },
  },
  methods: {
    handleAfterRead (file) {
      // fileId用于标记文件，方便后续删除定位文件
      const fileId = uuid();
      file.fileId = fileId;
      this.allfileList.push(file);
      //生成取消请求的token,方便在handleRemove取消上传时结束请求
      const CancelToken = axios.CancelToken;
      const source = CancelToken.source();
      cancelTokenObj.set(fileId, source);
      file.forEach((e, i) => {
        uni.uploadFile({
          url: process.env.VUE_APP_BASE_PATH + "/sys-storage/upload",
          name: "file",
          filePath: e.src,
          formData: e,
          header: {
            "Fawkes-Biz":
              "McpKuHo4bOLjXYw+tTuyARbJZVXJNoWK7egGAlLyd29x0QowIdKWQ1WPS6OCbZWFmKYJKDHvrUyKOjSh24rnfw==",
            "Fawkes-Auth": uni.getStorageSync("token"),
          },
          success: (res) => {
            let arr = JSON.parse(res.data);
            if (arr.status) {
              file.status = "success";
              file.fileToken = arr.data.fileToken;
              this.fileTokenList.push(arr.data.fileToken);
              console.log(this.fileTokenList);
              this.setG9s();
            }
          },
        });
      });
    },
    setG9s () {
      if (this.fileTokenList.length) {
        const g9s = uuid();
        changeFileG9s(g9s, this.fileTokenList);
        this.$emit("imageG9s", g9s);
      } else {
        this.$emit("imageG9s", "");
      }
    },
    remove (file) {
      if (this.allfileList.length !== 0) {
        for (let i = 0; i < this.allfileList.length; i++) {
          if (i == file) {
            this.fileTokenList.splice(i, 1);
            this.setG9s();
            return;
          }
        }
      }
    },
  },
};
</script>
<style scoped lang="scss">
</style>
